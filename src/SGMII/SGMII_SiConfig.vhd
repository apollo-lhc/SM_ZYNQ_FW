library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;


use work.types.all;


entity SGMII_SI_CONFIG is
  
  port (
    clk_200Mhz : in std_logic;
    reset  : in std_logic;

    SDA_i_phy    : in  std_logic;
    SDA_o_phy    : out std_logic;
    SDA_t_phy    : out std_logic;
    SCL_i_phy    : in  std_logic;
    SCL_o_phy    : out std_logic;
    SCL_t_phy    : out std_logic;
    SI_OE_N      : out std_logic;
    SI_EN        : out std_logic;
    --normal signals are from the zynq to be routed out to phy signals, so
    --opposite direction
    SDA_i_normal   : out std_logic;
    SDA_o_normal   : in  std_logic;
    SDA_t_normal   : in  std_logic;
    SCL_i_normal   : out std_logic;
    SCL_o_normal   : in  std_logic;
    SCL_t_normal   : in  std_logic;
    SI_OE_normal   : in  std_logic;
    SI_EN_normal   : in  std_logic;
    handoff        : out std_logic);

end entity SGMII_SI_CONFIG;


architecture behavioral of SGMII_SI_CONFIG is

  type SM_t is (SM_INIT,                 --INIT SiChip and local variables for
                                         --programming
                SM_WAIT,                 --Wait 300ms for soft SI reset
                SM_CONFIG_DO_WRITE,      --write current reg data
                SM_CONFIG_WRITE_WAIT,    --wait for current write to finish
                SM_FINISH,               --enable the SI ouputs
                SM_DONE                  --Give control of Si chip back to the
                                         --user
                );
  signal state : SM_t;

  constant Si_I2C_addr : slv_7_t := "1101000";-- x"68";
  signal run : std_logic;
  
  signal reg_addr : slv_12_t;
  signal reg_data : slv_8_t;
  signal write_addr : slv_8_t;
  signal write_data : slv_8_t;
  signal write_done : std_logic;
  signal   reg_counter     : integer range 0 to 511;
  constant reg_counter_end : integer range 0 to 511 := 465;--464;

--  signal wait_counter : integer;
--  constant wait_counter_start : integer := 6000000;0
  signal   wait_counter       : uint27_t := (others => '0');--unsigned("00"&x"000000");
--  constant wait_counter_start : uint26_t := "11100100111000011100000000";--unsigned("11"&x"938700");
  constant wait_counter_start : uint27_t := "111001001110000111000000000";--unsigned("11"&x"938700");
  
  signal page : slv_4_t;
  signal page_address : slv_8_t := x"01";


  signal SDA_i_SI   : std_logic;
  signal SDA_o_SI   : std_logic;
  signal SDA_t_SI   : std_logic;
  signal SCL_i_SI   : std_logic;
  signal SCL_o_SI   : std_logic;
  signal SCL_t_SI   : std_logic;

  signal init_SI_OE : std_logic;
  signal init_SI_EN : std_logic;

  
