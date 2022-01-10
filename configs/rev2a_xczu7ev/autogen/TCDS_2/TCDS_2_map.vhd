--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.TCDS_2_Ctrl.all;

entity TCDS_2_map is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  TCDS_2_Mon_t;
    Ctrl             : out TCDS_2_Ctrl_t
    );
end entity TCDS_2_map;
architecture behavioral of TCDS_2_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 563);
  constant Default_reg_data : slv32_array_t(integer range 0 to 563) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(9 downto 0))) is

        when 0 => --0x0
          localRdData( 0)            <=  Mon.TCDS_2.hw_cfg.has_spy_registers;                        --
          localRdData( 1)            <=  Mon.TCDS_2.hw_cfg.has_link_test_mode;                       --
        when 8 => --0x8
          localRdData( 0)            <=  reg_data( 8)( 0);                                           --
        when 9 => --0x9
          localRdData( 0)            <=  reg_data( 9)( 0);                                           --
          localRdData( 1)            <=  reg_data( 9)( 1);                                           --
        when 12 => --0xc
          localRdData( 0)            <=  Mon.TCDS_2.link_test.status.prbs_chk_error;                 --
          localRdData( 1)            <=  Mon.TCDS_2.link_test.status.prbs_chk_locked;                --
        when 13 => --0xd
          localRdData(31 downto  0)  <=  Mon.TCDS_2.link_test.status.prbs_chk_unlock_counter;        --
        when 14 => --0xe
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.link_test.status.prbs_gen_o_hint;                --
          localRdData(15 downto  8)  <=  Mon.TCDS_2.link_test.status.prbs_chk_i_hint;                --
          localRdData(23 downto 16)  <=  Mon.TCDS_2.link_test.status.prbs_chk_o_hint;                --
        when 64 => --0x40
          localRdData( 0)            <=  reg_data(64)( 0);                                           --
          localRdData( 4)            <=  reg_data(64)( 4);                                           --Direct full (i.e., both TX and RX) reset of the MGT. Only enabled when the TCLink channel controller is disabled (i.e., control.tclink_channel_ctrl_enable is low).
          localRdData( 5)            <=  reg_data(64)( 5);                                           --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData( 6)            <=  reg_data(64)( 6);                                           --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData( 7)            <=  reg_data(64)( 7);                                           --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData( 8)            <=  reg_data(64)( 8);                                           --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData(12)            <=  reg_data(64)(12);                                           --Resets the TCLink channel controller.
          localRdData(13)            <=  reg_data(64)(13);                                           --Enables/disables the TCLink channel controller.
          localRdData(14)            <=  reg_data(64)(14);                                           --When high: tells the TCLink channel controller to use the 'gentle' instead of the 'full' reset procedure. The 'gentle' procedure does not reset the MGT QUAD PLLs, whereas the 'full' procedure does.
          localRdData(16)            <=  reg_data(64)(16);                                           --When high: activates the TCLink phase stabilisation.
        when 65 => --0x41
          localRdData(31 downto  0)  <=  reg_data(65)(31 downto  0);                                 --Lower 32 bits of status.tclink_phase_offset.
        when 66 => --0x42
          localRdData(15 downto  0)  <=  reg_data(66)(15 downto  0);                                 --Upper 16 bits of status.tclink_phase_offset.
        when 67 => --0x43
          localRdData( 9 downto  0)  <=  reg_data(67)( 9 downto  0);                                 --
          localRdData(10)            <=  reg_data(67)(10);                                           --
          localRdData(18 downto 16)  <=  reg_data(67)(18 downto 16);                                 --
          localRdData(19)            <=  reg_data(67)(19);                                           --
          localRdData(30 downto 24)  <=  reg_data(67)(30 downto 24);                                 --
          localRdData(31)            <=  reg_data(67)(31);                                           --
        when 68 => --0x44
          localRdData( 0)            <=  reg_data(68)( 0);                                           --Choice of MGT mode: 1: LPM, 0: DFE.
          localRdData( 1)            <=  reg_data(68)( 1);                                           --Reset to be strobed after changing MGT RXmode (LPM/DFE).
        when 69 => --0x45
          localRdData( 4)            <=  reg_data(69)( 4);                                           --
          localRdData( 5)            <=  reg_data(69)( 5);                                           --
          localRdData( 6)            <=  reg_data(69)( 6);                                           --
          localRdData( 7)            <=  reg_data(69)( 7);                                           --
        when 70 => --0x46
          localRdData( 8)            <=  reg_data(70)( 8);                                           --
          localRdData( 9)            <=  reg_data(70)( 9);                                           --
          localRdData(10)            <=  reg_data(70)(10);                                           --
          localRdData(11)            <=  reg_data(70)(11);                                           --
          localRdData(12)            <=  reg_data(70)(12);                                           --
        when 71 => --0x47
          localRdData( 0)            <=  reg_data(71)( 0);                                           --Reset of the lpGBT FEC monitoring.
        when 72 => --0x48
          localRdData(15 downto  0)  <=  reg_data(72)(15 downto  0);                                 --
        when 73 => --0x49
          localRdData(11 downto  0)  <=  reg_data(73)(11 downto  0);                                 --
        when 74 => --0x4a
          localRdData(31 downto  0)  <=  reg_data(74)(31 downto  0);                                 --
        when 75 => --0x4b
          localRdData(15 downto  0)  <=  reg_data(75)(15 downto  0);                                 --
        when 76 => --0x4c
          localRdData(31 downto  0)  <=  reg_data(76)(31 downto  0);                                 --
        when 77 => --0x4d
          localRdData(15 downto  0)  <=  reg_data(77)(15 downto  0);                                 --
        when 78 => --0x4e
          localRdData( 3 downto  0)  <=  reg_data(78)( 3 downto  0);                                 --
          localRdData( 4)            <=  reg_data(78)( 4);                                           --
          localRdData(11 downto  8)  <=  reg_data(78)(11 downto  8);                                 --
        when 79 => --0x4f
          localRdData(31 downto 16)  <=  reg_data(79)(31 downto 16);                                 --
        when 80 => --0x50
          localRdData( 0)            <=  reg_data(80)( 0);                                           --
        when 81 => --0x51
          localRdData(31 downto  0)  <=  reg_data(81)(31 downto  0);                                 --
        when 82 => --0x52
          localRdData(15 downto  0)  <=  reg_data(82)(15 downto  0);                                 --
        when 96 => --0x60
          localRdData( 0)            <=  Mon.TCDS_2.csr.status.is_link_optical;                      --
          localRdData( 1)            <=  Mon.TCDS_2.csr.status.is_link_speed_10g;                    --
          localRdData( 2)            <=  Mon.TCDS_2.csr.status.is_leader;                            --
          localRdData( 3)            <=  Mon.TCDS_2.csr.status.is_quad_leader;                       --
          localRdData( 4)            <=  Mon.TCDS_2.csr.status.is_mgt_rx_mode_lpm;                   --
        when 97 => --0x61
          localRdData( 0)            <=  Mon.TCDS_2.csr.status.mmcm_locked;                          --
          localRdData( 1)            <=  Mon.TCDS_2.csr.status.mgt_power_good;                       --
          localRdData( 4)            <=  Mon.TCDS_2.csr.status.mgt_tx_pll_locked;                    --
          localRdData( 5)            <=  Mon.TCDS_2.csr.status.mgt_rx_pll_locked;                    --
          localRdData( 8)            <=  Mon.TCDS_2.csr.status.mgt_reset_tx_done;                    --
          localRdData( 9)            <=  Mon.TCDS_2.csr.status.mgt_reset_rx_done;                    --
          localRdData(12)            <=  Mon.TCDS_2.csr.status.mgt_tx_ready;                         --
          localRdData(13)            <=  Mon.TCDS_2.csr.status.mgt_rx_ready;                         --
          localRdData(14)            <=  Mon.TCDS_2.csr.status.cdc40_tx_ready;                       --
          localRdData(15)            <=  Mon.TCDS_2.csr.status.cdc40_rx_ready;                       --
          localRdData(16)            <=  Mon.TCDS_2.csr.status.rx_data_not_idle;                     --
          localRdData(17)            <=  Mon.TCDS_2.csr.status.rx_frame_locked;                      --
          localRdData(18)            <=  Mon.TCDS_2.csr.status.tx_user_data_ready;                   --
          localRdData(19)            <=  Mon.TCDS_2.csr.status.rx_user_data_ready;                   --
          localRdData(20)            <=  Mon.TCDS_2.csr.status.tclink_ready;                         --
        when 98 => --0x62
          localRdData(30 downto  0)  <=  Mon.TCDS_2.csr.status.initializer_fsm_state;                --
          localRdData(31)            <=  Mon.TCDS_2.csr.status.initializer_fsm_running;              --
        when 99 => --0x63
          localRdData(31 downto  0)  <=  Mon.TCDS_2.csr.status.rx_frame_unlock_counter;              --
        when 100 => --0x64
          localRdData( 9 downto  0)  <=  Mon.TCDS_2.csr.status.phase_cdc40_tx_measured;              --
          localRdData(18 downto 16)  <=  Mon.TCDS_2.csr.status.phase_cdc40_rx_measured;              --
          localRdData(30 downto 24)  <=  Mon.TCDS_2.csr.status.phase_pi_tx_measured;                 --
        when 101 => --0x65
          localRdData( 0)            <=  Mon.TCDS_2.csr.status.fec_correction_applied;               --Latched flag indicating that the link is not error-free.
        when 102 => --0x66
          localRdData( 0)            <=  Mon.TCDS_2.csr.status.tclink_loop_closed;                   --High if the TCLink control loop is closed (i.e. configured as closed and not internally opened due to issues).
          localRdData( 1)            <=  Mon.TCDS_2.csr.status.tclink_operation_error;               --High if the TCLink encountered a DCO error during operation.
        when 103 => --0x67
          localRdData(31 downto  0)  <=  Mon.TCDS_2.csr.status.tclink_phase_measured;                --Phase value measured by the TCLink. Signed two's complement number. Conversion to ps: DDMTD_UNIT / navg * value.
        when 104 => --0x68
          localRdData(31 downto  0)  <=  Mon.TCDS_2.csr.status.tclink_phase_error.lo;                --
        when 105 => --0x69
          localRdData(15 downto  0)  <=  Mon.TCDS_2.csr.status.tclink_phase_error.hi;                --
        when 256 => --0x100
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word0;                              --
        when 257 => --0x101
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word1;                              --
        when 258 => --0x102
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word2;                              --
        when 259 => --0x103
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word3;                              --
        when 260 => --0x104
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word4;                              --
        when 261 => --0x105
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word5;                              --
        when 262 => --0x106
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word6;                              --
        when 263 => --0x107
          localRdData( 9 downto  0)  <=  Mon.TCDS_2.spy_frame_tx.word7;                              --
        when 272 => --0x110
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word0;                              --
        when 273 => --0x111
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word1;                              --
        when 274 => --0x112
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word2;                              --
        when 275 => --0x113
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word3;                              --
        when 276 => --0x114
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word4;                              --
        when 277 => --0x115
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word5;                              --
        when 278 => --0x116
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word6;                              --
        when 279 => --0x117
          localRdData( 9 downto  0)  <=  Mon.TCDS_2.spy_frame_rx.word7;                              --
        when 288 => --0x120
          localRdData( 0)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.physics;              --
          localRdData( 1)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.calibration;          --
          localRdData( 2)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.random;               --
          localRdData( 3)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.software;             --
          localRdData( 4)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_4;           --
          localRdData( 5)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_5;           --
          localRdData( 6)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_6;           --
          localRdData( 7)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_7;           --
          localRdData( 8)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_8;           --
          localRdData( 9)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_9;           --
          localRdData(10)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_10;          --
          localRdData(11)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_11;          --
          localRdData(12)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_12;          --
          localRdData(13)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_13;          --
          localRdData(14)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_14;          --
          localRdData(15)            <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_15;          --
        when 289 => --0x121
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.physics_subtype;      --
        when 290 => --0x122
          localRdData(15 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel0.bril_trigger_info;             --
        when 291 => --0x123
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel0.timing_and_sync_info.lo;       --
        when 292 => --0x124
          localRdData(16 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel0.timing_and_sync_info.hi;       --
        when 293 => --0x125
          localRdData( 4 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel0.status_info;                   --
        when 294 => --0x126
          localRdData(17 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel0.reserved;                      --
        when 304 => --0x130
          localRdData( 0)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.physics;              --
          localRdData( 1)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.calibration;          --
          localRdData( 2)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.random;               --
          localRdData( 3)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.software;             --
          localRdData( 4)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_4;           --
          localRdData( 5)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_5;           --
          localRdData( 6)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_6;           --
          localRdData( 7)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_7;           --
          localRdData( 8)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_8;           --
          localRdData( 9)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_9;           --
          localRdData(10)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_10;          --
          localRdData(11)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_11;          --
          localRdData(12)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_12;          --
          localRdData(13)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_13;          --
          localRdData(14)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_14;          --
          localRdData(15)            <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_15;          --
        when 305 => --0x131
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.physics_subtype;      --
        when 306 => --0x132
          localRdData(15 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel1.bril_trigger_info;             --
        when 307 => --0x133
          localRdData(31 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel1.timing_and_sync_info.lo;       --
        when 308 => --0x134
          localRdData(16 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel1.timing_and_sync_info.hi;       --
        when 309 => --0x135
          localRdData( 4 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel1.status_info;                   --
        when 310 => --0x136
          localRdData(17 downto  0)  <=  Mon.TCDS_2.spy_ttc2_channel1.reserved;                      --
        when 320 => --0x140
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_0;                       --
        when 321 => --0x141
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_1;                       --
        when 322 => --0x142
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_2;                       --
        when 323 => --0x143
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_3;                       --
        when 324 => --0x144
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_4;                       --
        when 325 => --0x145
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_5;                       --
        when 326 => --0x146
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_6;                       --
        when 327 => --0x147
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_7;                       --
        when 328 => --0x148
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_8;                       --
        when 329 => --0x149
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_9;                       --
        when 330 => --0x14a
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_10;                      --
        when 331 => --0x14b
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_11;                      --
        when 332 => --0x14c
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_12;                      --
        when 333 => --0x14d
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel0.value_13;                      --
        when 336 => --0x150
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_0;                       --
        when 337 => --0x151
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_1;                       --
        when 338 => --0x152
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_2;                       --
        when 339 => --0x153
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_3;                       --
        when 340 => --0x154
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_4;                       --
        when 341 => --0x155
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_5;                       --
        when 342 => --0x156
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_6;                       --
        when 343 => --0x157
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_7;                       --
        when 344 => --0x158
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_8;                       --
        when 345 => --0x159
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_9;                       --
        when 346 => --0x15a
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_10;                      --
        when 347 => --0x15b
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_11;                      --
        when 348 => --0x15c
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_12;                      --
        when 349 => --0x15d
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.spy_tts2_channel1.value_13;                      --
        when 514 => --0x202
          localRdData( 0)            <=  Mon.LTCDS(1).STATUS.RESET_RX_CDR_STABLE;                    --
          localRdData( 1)            <=  Mon.LTCDS(1).STATUS.RESET_TX_DONE;                          --
          localRdData( 2)            <=  Mon.LTCDS(1).STATUS.RESET_RX_DONE;                          --
          localRdData( 8)            <=  Mon.LTCDS(1).STATUS.USERCLK_TX_ACTIVE;                      --
          localRdData( 9)            <=  Mon.LTCDS(1).STATUS.USERCLK_RX_ACTIVE;                      --
          localRdData(16)            <=  Mon.LTCDS(1).STATUS.GT_POWER_GOOD;                          --
          localRdData(17)            <=  Mon.LTCDS(1).STATUS.RX_BYTE_ISALIGNED;                      --
          localRdData(18)            <=  Mon.LTCDS(1).STATUS.RX_BYTE_REALIGN;                        --
          localRdData(19)            <=  Mon.LTCDS(1).STATUS.RX_COMMADET;                            --
          localRdData(20)            <=  Mon.LTCDS(1).STATUS.RX_PMA_RESET_DONE;                      --
          localRdData(21)            <=  Mon.LTCDS(1).STATUS.TX_PMA_RESET_DONE;                      --
        when 528 => --0x210
          localRdData(15 downto  0)  <=  reg_data(528)(15 downto  0);                                --
          localRdData(31 downto 16)  <=  reg_data(528)(31 downto 16);                                --
        when 529 => --0x211
          localRdData( 7 downto  0)  <=  reg_data(529)( 7 downto  0);                                --
        when 530 => --0x212
          localRdData(15 downto  0)  <=  Mon.LTCDS(1).RX.CTRL0;                                      --
          localRdData(31 downto 16)  <=  Mon.LTCDS(1).RX.CTRL1;                                      --
        when 531 => --0x213
          localRdData( 7 downto  0)  <=  Mon.LTCDS(1).RX.CTRL2;                                      --
          localRdData(15 downto  8)  <=  Mon.LTCDS(1).RX.CTRL3;                                      --
        when 546 => --0x222
          localRdData( 0)            <=  Mon.LTCDS(2).STATUS.RESET_RX_CDR_STABLE;                    --
          localRdData( 1)            <=  Mon.LTCDS(2).STATUS.RESET_TX_DONE;                          --
          localRdData( 2)            <=  Mon.LTCDS(2).STATUS.RESET_RX_DONE;                          --
          localRdData( 8)            <=  Mon.LTCDS(2).STATUS.USERCLK_TX_ACTIVE;                      --
          localRdData( 9)            <=  Mon.LTCDS(2).STATUS.USERCLK_RX_ACTIVE;                      --
          localRdData(16)            <=  Mon.LTCDS(2).STATUS.GT_POWER_GOOD;                          --
          localRdData(17)            <=  Mon.LTCDS(2).STATUS.RX_BYTE_ISALIGNED;                      --
          localRdData(18)            <=  Mon.LTCDS(2).STATUS.RX_BYTE_REALIGN;                        --
          localRdData(19)            <=  Mon.LTCDS(2).STATUS.RX_COMMADET;                            --
          localRdData(20)            <=  Mon.LTCDS(2).STATUS.RX_PMA_RESET_DONE;                      --
          localRdData(21)            <=  Mon.LTCDS(2).STATUS.TX_PMA_RESET_DONE;                      --
        when 560 => --0x230
          localRdData(15 downto  0)  <=  reg_data(560)(15 downto  0);                                --
          localRdData(31 downto 16)  <=  reg_data(560)(31 downto 16);                                --
        when 561 => --0x231
          localRdData( 7 downto  0)  <=  reg_data(561)( 7 downto  0);                                --
        when 562 => --0x232
          localRdData(15 downto  0)  <=  Mon.LTCDS(2).RX.CTRL0;                                      --
          localRdData(31 downto 16)  <=  Mon.LTCDS(2).RX.CTRL1;                                      --
        when 563 => --0x233
          localRdData( 7 downto  0)  <=  Mon.LTCDS(2).RX.CTRL2;                                      --
          localRdData(15 downto  8)  <=  Mon.LTCDS(2).RX.CTRL3;                                      --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.TCDS_2.link_test.control.link_test_mode                   <=  reg_data( 8)( 0);                
  Ctrl.TCDS_2.link_test.control.prbs_gen_reset                   <=  reg_data( 9)( 0);                
  Ctrl.TCDS_2.link_test.control.prbs_chk_reset                   <=  reg_data( 9)( 1);                
  Ctrl.TCDS_2.csr.control.reset_all                              <=  reg_data(64)( 0);                
  Ctrl.TCDS_2.csr.control.mgt_reset_all                          <=  reg_data(64)( 4);                
  Ctrl.TCDS_2.csr.control.mgt_reset_tx_pll_and_datapath          <=  reg_data(64)( 5);                
  Ctrl.TCDS_2.csr.control.mgt_reset_tx_datapath                  <=  reg_data(64)( 6);                
  Ctrl.TCDS_2.csr.control.mgt_reset_rx_pll_and_datapath          <=  reg_data(64)( 7);                
  Ctrl.TCDS_2.csr.control.mgt_reset_rx_datapath                  <=  reg_data(64)( 8);                
  Ctrl.TCDS_2.csr.control.tclink_channel_ctrl_reset              <=  reg_data(64)(12);                
  Ctrl.TCDS_2.csr.control.tclink_channel_ctrl_enable             <=  reg_data(64)(13);                
  Ctrl.TCDS_2.csr.control.tclink_channel_ctrl_gentle             <=  reg_data(64)(14);                
  Ctrl.TCDS_2.csr.control.tclink_close_loop                      <=  reg_data(64)(16);                
  Ctrl.TCDS_2.csr.control.tclink_phase_offset.lo                 <=  reg_data(65)(31 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_phase_offset.hi                 <=  reg_data(66)(15 downto  0);      
  Ctrl.TCDS_2.csr.control.phase_cdc40_tx_calib                   <=  reg_data(67)( 9 downto  0);      
  Ctrl.TCDS_2.csr.control.phase_cdc40_tx_force                   <=  reg_data(67)(10);                
  Ctrl.TCDS_2.csr.control.phase_cdc40_rx_calib                   <=  reg_data(67)(18 downto 16);      
  Ctrl.TCDS_2.csr.control.phase_cdc40_rx_force                   <=  reg_data(67)(19);                
  Ctrl.TCDS_2.csr.control.phase_pi_tx_calib                      <=  reg_data(67)(30 downto 24);      
  Ctrl.TCDS_2.csr.control.phase_pi_tx_force                      <=  reg_data(67)(31);                
  Ctrl.TCDS_2.csr.control.mgt_rx_dfe_vs_lpm                      <=  reg_data(68)( 0);                
  Ctrl.TCDS_2.csr.control.mgt_rx_dfe_vs_lpm_reset                <=  reg_data(68)( 1);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmgcovrden      <=  reg_data(69)( 4);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmhfovrden      <=  reg_data(69)( 5);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmlfklovrden    <=  reg_data(69)( 6);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmosovrden      <=  reg_data(69)( 7);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxosovrden         <=  reg_data(70)( 8);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfeagcovrden     <=  reg_data(70)( 9);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfelfovrden      <=  reg_data(70)(10);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfeutovrden      <=  reg_data(70)(11);                
  Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfevpovrden      <=  reg_data(70)(12);                
  Ctrl.TCDS_2.csr.control.fec_monitor_reset                      <=  reg_data(71)( 0);                
  Ctrl.TCDS_2.csr.control.tclink_param_metastability_deglitch    <=  reg_data(72)(15 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_phase_detector_navg       <=  reg_data(73)(11 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_modulo_carrier_period.lo  <=  reg_data(74)(31 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_modulo_carrier_period.hi  <=  reg_data(75)(15 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_master_rx_ui_period.lo    <=  reg_data(76)(31 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_master_rx_ui_period.hi    <=  reg_data(77)(15 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_aie                       <=  reg_data(78)( 3 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_aie_enable                <=  reg_data(78)( 4);                
  Ctrl.TCDS_2.csr.control.tclink_param_ape                       <=  reg_data(78)(11 downto  8);      
  Ctrl.TCDS_2.csr.control.tclink_param_sigma_delta_clk_div       <=  reg_data(79)(31 downto 16);      
  Ctrl.TCDS_2.csr.control.tclink_param_enable_mirror             <=  reg_data(80)( 0);                
  Ctrl.TCDS_2.csr.control.tclink_param_adco.lo                   <=  reg_data(81)(31 downto  0);      
  Ctrl.TCDS_2.csr.control.tclink_param_adco.hi                   <=  reg_data(82)(15 downto  0);      
  Ctrl.LTCDS(1).TX.CTRL0                                         <=  reg_data(528)(15 downto  0);     
  Ctrl.LTCDS(1).TX.CTRL1                                         <=  reg_data(528)(31 downto 16);     
  Ctrl.LTCDS(1).TX.CTRL2                                         <=  reg_data(529)( 7 downto  0);     
  Ctrl.LTCDS(2).TX.CTRL0                                         <=  reg_data(560)(15 downto  0);     
  Ctrl.LTCDS(2).TX.CTRL1                                         <=  reg_data(560)(31 downto 16);     
  Ctrl.LTCDS(2).TX.CTRL2                                         <=  reg_data(561)( 7 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 8)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.link_test.control.link_test_mode;
      reg_data( 9)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.link_test.control.prbs_gen_reset;
      reg_data( 9)( 1)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.link_test.control.prbs_chk_reset;
      reg_data(64)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.reset_all;
      reg_data(64)( 4)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_reset_all;
      reg_data(64)( 5)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_reset_tx_pll_and_datapath;
      reg_data(64)( 6)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_reset_tx_datapath;
      reg_data(64)( 7)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_reset_rx_pll_and_datapath;
      reg_data(64)( 8)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_reset_rx_datapath;
      reg_data(64)(12)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_channel_ctrl_reset;
      reg_data(64)(13)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_channel_ctrl_enable;
      reg_data(64)(14)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_channel_ctrl_gentle;
      reg_data(64)(16)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_close_loop;
      reg_data(65)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_phase_offset.lo;
      reg_data(66)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_phase_offset.hi;
      reg_data(67)( 9 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.phase_cdc40_tx_calib;
      reg_data(67)(10)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.phase_cdc40_tx_force;
      reg_data(67)(18 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.phase_cdc40_rx_calib;
      reg_data(67)(19)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.phase_cdc40_rx_force;
      reg_data(67)(30 downto 24)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.phase_pi_tx_calib;
      reg_data(67)(31)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.phase_pi_tx_force;
      reg_data(68)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rx_dfe_vs_lpm;
      reg_data(68)( 1)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rx_dfe_vs_lpm_reset;
      reg_data(69)( 4)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmgcovrden;
      reg_data(69)( 5)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmhfovrden;
      reg_data(69)( 6)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmlfklovrden;
      reg_data(69)( 7)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmosovrden;
      reg_data(70)( 8)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxosovrden;
      reg_data(70)( 9)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfeagcovrden;
      reg_data(70)(10)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfelfovrden;
      reg_data(70)(11)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfeutovrden;
      reg_data(70)(12)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfevpovrden;
      reg_data(71)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.fec_monitor_reset;
      reg_data(72)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_metastability_deglitch;
      reg_data(73)(11 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_phase_detector_navg;
      reg_data(74)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_modulo_carrier_period.lo;
      reg_data(75)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_modulo_carrier_period.hi;
      reg_data(76)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_master_rx_ui_period.lo;
      reg_data(77)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_master_rx_ui_period.hi;
      reg_data(78)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_aie;
      reg_data(78)( 4)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_aie_enable;
      reg_data(78)(11 downto  8)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_ape;
      reg_data(79)(31 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_sigma_delta_clk_div;
      reg_data(80)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_enable_mirror;
      reg_data(81)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_adco.lo;
      reg_data(82)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.csr.control.tclink_param_adco.hi;
      reg_data(512)( 0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.RESET_ALL;
      reg_data(512)( 4)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.TX_PLL_AND_DATAPATH;
      reg_data(512)( 5)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.TX_DATAPATH;
      reg_data(512)( 6)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.RX_PLL_AND_DATAPATH;
      reg_data(512)( 7)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.RX_DATAPATH;
      reg_data(512)( 8)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.USERCLK_TX;
      reg_data(512)( 9)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.USERCLK_RX;
      reg_data(528)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).TX.CTRL0;
      reg_data(528)(31 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).TX.CTRL1;
      reg_data(529)( 7 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).TX.CTRL2;
      reg_data(544)( 0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.RESET_ALL;
      reg_data(544)( 4)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.TX_PLL_AND_DATAPATH;
      reg_data(544)( 5)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.TX_DATAPATH;
      reg_data(544)( 6)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.RX_PLL_AND_DATAPATH;
      reg_data(544)( 7)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.RX_DATAPATH;
      reg_data(544)( 8)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.USERCLK_TX;
      reg_data(544)( 9)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.USERCLK_RX;
      reg_data(560)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).TX.CTRL0;
      reg_data(560)(31 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).TX.CTRL1;
      reg_data(561)( 7 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).TX.CTRL2;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.LTCDS(1).RESET.RESET_ALL <= '0';
      Ctrl.LTCDS(1).RESET.TX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.TX_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.RX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.RX_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.USERCLK_TX <= '0';
      Ctrl.LTCDS(1).RESET.USERCLK_RX <= '0';
      Ctrl.LTCDS(2).RESET.RESET_ALL <= '0';
      Ctrl.LTCDS(2).RESET.TX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.TX_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.RX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.RX_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.USERCLK_TX <= '0';
      Ctrl.LTCDS(2).RESET.USERCLK_RX <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(9 downto 0))) is
        when 8 => --0x8
          reg_data( 8)( 0)                         <=  localWrData( 0);                --
        when 9 => --0x9
          reg_data( 9)( 0)                         <=  localWrData( 0);                --
          reg_data( 9)( 1)                         <=  localWrData( 1);                --
        when 64 => --0x40
          reg_data(64)( 0)                         <=  localWrData( 0);                --
          reg_data(64)( 4)                         <=  localWrData( 4);                --Direct full (i.e., both TX and RX) reset of the MGT. Only enabled when the TCLink channel controller is disabled (i.e., control.tclink_channel_ctrl_enable is low).
          reg_data(64)( 5)                         <=  localWrData( 5);                --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)( 6)                         <=  localWrData( 6);                --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)( 7)                         <=  localWrData( 7);                --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)( 8)                         <=  localWrData( 8);                --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)(12)                         <=  localWrData(12);                --Resets the TCLink channel controller.
          reg_data(64)(13)                         <=  localWrData(13);                --Enables/disables the TCLink channel controller.
          reg_data(64)(14)                         <=  localWrData(14);                --When high: tells the TCLink channel controller to use the 'gentle' instead of the 'full' reset procedure. The 'gentle' procedure does not reset the MGT QUAD PLLs, whereas the 'full' procedure does.
          reg_data(64)(16)                         <=  localWrData(16);                --When high: activates the TCLink phase stabilisation.
        when 65 => --0x41
          reg_data(65)(31 downto  0)               <=  localWrData(31 downto  0);      --Lower 32 bits of status.tclink_phase_offset.
        when 66 => --0x42
          reg_data(66)(15 downto  0)               <=  localWrData(15 downto  0);      --Upper 16 bits of status.tclink_phase_offset.
        when 67 => --0x43
          reg_data(67)( 9 downto  0)               <=  localWrData( 9 downto  0);      --
          reg_data(67)(10)                         <=  localWrData(10);                --
          reg_data(67)(18 downto 16)               <=  localWrData(18 downto 16);      --
          reg_data(67)(19)                         <=  localWrData(19);                --
          reg_data(67)(30 downto 24)               <=  localWrData(30 downto 24);      --
          reg_data(67)(31)                         <=  localWrData(31);                --
        when 68 => --0x44
          reg_data(68)( 0)                         <=  localWrData( 0);                --Choice of MGT mode: 1: LPM, 0: DFE.
          reg_data(68)( 1)                         <=  localWrData( 1);                --Reset to be strobed after changing MGT RXmode (LPM/DFE).
        when 69 => --0x45
          reg_data(69)( 4)                         <=  localWrData( 4);                --
          reg_data(69)( 5)                         <=  localWrData( 5);                --
          reg_data(69)( 6)                         <=  localWrData( 6);                --
          reg_data(69)( 7)                         <=  localWrData( 7);                --
        when 70 => --0x46
          reg_data(70)( 8)                         <=  localWrData( 8);                --
          reg_data(70)( 9)                         <=  localWrData( 9);                --
          reg_data(70)(10)                         <=  localWrData(10);                --
          reg_data(70)(11)                         <=  localWrData(11);                --
          reg_data(70)(12)                         <=  localWrData(12);                --
        when 71 => --0x47
          reg_data(71)( 0)                         <=  localWrData( 0);                --Reset of the lpGBT FEC monitoring.
        when 72 => --0x48
          reg_data(72)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 73 => --0x49
          reg_data(73)(11 downto  0)               <=  localWrData(11 downto  0);      --
        when 74 => --0x4a
          reg_data(74)(31 downto  0)               <=  localWrData(31 downto  0);      --
        when 75 => --0x4b
          reg_data(75)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 76 => --0x4c
          reg_data(76)(31 downto  0)               <=  localWrData(31 downto  0);      --
        when 77 => --0x4d
          reg_data(77)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 78 => --0x4e
          reg_data(78)( 3 downto  0)               <=  localWrData( 3 downto  0);      --
          reg_data(78)( 4)                         <=  localWrData( 4);                --
          reg_data(78)(11 downto  8)               <=  localWrData(11 downto  8);      --
        when 79 => --0x4f
          reg_data(79)(31 downto 16)               <=  localWrData(31 downto 16);      --
        when 80 => --0x50
          reg_data(80)( 0)                         <=  localWrData( 0);                --
        when 81 => --0x51
          reg_data(81)(31 downto  0)               <=  localWrData(31 downto  0);      --
        when 82 => --0x52
          reg_data(82)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 512 => --0x200
          Ctrl.LTCDS(1).RESET.RESET_ALL            <=  localWrData( 0);               
          Ctrl.LTCDS(1).RESET.TX_PLL_AND_DATAPATH  <=  localWrData( 4);               
          Ctrl.LTCDS(1).RESET.TX_DATAPATH          <=  localWrData( 5);               
          Ctrl.LTCDS(1).RESET.RX_PLL_AND_DATAPATH  <=  localWrData( 6);               
          Ctrl.LTCDS(1).RESET.RX_DATAPATH          <=  localWrData( 7);               
          Ctrl.LTCDS(1).RESET.USERCLK_TX           <=  localWrData( 8);               
          Ctrl.LTCDS(1).RESET.USERCLK_RX           <=  localWrData( 9);               
        when 528 => --0x210
          reg_data(528)(15 downto  0)              <=  localWrData(15 downto  0);      --
          reg_data(528)(31 downto 16)              <=  localWrData(31 downto 16);      --
        when 529 => --0x211
          reg_data(529)( 7 downto  0)              <=  localWrData( 7 downto  0);      --
        when 544 => --0x220
          Ctrl.LTCDS(2).RESET.RESET_ALL            <=  localWrData( 0);               
          Ctrl.LTCDS(2).RESET.TX_PLL_AND_DATAPATH  <=  localWrData( 4);               
          Ctrl.LTCDS(2).RESET.TX_DATAPATH          <=  localWrData( 5);               
          Ctrl.LTCDS(2).RESET.RX_PLL_AND_DATAPATH  <=  localWrData( 6);               
          Ctrl.LTCDS(2).RESET.RX_DATAPATH          <=  localWrData( 7);               
          Ctrl.LTCDS(2).RESET.USERCLK_TX           <=  localWrData( 8);               
          Ctrl.LTCDS(2).RESET.USERCLK_RX           <=  localWrData( 9);               
        when 560 => --0x230
          reg_data(560)(15 downto  0)              <=  localWrData(15 downto  0);      --
          reg_data(560)(31 downto 16)              <=  localWrData(31 downto 16);      --
        when 561 => --0x231
          reg_data(561)( 7 downto  0)              <=  localWrData( 7 downto  0);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;