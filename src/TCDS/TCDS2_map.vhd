--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.TCDS2_Ctrl.all;
entity TCDS2_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  TCDS2_Mon_t;
    Ctrl             : out TCDS2_Ctrl_t
    );
end entity TCDS2_interface;
architecture behavioral of TCDS2_interface is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 173);
  constant Default_reg_data : slv32_array_t(integer range 0 to 173) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(7 downto 0))) is

        when 171 => --0xab
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_11;                      --
        when 172 => --0xac
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_12;                      --
        when 173 => --0xad
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_13;                      --
        when 144 => --0x90
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_0;                       --
        when 145 => --0x91
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_1;                       --
        when 146 => --0x92
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_2;                       --
        when 147 => --0x93
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_3;                       --
        when 148 => --0x94
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_4;                       --
        when 149 => --0x95
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_5;                       --
        when 150 => --0x96
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_6;                       --
        when 151 => --0x97
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_7;                       --
        when 152 => --0x98
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_8;                       --
        when 153 => --0x99
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_9;                       --
        when 154 => --0x9a
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_10;                      --
        when 155 => --0x9b
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_11;                      --
        when 156 => --0x9c
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_12;                      --
        when 157 => --0x9d
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel0.value_13;                      --
        when 32 => --0x20
          localRdData( 0)            <=  reg_data(32)( 0);                                          --
          localRdData( 1)            <=  reg_data(32)( 1);                                          --
          localRdData( 2)            <=  reg_data(32)( 2);                                          --
          localRdData( 3)            <=  reg_data(32)( 3);                                          --
        when 33 => --0x21
          localRdData( 0)            <=  reg_data(33)( 0);                                          --
          localRdData( 1)            <=  reg_data(33)( 1);                                          --
        when 162 => --0xa2
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_2;                       --
        when 163 => --0xa3
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_3;                       --
        when 164 => --0xa4
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_4;                       --
        when 165 => --0xa5
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_5;                       --
        when 166 => --0xa6
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_6;                       --
        when 167 => --0xa7
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_7;                       --
        when 40 => --0x28
          localRdData( 0)            <=  Mon.TCDS2.csr.status.has_spy_registers;                    --
          localRdData( 1)            <=  Mon.TCDS2.csr.status.is_link_speed_10g;                    --
          localRdData( 2)            <=  Mon.TCDS2.csr.status.has_link_test_mode;                   --
        when 41 => --0x29
          localRdData( 0)            <=  Mon.TCDS2.csr.status.mgt_power_good;                       --
          localRdData( 1)            <=  Mon.TCDS2.csr.status.mgt_tx_pll_lock;                      --
          localRdData( 2)            <=  Mon.TCDS2.csr.status.mgt_rx_pll_lock;                      --
          localRdData( 3)            <=  Mon.TCDS2.csr.status.mgt_reset_tx_done;                    --
          localRdData( 4)            <=  Mon.TCDS2.csr.status.mgt_reset_rx_done;                    --
          localRdData( 5)            <=  Mon.TCDS2.csr.status.mgt_tx_ready;                         --
          localRdData( 6)            <=  Mon.TCDS2.csr.status.mgt_rx_ready;                         --
          localRdData( 7)            <=  Mon.TCDS2.csr.status.rx_frame_locked;                      --
        when 42 => --0x2a
          localRdData(31 downto  0)  <=  Mon.TCDS2.csr.status.rx_frame_unlock_counter;              --
        when 43 => --0x2b
          localRdData( 1)            <=  Mon.TCDS2.csr.status.prbs_chk_error;                       --
          localRdData( 2)            <=  Mon.TCDS2.csr.status.prbs_chk_locked;                      --
        when 44 => --0x2c
          localRdData(31 downto  0)  <=  Mon.TCDS2.csr.status.prbs_chk_unlock_counter;              --
        when 45 => --0x2d
          localRdData( 7 downto  0)  <=  Mon.TCDS2.csr.status.prbs_gen_o_hint;                      --
          localRdData(15 downto  8)  <=  Mon.TCDS2.csr.status.prbs_chk_i_hint;                      --
          localRdData(23 downto 16)  <=  Mon.TCDS2.csr.status.prbs_chk_o_hint;                      --
        when 168 => --0xa8
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_8;                       --
        when 64 => --0x40
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word0;                              --
        when 65 => --0x41
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word1;                              --
        when 66 => --0x42
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word2;                              --
        when 67 => --0x43
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word3;                              --
        when 68 => --0x44
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word4;                              --
        when 69 => --0x45
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word5;                              --
        when 70 => --0x46
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word6;                              --
        when 71 => --0x47
          localRdData( 9 downto  0)  <=  Mon.TCDS2.spy_frame_tx.word7;                              --
        when 160 => --0xa0
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_0;                       --
        when 80 => --0x50
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word0;                              --
        when 81 => --0x51
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word1;                              --
        when 82 => --0x52
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word2;                              --
        when 83 => --0x53
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word3;                              --
        when 84 => --0x54
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word4;                              --
        when 85 => --0x55
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word5;                              --
        when 86 => --0x56
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word6;                              --
        when 87 => --0x57
          localRdData( 9 downto  0)  <=  Mon.TCDS2.spy_frame_rx.word7;                              --
        when 96 => --0x60
          localRdData( 0)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.physics;              --
          localRdData( 1)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.calibration;          --
          localRdData( 2)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.random;               --
          localRdData( 3)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.software;             --
          localRdData( 4)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_4;           --
          localRdData( 5)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_5;           --
          localRdData( 6)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_6;           --
          localRdData( 7)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_7;           --
          localRdData( 8)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_8;           --
          localRdData( 9)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_9;           --
          localRdData(10)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_10;          --
          localRdData(11)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_11;          --
          localRdData(12)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_12;          --
          localRdData(13)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_13;          --
          localRdData(14)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_14;          --
          localRdData(15)            <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.reserved_15;          --
        when 97 => --0x61
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel0.l1a_info.physics_subtype;      --
        when 98 => --0x62
          localRdData(15 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel0.bril_trigger_info;             --
        when 99 => --0x63
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel0.timing_and_sync_info.lo;       --
        when 100 => --0x64
          localRdData(16 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel0.timing_and_sync_info.hi;       --
        when 101 => --0x65
          localRdData( 4 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel0.status_info;                   --
        when 102 => --0x66
          localRdData(17 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel0.reserved;                      --
        when 161 => --0xa1
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_1;                       --
        when 112 => --0x70
          localRdData( 0)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.physics;              --
          localRdData( 1)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.calibration;          --
          localRdData( 2)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.random;               --
          localRdData( 3)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.software;             --
          localRdData( 4)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_4;           --
          localRdData( 5)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_5;           --
          localRdData( 6)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_6;           --
          localRdData( 7)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_7;           --
          localRdData( 8)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_8;           --
          localRdData( 9)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_9;           --
          localRdData(10)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_10;          --
          localRdData(11)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_11;          --
          localRdData(12)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_12;          --
          localRdData(13)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_13;          --
          localRdData(14)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_14;          --
          localRdData(15)            <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.reserved_15;          --
        when 113 => --0x71
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel1.l1a_info.physics_subtype;      --
        when 114 => --0x72
          localRdData(15 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel1.bril_trigger_info;             --
        when 115 => --0x73
          localRdData(31 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel1.timing_and_sync_info.lo;       --
        when 116 => --0x74
          localRdData(16 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel1.timing_and_sync_info.hi;       --
        when 117 => --0x75
          localRdData( 4 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel1.status_info;                   --
        when 118 => --0x76
          localRdData(17 downto  0)  <=  Mon.TCDS2.spy_ttc2_channel1.reserved;                      --
        when 169 => --0xa9
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_9;                       --
        when 170 => --0xaa
          localRdData( 7 downto  0)  <=  Mon.TCDS2.spy_tts2_channel1.value_10;                      --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.TCDS2.csr.control.mgt_reset_all   <=  reg_data(32)( 0);     
  Ctrl.TCDS2.csr.control.mgt_reset_tx    <=  reg_data(32)( 1);     
  Ctrl.TCDS2.csr.control.mgt_reset_rx    <=  reg_data(32)( 2);     
  Ctrl.TCDS2.csr.control.link_test_mode  <=  reg_data(32)( 3);     
  Ctrl.TCDS2.csr.control.prbs_gen_reset  <=  reg_data(33)( 0);     
  Ctrl.TCDS2.csr.control.prbs_chk_reset  <=  reg_data(33)( 1);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data(32)( 0)  <= DEFAULT_TCDS2_CTRL_t.TCDS2.csr.control.mgt_reset_all;
      reg_data(32)( 1)  <= DEFAULT_TCDS2_CTRL_t.TCDS2.csr.control.mgt_reset_tx;
      reg_data(32)( 2)  <= DEFAULT_TCDS2_CTRL_t.TCDS2.csr.control.mgt_reset_rx;
      reg_data(32)( 3)  <= DEFAULT_TCDS2_CTRL_t.TCDS2.csr.control.link_test_mode;
      reg_data(33)( 0)  <= DEFAULT_TCDS2_CTRL_t.TCDS2.csr.control.prbs_gen_reset;
      reg_data(33)( 1)  <= DEFAULT_TCDS2_CTRL_t.TCDS2.csr.control.prbs_chk_reset;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(7 downto 0))) is
        when 32 => --0x20
          reg_data(32)( 0)  <=  localWrData( 0);      --
          reg_data(32)( 1)  <=  localWrData( 1);      --
          reg_data(32)( 2)  <=  localWrData( 2);      --
          reg_data(32)( 3)  <=  localWrData( 3);      --
        when 33 => --0x21
          reg_data(33)( 0)  <=  localWrData( 0);      --
          reg_data(33)( 1)  <=  localWrData( 1);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;