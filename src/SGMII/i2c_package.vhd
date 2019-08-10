library IEEE;
use IEEE.std_logic_1164.all;

package i2c_CTRL is

  type i2c_control_t is record
    reset      : std_logic;
    run        : std_logic;
    rw         : std_logic;
    addr       : std_logic_vector(6 downto 0);
    reg_addr   : std_logic_vector(7 downto 0);
    wr_data    : std_logic_vector(31 downto 0);
    byte_count : std_logic_vector(2 downto 0);        
  end record i2c_control_t;
  constant DEFAULT_i2c_CONTROL : i2c_control_t := (reset      => '0',
                                                   run        => '0',
                                                   rw         => '0',
                                                   addr       => "0000000",
                                                   reg_addr   => x"00",
                                                   wr_data    => x"00000000",
                                                   byte_count => "000");
  type i2c_monitor_t is record
    reset      : std_logic;
    rw         : std_logic;
    addr       : std_logic_vector(6 downto 0);
    reg_addr   : std_logic_vector(7 downto 0);
    wr_data    : std_logic_vector(31 downto 0);
    rd_data    : std_logic_vector(31 downto 0);
    byte_count : std_logic_vector(2 downto 0);
    done       : std_logic;
    error      : std_logic;    
  end record i2c_monitor_t;

end package i2c_CTRL;
