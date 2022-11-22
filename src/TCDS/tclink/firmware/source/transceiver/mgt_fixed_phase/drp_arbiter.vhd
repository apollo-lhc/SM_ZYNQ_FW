--==============================================================================
-- © Copyright CERN for the benefit of the TTC-PON project. All rights not
--   expressly granted are reserved.
--
--   This file is part of ttc_pon.
--
-- ttc_pon is free VHDL code: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- ttc_pon is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with ttc_pon.  If not, see <https://www.gnu.org/licenses/>.
--=============================================================================
--! @file drp_arbiter.vhd
--=============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--! Specific packages
-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, TTC-PON
-- --
-------------------------------------------------------------------------------
--
-- unit name: GTH/GTX DRP arbiter (drp_arbiter)
--
--! @brief Dynamic Reconfiguration Port arbiter for GTX/GTH-Xilinx transceivers
--! <further description>
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 31\10\2018
--! @version 1.0
--! @details
--!
--! <b>Dependencies:</b>\n
--! <Entity Name,...>
--!
--! <b>References:</b>\n
--! <reference one> \n
--! <reference two>
--!
--! <b>Modified by:</b>\n
--! Author: Eduardo Brandao de Souza Mendes
-------------------------------------------------------------------------------
--! \n\n<b>Last changes:</b>\n
--! 31\10\2018 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--============================================================================
--! Entity declaration for drp_arbiter
--============================================================================
entity drp_arbiter is
  generic(
    g_NUM_MASTER : integer := 2
    );
  port (
    -- global input signals --
    clk_i   : in std_logic;
    reset_i : in std_logic;
    --------------------------

    -- Interface to user --
    master_drpwe_i   : in  std_logic_vector(g_NUM_MASTER-1 downto 0);
    master_drpen_i   : in  std_logic_vector(g_NUM_MASTER-1 downto 0);
    master_drpaddr_i : in  std_logic_vector(10*g_NUM_MASTER-1 downto 0);
    master_drpdi_i   : in  std_logic_vector(16*g_NUM_MASTER-1 downto 0);
    master_drprdy_o  : out std_logic_vector(g_NUM_MASTER-1 downto 0);
    master_drpdo_o   : out std_logic_vector(16*g_NUM_MASTER-1 downto 0);
    -------------------------------

    -- DRP connection to GTH/GTX --
    mgt_drpwe_o   : out std_logic;
    mgt_drpen_o   : out std_logic;
    mgt_drpaddr_o : out std_logic_vector(9 downto 0);
    mgt_drpdi_o   : out std_logic_vector(15 downto 0);
    mgt_drprdy_i  : in  std_logic;
    mgt_drpdo_i   : in  std_logic_vector(15 downto 0)
    -------------------------------
    );
end entity drp_arbiter;

