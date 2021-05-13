--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.PLXVC_Ctrl.all;
entity PLXVC_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    
    Mon              : in  PLXVC_Mon_t;
    Ctrl             : out PLXVC_Ctrl_t
        
    );
end entity PLXVC_interface;
architecture behavioral of PLXVC_interface is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  
  signal reg_data :  slv32_array_t(integer range 0 to 40);
  constant Default_reg_data : slv32_array_t(integer range 0 to 40) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => slave_readMOSI,
      readMISO    => slave_readMISO,
      writeMOSI   => slave_writeMOSI,
      writeMISO   => slave_writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localRdReq = '1' then
        localRdData_latch <= localRdData;

        
          
      end if;
    end if;
  end process latch_reads;

  
  localRdAck <= regRdAck ;  
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    regRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      regRdAck  <= '1';
      case to_integer(unsigned(localAddress(5 downto 0))) is

        when 0 => --0x0
          localRdData(31 downto  0)  <=  reg_data( 0)(31 downto  0);      --Length of shift operation in bits
        when 1 => --0x1
          localRdData(31 downto  0)  <=  reg_data( 1)(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 2 => --0x2
          localRdData(31 downto  0)  <=  reg_data( 2)(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 3 => --0x3
          localRdData(31 downto  0)  <=  Mon.XVC(1).TDO_VECTOR;           --Test Data Out (TDO) Capture Vector
        when 4 => --0x4
          localRdData( 1)            <=  Mon.XVC(1).BUSY;                 --Cable is operating
        when 5 => --0x5
          localRdData(31 downto  0)  <=  reg_data( 5)(31 downto  0);      --Lock cable from access
        when 6 => --0x6
          localRdData(31 downto  0)  <=  reg_data( 6)(31 downto  0);      --IP of remote connection
        when 7 => --0x7
          localRdData(15 downto  0)  <=  reg_data( 7)(15 downto  0);      --port of remote connection
        when 8 => --0x8
          localRdData( 0)            <=  reg_data( 8)( 0);                --PS reset
        when 16 => --0x10
          localRdData(31 downto  0)  <=  reg_data(16)(31 downto  0);      --Length of shift operation in bits
        when 17 => --0x11
          localRdData(31 downto  0)  <=  reg_data(17)(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 18 => --0x12
          localRdData(31 downto  0)  <=  reg_data(18)(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 19 => --0x13
          localRdData(31 downto  0)  <=  Mon.XVC(2).TDO_VECTOR;           --Test Data Out (TDO) Capture Vector
        when 20 => --0x14
          localRdData( 1)            <=  Mon.XVC(2).BUSY;                 --Cable is operating
        when 21 => --0x15
          localRdData(31 downto  0)  <=  reg_data(21)(31 downto  0);      --Lock cable from access
        when 22 => --0x16
          localRdData(31 downto  0)  <=  reg_data(22)(31 downto  0);      --IP of remote connection
        when 23 => --0x17
          localRdData(15 downto  0)  <=  reg_data(23)(15 downto  0);      --port of remote connection
        when 24 => --0x18
          localRdData( 0)            <=  reg_data(24)( 0);                --PS reset
        when 32 => --0x20
          localRdData(31 downto  0)  <=  reg_data(32)(31 downto  0);      --Length of shift operation in bits
        when 33 => --0x21
          localRdData(31 downto  0)  <=  reg_data(33)(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 34 => --0x22
          localRdData(31 downto  0)  <=  reg_data(34)(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 35 => --0x23
          localRdData(31 downto  0)  <=  Mon.XVC(3).TDO_VECTOR;           --Test Data Out (TDO) Capture Vector
        when 36 => --0x24
          localRdData( 1)            <=  Mon.XVC(3).BUSY;                 --Cable is operating
        when 37 => --0x25
          localRdData(31 downto  0)  <=  reg_data(37)(31 downto  0);      --Lock cable from access
        when 38 => --0x26
          localRdData(31 downto  0)  <=  reg_data(38)(31 downto  0);      --IP of remote connection
        when 39 => --0x27
          localRdData(15 downto  0)  <=  reg_data(39)(15 downto  0);      --port of remote connection
        when 40 => --0x28
          localRdData( 0)            <=  reg_data(40)( 0);                --PS reset


        when others =>
          localRdData <= x"00000000";
      end case;
      

    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.XVC(1).LENGTH              <=  reg_data( 0)(31 downto  0);     
  Ctrl.XVC(1).PS_RST              <=  reg_data( 8)( 0);               
  Ctrl.XVC(1).TMS_VECTOR          <=  reg_data( 1)(31 downto  0);     
  Ctrl.XVC(1).TDI_VECTOR          <=  reg_data( 2)(31 downto  0);     
  Ctrl.XVC(1).LOCK                <=  reg_data( 5)(31 downto  0);     
  Ctrl.XVC(1).REMOTE.IP           <=  reg_data( 6)(31 downto  0);     
  Ctrl.XVC(1).REMOTE.PORT_NUMBER  <=  reg_data( 7)(15 downto  0);     
  Ctrl.XVC(2).LENGTH              <=  reg_data(16)(31 downto  0);     
  Ctrl.XVC(2).PS_RST              <=  reg_data(24)( 0);               
  Ctrl.XVC(2).TMS_VECTOR          <=  reg_data(17)(31 downto  0);     
  Ctrl.XVC(2).TDI_VECTOR          <=  reg_data(18)(31 downto  0);     
  Ctrl.XVC(2).LOCK                <=  reg_data(21)(31 downto  0);     
  Ctrl.XVC(2).REMOTE.IP           <=  reg_data(22)(31 downto  0);     
  Ctrl.XVC(2).REMOTE.PORT_NUMBER  <=  reg_data(23)(15 downto  0);     
  Ctrl.XVC(3).LENGTH              <=  reg_data(32)(31 downto  0);     
  Ctrl.XVC(3).PS_RST              <=  reg_data(40)( 0);               
  Ctrl.XVC(3).TMS_VECTOR          <=  reg_data(33)(31 downto  0);     
  Ctrl.XVC(3).TDI_VECTOR          <=  reg_data(34)(31 downto  0);     
  Ctrl.XVC(3).LOCK                <=  reg_data(37)(31 downto  0);     
  Ctrl.XVC(3).REMOTE.IP           <=  reg_data(38)(31 downto  0);     
  Ctrl.XVC(3).REMOTE.PORT_NUMBER  <=  reg_data(39)(15 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 0)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(1).LENGTH;
      reg_data( 8)( 0)  <= DEFAULT_PLXVC_CTRL_t.XVC(1).PS_RST;
      reg_data( 1)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(1).TMS_VECTOR;
      reg_data( 2)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(1).TDI_VECTOR;
      reg_data( 5)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(1).LOCK;
      reg_data( 6)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(1).REMOTE.IP;
      reg_data( 7)(15 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(1).REMOTE.PORT_NUMBER;
      reg_data(16)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(2).LENGTH;
      reg_data(24)( 0)  <= DEFAULT_PLXVC_CTRL_t.XVC(2).PS_RST;
      reg_data(17)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(2).TMS_VECTOR;
      reg_data(18)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(2).TDI_VECTOR;
      reg_data(21)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(2).LOCK;
      reg_data(22)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(2).REMOTE.IP;
      reg_data(23)(15 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(2).REMOTE.PORT_NUMBER;
      reg_data(32)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(3).LENGTH;
      reg_data(40)( 0)  <= DEFAULT_PLXVC_CTRL_t.XVC(3).PS_RST;
      reg_data(33)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(3).TMS_VECTOR;
      reg_data(34)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(3).TDI_VECTOR;
      reg_data(37)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(3).LOCK;
      reg_data(38)(31 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(3).REMOTE.IP;
      reg_data(39)(15 downto  0)  <= DEFAULT_PLXVC_CTRL_t.XVC(3).REMOTE.PORT_NUMBER;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.XVC(1).GO <= '0';
      Ctrl.XVC(2).GO <= '0';
      Ctrl.XVC(3).GO <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(5 downto 0))) is
        when 0 => --0x0
          reg_data( 0)(31 downto  0)  <=  localWrData(31 downto  0);      --Length of shift operation in bits
        when 1 => --0x1
          reg_data( 1)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 2 => --0x2
          reg_data( 2)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 4 => --0x4
          Ctrl.XVC(1).GO              <=  localWrData( 0);               
        when 5 => --0x5
          reg_data( 5)(31 downto  0)  <=  localWrData(31 downto  0);      --Lock cable from access
        when 6 => --0x6
          reg_data( 6)(31 downto  0)  <=  localWrData(31 downto  0);      --IP of remote connection
        when 7 => --0x7
          reg_data( 7)(15 downto  0)  <=  localWrData(15 downto  0);      --port of remote connection
        when 8 => --0x8
          reg_data( 8)( 0)            <=  localWrData( 0);                --PS reset
        when 16 => --0x10
          reg_data(16)(31 downto  0)  <=  localWrData(31 downto  0);      --Length of shift operation in bits
        when 17 => --0x11
          reg_data(17)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 18 => --0x12
          reg_data(18)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 20 => --0x14
          Ctrl.XVC(2).GO              <=  localWrData( 0);               
        when 21 => --0x15
          reg_data(21)(31 downto  0)  <=  localWrData(31 downto  0);      --Lock cable from access
        when 22 => --0x16
          reg_data(22)(31 downto  0)  <=  localWrData(31 downto  0);      --IP of remote connection
        when 23 => --0x17
          reg_data(23)(15 downto  0)  <=  localWrData(15 downto  0);      --port of remote connection
        when 24 => --0x18
          reg_data(24)( 0)            <=  localWrData( 0);                --PS reset
        when 32 => --0x20
          reg_data(32)(31 downto  0)  <=  localWrData(31 downto  0);      --Length of shift operation in bits
        when 33 => --0x21
          reg_data(33)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 34 => --0x22
          reg_data(34)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 36 => --0x24
          Ctrl.XVC(3).GO              <=  localWrData( 0);               
        when 37 => --0x25
          reg_data(37)(31 downto  0)  <=  localWrData(31 downto  0);      --Lock cable from access
        when 38 => --0x26
          reg_data(38)(31 downto  0)  <=  localWrData(31 downto  0);      --IP of remote connection
        when 39 => --0x27
          reg_data(39)(15 downto  0)  <=  localWrData(15 downto  0);      --port of remote connection
        when 40 => --0x28
          reg_data(40)( 0)            <=  localWrData( 0);                --PS reset

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;




  
end architecture behavioral;