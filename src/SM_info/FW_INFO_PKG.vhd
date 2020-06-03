--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package FW_INFO_CTRL is
  type FW_INFO_BUILD_DATE_MON_t is record
    DAY                        :std_logic_vector( 7 downto 0);
    MONTH                      :std_logic_vector( 7 downto 0);
    YEAR                       :std_logic_vector(15 downto 0);
  end record FW_INFO_BUILD_DATE_MON_t;


  type FW_INFO_BUILD_TIME_MON_t is record
    SEC                        :std_logic_vector( 7 downto 0);
    MIN                        :std_logic_vector( 7 downto 0);
    HOUR                       :std_logic_vector( 7 downto 0);
  end record FW_INFO_BUILD_TIME_MON_t;


  type FW_INFO_FPGA_MON_t is record
    WORD_00                    :std_logic_vector(31 downto 0);
    WORD_01                    :std_logic_vector(31 downto 0);
    WORD_02                    :std_logic_vector(31 downto 0);
    WORD_03                    :std_logic_vector(31 downto 0);
    WORD_04                    :std_logic_vector(31 downto 0);
    WORD_05                    :std_logic_vector(31 downto 0);
    WORD_06                    :std_logic_vector(31 downto 0);
    WORD_07                    :std_logic_vector(31 downto 0);
    WORD_08                    :std_logic_vector(31 downto 0);
  end record FW_INFO_FPGA_MON_t;


  type FW_INFO_MON_t is record
    GIT_VALID                  :std_logic;   
    GIT_HASH_1                 :std_logic_vector(31 downto 0);
    GIT_HASH_2                 :std_logic_vector(31 downto 0);
    GIT_HASH_3                 :std_logic_vector(31 downto 0);
    GIT_HASH_4                 :std_logic_vector(31 downto 0);
    GIT_HASH_5                 :std_logic_vector(31 downto 0);
    BUILD_DATE                 :FW_INFO_BUILD_DATE_MON_t;     
    BUILD_TIME                 :FW_INFO_BUILD_TIME_MON_t;     
    FPGA                       :FW_INFO_FPGA_MON_t;           
  end record FW_INFO_MON_t;




end package FW_INFO_CTRL;