begin  -- architecture behavioral

  SGMII_SI_data_1: entity work.SGMII_SI_data
    port map (
      entry => reg_counter,
      addr  => reg_addr,
      data  => reg_data);
  
  I2C_reg_master_1: entity work.I2C_reg_master
    generic map (
--      I2C_QUARTER_PERIOD_CLOCK_COUNT => 500,
--      I2C_QUARTER_PERIOD_CLOCK_COUNT => 125,
      I2C_QUARTER_PERIOD_CLOCK_COUNT => 500,
      USE_RESTART_FOR_READ_SEQUENCE  => '0')
    port map (
      clk_sys     => clk_200Mhz,
      reset       => reset,
      I2C_Address => Si_I2C_addr,
      run         => run,
      rw          => '0',
      reg_addr    => write_addr,
      rd_data     => open,
      wr_data     => x"000000"&write_data,
      byte_count  => "001",
      done        => write_done,
      error       => open,
      SDA_i       => SDA_i_SI,
      SDA_o       => SDA_o_SI,
      SDA_t       => SDA_t_SI,
      SCL_i       => SCL_i_SI,
      SCL_o       => SCL_o_SI,
      SCL_t       => SCL_t_SI);



  state_machine: process (clk_200Mhz, reset) is
  begin  -- process state_machine
    if reset = '1' then                 -- asynchronous reset (active high)
      state <= SM_INIT;
    elsif clk_200Mhz'event and clk_200Mhz = '1' then  -- rising clock edge
      case state is
        ---------------------------------
        when SM_INIT =>
          --start configuration
          state <= SM_CONFIG_DO_WRITE;
        ---------------------------------
        when SM_WAIT =>
          if or_reduce(std_logic_vector(wait_counter)) = '0' then
            state <= SM_CONFIG_WRITE_WAIT;
          else
            state <= SM_WAIT;
          end if;
        ---------------------------------
        when SM_CONFIG_DO_WRITE =>
          --we setup a write, wait for it to finish          
          state <= SM_CONFIG_WRITE_WAIT;
        ---------------------------------
        when SM_CONFIG_WRITE_WAIT =>
          if write_done = '1' then
            --Write finished, move on to the next one.
            if or_reduce(std_logic_vector(wait_counter)) = '1' and reg_counter = 3 then
              --We need to wait after this write
              state <= SM_WAIT;
            elsif reg_counter = reg_counter_end then
              --We are done programming
              state <= SM_FINISH;
            else
              --move on to the next write
              state <= SM_CONFIG_DO_WRITE;
            end if;
          else
            -- wait.
            state <= SM_CONFIG_WRITE_WAIT;
          end if;
        ---------------------------------
        when SM_FINISH =>
          state <= SM_DONE;
        ---------------------------------     
        when SM_DONE =>
          state <= SM_DONE;
        ---------------------------------
        when others => state <= SM_INIT;
      end case;
    end if;
  end process state_machine;

  sm_proc: process (clk_200Mhz,reset) is
  begin  -- process sm_proc
    if reset = '1' then
      init_SI_OE <= '0'; -- disable SI outputs
      init_SI_EN <= '0'; -- power down SI chip      
    elsif clk_200Mhz'event and clk_200Mhz = '1' then  -- rising clock edge
      run <= '0';
      case state is
        ---------------------------------
        when SM_INIT =>
          init_SI_OE <= '0'; -- disable SI outputs
          init_SI_EN <= '1'; -- power up SI chip
          reg_counter <= 0;
          page <= x"F"; -- set inital page to invalid page
          wait_counter <= wait_counter_start; -- 300ms
        ---------------------------------
        when SM_WAIT =>
          if or_reduce(std_logic_vector(wait_counter)) = '1' then
            wait_counter <= wait_counter - 1 ;           
          end if;
        ---------------------------------
        when SM_CONFIG_DO_WRITE =>          
          if page = reg_addr(11 downto 8) then
            --We are on the correct page
            write_addr <= reg_addr(7 downto 0);
            write_data <= reg_data;
            reg_counter <= reg_counter + 1;
          else
            --We need to update the page
            write_addr <= page_address;
            write_data <= x"0"&reg_addr(11 downto 8);
            page <= reg_addr(11 downto 8);
          end if;
          run <= '1';
        ---------------------------------
--        when SM_CONFIG_WRITE_WAIT =>
--          if write_done = '1' then
--            -- move to the next register
----            wait_counter <= wait_counter_start; -- 300ms
----            reg_counter <= reg_counter + 1;
--          end if;
        ---------------------------------
        when SM_FINISH =>
          init_SI_OE <= '1'; -- enable SI outputs
        when others => null;
      end case;
    end if;
  end process sm_proc;


  swap_signals: process (state,
                         SDA_i_phy,       
                         SDA_o_normal,    
                         SDA_t_normal,    
                         SCL_i_phy,       
                         SCL_o_normal,    
                         SCL_t_normal,    
                         SI_OE_normal,
                         SI_EN_normal,
                         SDA_i_phy,     
                         SDA_o_SI,      
                         SDA_t_SI,      
                         SCL_i_phy,     
                         SCL_o_SI,      
                         SCL_t_SI,      
                         init_SI_OE,
                         init_SI_EN
                         ) is
  begin  -- process swap_signals
    if state = SM_INIT then
      SDA_i_SI <= '1';
      SCL_i_SI <= '1';
      SDA_i_normal <= '1';
      SCL_i_normal <= '1';

      SDA_o_phy    <= '1';
      SDA_t_phy    <= '1';
      SCL_o_phy    <= '1';
      SCL_t_phy    <= '1';

      SI_OE_N      <= '1';
      SI_EN        <= '0';
      handoff      <= '0';
    elsif state = SM_DONE then
      --Normal: Control given to PS/AXI PL
      SDA_i_normal <= SDA_i_phy;
      SDA_o_phy    <= SDA_o_normal;
      SDA_t_phy    <= SDA_t_normal;
      SCL_i_normal <= SCL_i_phy;
      SCL_o_phy    <= SCL_o_normal;
      SCL_t_phy    <= SCL_t_normal;
      SI_OE_N      <= not SI_OE_normal;
      SI_EN        <= SI_EN_normal;

      SDA_i_SI <= '1';
      SCL_i_SI <= '1';
      handoff  <= '1';
    else
      -- bootup: control given to init PL
      SDA_i_SI  <= SDA_i_phy;
      SDA_o_phy <= SDA_o_SI;
      SDA_t_phy <= SDA_t_SI;
      SCL_i_SI  <= SCL_i_phy;
      SCL_o_phy <= SCL_o_SI;
      SCL_t_phy <= SCL_t_SI;
      SI_OE_N   <= not init_SI_OE;
      SI_EN     <= init_SI_EN;    

      SDA_i_normal <= '1';
      SCL_i_normal <= '1';
      handoff      <= '0';
    end if;
  end process swap_signals;
  
end architecture behavioral;

