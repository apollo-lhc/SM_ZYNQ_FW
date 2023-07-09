library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.CM_package.all;
use work.CM_Ctrl.all;
use work.AXISlaveAddrPkg.all;
use work.uC_LINK.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity CM_intf is
  generic (
    CM_COUNT         : integer range 1 to 2 := 1; --Count for how many Command Moduless are present
    CM1_LANES        : std_logic_vector(2 downto 1) := "01"; -- active links on
                                                             -- CM1 
    CM2_LANES        : std_logic_vector(2 downto 1) := "01"; -- active links on
                                                             -- CM1 
    COUNTER_COUNT    : integer := 2;               --Count for counters in loop
    CLKFREQ          : integer := 50000000;       --clk frequency in Hz
    ERROR_WAIT_TIME  : integer := 50000000;       --Wait time for error checking states
    ALLOCATED_MEMORY_RANGE : integer);            
  port (
    clk_axi           : in  std_logic;
    reset_axi_n       : in  std_logic;
    slave_readMOSI    : in  AXIReadMOSI;
    slave_readMISO    : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI   : in  AXIWriteMOSI;
    slave_writeMISO   : out AXIWriteMISO := DefaultAXIWriteMISO;
    master_readMOSI   : out AXIReadMOSI  := DefaultAXIReadMOSI;
    master_readMISO   : in  AXIReadMISO;
    master_writeMOSI  : out AXIWriteMOSI := DefaultAXIWriteMOSI;
    master_writeMISO  : in  AXIWriteMISO;
    CM_mon_uart       : in  std_logic := '1';
    enableCM          : out std_logic_vector(2 downto 1);
    enableCM_PWR      : out std_logic_vector(2 downto 1);
    enableCM_IOs      : out std_logic_vector(2 downto 1);
    from_CM           : in  from_CM_t;
    to_CM_in          : in  to_CM_t; --from SM
    to_CM_out         : out to_CM_t; --from SM, but tristated
    clk_C2C           : in  std_logic_vector(4 downto 1);
    DRP_clk           : in  std_logic_vector(4 downto 1);
    reset_c2c         : out std_logic;
    CM_C2C_Mon        : in  C2C_Monitor_t;
    CM_C2C_Ctrl       : out C2C_Control_t;
    UART_Rx           : in  std_logic_vector(2 downto 1);
    UART_Tx           : out std_logic_vector(2 downto 1)
    );
end entity CM_intf;

