library ieee;
use ieee.std_logic_1164.all;

package register_pkg is
	subtype reg is std_logic_vector(31 downto 0);
	type reg_matrix is array (natural range <>) of reg;

	-- CONTROL registers
	constant N_CTRL_REGS							: integer	:= 1;
	
	constant reset_from_software_REG				: natural := 0;
	constant reset_from_software_RANGE				: natural := 0;


	-- STATUS registers
--	constant N_STATUS_REGS							: integer	:= 7;
--	constant DATE_HEX_REG							: natural := 0;
--	type DATE_HEX_RANGE							is range 31 downto 0;
--	constant TIME_HEX_REG							: natural := 1;
--	type TIME_HEX_RANGE							is range 31 downto 0;
--	constant GIT_HASH_0_REG							: natural := 2;
--	type GIT_HASH_0_RANGE							is range 31 downto 0;
--	constant GIT_HASH_1_REG							: natural := 3;
--	type GIT_HASH_1_RANGE							is range 31 downto 0;
--	constant GIT_HASH_2_REG							: natural := 4;
--	type GIT_HASH_2_RANGE							is range 31 downto 0;
--	constant GIT_HASH_3_REG							: natural := 5;
--	type GIT_HASH_3_RANGE							is range 31 downto 0;	
--	constant GIT_HASH_4_REG							: natural := 6;
--	type GIT_HASH_4_RANGE							is range 31 downto 0;
--	constant REGS_AXI_ADDR_WIDTH : integer := 31;
	
	
	    -- STATUS registers
    constant N_STATUS_REGS                          : integer    := 14;
        
    constant GLOBAL_DATE_REG                        : natural := 0;
    subtype GLOBAL_DATE_RANGE                        is natural range 31 downto 0;
            
    constant GLOBAL_TIME_REG                        : natural := 1;
    subtype GLOBAL_TIME_RANGE                       is natural range 31 downto 0;
    
    constant GLOBAL_VER_REG                         : natural := 2;
    subtype GLOBAL_VER_RANGE                        is natural range 31 downto 0;
        
    constant GLOBAL_SHA_REG                         : natural := 3;
    subtype GLOBAL_SHA_RANGE                        is natural range 31 downto 0;
        
    constant TOP_VER_REG                            : natural := 4;
    subtype TOP_VER_RANGE                           is natural range 31 downto 0;
        
    constant TOP_SHA_REG                            : natural := 5;
    subtype TOP_SHA_RANGE                           is natural range 31 downto 0;
        
    constant CON_VER_REG                            : natural := 6;
    subtype CON_VER_RANGE                           is natural range 31 downto 0;
        
    constant CON_SHA_REG                            : natural := 7;
    subtype CON_SHA_RANGE                           is natural range 31 downto 0;
    
    constant HOG_VER_REG                            : natural := 8;
    subtype HOG_VER_RANGE                           is natural range 31 downto 0;
        
    constant HOG_SHA_REG                            : natural := 9;
    subtype HOG_SHA_RANGE                           is natural range 31 downto 0;
    
    constant xil_defaultlib_VER_REG                 : natural := 10;
    subtype xil_defaultlib_VER_RANGE                is natural range 31 downto 0;
        
    constant xil_defaultlib_SHA_REG                 : natural := 11;
    subtype xil_defaultlib_SHA_RANGE                is natural range 31 downto 0;
    
    constant Default_VER_REG                        : natural := 12;
    subtype Default_VER_RANGE                       is natural range 31 downto 0;
        
    constant Default_SHA_REG                        : natural := 13;
    subtype Default_SHA_RANGE                       is natural range 31 downto 0;
    constant REGS_AXI_ADDR_WIDTH : integer := 31;

end package;
