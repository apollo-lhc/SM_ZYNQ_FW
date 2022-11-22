--======================================================================
-- Initialization/reset FSM for the TCLink.
--======================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tclink_lpgbt_pkg.all;

--==================================================

entity tclink_channel_controller is
  generic (
    g_MASTER_NSLAVE  : boolean;
    g_QUAD_LEADER    : boolean
  );
  port (
    -- The 'system clock' driving the initialization process. This
    -- should be the system clock used to drive the TCLink itself and
    -- the corresponding MGT.
    clk_sys_i : in std_logic;

    -- One always needs a way to reset.
    reset_i : in std_logic;

    -- An overall enable/disable flag.
    enable_i : in std_logic;

    -- NOTE:
    -- The recommendation is to:
    -- - always use a full reset the first time after FPGA
    --   configuration, and then
    -- - use a gentle reset for any successive intervention.
    be_gentle_i : in std_logic;

    -- Status connections from various places.
    mgt_powergood_i     : in std_logic;
    mgt_txpll_lock_i    : in std_logic;
    mgt_rxpll_lock_i    : in std_logic;
    mgt_reset_tx_done_i : in std_logic;
    mgt_reset_rx_done_i : in std_logic;
    mgt_tx_ready_i      : in std_logic;
    mgt_rx_ready_i      : in std_logic;
    rx_frame_locked_i   : in std_logic;
    mmcm_lock_i         : in std_logic;

    -- MGT resets driven by the FSM.
    mgt_reset_all_o                 : out std_logic;
    mgt_reset_tx_pll_and_datapath_o : out std_logic;
    mgt_reset_rx_pll_and_datapath_o : out std_logic;
    mgt_reset_tx_datapath_o         : out std_logic;
    mgt_reset_rx_datapath_o         : out std_logic;

    -- Status flag indicating whether or not the FMS is running.
    fsm_running_o : out std_logic;

    -- Some more detailed monitoring.
    fsm_state_o : out t_tclink_channel_controller_state_vector;

    -- Output flag indicating that all is done (or not).
    channel_ready_o : out std_logic
  );

end tclink_channel_controller;

--==================================================

architecture arch of tclink_channel_controller is

  type fsm_state_type is (
    FSM_STATE_IDLE,
    FSM_STATE_RESET_ALL,
    FSM_STATE_RESET_ALL_RELEASE,
    FSM_STATE_RESET_TX,
    FSM_STATE_RESET_TX_RELEASE,
    FSM_STATE_RESET_RX,
    FSM_STATE_RESET_RX_RELEASE,
    FSM_STATE_WAIT_FOR_MGT_POWERGOOD,
    FSM_STATE_WAIT_FOR_TX_PLL_LOCK,
    FSM_STATE_WAIT_FOR_RX_PLL_LOCK,
    FSM_STATE_WAIT_FOR_RESET_TX_DONE,
    FSM_STATE_WAIT_FOR_RESET_RX_DONE,
    FSM_STATE_WAIT_FOR_TX_READY,
    FSM_STATE_WAIT_FOR_RX_READY,
    FSM_STATE_WAIT_FOR_RX_FRAME_LOCKED,
    FSM_STATE_ALIGNED,
    FSM_STATE_WAIT_FOR_MMCM_LOCK
  );

  signal fsm_state : fsm_state_type;
  constant C_NUM_STATES : natural := fsm_state_type'pos(fsm_state_type'right) + 1;
  signal fsm_state_val : std_logic_vector(C_NUM_STATES - 1 downto 0);

  signal mgt_reset_all : std_logic;
  signal mgt_reset_tx_pll_and_datapath : std_logic;
  signal mgt_reset_rx_pll_and_datapath : std_logic;
  signal mgt_reset_tx_datapath : std_logic;
  signal mgt_reset_rx_datapath : std_logic;
  signal mgt_powergood : std_logic;
  signal mgt_txpll_lock : std_logic;
  signal mgt_rxpll_lock : std_logic;
  signal seen_mgt_txpll_unlock : std_logic;
  signal seen_mgt_rxpll_unlock : std_logic;
  signal mmcm_lock : std_logic;
  signal mgt_reset_tx_done : std_logic;
  signal mgt_reset_rx_done : std_logic;
  signal mgt_tx_ready : std_logic;
  signal mgt_rx_ready : std_logic;
  signal rx_frame_locked : std_logic;

  signal channel_ready : std_logic;

  -- 3 s at 125 MHz:
  constant C_RETRIAL_RX_RESET_CNTR_MAX : integer := 3*125000000;
  signal retrial_rx_reset_cntr : integer range 0 to C_RETRIAL_RX_RESET_CNTR_MAX;

  attribute mark_debug : string;
  attribute mark_debug of fsm_state_val : signal is "true";
  attribute mark_debug of mgt_reset_all : signal is "true";
  attribute mark_debug of mgt_reset_tx_pll_and_datapath : signal is "true";
  attribute mark_debug of mgt_reset_rx_pll_and_datapath : signal is "true";
  attribute mark_debug of mgt_reset_tx_datapath : signal is "true";
  attribute mark_debug of mgt_reset_rx_datapath : signal is "true";
  attribute mark_debug of mgt_powergood : signal is "true";
  attribute mark_debug of mgt_txpll_lock : signal is "true";
  attribute mark_debug of mgt_rxpll_lock : signal is "true";
  attribute mark_debug of seen_mgt_txpll_unlock : signal is "true";
  attribute mark_debug of seen_mgt_rxpll_unlock : signal is "true";
  attribute mark_debug of mmcm_lock : signal is "true";
  attribute mark_debug of mgt_reset_tx_done : signal is "true";
  attribute mark_debug of mgt_reset_rx_done : signal is "true";
  attribute mark_debug of mgt_tx_ready : signal is "true";
  attribute mark_debug of mgt_rx_ready : signal is "true";
  attribute mark_debug of rx_frame_locked : signal is "true";
  attribute mark_debug of channel_ready : signal is "true";

  ------------------------------------------

