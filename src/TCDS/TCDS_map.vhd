--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.TCDS_Ctrl.all;
entity TCDS_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  TCDS_Mon_t;
    Ctrl             : out TCDS_Ctrl_t
    );
end entity TCDS_interface;
architecture behavioral of TCDS_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 4615);
  constant Default_reg_data : slv32_array_t(integer range 0 to 4615) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(12 downto 0))) is

        when 0 => --0x0
          localRdData( 4)            <=  Mon.LINK0.CLOCKING.FB_CLK_LOST;      --
          localRdData( 5)            <=  Mon.LINK0.CLOCKING.CLK_LOCKED;       --
        when 1 => --0x1
          localRdData( 0)            <=  reg_data( 1)( 0);                    --
        when 2 => --0x2
          localRdData(31 downto  0)  <=  reg_data( 2)(31 downto  0);          --
        when 3 => --0x3
          localRdData(31 downto  0)  <=  Mon.LINK0.TEST2;                     --
        when 4100 => --0x1004
          localRdData(31 downto  0)  <=  Mon.CTRL0.CAPTURE_D;                 --
        when 4101 => --0x1005
          localRdData( 3 downto  0)  <=  Mon.CTRL0.CAPTURE_K;                 --
        when 520 => --0x208
          localRdData( 2 downto  0)  <=  reg_data(520)( 2 downto  0);         --
        when 257 => --0x101
          localRdData( 0)            <=  reg_data(257)( 0);                   --
        when 8 => --0x8
          localRdData( 2 downto  0)  <=  reg_data( 8)( 2 downto  0);          --
        when 9 => --0x9
          localRdData( 7 downto  0)  <=  Mon.LINK0.DMONITOR;                  --
        when 533 => --0x215
          localRdData(31 downto  0)  <=  Mon.LINK2.RX.DISP_ERR_COUNT;         --
        when 258 => --0x102
          localRdData(31 downto  0)  <=  reg_data(258)(31 downto  0);         --
        when 256 => --0x100
          localRdData( 4)            <=  Mon.LINK1.CLOCKING.FB_CLK_LOST;      --
          localRdData( 5)            <=  Mon.LINK1.CLOCKING.CLK_LOCKED;       --
        when 16 => --0x10
          localRdData( 0)            <=  reg_data(16)( 0);                    --
          localRdData( 1)            <=  Mon.LINK0.RX.RESET_DONE;             --
          localRdData(18 downto 12)  <=  Mon.LINK0.RX.MONITOR;                --
        when 17 => --0x11
          localRdData( 2 downto  0)  <=  reg_data(17)( 2 downto  0);          --
          localRdData( 4)            <=  reg_data(17)( 4);                    --
          localRdData( 5)            <=  reg_data(17)( 5);                    --
          localRdData( 9 downto  8)  <=  reg_data(17)( 9 downto  8);          --
        when 18 => --0x12
          localRdData( 0)            <=  reg_data(18)( 0);                    --
          localRdData( 1)            <=  reg_data(18)( 1);                    --
        when 19 => --0x13
          localRdData(31 downto  0)  <=  Mon.LINK0.RX.PRBS_ERR_COUNT;         --
        when 20 => --0x14
          localRdData(31 downto  0)  <=  Mon.LINK0.RX.BAD_CHAR_COUNT;         --
        when 21 => --0x15
          localRdData(31 downto  0)  <=  Mon.LINK0.RX.DISP_ERR_COUNT;         --
        when 512 => --0x200
          localRdData( 4)            <=  Mon.LINK2.CLOCKING.FB_CLK_LOST;      --
          localRdData( 5)            <=  Mon.LINK2.CLOCKING.CLK_LOCKED;       --
        when 4356 => --0x1104
          localRdData(31 downto  0)  <=  Mon.CTRL1.CAPTURE_D;                 --
        when 4610 => --0x1202
          localRdData( 3 downto  0)  <=  reg_data(4610)( 3 downto  0);        --
        when 4357 => --0x1105
          localRdData( 3 downto  0)  <=  Mon.CTRL1.CAPTURE_K;                 --
        when 32 => --0x20
          localRdData( 1)            <=  Mon.LINK0.TX.RESET_DONE;             --
        when 33 => --0x21
          localRdData( 2 downto  0)  <=  reg_data(33)( 2 downto  0);          --
          localRdData( 4)            <=  reg_data(33)( 4);                    --
          localRdData( 5)            <=  reg_data(33)( 5);                    --
        when 34 => --0x22
          localRdData( 6)            <=  reg_data(34)( 6);                    --
        when 521 => --0x209
          localRdData( 7 downto  0)  <=  Mon.LINK2.DMONITOR;                  --
        when 4102 => --0x1006
          localRdData(31 downto  0)  <=  reg_data(4102)(31 downto  0);        --
        when 305 => --0x131
          localRdData( 0)            <=  reg_data(305)( 0);                   --
        when 4103 => --0x1007
          localRdData( 3 downto  0)  <=  reg_data(4103)( 3 downto  0);        --
        when 4613 => --0x1205
          localRdData( 3 downto  0)  <=  Mon.CTRL2.CAPTURE_K;                 --
        when 304 => --0x130
          localRdData( 0)            <=  Mon.LINK1.EYESCAN.DATA_ERROR;        --
        when 48 => --0x30
          localRdData( 0)            <=  Mon.LINK0.EYESCAN.DATA_ERROR;        --
        when 49 => --0x31
          localRdData( 0)            <=  reg_data(49)( 0);                    --
        when 530 => --0x212
          localRdData( 0)            <=  reg_data(530)( 0);                   --
          localRdData( 1)            <=  reg_data(530)( 1);                   --
        when 513 => --0x201
          localRdData( 0)            <=  reg_data(513)( 0);                   --
        when 265 => --0x109
          localRdData( 7 downto  0)  <=  Mon.LINK1.DMONITOR;                  --
        when 288 => --0x120
          localRdData( 1)            <=  Mon.LINK1.TX.RESET_DONE;             --
        when 4098 => --0x1002
          localRdData( 3 downto  0)  <=  reg_data(4098)( 3 downto  0);        --
        when 289 => --0x121
          localRdData( 2 downto  0)  <=  reg_data(289)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(289)( 4);                   --
          localRdData( 5)            <=  reg_data(289)( 5);                   --
        when 4354 => --0x1102
          localRdData( 3 downto  0)  <=  reg_data(4354)( 3 downto  0);        --
        when 4615 => --0x1207
          localRdData( 3 downto  0)  <=  reg_data(4615)( 3 downto  0);        --
        when 290 => --0x122
          localRdData( 6)            <=  reg_data(290)( 6);                   --
        when 4358 => --0x1106
          localRdData(31 downto  0)  <=  reg_data(4358)(31 downto  0);        --
        when 531 => --0x213
          localRdData(31 downto  0)  <=  Mon.LINK2.RX.PRBS_ERR_COUNT;         --
        when 514 => --0x202
          localRdData(31 downto  0)  <=  reg_data(514)(31 downto  0);         --
        when 561 => --0x231
          localRdData( 0)            <=  reg_data(561)( 0);                   --
        when 544 => --0x220
          localRdData( 1)            <=  Mon.LINK2.TX.RESET_DONE;             --
        when 546 => --0x222
          localRdData( 6)            <=  reg_data(546)( 6);                   --
        when 272 => --0x110
          localRdData( 0)            <=  reg_data(272)( 0);                   --
          localRdData( 1)            <=  Mon.LINK1.RX.RESET_DONE;             --
          localRdData(18 downto 12)  <=  Mon.LINK1.RX.MONITOR;                --
        when 4359 => --0x1107
          localRdData( 3 downto  0)  <=  reg_data(4359)( 3 downto  0);        --
        when 529 => --0x211
          localRdData( 2 downto  0)  <=  reg_data(529)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(529)( 4);                   --
          localRdData( 5)            <=  reg_data(529)( 5);                   --
          localRdData( 9 downto  8)  <=  reg_data(529)( 9 downto  8);         --
        when 273 => --0x111
          localRdData( 2 downto  0)  <=  reg_data(273)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(273)( 4);                   --
          localRdData( 5)            <=  reg_data(273)( 5);                   --
          localRdData( 9 downto  8)  <=  reg_data(273)( 9 downto  8);         --
        when 259 => --0x103
          localRdData(31 downto  0)  <=  Mon.LINK1.TEST2;                     --
        when 274 => --0x112
          localRdData( 0)            <=  reg_data(274)( 0);                   --
          localRdData( 1)            <=  reg_data(274)( 1);                   --
        when 532 => --0x214
          localRdData(31 downto  0)  <=  Mon.LINK2.RX.BAD_CHAR_COUNT;         --
        when 515 => --0x203
          localRdData(31 downto  0)  <=  Mon.LINK2.TEST2;                     --
        when 275 => --0x113
          localRdData(31 downto  0)  <=  Mon.LINK1.RX.PRBS_ERR_COUNT;         --
        when 545 => --0x221
          localRdData( 2 downto  0)  <=  reg_data(545)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(545)( 4);                   --
          localRdData( 5)            <=  reg_data(545)( 5);                   --
        when 528 => --0x210
          localRdData( 0)            <=  reg_data(528)( 0);                   --
          localRdData( 1)            <=  Mon.LINK2.RX.RESET_DONE;             --
          localRdData(18 downto 12)  <=  Mon.LINK2.RX.MONITOR;                --
        when 4614 => --0x1206
          localRdData(31 downto  0)  <=  reg_data(4614)(31 downto  0);        --
        when 4612 => --0x1204
          localRdData(31 downto  0)  <=  Mon.CTRL2.CAPTURE_D;                 --
        when 276 => --0x114
          localRdData(31 downto  0)  <=  Mon.LINK1.RX.BAD_CHAR_COUNT;         --
        when 560 => --0x230
          localRdData( 0)            <=  Mon.LINK2.EYESCAN.DATA_ERROR;        --
        when 264 => --0x108
          localRdData( 2 downto  0)  <=  reg_data(264)( 2 downto  0);         --
        when 277 => --0x115
          localRdData(31 downto  0)  <=  Mon.LINK1.RX.DISP_ERR_COUNT;         --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.LINK0.CLOCKING.RESET     <=  reg_data( 1)( 0);                 
  Ctrl.LINK0.LOOPBACK           <=  reg_data( 8)( 2 downto  0);       
  Ctrl.LINK0.TEST               <=  reg_data( 2)(31 downto  0);       
  Ctrl.LINK0.RX.COUNTER_ENABLE  <=  reg_data(16)( 0);                 
  Ctrl.LINK0.RX.RESET           <=  reg_data(18)( 0);                 
  Ctrl.LINK0.RX.PMA_RESET       <=  reg_data(18)( 1);                 
  Ctrl.LINK0.RX.PRBS_SEL        <=  reg_data(17)( 2 downto  0);       
  Ctrl.LINK0.RX.USER_READY      <=  reg_data(17)( 4);                 
  Ctrl.LINK0.RX.DFELPM_RESET    <=  reg_data(17)( 5);                 
  Ctrl.LINK0.RX.MONITOR_SEL     <=  reg_data(17)( 9 downto  8);       
  Ctrl.LINK0.TX.PRBS_SEL        <=  reg_data(33)( 2 downto  0);       
  Ctrl.LINK0.TX.INHIBIT         <=  reg_data(33)( 4);                 
  Ctrl.LINK0.TX.USER_READY      <=  reg_data(33)( 5);                 
  Ctrl.LINK0.TX.RESET           <=  reg_data(34)( 6);                 
  Ctrl.LINK0.EYESCAN.RESET      <=  reg_data(49)( 0);                 
  Ctrl.LINK1.CLOCKING.RESET     <=  reg_data(257)( 0);                
  Ctrl.LINK1.LOOPBACK           <=  reg_data(264)( 2 downto  0);      
  Ctrl.LINK1.TEST               <=  reg_data(258)(31 downto  0);      
  Ctrl.LINK1.RX.COUNTER_ENABLE  <=  reg_data(272)( 0);                
  Ctrl.LINK1.RX.RESET           <=  reg_data(274)( 0);                
  Ctrl.LINK1.RX.PMA_RESET       <=  reg_data(274)( 1);                
  Ctrl.LINK1.RX.PRBS_SEL        <=  reg_data(273)( 2 downto  0);      
  Ctrl.LINK1.RX.USER_READY      <=  reg_data(273)( 4);                
  Ctrl.LINK1.RX.DFELPM_RESET    <=  reg_data(273)( 5);                
  Ctrl.LINK1.RX.MONITOR_SEL     <=  reg_data(273)( 9 downto  8);      
  Ctrl.LINK1.TX.PRBS_SEL        <=  reg_data(289)( 2 downto  0);      
  Ctrl.LINK1.TX.INHIBIT         <=  reg_data(289)( 4);                
  Ctrl.LINK1.TX.USER_READY      <=  reg_data(289)( 5);                
  Ctrl.LINK1.TX.RESET           <=  reg_data(290)( 6);                
  Ctrl.LINK1.EYESCAN.RESET      <=  reg_data(305)( 0);                
  Ctrl.LINK2.CLOCKING.RESET     <=  reg_data(513)( 0);                
  Ctrl.LINK2.LOOPBACK           <=  reg_data(520)( 2 downto  0);      
  Ctrl.LINK2.TEST               <=  reg_data(514)(31 downto  0);      
  Ctrl.LINK2.RX.COUNTER_ENABLE  <=  reg_data(528)( 0);                
  Ctrl.LINK2.RX.RESET           <=  reg_data(530)( 0);                
  Ctrl.LINK2.RX.PMA_RESET       <=  reg_data(530)( 1);                
  Ctrl.LINK2.RX.PRBS_SEL        <=  reg_data(529)( 2 downto  0);      
  Ctrl.LINK2.RX.USER_READY      <=  reg_data(529)( 4);                
  Ctrl.LINK2.RX.DFELPM_RESET    <=  reg_data(529)( 5);                
  Ctrl.LINK2.RX.MONITOR_SEL     <=  reg_data(529)( 9 downto  8);      
  Ctrl.LINK2.TX.PRBS_SEL        <=  reg_data(545)( 2 downto  0);      
  Ctrl.LINK2.TX.INHIBIT         <=  reg_data(545)( 4);                
  Ctrl.LINK2.TX.USER_READY      <=  reg_data(545)( 5);                
  Ctrl.LINK2.TX.RESET           <=  reg_data(546)( 6);                
  Ctrl.LINK2.EYESCAN.RESET      <=  reg_data(561)( 0);                
  Ctrl.CTRL0.MODE               <=  reg_data(4098)( 3 downto  0);     
  Ctrl.CTRL0.FIXED_SEND_K       <=  reg_data(4103)( 3 downto  0);     
  Ctrl.CTRL0.FIXED_SEND_D       <=  reg_data(4102)(31 downto  0);     
  Ctrl.CTRL1.MODE               <=  reg_data(4354)( 3 downto  0);     
  Ctrl.CTRL1.FIXED_SEND_K       <=  reg_data(4359)( 3 downto  0);     
  Ctrl.CTRL1.FIXED_SEND_D       <=  reg_data(4358)(31 downto  0);     
  Ctrl.CTRL2.MODE               <=  reg_data(4610)( 3 downto  0);     
  Ctrl.CTRL2.FIXED_SEND_K       <=  reg_data(4615)( 3 downto  0);     
  Ctrl.CTRL2.FIXED_SEND_D       <=  reg_data(4614)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 1)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK0.CLOCKING.RESET;
      reg_data( 8)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK0.LOOPBACK;
      reg_data( 2)(31 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK0.TEST;
      reg_data(16)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK0.RX.COUNTER_ENABLE;
      reg_data(18)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK0.RX.RESET;
      reg_data(18)( 1)  <= DEFAULT_TCDS_CTRL_t.LINK0.RX.PMA_RESET;
      reg_data(17)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK0.RX.PRBS_SEL;
      reg_data(17)( 4)  <= DEFAULT_TCDS_CTRL_t.LINK0.RX.USER_READY;
      reg_data(17)( 5)  <= DEFAULT_TCDS_CTRL_t.LINK0.RX.DFELPM_RESET;
      reg_data(17)( 9 downto  8)  <= DEFAULT_TCDS_CTRL_t.LINK0.RX.MONITOR_SEL;
      reg_data(33)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK0.TX.PRBS_SEL;
      reg_data(33)( 4)  <= DEFAULT_TCDS_CTRL_t.LINK0.TX.INHIBIT;
      reg_data(33)( 5)  <= DEFAULT_TCDS_CTRL_t.LINK0.TX.USER_READY;
      reg_data(34)( 6)  <= DEFAULT_TCDS_CTRL_t.LINK0.TX.RESET;
      reg_data(49)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK0.EYESCAN.RESET;
      reg_data(257)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK1.CLOCKING.RESET;
      reg_data(264)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK1.LOOPBACK;
      reg_data(258)(31 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK1.TEST;
      reg_data(272)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK1.RX.COUNTER_ENABLE;
      reg_data(274)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK1.RX.RESET;
      reg_data(274)( 1)  <= DEFAULT_TCDS_CTRL_t.LINK1.RX.PMA_RESET;
      reg_data(273)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK1.RX.PRBS_SEL;
      reg_data(273)( 4)  <= DEFAULT_TCDS_CTRL_t.LINK1.RX.USER_READY;
      reg_data(273)( 5)  <= DEFAULT_TCDS_CTRL_t.LINK1.RX.DFELPM_RESET;
      reg_data(273)( 9 downto  8)  <= DEFAULT_TCDS_CTRL_t.LINK1.RX.MONITOR_SEL;
      reg_data(289)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK1.TX.PRBS_SEL;
      reg_data(289)( 4)  <= DEFAULT_TCDS_CTRL_t.LINK1.TX.INHIBIT;
      reg_data(289)( 5)  <= DEFAULT_TCDS_CTRL_t.LINK1.TX.USER_READY;
      reg_data(290)( 6)  <= DEFAULT_TCDS_CTRL_t.LINK1.TX.RESET;
      reg_data(305)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK1.EYESCAN.RESET;
      reg_data(513)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK2.CLOCKING.RESET;
      reg_data(520)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK2.LOOPBACK;
      reg_data(514)(31 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK2.TEST;
      reg_data(528)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK2.RX.COUNTER_ENABLE;
      reg_data(530)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK2.RX.RESET;
      reg_data(530)( 1)  <= DEFAULT_TCDS_CTRL_t.LINK2.RX.PMA_RESET;
      reg_data(529)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK2.RX.PRBS_SEL;
      reg_data(529)( 4)  <= DEFAULT_TCDS_CTRL_t.LINK2.RX.USER_READY;
      reg_data(529)( 5)  <= DEFAULT_TCDS_CTRL_t.LINK2.RX.DFELPM_RESET;
      reg_data(529)( 9 downto  8)  <= DEFAULT_TCDS_CTRL_t.LINK2.RX.MONITOR_SEL;
      reg_data(545)( 2 downto  0)  <= DEFAULT_TCDS_CTRL_t.LINK2.TX.PRBS_SEL;
      reg_data(545)( 4)  <= DEFAULT_TCDS_CTRL_t.LINK2.TX.INHIBIT;
      reg_data(545)( 5)  <= DEFAULT_TCDS_CTRL_t.LINK2.TX.USER_READY;
      reg_data(546)( 6)  <= DEFAULT_TCDS_CTRL_t.LINK2.TX.RESET;
      reg_data(561)( 0)  <= DEFAULT_TCDS_CTRL_t.LINK2.EYESCAN.RESET;
      reg_data(4098)( 3 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL0.MODE;
      reg_data(4103)( 3 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL0.FIXED_SEND_K;
      reg_data(4102)(31 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL0.FIXED_SEND_D;
      reg_data(4354)( 3 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL1.MODE;
      reg_data(4359)( 3 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL1.FIXED_SEND_K;
      reg_data(4358)(31 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL1.FIXED_SEND_D;
      reg_data(4610)( 3 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL2.MODE;
      reg_data(4615)( 3 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL2.FIXED_SEND_K;
      reg_data(4614)(31 downto  0)  <= DEFAULT_TCDS_CTRL_t.CTRL2.FIXED_SEND_D;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.LINK0.RX.PRBS_RESET <= '0';
      Ctrl.LINK0.TX.PRBS_FORCE_ERROR <= '0';
      Ctrl.LINK0.EYESCAN.TRIGGER <= '0';
      Ctrl.LINK1.RX.PRBS_RESET <= '0';
      Ctrl.LINK1.TX.PRBS_FORCE_ERROR <= '0';
      Ctrl.LINK1.EYESCAN.TRIGGER <= '0';
      Ctrl.LINK2.RX.PRBS_RESET <= '0';
      Ctrl.LINK2.TX.PRBS_FORCE_ERROR <= '0';
      Ctrl.LINK2.EYESCAN.TRIGGER <= '0';
      Ctrl.CTRL0.CAPTURE <= '0';
      Ctrl.CTRL1.CAPTURE <= '0';
      Ctrl.CTRL2.CAPTURE <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(12 downto 0))) is
        when 4096 => --0x1000
          Ctrl.CTRL0.CAPTURE              <=  localWrData( 0);               
        when 1 => --0x1
          reg_data( 1)( 0)                <=  localWrData( 0);                --
        when 2 => --0x2
          reg_data( 2)(31 downto  0)      <=  localWrData(31 downto  0);      --
        when 4102 => --0x1006
          reg_data(4102)(31 downto  0)    <=  localWrData(31 downto  0);      --
        when 257 => --0x101
          reg_data(257)( 0)               <=  localWrData( 0);                --
        when 520 => --0x208
          reg_data(520)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
        when 258 => --0x102
          reg_data(258)(31 downto  0)     <=  localWrData(31 downto  0);      --
        when 4352 => --0x1100
          Ctrl.CTRL1.CAPTURE              <=  localWrData( 0);               
        when 272 => --0x110
          reg_data(272)( 0)               <=  localWrData( 0);                --
        when 17 => --0x11
          Ctrl.LINK0.RX.PRBS_RESET        <=  localWrData( 3);               
          reg_data(17)( 2 downto  0)      <=  localWrData( 2 downto  0);      --
          reg_data(17)( 4)                <=  localWrData( 4);                --
          reg_data(17)( 5)                <=  localWrData( 5);                --
          reg_data(17)( 9 downto  8)      <=  localWrData( 9 downto  8);      --
        when 18 => --0x12
          reg_data(18)( 0)                <=  localWrData( 0);                --
          reg_data(18)( 1)                <=  localWrData( 1);                --
        when 546 => --0x222
          reg_data(546)( 6)               <=  localWrData( 6);                --
        when 529 => --0x211
          Ctrl.LINK2.RX.PRBS_RESET        <=  localWrData( 3);               
          reg_data(529)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(529)( 4)               <=  localWrData( 4);                --
          reg_data(529)( 5)               <=  localWrData( 5);                --
          reg_data(529)( 9 downto  8)     <=  localWrData( 9 downto  8);      --
        when 4608 => --0x1200
          Ctrl.CTRL2.CAPTURE              <=  localWrData( 0);               
        when 4610 => --0x1202
          reg_data(4610)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when 33 => --0x21
          Ctrl.LINK0.TX.PRBS_FORCE_ERROR  <=  localWrData( 3);               
          reg_data(33)( 2 downto  0)      <=  localWrData( 2 downto  0);      --
          reg_data(33)( 4)                <=  localWrData( 4);                --
          reg_data(33)( 5)                <=  localWrData( 5);                --
        when 34 => --0x22
          reg_data(34)( 6)                <=  localWrData( 6);                --
        when 4358 => --0x1106
          reg_data(4358)(31 downto  0)    <=  localWrData(31 downto  0);      --
        when 305 => --0x131
          reg_data(305)( 0)               <=  localWrData( 0);                --
          Ctrl.LINK1.EYESCAN.TRIGGER      <=  localWrData( 4);               
        when 4103 => --0x1007
          reg_data(4103)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when 49 => --0x31
          reg_data(49)( 0)                <=  localWrData( 0);                --
          Ctrl.LINK0.EYESCAN.TRIGGER      <=  localWrData( 4);               
        when 530 => --0x212
          reg_data(530)( 0)               <=  localWrData( 0);                --
          reg_data(530)( 1)               <=  localWrData( 1);                --
        when 513 => --0x201
          reg_data(513)( 0)               <=  localWrData( 0);                --
        when 4098 => --0x1002
          reg_data(4098)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when 289 => --0x121
          Ctrl.LINK1.TX.PRBS_FORCE_ERROR  <=  localWrData( 3);               
          reg_data(289)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(289)( 4)               <=  localWrData( 4);                --
          reg_data(289)( 5)               <=  localWrData( 5);                --
        when 4354 => --0x1102
          reg_data(4354)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when 290 => --0x122
          reg_data(290)( 6)               <=  localWrData( 6);                --
        when 528 => --0x210
          reg_data(528)( 0)               <=  localWrData( 0);                --
        when 514 => --0x202
          reg_data(514)(31 downto  0)     <=  localWrData(31 downto  0);      --
        when 561 => --0x231
          reg_data(561)( 0)               <=  localWrData( 0);                --
          Ctrl.LINK2.EYESCAN.TRIGGER      <=  localWrData( 4);               
        when 4359 => --0x1107
          reg_data(4359)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when 16 => --0x10
          reg_data(16)( 0)                <=  localWrData( 0);                --
        when 273 => --0x111
          Ctrl.LINK1.RX.PRBS_RESET        <=  localWrData( 3);               
          reg_data(273)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(273)( 4)               <=  localWrData( 4);                --
          reg_data(273)( 5)               <=  localWrData( 5);                --
          reg_data(273)( 9 downto  8)     <=  localWrData( 9 downto  8);      --
        when 4615 => --0x1207
          reg_data(4615)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when 274 => --0x112
          reg_data(274)( 0)               <=  localWrData( 0);                --
          reg_data(274)( 1)               <=  localWrData( 1);                --
        when 545 => --0x221
          Ctrl.LINK2.TX.PRBS_FORCE_ERROR  <=  localWrData( 3);               
          reg_data(545)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(545)( 4)               <=  localWrData( 4);                --
          reg_data(545)( 5)               <=  localWrData( 5);                --
        when 8 => --0x8
          reg_data( 8)( 2 downto  0)      <=  localWrData( 2 downto  0);      --
        when 4614 => --0x1206
          reg_data(4614)(31 downto  0)    <=  localWrData(31 downto  0);      --
        when 264 => --0x108
          reg_data(264)( 2 downto  0)     <=  localWrData( 2 downto  0);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;