architecture behavioral of CM_intf is
  constant HW_CM_COUNT : integer := 2;
  constant HW_LINK_PER_CM_COUNT : integer := 2;
  constant HW_LINK_COUNT : integer := HW_CM_COUNT * HW_LINK_PER_CM_COUNT;
  
  constant DATA_WIDTH : integer := 32;
  
  signal localAddress      : slv_32_t;
  signal localRdData       : slv_32_t;
  signal localRdData_latch : slv_32_t;
  signal localWrData       : slv_32_t;
  signal localWrEn         : std_logic;
  signal localRdReq        : std_logic;
  signal localRdAck        : std_logic;
  
  signal PWR_good          : std_logic_vector(HW_CM_COUNT downto 1);
  signal enable_PWR_out    : std_logic_vector(HW_CM_COUNT downto 1);
  signal enable_IOs_out    : std_logic_vector(HW_CM_COUNT downto 1);
  signal CM_disable        : std_logic_vector(HW_CM_COUNT downto 1);
  signal CM_uCIO_disable   : std_logic_vector(HW_CM_COUNT downto 1);

  --phy_lane_control
  signal phylanelock     : std_logic_vector(HW_LINK_COUNT downto 1);
  signal aurora_init_buf : std_logic_vector(HW_LINK_COUNT downto 1);
  signal phycontrol_en   : std_logic_vector(HW_LINK_COUNT downto 1);
  signal phy_reset       : std_logic_vector(HW_LINK_COUNT downto 1);
  
  signal reset : std_logic;                     

  signal mon_active : std_logic_vector(2 downto 1);
  signal mon_errors : slv16_array_t(1 to 2);

  constant INACTIVE_COUNT : slv_32_t := x"03FFFFFF";
 
  signal debug_history   : slv32_array_t(1 to 2);
  signal debug_valid     : slv4_array_t(1 to 2);
  signal counter_en      : std_logic_vector(4 downto 1);
  signal C2C_counter     : slv32_array_t(0 to (2*2*COUNTER_COUNT)-1);
  signal counter_events  : std_logic_vector(  (2*2*COUNTER_COUNT)-1 downto 0);
  signal counter_clk     : std_logic_vector(  (2*2*COUNTER_COUNT)-1 downto 0);
  
  signal Mon  : CM_Mon_t;
  signal Ctrl : CM_Ctrl_t;

  constant CDC_PRBS_SEL_LENGTH : integer := CM_C2C_Ctrl.Link(1).DEBUG.RX.PRBS_SEL'length;
  type CDC_PASSTHROUGH_t is array (1 to 2*2) of std_logic_vector(CDC_PRBS_SEL_LENGTH -1 + 1 downto 0);
  signal CDC_PASSTHROUGH : CDC_PASSTHROUGH_t;

  signal soft_error_rate : slv32_array_t(HW_LINK_COUNT*COUNTER_COUNT downto 1);
  signal hard_error_rate : slv32_array_t(HW_LINK_COUNT*COUNTER_COUNT downto 1);
  signal link_INFO_out : uC_Link_out_t_array(0 to 3);
  signal link_INFO_in  : uC_Link_in_t_array (0 to 3);

  signal drp_en_signal : std_logic_vector(4 downto 1);

  type DRP_MOSI_array_t is array (1 to 4) of CM_CM_C2C_DRP_MOSI_t;
  signal DRP_MOSI : DRP_MOSI_array_t;

  signal clk_TCDS_o : std_logic;
