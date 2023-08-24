--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;

use work.plXVC_Ctrl.all;



entity plXVC_map is
  generic (
    READ_TIMEOUT     : integer := 2048;
    ALLOCATED_MEMORY_RANGE : integer
    );
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
end entity plXVC_map;
architecture behavioral of plXVC_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localWrAck         : std_logic;
  signal localWrErr         : std_logic;
  signal regWrAck           : std_logic;

  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal localRdErr         : std_logic;
  signal regRdAck           : std_logic;




  constant FIFO_COUNT       : integer := 9;
  constant FIFO_range       : int_array_t(0 to FIFO_COUNT-1) := ();
  constant FIFO_addr        : slv32_array_t(0 to FIFO_COUNT-1) := ();
  signal FIFO_MOSI          : FIFOPortMOSI_array_t(0 to FIFO_COUNT-1);
  signal FIFO_MISO          : FIFOPortMISO_array_t(0 to FIFO_COUNT-1);


  signal reg_data :  slv32_array_t(integer range 0 to 41);
  constant Default_reg_data : slv32_array_t(integer range 0 to 41) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  assert ((4*41) <= ALLOCATED_MEMORY_RANGE)
    report "plXVC: Regmap addressing range " & integer'image(4*41) & " is outside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity ERROR;
  assert ((4*41) > ALLOCATED_MEMORY_RANGE)
    report "plXVC: Regmap addressing range " & integer'image(4*41) & " is inside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity NOTE;

  AXIRegBridge : entity work.axiLiteRegBlocking
    generic map (
      READ_TIMEOUT => READ_TIMEOUT
      )
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
      write_ack   => localWrAck,
      write_err   => localWrErr,
      read_req    => localRdReq,
      read_ack    => localRdAck,
      read_err    => localRdErr);

  -------------------------------------------------------------------------------
  -- Record read decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  latch_reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      localRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      localRdAck <= '0';

      if regRdAck = '1' then
        localRdData_latch <= localRdData;
        localRdAck        <= '1';

      elsif FIFO_MISO(0).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(0).rd_data;
        localRderr        <= FIFO_MISO(0).rd_error;
elsif FIFO_MISO(1).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(1).rd_data;
        localRderr        <= FIFO_MISO(1).rd_error;
elsif FIFO_MISO(2).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(2).rd_data;
        localRderr        <= FIFO_MISO(2).rd_error;
elsif FIFO_MISO(3).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(3).rd_data;
        localRderr        <= FIFO_MISO(3).rd_error;
elsif FIFO_MISO(4).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(4).rd_data;
        localRderr        <= FIFO_MISO(4).rd_error;
elsif FIFO_MISO(5).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(5).rd_data;
        localRderr        <= FIFO_MISO(5).rd_error;
elsif FIFO_MISO(6).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(6).rd_data;
        localRderr        <= FIFO_MISO(6).rd_error;
elsif FIFO_MISO(7).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(7).rd_data;
        localRderr        <= FIFO_MISO(7).rd_error;
elsif FIFO_MISO(8).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO(8).rd_data;
        localRderr        <= FIFO_MISO(8).rd_error;

      end if;
    end if;
  end process latch_reads;


  reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      regRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
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
        when 9 => --0x9
          localRdData( 0)            <=  reg_data( 9)( 0);                --Enable FIFO mode
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
        when 25 => --0x19
          localRdData( 0)            <=  reg_data(25)( 0);                --Enable FIFO mode
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
        when 41 => --0x29
          localRdData( 0)            <=  reg_data(41)( 0);                --Enable FIFO mode


          when others =>
            regRdAck <= '0';
            localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;


  -------------------------------------------------------------------------------
  -- Record write decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------


  write_ack_proc : process (clk_axi, reset_axi_n) is
  begin
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      localWrAck <= '0';
      localWrErr <= '0';
    elsif clk'event and clk_axi = '1' then
      localWrAck <= '0';
      localWrErr <= '0';
      if regWrAck = '1' then
        localWrAck <= '1';
        localWrErr <= '0';

      elsif FIFO_MISO(0).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(0).wr_response;
