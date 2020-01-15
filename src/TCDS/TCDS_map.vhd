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
      case localAddress(12 downto 0) is
        when x"0" =>
          localRdData( 4)            <=  Mon.LINK0.CLOCKING.FB_CLK_LOST;      --
          localRdData( 5)            <=  Mon.LINK0.CLOCKING.CLK_LOCKED;       --
        when x"1" =>
          localRdData( 0)            <=  reg_data( 1)( 0);                    --
        when x"1002" =>
          localRdData( 3 downto  0)  <=  reg_data(4098)( 3 downto  0);        --
        when x"1004" =>
          localRdData(31 downto  0)  <=  Mon.CTRL0.CAPTURE_D;                 --
        when x"1005" =>
          localRdData( 3 downto  0)  <=  Mon.CTRL0.CAPTURE_K;                 --
        when x"208" =>
          localRdData( 2 downto  0)  <=  reg_data(520)( 2 downto  0);         --
        when x"101" =>
          localRdData( 0)            <=  reg_data(257)( 0);                   --
        when x"8" =>
          localRdData( 2 downto  0)  <=  reg_data( 8)( 2 downto  0);          --
        when x"9" =>
          localRdData( 7 downto  0)  <=  Mon.LINK0.DMONITOR;                  --
        when x"1102" =>
          localRdData( 3 downto  0)  <=  reg_data(4354)( 3 downto  0);        --
        when x"100" =>
          localRdData( 4)            <=  Mon.LINK1.CLOCKING.FB_CLK_LOST;      --
          localRdData( 5)            <=  Mon.LINK1.CLOCKING.CLK_LOCKED;       --
        when x"10" =>
          localRdData( 0)            <=  Mon.LINK0.RX.PRBS_ERROR;             --
          localRdData( 1)            <=  Mon.LINK0.RX.RESET_DONE;             --
          localRdData( 7 downto  4)  <=  Mon.LINK0.RX.BAD_CHAR;               --
          localRdData(11 downto  8)  <=  Mon.LINK0.RX.DISP_ERROR;             --
          localRdData(18 downto 12)  <=  Mon.LINK0.RX.MONITOR;                --
        when x"11" =>
          localRdData( 2 downto  0)  <=  reg_data(17)( 2 downto  0);          --
          localRdData( 4)            <=  reg_data(17)( 4);                    --
          localRdData( 5)            <=  reg_data(17)( 5);                    --
          localRdData( 9 downto  8)  <=  reg_data(17)( 9 downto  8);          --
        when x"112" =>
          localRdData( 0)            <=  reg_data(274)( 0);                   --
          localRdData( 1)            <=  reg_data(274)( 1);                   --
        when x"222" =>
          localRdData( 6)            <=  reg_data(546)( 6);                   --
        when x"211" =>
          localRdData( 2 downto  0)  <=  reg_data(529)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(529)( 4);                   --
          localRdData( 5)            <=  reg_data(529)( 5);                   --
          localRdData( 9 downto  8)  <=  reg_data(529)( 9 downto  8);         --
        when x"200" =>
          localRdData( 4)            <=  Mon.LINK2.CLOCKING.FB_CLK_LOST;      --
          localRdData( 5)            <=  Mon.LINK2.CLOCKING.CLK_LOCKED;       --
        when x"1104" =>
          localRdData(31 downto  0)  <=  Mon.CTRL1.CAPTURE_D;                 --
        when x"1105" =>
          localRdData( 3 downto  0)  <=  Mon.CTRL1.CAPTURE_K;                 --
        when x"20" =>
          localRdData( 1)            <=  Mon.LINK0.TX.RESET_DONE;             --
        when x"21" =>
          localRdData( 2 downto  0)  <=  reg_data(33)( 2 downto  0);          --
          localRdData( 4)            <=  reg_data(33)( 4);                    --
          localRdData( 5)            <=  reg_data(33)( 5);                    --
        when x"22" =>
          localRdData( 6)            <=  reg_data(34)( 6);                    --
        when x"209" =>
          localRdData( 7 downto  0)  <=  Mon.LINK2.DMONITOR;                  --
        when x"1006" =>
          localRdData(31 downto  0)  <=  reg_data(4102)(31 downto  0);        --
        when x"131" =>
          localRdData( 0)            <=  reg_data(305)( 0);                   --
        when x"1007" =>
          localRdData( 3 downto  0)  <=  reg_data(4103)( 3 downto  0);        --
        when x"1205" =>
          localRdData( 3 downto  0)  <=  Mon.CTRL2.CAPTURE_K;                 --
        when x"130" =>
          localRdData( 0)            <=  Mon.LINK1.EYESCAN.DATA_ERROR;        --
        when x"30" =>
          localRdData( 0)            <=  Mon.LINK0.EYESCAN.DATA_ERROR;        --
        when x"31" =>
          localRdData( 0)            <=  reg_data(49)( 0);                    --
        when x"212" =>
          localRdData( 0)            <=  reg_data(530)( 0);                   --
          localRdData( 1)            <=  reg_data(530)( 1);                   --
        when x"201" =>
          localRdData( 0)            <=  reg_data(513)( 0);                   --
        when x"109" =>
          localRdData( 7 downto  0)  <=  Mon.LINK1.DMONITOR;                  --
        when x"120" =>
          localRdData( 1)            <=  Mon.LINK1.TX.RESET_DONE;             --
        when x"1106" =>
          localRdData(31 downto  0)  <=  reg_data(4358)(31 downto  0);        --
        when x"121" =>
          localRdData( 2 downto  0)  <=  reg_data(289)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(289)( 4);                   --
          localRdData( 5)            <=  reg_data(289)( 5);                   --
        when x"1206" =>
          localRdData(31 downto  0)  <=  reg_data(4614)(31 downto  0);        --
        when x"1204" =>
          localRdData(31 downto  0)  <=  Mon.CTRL2.CAPTURE_D;                 --
        when x"122" =>
          localRdData( 6)            <=  reg_data(290)( 6);                   --
        when x"1202" =>
          localRdData( 3 downto  0)  <=  reg_data(4610)( 3 downto  0);        --
        when x"231" =>
          localRdData( 0)            <=  reg_data(561)( 0);                   --
        when x"220" =>
          localRdData( 1)            <=  Mon.LINK2.TX.RESET_DONE;             --
        when x"1107" =>
          localRdData( 3 downto  0)  <=  reg_data(4359)( 3 downto  0);        --
        when x"110" =>
          localRdData( 0)            <=  Mon.LINK1.RX.PRBS_ERROR;             --
          localRdData( 1)            <=  Mon.LINK1.RX.RESET_DONE;             --
          localRdData( 7 downto  4)  <=  Mon.LINK1.RX.BAD_CHAR;               --
          localRdData(11 downto  8)  <=  Mon.LINK1.RX.DISP_ERROR;             --
          localRdData(18 downto 12)  <=  Mon.LINK1.RX.MONITOR;                --
        when x"230" =>
          localRdData( 0)            <=  Mon.LINK2.EYESCAN.DATA_ERROR;        --
        when x"111" =>
          localRdData( 2 downto  0)  <=  reg_data(273)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(273)( 4);                   --
          localRdData( 5)            <=  reg_data(273)( 5);                   --
          localRdData( 9 downto  8)  <=  reg_data(273)( 9 downto  8);         --
        when x"1207" =>
          localRdData( 3 downto  0)  <=  reg_data(4615)( 3 downto  0);        --
        when x"12" =>
          localRdData( 0)            <=  reg_data(18)( 0);                    --
          localRdData( 1)            <=  reg_data(18)( 1);                    --
        when x"221" =>
          localRdData( 2 downto  0)  <=  reg_data(545)( 2 downto  0);         --
          localRdData( 4)            <=  reg_data(545)( 4);                   --
          localRdData( 5)            <=  reg_data(545)( 5);                   --
        when x"210" =>
          localRdData( 0)            <=  Mon.LINK2.RX.PRBS_ERROR;             --
          localRdData( 1)            <=  Mon.LINK2.RX.RESET_DONE;             --
          localRdData( 7 downto  4)  <=  Mon.LINK2.RX.BAD_CHAR;               --
          localRdData(11 downto  8)  <=  Mon.LINK2.RX.DISP_ERROR;             --
          localRdData(18 downto 12)  <=  Mon.LINK2.RX.MONITOR;                --
        when x"108" =>
          localRdData( 2 downto  0)  <=  reg_data(264)( 2 downto  0);         --
        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;



  -- Register mapping to ctrl structures
  Ctrl.LINK0.CLOCKING.RESET   <=  reg_data( 1)( 0);                 
  Ctrl.LINK0.LOOPBACK         <=  reg_data( 8)( 2 downto  0);       
  Ctrl.LINK0.RX.PRBS_SEL      <=  reg_data(17)( 2 downto  0);       
  Ctrl.LINK0.RX.USER_READY    <=  reg_data(17)( 4);                 
  Ctrl.LINK0.RX.DFELPM_RESET  <=  reg_data(17)( 5);                 
  Ctrl.LINK0.RX.MONITOR_SEL   <=  reg_data(17)( 9 downto  8);       
  Ctrl.LINK0.RX.RESET         <=  reg_data(18)( 0);                 
  Ctrl.LINK0.RX.PMA_RESET     <=  reg_data(18)( 1);                 
  Ctrl.LINK0.TX.PRBS_SEL      <=  reg_data(33)( 2 downto  0);       
  Ctrl.LINK0.TX.INHIBIT       <=  reg_data(33)( 4);                 
  Ctrl.LINK0.TX.USER_READY    <=  reg_data(33)( 5);                 
  Ctrl.LINK0.TX.RESET         <=  reg_data(34)( 6);                 
  Ctrl.LINK0.EYESCAN.RESET    <=  reg_data(49)( 0);                 
  Ctrl.LINK1.CLOCKING.RESET   <=  reg_data(257)( 0);                
  Ctrl.LINK1.LOOPBACK         <=  reg_data(264)( 2 downto  0);      
  Ctrl.LINK1.RX.PRBS_SEL      <=  reg_data(273)( 2 downto  0);      
  Ctrl.LINK1.RX.USER_READY    <=  reg_data(273)( 4);                
  Ctrl.LINK1.RX.DFELPM_RESET  <=  reg_data(273)( 5);                
  Ctrl.LINK1.RX.MONITOR_SEL   <=  reg_data(273)( 9 downto  8);      
  Ctrl.LINK1.RX.RESET         <=  reg_data(274)( 0);                
  Ctrl.LINK1.RX.PMA_RESET     <=  reg_data(274)( 1);                
  Ctrl.LINK1.TX.PRBS_SEL      <=  reg_data(289)( 2 downto  0);      
  Ctrl.LINK1.TX.INHIBIT       <=  reg_data(289)( 4);                
  Ctrl.LINK1.TX.USER_READY    <=  reg_data(289)( 5);                
  Ctrl.LINK1.TX.RESET         <=  reg_data(290)( 6);                
  Ctrl.LINK1.EYESCAN.RESET    <=  reg_data(305)( 0);                
  Ctrl.LINK2.CLOCKING.RESET   <=  reg_data(513)( 0);                
  Ctrl.LINK2.LOOPBACK         <=  reg_data(520)( 2 downto  0);      
  Ctrl.LINK2.RX.PRBS_SEL      <=  reg_data(529)( 2 downto  0);      
  Ctrl.LINK2.RX.USER_READY    <=  reg_data(529)( 4);                
  Ctrl.LINK2.RX.DFELPM_RESET  <=  reg_data(529)( 5);                
  Ctrl.LINK2.RX.MONITOR_SEL   <=  reg_data(529)( 9 downto  8);      
  Ctrl.LINK2.RX.RESET         <=  reg_data(530)( 0);                
  Ctrl.LINK2.RX.PMA_RESET     <=  reg_data(530)( 1);                
  Ctrl.LINK2.TX.PRBS_SEL      <=  reg_data(545)( 2 downto  0);      
  Ctrl.LINK2.TX.INHIBIT       <=  reg_data(545)( 4);                
  Ctrl.LINK2.TX.USER_READY    <=  reg_data(545)( 5);                
  Ctrl.LINK2.TX.RESET         <=  reg_data(546)( 6);                
  Ctrl.LINK2.EYESCAN.RESET    <=  reg_data(561)( 0);                
  Ctrl.CTRL0.MODE             <=  reg_data(4098)( 3 downto  0);     
  Ctrl.CTRL0.FIXED_SEND_D     <=  reg_data(4102)(31 downto  0);     
  Ctrl.CTRL0.FIXED_SEND_K     <=  reg_data(4103)( 3 downto  0);     
  Ctrl.CTRL1.MODE             <=  reg_data(4354)( 3 downto  0);     
  Ctrl.CTRL1.FIXED_SEND_D     <=  reg_data(4358)(31 downto  0);     
  Ctrl.CTRL1.FIXED_SEND_K     <=  reg_data(4359)( 3 downto  0);     
  Ctrl.CTRL2.MODE             <=  reg_data(4610)( 3 downto  0);     
  Ctrl.CTRL2.FIXED_SEND_D     <=  reg_data(4614)(31 downto  0);     
  Ctrl.CTRL2.FIXED_SEND_K     <=  reg_data(4615)( 3 downto  0);     



  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data <= default_reg_data;
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
        case localAddress(12 downto 0) is
        when x"1000" =>
          Ctrl.CTRL0.CAPTURE              <=  localWrData( 0);               
        when x"1" =>
          reg_data( 1)( 0)                <=  localWrData( 0);                --
        when x"131" =>
          reg_data(305)( 0)               <=  localWrData( 0);                --
          Ctrl.LINK1.EYESCAN.TRIGGER      <=  localWrData( 4);               
        when x"1006" =>
          reg_data(4102)(31 downto  0)    <=  localWrData(31 downto  0);      --
        when x"101" =>
          reg_data(257)( 0)               <=  localWrData( 0);                --
        when x"208" =>
          reg_data(520)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
        when x"122" =>
          reg_data(290)( 6)               <=  localWrData( 6);                --
        when x"111" =>
          Ctrl.LINK1.RX.PRBS_RESET        <=  localWrData( 3);               
          reg_data(273)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(273)( 4)               <=  localWrData( 4);                --
          reg_data(273)( 5)               <=  localWrData( 5);                --
          reg_data(273)( 9 downto  8)     <=  localWrData( 9 downto  8);      --
        when x"1002" =>
          reg_data(4098)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when x"1100" =>
          Ctrl.CTRL1.CAPTURE              <=  localWrData( 0);               
        when x"11" =>
          Ctrl.LINK0.RX.PRBS_RESET        <=  localWrData( 3);               
          reg_data(17)( 2 downto  0)      <=  localWrData( 2 downto  0);      --
          reg_data(17)( 4)                <=  localWrData( 4);                --
          reg_data(17)( 5)                <=  localWrData( 5);                --
          reg_data(17)( 9 downto  8)      <=  localWrData( 9 downto  8);      --
        when x"112" =>
          reg_data(274)( 0)               <=  localWrData( 0);                --
          reg_data(274)( 1)               <=  localWrData( 1);                --
        when x"1200" =>
          Ctrl.CTRL2.CAPTURE              <=  localWrData( 0);               
        when x"21" =>
          Ctrl.LINK0.TX.PRBS_FORCE_ERROR  <=  localWrData( 3);               
          reg_data(33)( 2 downto  0)      <=  localWrData( 2 downto  0);      --
          reg_data(33)( 4)                <=  localWrData( 4);                --
          reg_data(33)( 5)                <=  localWrData( 5);                --
        when x"22" =>
          reg_data(34)( 6)                <=  localWrData( 6);                --
        when x"1106" =>
          reg_data(4358)(31 downto  0)    <=  localWrData(31 downto  0);      --
        when x"231" =>
          reg_data(561)( 0)               <=  localWrData( 0);                --
          Ctrl.LINK2.EYESCAN.TRIGGER      <=  localWrData( 4);               
        when x"1007" =>
          reg_data(4103)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when x"31" =>
          reg_data(49)( 0)                <=  localWrData( 0);                --
          Ctrl.LINK0.EYESCAN.TRIGGER      <=  localWrData( 4);               
        when x"212" =>
          reg_data(530)( 0)               <=  localWrData( 0);                --
          reg_data(530)( 1)               <=  localWrData( 1);                --
        when x"201" =>
          reg_data(513)( 0)               <=  localWrData( 0);                --
        when x"121" =>
          Ctrl.LINK1.TX.PRBS_FORCE_ERROR  <=  localWrData( 3);               
          reg_data(289)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(289)( 4)               <=  localWrData( 4);                --
          reg_data(289)( 5)               <=  localWrData( 5);                --
        when x"1102" =>
          reg_data(4354)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when x"222" =>
          reg_data(546)( 6)               <=  localWrData( 6);                --
        when x"1202" =>
          reg_data(4610)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when x"1107" =>
          reg_data(4359)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when x"211" =>
          Ctrl.LINK2.RX.PRBS_RESET        <=  localWrData( 3);               
          reg_data(529)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(529)( 4)               <=  localWrData( 4);                --
          reg_data(529)( 5)               <=  localWrData( 5);                --
          reg_data(529)( 9 downto  8)     <=  localWrData( 9 downto  8);      --
        when x"1207" =>
          reg_data(4615)( 3 downto  0)    <=  localWrData( 3 downto  0);      --
        when x"12" =>
          reg_data(18)( 0)                <=  localWrData( 0);                --
          reg_data(18)( 1)                <=  localWrData( 1);                --
        when x"221" =>
          Ctrl.LINK2.TX.PRBS_FORCE_ERROR  <=  localWrData( 3);               
          reg_data(545)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          reg_data(545)( 4)               <=  localWrData( 4);                --
          reg_data(545)( 5)               <=  localWrData( 5);                --
        when x"8" =>
          reg_data( 8)( 2 downto  0)      <=  localWrData( 2 downto  0);      --
        when x"1206" =>
          reg_data(4614)(31 downto  0)    <=  localWrData(31 downto  0);      --
        when x"108" =>
          reg_data(264)( 2 downto  0)     <=  localWrData( 2 downto  0);      --
          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;

end architecture behavioral;