begin
  --reset
  reset <= not reset_axi_n;

  --For signals variable on CM_COUNT
  phycontrol_en(1) <=                    from_CM.CM(1).PWR_good and CTRL.CM(1).C2C(1).ENABLE_PHY_CTRL;
  counter_en(1)    <= from_CM.CM(1).PWR_good;
  
  phycontrol_en(2) <= phylanelock(1) and from_CM.CM(1).PWR_good and CTRL.CM(1).C2C(2).ENABLE_PHY_CTRL;
  counter_en(2)    <= from_CM.CM(1).PWR_good;

  CM_CTRL_GENERATE_1: if CM_COUNT = 1 generate
    phycontrol_en(3) <= phylanelock(1) and from_CM.CM(1).PWR_good and CTRL.CM(2).C2C(1).ENABLE_PHY_CTRL;
    counter_en(3)    <= from_CM.CM(1).PWR_good;
    phycontrol_en(4) <= phylanelock(1) and from_CM.CM(1).PWR_good and CTRL.CM(2).C2C(2).ENABLE_PHY_CTRL;
    counter_en(4)    <= from_CM.CM(1).PWR_good;
  end generate CM_CTRL_GENERATE_1;
  CM_CTRL_GENERATE_2: if CM_COUNT = 2 generate
    phycontrol_en(3) <=                    from_CM.CM(2).PWR_good and CTRL.CM(2).C2C(1).ENABLE_PHY_CTRL;
    counter_en(3)    <= from_CM.CM(2).PWR_good;
    phycontrol_en(4) <= phylanelock(3) and from_CM.CM(2).PWR_good and CTRL.CM(2).C2C(2).ENABLE_PHY_CTRL;
    counter_en(4)    <= from_CM.CM(2).PWR_good;
  end generate CM_CTRL_GENERATE_2;


  reset_c2c <= Ctrl.C2C_RESET;



  
  --For AXI
  CM_interface_1: entity work.CM_map
    generic map(
      READ_TIMEOUT    => 2047,
      ALLOCATED_MEMORY_RANGE =>         ALLOCATED_MEMORY_RANGE      
      )
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => slave_readMOSI,
      slave_readMISO  => slave_readMISO,
      slave_writeMOSI => slave_writeMOSI,
      slave_writeMISO => slave_writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);

  --Signals only relavant to CM1
  Mon.CM(1).MONITOR.ACTIVE         <= mon_active(1);
  Mon.CM(1).MONITOR.HISTORY_VALID  <= debug_valid(1);
  --Mon.CM(1).MONITOR.ERRORS         <= mon_errors(0);
  Mon.CM(1).MONITOR.HISTORY        <= debug_history(1);
  
  CM_Monitoring_1: entity work.CM_Monitoring
    generic map (
      BAUD_COUNT_BITS                => 8,
      INACTIVE_COUNT                 => INACTIVE_COUNT,
      BASE_ADDRESS                   => AXI_ADDR_PL_MEM_CM)
    port map (
      clk                            => clk_axi,
      reset                          => reset,
      enable_axi_writes              => CTRL.CM(1).MONITOR.ENABLE,
      uart_rx                        => CM_mon_uart,
      baud_16x_count                 => CTRL.CM(1).MONITOR.COUNT_16X_BAUD,
      sm_timeout_value               => CTRL.CM(1).MONITOR.SM_TIMEOUT,
      readMOSI                       => master_readMOSI,
      readMISO                       => master_readMISO,
      writeMOSI                      => master_writeMOSI,
      writeMISO                      => master_writeMISO,
      debug_history                  => debug_history(1),
      debug_valid                    => debug_valid(1),
      uart_byte_count                => Mon.CM(1).MONITOR.UART_BYTES,
      error_reset                    => CTRL.CM(1).MONITOR.ERRORS.RESET,
      error_count(0)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BAD_SOF,
      error_count(1)                 => Mon.CM(1).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2,
      error_count(2)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA,
      error_count(3)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA,
      error_count(4)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA,
      error_count(5)                 => Mon.CM(1).MONITOR.ERRORS.CNT_TIMEOUT,
      error_count(6)                 => Mon.CM(1).MONITOR.ERRORS.CNT_UNKNOWN,
      bad_transaction(31 downto 24)  => Mon.CM(1).MONITOR.BAD_TRANS.ERROR_MASK,
      bad_transaction(23 downto  8)  => Mon.CM(1).MONITOR.BAD_TRANS.DATA,
      bad_transaction( 7 downto  0)  => Mon.CM(1).MONITOR.BAD_TRANS.ADDR,
      last_transaction(31 downto 24) => Mon.CM(1).MONITOR.LAST_TRANS.ERROR_MASK,
      last_transaction(23 downto  8) => Mon.CM(1).MONITOR.LAST_TRANS.DATA,
      last_transaction( 7 downto  0) => Mon.CM(1).MONITOR.LAST_TRANS.ADDR,
      channel_active                 => mon_active(1));



  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.ADDR_LSB      <= x"00000000";--std_logic_vector(AXI_ADDR_C2C1_AXI_BRIDGE(31 downto 0));
  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.ADDR_MSB      <= x"00000000";
  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.SIZE          <= x"00000000";-- std_logic_vector(AXI_RANGE_C2C1_AXI_BRIDGE);
  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.VALID         <= '1';
  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.ADDR_LSB  <= x"00000000";
  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.ADDR_MSB  <= x"00000000";
  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.SIZE      <= x"00000000";
  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.VALID     <= '0';

  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.ADDR_LSB      <= x"00000000";
  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.ADDR_MSB      <= x"00000000";
  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.SIZE          <= x"00000000";
  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.VALID         <= '0';
  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.ADDR_LSB  <=  x"00000000";--std_logic_vector(AXI_ADDR_C2C1B_AXI_LITE_BRIDGE(31 downto 0));
  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.ADDR_MSB  <= x"00000000";
  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.SIZE      <=  x"00000000";--std_logic_vector(AXI_RANGE_C2C1B_AXI_LITE_BRIDGE);
  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.VALID     <= '1';

  
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.ADDR_LSB      <=  x"00000000";--std_logic_vector(AXI_ADDR_C2C2_AXI_BRIDGE(31 downto 0));
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.ADDR_MSB      <= x"00000000";
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.SIZE          <=  x"00000000";--std_logic_vector(AXI_RANGE_C2C2_AXI_BRIDGE);
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.VALID         <= '1';
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.ADDR_LSB  <= x"00000000";
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.ADDR_MSB  <= x"00000000";
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.SIZE      <= x"00000000";
  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.VALID     <= '0';

  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.ADDR_LSB      <= x"00000000";
  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.ADDR_MSB      <= x"00000000";
  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.SIZE          <= x"00000000";
  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.VALID         <= '0';
  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.ADDR_LSB  <= x"00000000";--std_logic_vector(AXI_ADDR_C2C2b_AXI_LITE_BRIDGE(31 downto 0));
  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.ADDR_MSB  <= x"00000000";
  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.SIZE      <= x"00000000";--std_logic_vector(AXI_RANGE_C2C2b_AXI_LITE_BRIDGE);
  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.VALID     <= '1';


  
  GENERATE_LOOP: for iCM in 1 to 2 generate

    -------------------------------------------------------------------------------
    -- CM interface
    -------------------------------------------------------------------------------
    CM_UART_BUF_X : OBUFT
      port map (
        T => CM_ucIO_disable(iCM),
        I => to_CM_in.CM(iCM).UART_Tx,
        O => to_CM_out.CM(iCM).UART_Tx);
    CM_TMS_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM),
        I => to_CM_in.CM(iCM).TMS,
        O => to_CM_out.CM(iCM).TMS);
    CM_TDI_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM),
        I => to_CM_in.CM(iCM).TDI,
        O => to_CM_out.CM(iCM).TDI);
    CM_TCK_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM),
        I => to_CM_in.CM(iCM).TCK,
        O => to_CM_out.CM(iCM).TCK);

    -------------------------------------------------------------------------------
    --Power-up sequences
    -------------------------------------------------------------------------------
    CM_PWR_SEQ_X: entity work.CM_pwr
      generic map (
        COUNT_ERROR_WAIT  => ERROR_WAIT_TIME)
      port map (
        clk               => clk_axi,
        reset_async       => reset,
        reset_sync        => Ctrl.CM(iCM).CTRL.ERROR_STATE_RESET,
        uc_enabled        => Ctrl.CM(iCM).CTRL.ENABLE_UC,
        start_PWR         => Ctrl.CM(iCM).CTRL.ENABLE_PWR,
        sequence_override => Ctrl.CM(iCM).CTRL.OVERRIDE_PWR_GOOD,
        current_state     => Mon.CM(iCM).CTRL.STATE,
        enabled_PWR       => enable_PWR_out(iCM),
        enabled_IOs       => enable_IOs_out(iCM),
        power_good        => from_CM.CM(iCM).PWR_good);
    --For Power-up Sequences

    enableCM(iCM)           <= Ctrl.CM(iCM).CTRL.ENABLE_UC;
    enableCM_PWR(iCM)       <= enable_PWR_out(iCM);
    enableCM_IOs(iCM)       <= enable_IOs_out(iCM);
    CM_disable(iCM)         <= not enable_IOs_out(iCM);
    CM_ucIO_disable(iCM)    <= not Ctrl.CM(iCM).CTRL.ENABLE_UC;
    
    Mon.CM(iCM).CTRL.PWR_GOOD <= from_CM.CM(iCM).PWR_good;  
    Mon.CM(iCM).CTRL.PWR_ENABLED       <= enable_PWR_out(iCM);
    Mon.CM(iCM).CTRL.IOS_ENABLED       <= enable_IOs_out(iCM);

    -------------------------------------------------------------------------------
    -- AXI 
    -------------------------------------------------------------------------------
    rd_dv: process(clk_axi) is
    begin
      if clk_axi'event and clk_axi = '1' then
        MON.CM(iCM).PB.MEM.rd_data_valid <= CTRL.CM(iCM).PB.MEM.enable;
      end if;
    end process rd_dv;
    uC_1: entity work.uC
    generic map(
      LINK_COUNT => 2)
      port map (
        clk                   => clk_axi,
        reset                 => reset,
        reprogram_addr        => CTRL.CM(iCM).PB.MEM.address,
        reprogram_wen         => CTRL.CM(iCM).PB.MEM.wr_enable,
        reprogram_di          => CTRL.CM(iCM).PB.MEM.wr_data,
        reprogram_do          => MON.CM(iCM).PB.MEM.rd_data,
        reprogram_reset       => CTRL.CM(iCM).PB.reset,
        UART_Rx               => UART_Rx(iCM),
        UART_Tx               => UART_Tx(iCM),
        irq_count             => CTRL.CM(iCM).PB.IRQ_COUNT,
        link_INFO_in          => link_INFO_in (2*(iCM-1) to (2*iCM)-1),
        link_INFO_out         => link_INFO_out(2*(iCM-1) to (2*iCM)-1)
        );
    
    
    GENERATE_LANE_LOOP: for iLane in 1 to 2 generate
      signal linkID : integer := 2*(iCM-1) + (iLane);
    begin      
      --C2C control signals
      --CM_C2C_Ctrl.Link(I).aurora_pma_init_in <= CTRL.CM(I).C2C.INITIALIZE;
    
      -------------------------------------------------------------------------------
      -- DC data CDC
      -------------------------------------------------------------------------------
      
      --The following code is ugly, but it is being used to pass two signals from
      --a record assignment through a CDC
      --The signals aren't listed explicityly since we want the fundamental
      --record type to be unexposed since this record will change between 7series
      --and USP
      DC_data_CDC_X: entity work.DC_data_CDC
        generic map (
          DATA_WIDTH           => 1 + CDC_PRBS_SEL_LENGTH)
        port map (
          clk_in               => clk_axi,
          clk_out              => clk_C2C(linkID),
          reset                => reset,
          pass_in(0)                                      => CTRL.CM(iCM).C2C(iLane).DEBUG.RX.PRBS_CNT_RST,
          pass_in( (CDC_PRBS_SEL_LENGTH -1) + 1 downto 1) => CTRL.CM(iCM).C2C(iLane).DEBUG.RX.PRBS_SEL,
          pass_out(0)                                     => CDC_PASSTHROUGH(linkID)(0),               
          pass_out((CDC_PRBS_SEL_LENGTH -1) + 1 downto 1) => CDC_PASSTHROUGH(linkID)((CDC_PRBS_SEL_LENGTH - 1) + 1 downto 1));


      Mon.CM(iCM).C2C(iLane).DEBUG                   <= CM_C2C_Mon.Link(linkID).DEBUG;
      Mon.CM(iCM).C2C(iLane).STATUS                  <= CM_C2C_Mon.Link(linkID).STATUS;
      Mon.CM(iCM).C2C(iLane).COUNTERS.USER_CLK_FREQ  <= CM_C2C_Mon.Link(linkID).user_clk_freq;
            
      partial_assignment: process (Ctrl.CM(iCM).C2C(iLane).debug,
                                   DRP_MOSI,
                                   Ctrl.CM(iCM).C2C(iLane).status,
                                   CDC_PASSTHROUGH,
                                   aurora_init_buf,
                                   phy_reset
                                   ) is
      begin  -- process partial_assignment
        CM_C2C_Ctrl.Link(linkID).debug                 <= CTRL.CM(iCM).C2C(iLane).DEBUG;
        CM_C2C_Ctrl.Link(linkID).DRP                   <= DRP_MOSI(linkID);
        CM_C2C_Ctrl.Link(linkID).status                <= CTRL.CM(iCM).C2C(iLane).status;
        CM_C2C_Ctrl.Link(linkID).DEBUG.RX.PRBS_CNT_RST <= CDC_PASSTHROUGH(linkID)(0);
        CM_C2C_Ctrl.Link(linkID).DEBUG.RX.PRBS_SEL     <= CDC_PASSTHROUGH(linkID)((CDC_PRBS_SEL_LENGTH -1) + 1 downto 1);

        if CTRL.CM(iCM).C2C(iLane).ENABLE_PHY_CTRL = '1' then
          CM_C2C_Ctrl.Link(linkID).STATUS.INITIALIZE  <= aurora_init_buf(linkID);
          CM_C2C_Ctrl.Link(linkID).DEBUG.RX.PMA_RESET <= (phy_reset(linkID) or Ctrl.CM(iCM).C2C(iLane).DEBUG.RX.PMA_RESET);
        else
          CM_C2C_Ctrl.Link(linkID).STATUS.INITIALIZE  <= Ctrl.CM(iCM).C2C(iLane).STATUS.INITIALIZE;
          CM_C2C_Ctrl.Link(linkID).DEBUG.RX.PMA_RESET <= Ctrl.CM(iCM).C2C(iLane).DEBUG.RX.PMA_RESET;
        end if;
        
      end process partial_assignment;
      ---------------------------------------------------------------------------
      -- DRP CDC
      ---------------------------------------------------------------------------
      drp_en_signal(linkID) <= CTRL.CM(iCM).C2C(iLane).DRP.wr_enable or CTRL.CM(iCM).C2C(iLane).DRP.enable;
      DRP_DATA_to_DRP : entity work.data_CDC
        generic map (
          WIDTH => (1 +
                    CTRL.CM(iCM).C2C(iLane).DRP.address'LENGTH +
                    CTRL.CM(iCM).C2C(iLane).DRP.wr_data'LENGTH)
          )
        port map (
          clkA       => CTRL.CM(iCM).C2C(iLane).DRP.clk,
          resetA     => reset,
          clkB       => DRP_clk(2*(iCM-1) + (iLane)),
          resetB     => reset,
          inA(0)                                                     => CTRL.CM(iCM).C2C(iLane).DRP.wr_enable,

          inA(CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.address'LENGTH downto 1)  => CTRL.CM(iCM).C2C(iLane).DRP.address,

          inA(CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.wr_data'LENGTH - 1 +
              CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.address'LENGTH + 1
              downto
              CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.address'LENGTH + 1)       => CTRL.CM(iCM).C2C(iLane).DRP.wr_data,
        
          inA_valid  => drp_en_signal(2*(iCM-1) + (iLane)),
          
          outB(0)                                                    => DRP_MOSI(2*(iCM-1) + (iLane)).wr_enable,
          outB(CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.address'LENGTH downto 1) => DRP_MOSI(2*(iCM-1) + (iLane)).address,
          outB(CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.wr_data'LENGTH - 1 +
               CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.address'LENGTH + 1
               downto
               CM_C2C_Ctrl.Link(2*(iCM-1) + (iLane)).DRP.address'LENGTH + 1)      => DRP_MOSI(2*(iCM-1) + (iLane)).wr_data,
          outB_valid => DRP_MOSI(2*(iCM-1) + (iLane)).enable);
      DRP_DATA_from_DRP: entity work.data_CDC
        generic map (
          WIDTH => CM_C2C_Mon.Link(linkID).DRP.rd_data'LENGTH)
        port map (
          clkA       => DRP_clk(linkID),
          resetA     => reset,
          clkB       => clk_axi,
          resetB     => reset,
          inA        => CM_C2C_Mon.Link(linkID).DRP.rd_data,
          inA_valid  => CM_C2C_Mon.Link(linkID).DRP.rd_data_valid,
          outB       => Mon.CM(iCM).C2C(iLane).DRP.rd_data,
          outB_valid => Mon.CM(iCM).C2C(iLane).DRP.rd_data_valid);
      ---------------------------------------------------------------------------

      
      -------------------------------------------------------------------------------
      -- Phy_lane_control
      -------------------------------------------------------------------------------
      soft_error_rate_counter: entity work.rate_counter
        generic map (
          CLK_A_1_SECOND => CLKFREQ)
        port map (
          clk_A             => clk_axi,
          clk_B             => clk_C2C(iLane),
          reset_A_async     => '0',
          event_b           => Mon.CM(iCM).C2C(iLane).STATUS.PHY_SOFT_ERR,
          rate              => soft_error_rate(linkID));
      Mon.CM(iCM).C2C(iLane).COUNTERS.SOFT_ERROR_RATE <= soft_error_rate(linkID);
      hard_error_rate_counter: entity work.rate_counter
        generic map (
          CLK_A_1_SECOND => CLKFREQ)
        port map (
          clk_A             => clk_axi,
          clk_B             => clk_C2C(iLane),
          reset_A_async     => '0',
          event_b           => Mon.CM(iCM).C2C(iLane).STATUS.PHY_HARD_ERR,
          rate              => hard_error_rate(linkID));
      Mon.CM(iCM).C2C(iLane).COUNTERS.HARD_ERROR_RATE <= hard_error_rate(linkID);
      

      phy_reset(linkID)                             <= link_INFO_out(linkID-1).link_reset;       
      aurora_init_buf(linkID)                       <= link_INFO_out(linkID-1).link_init;        
      Mon.CM(iCM).C2C(iLane).COUNTERS.PHYLANE_STATE <= link_INFO_out(linkID-1).state(2 downto 0);
                                  
      link_INFO_in(linkID-1).link_reset_done            <= '1';--Mon.CM(iCM).C2C(iLane).DEBUG.RX.PMA_RESET_DONE;     
      link_INFO_in(linkID-1).link_good                  <= Mon.CM(iCM).C2C(iLane).status.LINK_GOOD;
      link_INFO_in(linkID-1).lane_up                    <= Mon.CM(iCM).C2C(iLane).status.phy_lane_up(0);
      link_INFO_in(linkID-1).soft_err_rate              <= soft_error_rate(linkID);
      link_INFO_in(linkID-1).soft_err_rate_threshold    <= CTRL.CM(iCM).C2C(iLane).PHY_MAX_SOFT_ERROR_RATE;
      link_INFO_in(linkID-1).hard_err_rate              <= hard_error_rate(linkID);
      link_INFO_in(linkID-1).hard_err_rate_threshold    <= CTRL.CM(iCM).C2C(iLane).PHY_MAX_HARD_ERROR_RATE;


      -------------------------------------------------------------------------------
      -- COUNTERS
      -------------------------------------------------------------------------------
      GENERATE_COUNTERS_LOOP: for iCNT in 0 to COUNTER_COUNT -1 generate --....counter_count
        counter_CDC_X: entity work.counter_CDC
          generic map (
            roll_over   => '0' )
          port map (
            clk_in      => counter_clk(iCNT),
            reset_async => reset or Mon.CM(iCM).C2C(iLane).STATUS.PB_RESET,
            event       => counter_events((linkID-1)*COUNTER_COUNT + iCNT ),
            clk_out     => clk_axi,
            enable      => counter_en(linkID),
            reset_sync  => CTRL.CM(iCM).C2C(iLane).COUNTERS.RESET_COUNTERS,
            count       => C2C_Counter((LinkID-1)*COUNTER_COUNT + iCNT),
            at_max      => open);
        
      end generate GENERATE_COUNTERS_LOOP;
      --PATTERN FOR COUNTERS
      counter_clk((LinkID-1)*COUNTER_COUNT + 0) <= clk_C2C(LinkID);
      counter_clk((LinkID-1)*COUNTER_COUNT + 1) <= clk_C2C(LinkID);
      
      --setting events, run 0 to (COUNTER_COUNT - 1)
      counter_events((LinkID-1)*COUNTER_COUNT + 0) <= Mon.CM(iCM).C2C(iLane).STATUS.PHY_HARD_ERR;
      counter_events((LinkID-1)*COUNTER_COUNT + 1) <= Mon.CM(iCM).C2C(iLane).STATUS.PHY_SOFT_ERR;
      --setting counters, run 1 to COUNTER_COUNT
      Mon.CM(iCM).C2C(iLane).COUNTERS.PHY_HARD_ERROR_COUNT <= C2C_Counter((LinkID-1)*COUNTER_COUNT + 0);
      Mon.CM(iCM).C2C(iLane).COUNTERS.PHY_SOFT_ERROR_COUNT <= C2C_Counter((LinkID-1)*COUNTER_COUNT + 1);   
    end generate GENERATE_LANE_LOOP;
  end generate GENERATE_LOOP;
end architecture behavioral;