begin

  mgt_powergood     <= mgt_powergood_i;
  mgt_txpll_lock    <= mgt_txpll_lock_i;
  mgt_rxpll_lock    <= mgt_rxpll_lock_i;
  mgt_reset_tx_done <= mgt_reset_tx_done_i;
  mgt_reset_rx_done <= mgt_reset_rx_done_i;
  mgt_tx_ready      <= mgt_tx_ready_i;
  mgt_rx_ready      <= mgt_rx_ready_i;
  rx_frame_locked   <= rx_frame_locked_i;
  mmcm_lock         <= mmcm_lock_i;

  ------------

  fsm : process(clk_sys_i) is
  begin

    if rising_edge(clk_sys_i) then

      fsm_state <= fsm_state;
      mgt_reset_all <= mgt_reset_all;
      mgt_reset_tx_pll_and_datapath <= mgt_reset_tx_pll_and_datapath;
      mgt_reset_rx_pll_and_datapath <= mgt_reset_rx_pll_and_datapath;
      mgt_reset_tx_datapath <= mgt_reset_tx_datapath;
      mgt_reset_rx_datapath <= mgt_reset_rx_datapath;
      seen_mgt_txpll_unlock <= seen_mgt_txpll_unlock;
      seen_mgt_rxpll_unlock <= seen_mgt_rxpll_unlock;
      retrial_rx_reset_cntr <= retrial_rx_reset_cntr;
      channel_ready <= '0';

      if reset_i = '1' then
        fsm_state <= FSM_STATE_IDLE;
      elsif enable_i = '0' then
        fsm_state <= fsm_state;
      else
        case fsm_state is

          when FSM_STATE_IDLE =>
            mgt_reset_all <= '0';
            mgt_reset_tx_pll_and_datapath <= '0';
            mgt_reset_rx_pll_and_datapath <= '0';
            mgt_reset_tx_datapath <= '0';
            mgt_reset_rx_datapath <= '0';
            seen_mgt_txpll_unlock <= '0';
            seen_mgt_rxpll_unlock <= '0';
            retrial_rx_reset_cntr <= 0;

            channel_ready <= '0';
            fsm_state <= FSM_STATE_WAIT_FOR_MGT_POWERGOOD;

          ------------

          when FSM_STATE_WAIT_FOR_MGT_POWERGOOD =>
            if mgt_powergood = '1' then
              if g_QUAD_LEADER and be_gentle_i = '0' then
                fsm_state <= FSM_STATE_RESET_ALL;
              else
                fsm_state <= FSM_STATE_WAIT_FOR_TX_PLL_LOCK;
              end if;
            end if;

          ------------

          when FSM_STATE_RESET_ALL =>
            -- The MGT 'reset all' triggers on the falling edge if
            -- this mgt_reset_all.
            mgt_reset_all <= '1';
            seen_mgt_txpll_unlock <= '0';
            seen_mgt_rxpll_unlock <= '0';
            fsm_state <= FSM_STATE_RESET_ALL_RELEASE;

          ------------

          when FSM_STATE_RESET_ALL_RELEASE =>
            -- The MGT 'reset all' triggers on the falling edge if
            -- this mgt_reset_all.
            mgt_reset_all <= '0';
            -- Wait for the reset to take effect.
            -- As the MGT 'reset all' is activated in the falling
            -- edge, the condition of both PLL to be unlocked at the
            -- same time is not necessarily true at the slave as the
            -- PLLs are separated and one can lock faster than the
            -- other. Therefore a 'memory' scheme is used to check
            -- both PLLs were seen unlocked.
            if mgt_txpll_lock = '0' then
              seen_mgt_txpll_unlock <= '1';
            end if;
            if mgt_rxpll_lock = '0' then
              seen_mgt_rxpll_unlock <= '1';
            end if;

            if seen_mgt_txpll_unlock = '1' and seen_mgt_rxpll_unlock = '1' then
              fsm_state <= FSM_STATE_WAIT_FOR_TX_PLL_LOCK;
            end if;

          ------------

          when FSM_STATE_WAIT_FOR_TX_PLL_LOCK =>
            if mgt_txpll_lock = '1' then
              fsm_state <= FSM_STATE_WAIT_FOR_RX_PLL_LOCK;
            end if;

          ------------

          when FSM_STATE_WAIT_FOR_RX_PLL_LOCK =>
            if mgt_txpll_lock = '1' then
              if g_MASTER_NSLAVE then
                fsm_state <= FSM_STATE_RESET_TX;
              else
                fsm_state <= FSM_STATE_RESET_RX;
              end if;
            end if;

          ------------

          when FSM_STATE_RESET_TX =>
            -- The MGT 'reset TX xxxx' is active as long as
            -- mgt_reset_tx_xxxx is kept high, but the PLL resets seem
            -- to be triggered by the falling edge of this signal.
            if g_QUAD_LEADER and be_gentle_i = '0' then
              mgt_reset_tx_pll_and_datapath <= '1';
            else
              mgt_reset_tx_datapath <= '1';
            end if;
            -- Wait for the reset to take effect.
            if mgt_reset_tx_done = '0' then
              fsm_state <= FSM_STATE_RESET_TX_RELEASE;
            end if;

          ------------

          when FSM_STATE_RESET_TX_RELEASE =>
            -- The MGT 'reset TX xxxx' is active as long as
            -- mgt_reset_tx_xxxx is kept high, but the PLL resets seem
            -- to be triggered by the falling edge of this signal.
            mgt_reset_tx_pll_and_datapath <= '0';
            mgt_reset_tx_datapath <= '0';
            fsm_state <= FSM_STATE_WAIT_FOR_RESET_TX_DONE;

          ------------

          when FSM_STATE_WAIT_FOR_RESET_TX_DONE =>
            if mgt_reset_tx_done = '1' then
              fsm_state <= FSM_STATE_WAIT_FOR_TX_READY;
            end if;

          ------------

          when FSM_STATE_WAIT_FOR_TX_READY =>
            if mgt_tx_ready = '1' then
              if g_MASTER_NSLAVE then
                fsm_state <= FSM_STATE_RESET_RX;
              else
                fsm_state <= FSM_STATE_ALIGNED;
              end if;
            end if;

          ------------

          when FSM_STATE_RESET_RX =>
            -- The MGT 'reset RX xxxx' is active as long as
            -- mgt_reset_rx_xxxx is kept high, but the PLL resets seem
            -- to be triggered by the falling edge of this signal.
            if not g_MASTER_NSLAVE and g_QUAD_LEADER and be_gentle_i = '0' then
              mgt_reset_rx_pll_and_datapath <= '1';
            else
              mgt_reset_rx_datapath <= '1';
            end if;

            -- Wait for the reset to take effect.
            if mgt_reset_rx_done = '0' then
              fsm_state <= FSM_STATE_RESET_RX_RELEASE;
            end if;

          ------------

          when FSM_STATE_RESET_RX_RELEASE =>
            -- The MGT 'reset RX xxxx' is active as long as
            -- mgt_reset_rx_xxxx is kept high, but the PLL resets seem
            -- to be triggered by the falling edge of this signal.
            mgt_reset_rx_pll_and_datapath <= '0';
            mgt_reset_rx_datapath <= '0';
            fsm_state <= FSM_STATE_WAIT_FOR_RESET_RX_DONE;
            retrial_rx_reset_cntr <= 0;

          ------------

          when FSM_STATE_WAIT_FOR_RESET_RX_DONE =>
            if mgt_reset_rx_done = '1' then
                fsm_state <= FSM_STATE_WAIT_FOR_RX_READY;
            end if;

          ------------

          when FSM_STATE_WAIT_FOR_RX_READY =>
            if mgt_rx_ready = '1' then
              fsm_state <= FSM_STATE_WAIT_FOR_RX_FRAME_LOCKED;
            end if;

          ------------

          when FSM_STATE_WAIT_FOR_RX_FRAME_LOCKED =>
            if rx_frame_locked = '1' then
              if g_MASTER_NSLAVE then
                fsm_state <= FSM_STATE_WAIT_FOR_MMCM_LOCK;
              else
                fsm_state <= FSM_STATE_RESET_TX;
              end if;
            elsif retrial_rx_reset_cntr = C_RETRIAL_RX_RESET_CNTR_MAX then
              fsm_state <= FSM_STATE_RESET_RX;
            end if;

            retrial_rx_reset_cntr <= retrial_rx_reset_cntr + 1;

          ------------

          when FSM_STATE_WAIT_FOR_MMCM_LOCK =>
            if mmcm_lock = '1' then
              fsm_state <= FSM_STATE_ALIGNED;
            end if;

          ------------

          when FSM_STATE_ALIGNED =>
            channel_ready <= '1';
            -- NOTE: The target state choices of the following 'link
            -- loss' conditions are relatively delicate. This is most
            -- clear in the case of a 'master' TCLink, distributing
            -- the clock to a 'slave' TCLink. If the link from slave
            -- to master gets upset and the RX frame unlocks on the
            -- master side, resetting the MGT (TX side) would only
            -- make matters worse by glitching the clock on the slave
            -- side.
            -- The reset/re-align approach is as follows:
            -- - If the MGT power goes bad, we have to start from the
            --   beginning.
            -- - If MGT TX goes bad (in any way), let's go back to the
            --   TX reset part.
            -- - If MGT RX goes bad (in any way), let's go back to the
            --   RX reset part.
            -- - If the RX frame simply unlocks (without the MGT RX
            --   going bad), let's wait for it to re-lock by itself.
            -- - If only the MMCM unlocks, let's not touch the link
            --   itself but just wait for the MMCM to re-lock. (And of
            --   course this only matters for the master.)
            if mgt_powergood = '0' then
              fsm_state <= FSM_STATE_WAIT_FOR_MGT_POWERGOOD;
            elsif mgt_txpll_lock = '0'
              or mgt_reset_tx_done = '0'
              or mgt_tx_ready = '0' then
              fsm_state <= FSM_STATE_WAIT_FOR_TX_PLL_LOCK;
            elsif mgt_rxpll_lock = '0'
              or mgt_reset_rx_done = '0'
              or mgt_rx_ready = '0' then
              fsm_state <= FSM_STATE_WAIT_FOR_RX_PLL_LOCK;
            elsif rx_frame_locked = '0' then
              fsm_state <= FSM_STATE_WAIT_FOR_RX_FRAME_LOCKED;
            elsif (mmcm_lock = '0') and g_MASTER_NSLAVE then
              fsm_state <= FSM_STATE_WAIT_FOR_MMCM_LOCK;
            end if;

          ------------

          -- Just in case...
          when others =>
            fsm_state <= FSM_STATE_IDLE;

        end case;

      end if;
    end if;

  end process;

  fsm_state_val <= std_logic_vector(to_unsigned(1, fsm_state_val'length) sll fsm_state_type'pos(fsm_state));

  ------------------------------------------

  mgt_reset_all_o <= mgt_reset_all;
  mgt_reset_tx_pll_and_datapath_o <= mgt_reset_tx_pll_and_datapath;
  mgt_reset_rx_pll_and_datapath_o <= mgt_reset_rx_pll_and_datapath;
  mgt_reset_tx_datapath_o <= mgt_reset_tx_datapath;
  mgt_reset_rx_datapath_o <= mgt_reset_rx_datapath;

  fsm_running_o <= enable_i;
  fsm_state_o <= fsm_state_val;
  channel_ready_o <= channel_ready;

end arch;

--======================================================================