elsif FIFO_MISO(1).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(1).wr_response;
elsif FIFO_MISO(2).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(2).wr_response;
elsif FIFO_MISO(3).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(3).wr_response;
elsif FIFO_MISO(4).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(4).wr_response;
elsif FIFO_MISO(5).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(5).wr_response;
elsif FIFO_MISO(6).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(6).wr_response;
elsif FIFO_MISO(7).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(7).wr_response;
elsif FIFO_MISO(8).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO(8).wr_response;


    end if;
  end process write_ack_proc;

  -- Register mapping to ctrl structures
  Ctrl.XVC(1).LENGTH              <=  reg_data( 0)(31 downto  0);
  Ctrl.XVC(1).TMS_VECTOR          <=  reg_data( 1)(31 downto  0);
  Ctrl.XVC(1).TDI_VECTOR          <=  reg_data( 2)(31 downto  0);
  Ctrl.XVC(1).LOCK                <=  reg_data( 5)(31 downto  0);
  Ctrl.XVC(1).REMOTE.IP           <=  reg_data( 6)(31 downto  0);
  Ctrl.XVC(1).REMOTE.PORT_NUMBER  <=  reg_data( 7)(15 downto  0);
  Ctrl.XVC(1).PS_RST              <=  reg_data( 8)( 0);
  Ctrl.XVC(1).FIFO_MODE.ENABLE    <=  reg_data( 9)( 0);
  Ctrl.XVC(2).LENGTH              <=  reg_data(16)(31 downto  0);
  Ctrl.XVC(2).TMS_VECTOR          <=  reg_data(17)(31 downto  0);
  Ctrl.XVC(2).TDI_VECTOR          <=  reg_data(18)(31 downto  0);
  Ctrl.XVC(2).LOCK                <=  reg_data(21)(31 downto  0);
  Ctrl.XVC(2).REMOTE.IP           <=  reg_data(22)(31 downto  0);
  Ctrl.XVC(2).REMOTE.PORT_NUMBER  <=  reg_data(23)(15 downto  0);
  Ctrl.XVC(2).PS_RST              <=  reg_data(24)( 0);
  Ctrl.XVC(2).FIFO_MODE.ENABLE    <=  reg_data(25)( 0);
  Ctrl.XVC(3).LENGTH              <=  reg_data(32)(31 downto  0);
  Ctrl.XVC(3).TMS_VECTOR          <=  reg_data(33)(31 downto  0);
  Ctrl.XVC(3).TDI_VECTOR          <=  reg_data(34)(31 downto  0);
  Ctrl.XVC(3).LOCK                <=  reg_data(37)(31 downto  0);
  Ctrl.XVC(3).REMOTE.IP           <=  reg_data(38)(31 downto  0);
  Ctrl.XVC(3).REMOTE.PORT_NUMBER  <=  reg_data(39)(15 downto  0);
  Ctrl.XVC(3).PS_RST              <=  reg_data(40)( 0);
  Ctrl.XVC(3).FIFO_MODE.ENABLE    <=  reg_data(41)( 0);


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
            reg_data( 0)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).LENGTH;
      reg_data( 1)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).TMS_VECTOR;
      reg_data( 2)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).TDI_VECTOR;
      reg_data( 4)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).GO;
      reg_data( 5)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).LOCK;
      reg_data( 6)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).REMOTE.IP;
      reg_data( 7)(15 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).REMOTE.PORT_NUMBER;
      reg_data( 8)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).PS_RST;
      reg_data( 9)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(1).FIFO_MODE.ENABLE;
      reg_data(16)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).LENGTH;
      reg_data(17)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).TMS_VECTOR;
      reg_data(18)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).TDI_VECTOR;
      reg_data(20)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).GO;
      reg_data(21)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).LOCK;
      reg_data(22)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).REMOTE.IP;
      reg_data(23)(15 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).REMOTE.PORT_NUMBER;
      reg_data(24)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).PS_RST;
      reg_data(25)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(2).FIFO_MODE.ENABLE;
      reg_data(32)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).LENGTH;
      reg_data(33)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).TMS_VECTOR;
      reg_data(34)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).TDI_VECTOR;
      reg_data(36)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).GO;
      reg_data(37)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).LOCK;
      reg_data(38)(31 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).REMOTE.IP;
      reg_data(39)(15 downto  0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).REMOTE.PORT_NUMBER;
      reg_data(40)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).PS_RST;
      reg_data(41)( 0)  <= DEFAULT_plXVC_CTRL_t.XVC(3).FIFO_MODE.ENABLE;

      regWrAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.XVC(1).GO <= '0';
      Ctrl.XVC(2).GO <= '0';
      Ctrl.XVC(3).GO <= '0';


      regWrAck <= '0';
      if localWrEn = '1' then
        regWrAck <= '1';
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
        when 9 => --0x9
          reg_data( 9)( 0)            <=  localWrData( 0);                --Enable FIFO mode
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
        when 25 => --0x19
          reg_data(25)( 0)            <=  localWrData( 0);                --Enable FIFO mode
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
        when 41 => --0x29
          reg_data(41)( 0)            <=  localWrData( 0);                --Enable FIFO mode

        when others =>
          regWrAck <= '0';
        end case;
      end if;
    end if;
  end process reg_writes;









  -------------------------------------------------------------------------------
  -- FIFO decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  FIFO_reads: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_read: process (clk_axi,reset_axi_n) is
    begin  -- process FIFO_reads
      if reset_axi_n = '0' then
        FIFO_MOSI(iFIFO).rd_enable  <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        FIFO_MOSI(iFIFO).rd_enable  <= '0';
        if localAddress(5 downto FIFO_range(iFIFO)) = FIFO_addr(iFIFO)(5 downto FIFO_range(iFIFO)) then
          FIFO_MOSI(iFIFO).rd_enable  <= localRdReq;
        end if;
      end if;
    end process FIFO_read;
  end generate FIFO_reads;



  FIFO_asyncs: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_MOSI(iFIFO).clk     <= clk_axi;
    FIFO_MOSI(iFIFO).wr_data <= localWrData;
  end generate FIFO_asyncs;

  Ctrl.XVC(1).FIFO_MODE.LENGTH.clk       <=  FIFO_MOSI(0).clk;
  Ctrl.XVC(1).FIFO_MODE.LENGTH.reset       <=  FIFO_MOSI(0).reset;
  Ctrl.XVC(1).FIFO_MODE.LENGTH.rd_enable    <=  FIFO_MOSI(0).rd_enable;
  Ctrl.XVC(1).FIFO_MODE.LENGTH.wr_enable <=  FIFO_MOSI(0).wr_enable;
  Ctrl.XVC(1).FIFO_MODE.LENGTH.wr_data   <=  FIFO_MOSI(0).wr_data(32-1 downto 0);

  Ctrl.XVC(2).FIFO_MODE.LENGTH.clk       <=  FIFO_MOSI(1).clk;
  Ctrl.XVC(2).FIFO_MODE.LENGTH.reset       <=  FIFO_MOSI(1).reset;
  Ctrl.XVC(2).FIFO_MODE.LENGTH.rd_enable    <=  FIFO_MOSI(1).rd_enable;
  Ctrl.XVC(2).FIFO_MODE.LENGTH.wr_enable <=  FIFO_MOSI(1).wr_enable;
  Ctrl.XVC(2).FIFO_MODE.LENGTH.wr_data   <=  FIFO_MOSI(1).wr_data(32-1 downto 0);

  Ctrl.XVC(3).FIFO_MODE.LENGTH.clk       <=  FIFO_MOSI(2).clk;
  Ctrl.XVC(3).FIFO_MODE.LENGTH.reset       <=  FIFO_MOSI(2).reset;
  Ctrl.XVC(3).FIFO_MODE.LENGTH.rd_enable    <=  FIFO_MOSI(2).rd_enable;
  Ctrl.XVC(3).FIFO_MODE.LENGTH.wr_enable <=  FIFO_MOSI(2).wr_enable;
  Ctrl.XVC(3).FIFO_MODE.LENGTH.wr_data   <=  FIFO_MOSI(2).wr_data(32-1 downto 0);

  Ctrl.XVC(1).FIFO_MODE.TMS_VECTOR.clk       <=  FIFO_MOSI(3).clk;
  Ctrl.XVC(1).FIFO_MODE.TMS_VECTOR.reset       <=  FIFO_MOSI(3).reset;
  Ctrl.XVC(1).FIFO_MODE.TMS_VECTOR.rd_enable    <=  FIFO_MOSI(3).rd_enable;
  Ctrl.XVC(1).FIFO_MODE.TMS_VECTOR.wr_enable <=  FIFO_MOSI(3).wr_enable;
  Ctrl.XVC(1).FIFO_MODE.TMS_VECTOR.wr_data   <=  FIFO_MOSI(3).wr_data(32-1 downto 0);

  Ctrl.XVC(2).FIFO_MODE.TMS_VECTOR.clk       <=  FIFO_MOSI(4).clk;
  Ctrl.XVC(2).FIFO_MODE.TMS_VECTOR.reset       <=  FIFO_MOSI(4).reset;
  Ctrl.XVC(2).FIFO_MODE.TMS_VECTOR.rd_enable    <=  FIFO_MOSI(4).rd_enable;
  Ctrl.XVC(2).FIFO_MODE.TMS_VECTOR.wr_enable <=  FIFO_MOSI(4).wr_enable;
  Ctrl.XVC(2).FIFO_MODE.TMS_VECTOR.wr_data   <=  FIFO_MOSI(4).wr_data(32-1 downto 0);

  Ctrl.XVC(3).FIFO_MODE.TMS_VECTOR.clk       <=  FIFO_MOSI(5).clk;
  Ctrl.XVC(3).FIFO_MODE.TMS_VECTOR.reset       <=  FIFO_MOSI(5).reset;
  Ctrl.XVC(3).FIFO_MODE.TMS_VECTOR.rd_enable    <=  FIFO_MOSI(5).rd_enable;
  Ctrl.XVC(3).FIFO_MODE.TMS_VECTOR.wr_enable <=  FIFO_MOSI(5).wr_enable;
  Ctrl.XVC(3).FIFO_MODE.TMS_VECTOR.wr_data   <=  FIFO_MOSI(5).wr_data(32-1 downto 0);

  Ctrl.XVC(1).FIFO_MODE.TDI_VECTOR.clk       <=  FIFO_MOSI(6).clk;
  Ctrl.XVC(1).FIFO_MODE.TDI_VECTOR.reset       <=  FIFO_MOSI(6).reset;
  Ctrl.XVC(1).FIFO_MODE.TDI_VECTOR.rd_enable    <=  FIFO_MOSI(6).rd_enable;
  Ctrl.XVC(1).FIFO_MODE.TDI_VECTOR.wr_enable <=  FIFO_MOSI(6).wr_enable;
  Ctrl.XVC(1).FIFO_MODE.TDI_VECTOR.wr_data   <=  FIFO_MOSI(6).wr_data(32-1 downto 0);

  Ctrl.XVC(2).FIFO_MODE.TDI_VECTOR.clk       <=  FIFO_MOSI(7).clk;
  Ctrl.XVC(2).FIFO_MODE.TDI_VECTOR.reset       <=  FIFO_MOSI(7).reset;
  Ctrl.XVC(2).FIFO_MODE.TDI_VECTOR.rd_enable    <=  FIFO_MOSI(7).rd_enable;
  Ctrl.XVC(2).FIFO_MODE.TDI_VECTOR.wr_enable <=  FIFO_MOSI(7).wr_enable;
  Ctrl.XVC(2).FIFO_MODE.TDI_VECTOR.wr_data   <=  FIFO_MOSI(7).wr_data(32-1 downto 0);

  Ctrl.XVC(3).FIFO_MODE.TDI_VECTOR.clk       <=  FIFO_MOSI(8).clk;
  Ctrl.XVC(3).FIFO_MODE.TDI_VECTOR.reset       <=  FIFO_MOSI(8).reset;
  Ctrl.XVC(3).FIFO_MODE.TDI_VECTOR.rd_enable    <=  FIFO_MOSI(8).rd_enable;
  Ctrl.XVC(3).FIFO_MODE.TDI_VECTOR.wr_enable <=  FIFO_MOSI(8).wr_enable;
  Ctrl.XVC(3).FIFO_MODE.TDI_VECTOR.wr_data   <=  FIFO_MOSI(8).wr_data(32-1 downto 0);


  FIFO_MISO(0).rd_data(32-1 downto 0) <= Mon.XVC(1).FIFO_MODE.LENGTH.rd_data;
  FIFO_MISO(0).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(0).rd_data_valid <= Mon.XVC(1).FIFO_MODE.LENGTH.rd_data_valid;

  FIFO_MISO(0).rd_error <= Mon.XVC(1).FIFO_MODE.LENGTH.rd_error;

  FIFO_MISO(0).wr_error <= Mon.XVC(1).FIFO_MODE.LENGTH.wr_error;

  FIFO_MISO(1).rd_data(32-1 downto 0) <= Mon.XVC(2).FIFO_MODE.LENGTH.rd_data;
  FIFO_MISO(1).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(1).rd_data_valid <= Mon.XVC(2).FIFO_MODE.LENGTH.rd_data_valid;

  FIFO_MISO(1).rd_error <= Mon.XVC(2).FIFO_MODE.LENGTH.rd_error;

  FIFO_MISO(1).wr_error <= Mon.XVC(2).FIFO_MODE.LENGTH.wr_error;

  FIFO_MISO(2).rd_data(32-1 downto 0) <= Mon.XVC(3).FIFO_MODE.LENGTH.rd_data;
  FIFO_MISO(2).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(2).rd_data_valid <= Mon.XVC(3).FIFO_MODE.LENGTH.rd_data_valid;

  FIFO_MISO(2).rd_error <= Mon.XVC(3).FIFO_MODE.LENGTH.rd_error;

  FIFO_MISO(2).wr_error <= Mon.XVC(3).FIFO_MODE.LENGTH.wr_error;

  FIFO_MISO(3).rd_data(32-1 downto 0) <= Mon.XVC(1).FIFO_MODE.TMS_VECTOR.rd_data;
  FIFO_MISO(3).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(3).rd_data_valid <= Mon.XVC(1).FIFO_MODE.TMS_VECTOR.rd_data_valid;

  FIFO_MISO(3).rd_error <= Mon.XVC(1).FIFO_MODE.TMS_VECTOR.rd_error;

  FIFO_MISO(3).wr_error <= Mon.XVC(1).FIFO_MODE.TMS_VECTOR.wr_error;

  FIFO_MISO(4).rd_data(32-1 downto 0) <= Mon.XVC(2).FIFO_MODE.TMS_VECTOR.rd_data;
  FIFO_MISO(4).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(4).rd_data_valid <= Mon.XVC(2).FIFO_MODE.TMS_VECTOR.rd_data_valid;

  FIFO_MISO(4).rd_error <= Mon.XVC(2).FIFO_MODE.TMS_VECTOR.rd_error;

  FIFO_MISO(4).wr_error <= Mon.XVC(2).FIFO_MODE.TMS_VECTOR.wr_error;

  FIFO_MISO(5).rd_data(32-1 downto 0) <= Mon.XVC(3).FIFO_MODE.TMS_VECTOR.rd_data;
  FIFO_MISO(5).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(5).rd_data_valid <= Mon.XVC(3).FIFO_MODE.TMS_VECTOR.rd_data_valid;

  FIFO_MISO(5).rd_error <= Mon.XVC(3).FIFO_MODE.TMS_VECTOR.rd_error;

  FIFO_MISO(5).wr_error <= Mon.XVC(3).FIFO_MODE.TMS_VECTOR.wr_error;

  FIFO_MISO(6).rd_data(32-1 downto 0) <= Mon.XVC(1).FIFO_MODE.TDI_VECTOR.rd_data;
  FIFO_MISO(6).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(6).rd_data_valid <= Mon.XVC(1).FIFO_MODE.TDI_VECTOR.rd_data_valid;

  FIFO_MISO(6).rd_error <= Mon.XVC(1).FIFO_MODE.TDI_VECTOR.rd_error;

  FIFO_MISO(6).wr_error <= Mon.XVC(1).FIFO_MODE.TDI_VECTOR.wr_error;

  FIFO_MISO(7).rd_data(32-1 downto 0) <= Mon.XVC(2).FIFO_MODE.TDI_VECTOR.rd_data;
  FIFO_MISO(7).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(7).rd_data_valid <= Mon.XVC(2).FIFO_MODE.TDI_VECTOR.rd_data_valid;

  FIFO_MISO(7).rd_error <= Mon.XVC(2).FIFO_MODE.TDI_VECTOR.rd_error;

  FIFO_MISO(7).wr_error <= Mon.XVC(2).FIFO_MODE.TDI_VECTOR.wr_error;

  FIFO_MISO(8).rd_data(32-1 downto 0) <= Mon.XVC(3).FIFO_MODE.TDI_VECTOR.rd_data;
  FIFO_MISO(8).rd_data(31 downto 32) <= (others => '0');
  FIFO_MISO(8).rd_data_valid <= Mon.XVC(3).FIFO_MODE.TDI_VECTOR.rd_data_valid;

  FIFO_MISO(8).rd_error <= Mon.XVC(3).FIFO_MODE.TDI_VECTOR.rd_error;

  FIFO_MISO(8).wr_error <= Mon.XVC(3).FIFO_MODE.TDI_VECTOR.wr_error;



  FIFO_writes: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_write: process (clk_axi,reset_axi_n) is
    begin  -- process FIFO_reads
      if reset_axi_n = '0' then
        FIFO_MOSI(iFIFO).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        FIFO_MOSI(iFIFO).wr_enable   <= '0';
        if localAddress(5 downto FIFO_range(iFIFO)) = FIFO_addr(iFIFO)(5 downto FIFO_range(iFIFO)) then
          FIFO_MOSI(iFIFO).wr_enable   <= localWrEn;
        end if;
      end if;
    end process FIFO_write;
  end generate FIFO_writes;



end architecture behavioral;