--============================================================================
-- ! architecture declaration
--============================================================================
architecture rtl of drp_arbiter is

  --! Signal declaration
  signal master_cntr     : integer range 0 to g_NUM_MASTER-1;  --! master select
  signal clear_req       : std_logic_vector(g_NUM_MASTER-1 downto 0);  --! clear request memory
  signal master_drprdy_r : std_logic_vector(g_NUM_MASTER-1 downto 0);  --! delay response master to avoid dead time
  signal mgt_drpdo_r     : std_logic_vector(mgt_drpdo_i'range);  --! delay response master to avoid dead time
  signal mgt_drpdo_r2    : std_logic_vector(mgt_drpdo_i'range);  --! delay response master to avoid dead time

  --! memorize DRP transaction requests
  signal drpwe_mem : std_logic_vector(g_NUM_MASTER-1 downto 0);
  signal drpen_mem : std_logic_vector(g_NUM_MASTER-1 downto 0);

  signal master_drpaddr_mem : std_logic_vector(10*g_NUM_MASTER-1 downto 0);
  signal master_drpdi_mem   : std_logic_vector(16*g_NUM_MASTER-1 downto 0);

  type   t_ARBITER_FSM is (IDLE, CHECK_REQUEST, GO_TRANS, WAIT_TRANS, CLEAR_REQUEST, NEXT_MASTER);
  signal arbiter_state : t_ARBITER_FSM;

  --! Component declaration


--============================================================================
-- architecture begin
--============================================================================
begin

  --============================================================================
  --! DRP Latch Request
  --============================================================================
  gen_request_loop : for i in 0 to g_NUM_MASTER-1 generate
    p_drp_request : process (clk_i) is
    begin  -- process p_drp_write
      if clk_i'event and clk_i = '1' then  -- rising clock edge
        if reset_i = '1' or clear_req(i) = '1' then
          drpwe_mem(i) <= '0';
          drpen_mem(i) <= '0';
        else
          if(master_drpen_i(i) = '1') then
            drpen_mem(i) <= '1';
            drpwe_mem(i) <= master_drpwe_i(i);
          end if;
        end if;
        if(master_drpen_i(i) = '1') then
          master_drpaddr_mem(10*(i+1)-1 downto 10*i) <= master_drpaddr_i(10*(i+1)-1 downto 10*i);
          master_drpdi_mem(16*(i+1)-1 downto 16*i) <= master_drpdi_i(16*(i+1)-1 downto 16*i);
        end if;
      end if;
    end process p_drp_request;
  end generate gen_request_loop;

  --============================================================================
  --! DRP acknowledgment
  --============================================================================  
  p_drp_ack : process (clk_i) is
  begin  -- process p_drp_write
    if clk_i'event and clk_i = '1' then  -- rising clock edge
      master_drprdy_o <= master_drprdy_r;
      mgt_drpdo_r2    <= mgt_drpdo_r;
      mgt_drpdo_r     <= mgt_drpdo_i;
      if(arbiter_state = WAIT_TRANS) then
        master_drprdy_r              <= (others => '0');
        master_drprdy_r(master_cntr) <= mgt_drprdy_i;
      else
        master_drprdy_r <= (others => '0');
      end if;
    end if;
  end process p_drp_ack;

  gen_drp_do : for i in 0 to g_NUM_MASTER-1 generate
    master_drpdo_o(16*(i+1)-1 downto 16*i) <= mgt_drpdo_r2;
  end generate;

  --============================================================================
  --! DRP arbiter fsm
  --============================================================================  
  p_arbiter_fsm : process(clk_i)
  begin
    if(rising_edge(clk_i)) then
      if(reset_i = '1') then
        arbiter_state <= IDLE;
      else
        case arbiter_state is
          when IDLE =>
            arbiter_state <= CHECK_REQUEST;
          when CHECK_REQUEST =>
            if(drpen_mem(master_cntr) = '1') then
              arbiter_state <= GO_TRANS;
            else
              arbiter_state <= NEXT_MASTER;
            end if;
          when GO_TRANS =>
            arbiter_state <= WAIT_TRANS;
          when WAIT_TRANS =>
            if(mgt_drprdy_i = '1') then
              arbiter_state <= CLEAR_REQUEST;
            end if;
          when CLEAR_REQUEST =>
            arbiter_state <= NEXT_MASTER;
          when NEXT_MASTER =>
            arbiter_state <= CHECK_REQUEST;
          when others =>
            arbiter_state <= IDLE;
        end case;
      end if;
    end if;
  end process p_arbiter_fsm;

  --============================================================================
  --! DRP clear request
  --============================================================================  
  p_clear_request : process(clk_i)
  begin
    if(rising_edge(clk_i)) then
      if(reset_i = '1') then
        clear_req <= (others => '0');
      else
        if(arbiter_state = CLEAR_REQUEST) then
          clear_req              <= (others => '0');
          clear_req(master_cntr) <= '1';
        else
          clear_req <= (others => '0');
        end if;
      end if;
    end if;
  end process p_clear_request;

  --============================================================================
  --! DRP master counter
  --============================================================================  
  p_master_cntr : process(clk_i)
  begin
    if(rising_edge(clk_i)) then
      if(reset_i = '1') then
        master_cntr <= 0;
      else
        if(arbiter_state = NEXT_MASTER) then
          if(master_cntr = g_NUM_MASTER-1) then
            master_cntr <= 0;
          else
            master_cntr <= master_cntr + 1;
          end if;
        end if;
      end if;
    end if;
  end process p_master_cntr;

  --============================================================================
  --! DRP generate transaction
  --============================================================================  
  p_gen_drp_transaction : process(clk_i)
  begin
    if(rising_edge(clk_i)) then
      if(reset_i = '1') then
        mgt_drpen_o   <= '0';
        mgt_drpwe_o   <= '0';
        mgt_drpaddr_o <= (others => '0');
        mgt_drpdi_o   <= (others => '0');
      else
        if(arbiter_state = GO_TRANS) then
          mgt_drpen_o   <= '1';
          mgt_drpwe_o   <= drpwe_mem(master_cntr);
          mgt_drpaddr_o <= master_drpaddr_mem(10*(master_cntr+1)-1 downto 10*master_cntr);
          mgt_drpdi_o   <= master_drpdi_mem(16*(master_cntr+1)-1 downto 16*master_cntr);
        else
          mgt_drpen_o   <= '0';
          mgt_drpwe_o   <= '0';
          mgt_drpaddr_o <= (others => '0');
          mgt_drpdi_o   <= (others => '0');
        end if;
      end if;
    end if;
  end process p_gen_drp_transaction;


  
  

end architecture rtl;
--============================================================================
-- architecture end
--============================================================================
