--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.plXVC_Ctrl.all;
entity plXVC_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  plXVC_Mon_t;
    Ctrl             : out plXVC_Ctrl_t
    );
end entity plXVC_interface;
architecture behavioral of plXVC_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 11);
  constant Default_reg_data : slv32_array_t(integer range 0 to 11) := (others => x"00000000");
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
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    localRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      localRdAck  <= '1';
      case to_integer(unsigned(localAddress(3 downto 0))) is

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
          localRdData(31 downto  0)  <=  reg_data( 6)(31 downto  0);      --Length of shift operation in bits
        when 7 => --0x7
          localRdData(31 downto  0)  <=  reg_data( 7)(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 8 => --0x8
          localRdData(31 downto  0)  <=  reg_data( 8)(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 9 => --0x9
          localRdData(31 downto  0)  <=  Mon.XVC(2).TDO_VECTOR;           --Test Data Out (TDO) Capture Vector
        when 10 => --0xa
          localRdData( 1)            <=  Mon.XVC(2).BUSY;                 --Cable is operating
        when 11 => --0xb
          localRdData(31 downto  0)  <=  reg_data(11)(31 downto  0);      --Lock cable from access


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.XVC(1).LENGTH      <=  reg_data( 0)(31 downto  0);     
  Ctrl.XVC(1).TMS_VECTOR  <=  reg_data( 1)(31 downto  0);     
  Ctrl.XVC(1).TDI_VECTOR  <=  reg_data( 2)(31 downto  0);     
  Ctrl.XVC(1).LOCK        <=  reg_data( 5)(31 downto  0);     
  Ctrl.XVC(2).LENGTH      <=  reg_data( 6)(31 downto  0);     
  Ctrl.XVC(2).TMS_VECTOR  <=  reg_data( 7)(31 downto  0);     
  Ctrl.XVC(2).TDI_VECTOR  <=  reg_data( 8)(31 downto  0);     
  Ctrl.XVC(2).LOCK        <=  reg_data(11)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 0)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).LENGTH;
      reg_data( 1)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).TMS_VECTOR;
      reg_data( 2)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).TDI_VECTOR;
      reg_data( 5)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).LOCK;
      reg_data( 6)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).LENGTH;
      reg_data( 7)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).TMS_VECTOR;
      reg_data( 8)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).TDI_VECTOR;
      reg_data(11)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).LOCK;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.XVC(1).GO <= '0';
      Ctrl.XVC(2).GO <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(3 downto 0))) is
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
          reg_data( 6)(31 downto  0)  <=  localWrData(31 downto  0);      --Length of shift operation in bits
        when 7 => --0x7
          reg_data( 7)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Mode Select (TMS) Bit Vector
        when 8 => --0x8
          reg_data( 8)(31 downto  0)  <=  localWrData(31 downto  0);      --Test Data In (TDI) Bit Vector
        when 10 => --0xa
          Ctrl.XVC(2).GO              <=  localWrData( 0);               
        when 11 => --0xb
          reg_data(11)(31 downto  0)  <=  localWrData(31 downto  0);      --Lock cable from access

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;