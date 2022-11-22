--==============================================================================
-- © Copyright CERN for the benefit of the HPTD interest group 2019. All rights not
--   expressly granted are reserved.
--
--   This file is part of TCLink.
--
-- TCLink is free VHDL code: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- TCLink is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with TCLink.  If not, see <https://www.gnu.org/licenses/>.
--==============================================================================
--! @file tclink_tester_unit.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Specific packages
-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: Hardware tester for TCLink transfer function (tclink_tester_unit)
--
--! @brief NCO with 2**10 frequency resolution and 32b amplitude resolution and RAM to stock TCLink results
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 07\08\2019
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
--! 07\08\2019 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for tclink_tester_unit
--==============================================================================
entity tclink_tester_unit is
  port (
    -- Clock/reset   
    clk_sys_i          : in  std_logic;                                   --! system clock input
    clk_en_i           : in  std_logic;                                   --! loop sampling clock enable for TCLink
    reset_i            : in  std_logic;                                   --! active high sync. reset
				
    -- Stimulis				
    enable_stimulis_i  : in  std_logic;                                   --! enable stimulis for TCLink
    fcw_i              : in  std_logic_vector(9 downto 0);                --! frequency control word for NCO (unsigned)
    nco_o              : out std_logic_vector(31 downto 0);               --! NCO output (sinus with amplitude 2**31/2**nco_scale) 
    nco_scale_i        : in  std_logic_vector(4 downto 0);                --! scale NCO output   

    -- TCLink response
    tclink_phase_i     : in  std_logic_vector(15 downto 0);               --! TCLink phase accumulated output
    enable_stock_out_i : in  std_logic;                                   --! enable output data stock
    addr_read_i        : in  std_logic_vector(9 downto 0);                --! read address for reading stocked TCLink phase accumulated results
    data_read_o        : out std_logic_vector(15 downto 0)                --! data of stocked TCLink phase accumulated results

    );
end tclink_tester_unit;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of tclink_tester_unit is

  --! Attribute declaration

  type t_memory32b is array(0 to 2**10-1) of std_logic_vector(31 downto 0);
  type t_memory16b is array(0 to 2**10-1) of std_logic_vector(15 downto 0);
  
  --! Constant declaration
  -- ==============================================================================
  -- ================================ ROM for NCO ================================
  -- ==============================================================================
  constant nco_rom : t_memory32b := (x"00000000", x"00c90f88", x"01921d20", x"025b26d7", x"03242abf", x"03ed26e6", x"04b6195d", x"057f0035", x"0647d97c", x"0710a345", x"07d95b9e", x"08a2009a", x"096a9049", x"0a3308bc", x"0afb6805", x"0bc3ac35", x"0c8bd35e", x"0d53db92", x"0e1bc2e4", x"0ee38766", x"0fab272b", x"1072a048", x"1139f0cf", x"120116d5", x"12c8106e", x"138edbb1", x"145576b1", x"151bdf85", x"15e21444", x"16a81305", x"176dd9de", x"183366e8", x"18f8b83c", x"19bdcbf3", x"1a82a025", x"1b4732ef", x"1c0b826a", x"1ccf8cb3", x"1d934fe5", x"1e56ca1e", x"1f19f97b", x"1fdcdc1b", x"209f701c", x"2161b39f", x"2223a4c5", x"22e541af", x"23a6887e", x"24677757", x"25280c5d", x"25e845b6", x"26a82185", x"27679df4", x"2826b928", x"28e5714a", x"29a3c485", x"2a61b101", x"2b1f34eb", x"2bdc4e6f", x"2c98fbba", x"2d553afb", x"2e110a62", x"2ecc681e", x"2f875262", x"3041c760", x"30fbc54d", x"31b54a5d", x"326e54c7", x"3326e2c2", x"33def287", x"3496824f", x"354d9056", x"36041ad9", x"36ba2013", x"376f9e46", x"382493b0", x"38d8fe93", x"398cdd32", x"3a402dd1", x"3af2eeb7", x"3ba51e29", x"3c56ba70", x"3d07c1d5", x"3db832a5", x"3e680b2c", x"3f1749b7", x"3fc5ec97", x"4073f21d", x"4121589a", x"41ce1e64", x"427a41d0", x"4325c135", x"43d09aec", x"447acd50", x"452456bc", x"45cd358f", x"46756827", x"471cece6", x"47c3c22e", x"4869e664", x"490f57ee", x"49b41533", x"4a581c9d", x"4afb6c97", x"4b9e038f", x"4c3fdff3", x"4ce10034", x"4d8162c3", x"4e210617", x"4ebfe8a4", x"4f5e08e2", x"4ffb654c", x"5097fc5e", x"5133cc94", x"51ced46e", x"5269126e", x"53028517", x"539b2aef", x"5433027d", x"54ca0a4a", x"556040e2", x"55f5a4d2", x"568a34a9", x"571deef9", x"57b0d255", x"5842dd54", x"58d40e8c", x"59646497", x"59f3de12", x"5a827999", x"5b1035ce", x"5b9d1153", x"5c290acc", x"5cb420df", x"5d3e5236", x"5dc79d7b", x"5e50015d", x"5ed77c89", x"5f5e0db2", x"5fe3b38d", x"60686cce", x"60ec382f", x"616f146b", x"61f1003e", x"6271fa68", x"62f201ac", x"637114cc", x"63ef328f", x"646c59bf", x"64e88925", x"6563bf91", x"65ddfbd2", x"66573cbb", x"66cf811f", x"6746c7d7", x"67bd0fbc", x"683257aa", x"68a69e80", x"6919e31f", x"698c246b", x"69fd614a", x"6a6d98a3", x"6adcc964", x"6b4af278", x"6bb812d0", x"6c24295f", x"6c8f351b", x"6cf934fb", x"6d6227f9", x"6dca0d14", x"6e30e349", x"6e96a99c", x"6efb5f11", x"6f5f02b1", x"6fc19384", x"70231099", x"708378fe", x"70e2cbc5", x"71410804", x"719e2cd1", x"71fa3948", x"72552c84", x"72af05a6", x"7307c3cf", x"735f6625", x"73b5ebd0", x"740b53fa", x"745f9dd0", x"74b2c883", x"7504d344", x"7555bd4b", x"75a585ce", x"75f42c0a", x"7641af3c", x"768e0ea5", x"76d94988", x"77235f2c", x"776c4eda", x"77b417df", x"77fab988", x"78403328", x"78848413", x"78c7aba1", x"7909a92c", x"794a7c11", x"798a23b0", x"79c89f6d", x"7a05eeac", x"7a4210d8", x"7a7d055a", x"7ab6cba3", x"7aef6323", x"7b26cb4e", x"7b5d039d", x"7b920b88", x"7bc5e28f", x"7bf8882f", x"7c29fbed", x"7c5a3d4f", x"7c894bdd", x"7cb72723", x"7ce3ceb1", x"7d0f4217", x"7d3980eb", x"7d628ac5", x"7d8a5f3f", x"7db0fdf7", x"7dd6668e", x"7dfa98a7", x"7e1d93e9", x"7e3f57fe", x"7e5fe492", x"7e7f3956", x"7e9d55fb", x"7eba3a38", x"7ed5e5c5", x"7ef0585f", x"7f0991c3", x"7f2191b3", x"7f3857f5", x"7f4de450", x"7f62368e", x"7f754e7f", x"7f872bf2", x"7f97cebc", x"7fa736b3", x"7fb563b2", x"7fc25595", x"7fce0c3d", x"7fd8878d", x"7fe1c76a", x"7fe9cbbf", x"7ff09477", x"7ff62181", x"7ffa72d0", x"7ffd8859", x"7fff6215", x"7fffffff", x"7fff6215", x"7ffd8859", x"7ffa72d0", x"7ff62181", x"7ff09477", x"7fe9cbbf", x"7fe1c76a", x"7fd8878d", x"7fce0c3d", x"7fc25595", x"7fb563b2", x"7fa736b3", x"7f97cebc", x"7f872bf2", x"7f754e7f", x"7f62368e", x"7f4de450", x"7f3857f5", x"7f2191b3", x"7f0991c3", x"7ef0585f", x"7ed5e5c5", x"7eba3a38", x"7e9d55fb", x"7e7f3956", x"7e5fe492", x"7e3f57fe", x"7e1d93e9", x"7dfa98a7", x"7dd6668e", x"7db0fdf7", x"7d8a5f3f", x"7d628ac5", x"7d3980eb", x"7d0f4217", x"7ce3ceb1", x"7cb72723", x"7c894bdd", x"7c5a3d4f", x"7c29fbed", x"7bf8882f", x"7bc5e28f", x"7b920b88", x"7b5d039d", x"7b26cb4e", x"7aef6323", x"7ab6cba3", x"7a7d055a", x"7a4210d8", x"7a05eeac", x"79c89f6d", x"798a23b0", x"794a7c11", x"7909a92c", x"78c7aba1", x"78848413", x"78403328", x"77fab988", x"77b417df", x"776c4eda", x"77235f2c", x"76d94988", x"768e0ea5", x"7641af3c", x"75f42c0a", x"75a585ce", x"7555bd4b", x"7504d344", x"74b2c883", x"745f9dd0", x"740b53fa", x"73b5ebd0", x"735f6625", x"7307c3cf", x"72af05a6", x"72552c84", x"71fa3948", x"719e2cd1", x"71410804", x"70e2cbc5", x"708378fe", x"70231099", x"6fc19384", x"6f5f02b1", x"6efb5f11", x"6e96a99c", x"6e30e349", x"6dca0d14", x"6d6227f9", x"6cf934fb", x"6c8f351b", x"6c24295f", x"6bb812d0", x"6b4af278", x"6adcc964", x"6a6d98a3", x"69fd614a", x"698c246b", x"6919e31f", x"68a69e80", x"683257aa", x"67bd0fbc", x"6746c7d7", x"66cf811f", x"66573cbb", x"65ddfbd2", x"6563bf91", x"64e88925", x"646c59bf", x"63ef328f", x"637114cc", x"62f201ac", x"6271fa68", x"61f1003e", x"616f146b", x"60ec382f", x"60686cce", x"5fe3b38d", x"5f5e0db2", x"5ed77c89", x"5e50015d", x"5dc79d7b", x"5d3e5236", x"5cb420df", x"5c290acc", x"5b9d1153", x"5b1035ce", x"5a827999", x"59f3de12", x"59646497", x"58d40e8c", x"5842dd54", x"57b0d255", x"571deef9", x"568a34a9", x"55f5a4d2", x"556040e2", x"54ca0a4a", x"5433027d", x"539b2aef", x"53028517", x"5269126e", x"51ced46e", x"5133cc94", x"5097fc5e", x"4ffb654c", x"4f5e08e2", x"4ebfe8a4", x"4e210617", x"4d8162c3", x"4ce10034", x"4c3fdff3", x"4b9e038f", x"4afb6c97", x"4a581c9d", x"49b41533", x"490f57ee", x"4869e664", x"47c3c22e", x"471cece6", x"46756827", x"45cd358f", x"452456bc", x"447acd50", x"43d09aec", x"4325c135", x"427a41d0", x"41ce1e64", x"4121589a", x"4073f21d", x"3fc5ec97", x"3f1749b7", x"3e680b2c", x"3db832a5", x"3d07c1d5", x"3c56ba70", x"3ba51e29", x"3af2eeb7", x"3a402dd1", x"398cdd32", x"38d8fe93", x"382493b0", x"376f9e46", x"36ba2013", x"36041ad9", x"354d9056", x"3496824f", x"33def287", x"3326e2c2", x"326e54c7", x"31b54a5d", x"30fbc54d", x"3041c760", x"2f875262", x"2ecc681e", x"2e110a62", x"2d553afb", x"2c98fbba", x"2bdc4e6f", x"2b1f34eb", x"2a61b101", x"29a3c485", x"28e5714a", x"2826b928", x"27679df4", x"26a82185", x"25e845b6", x"25280c5d", x"24677757", x"23a6887e", x"22e541af", x"2223a4c5", x"2161b39f", x"209f701c", x"1fdcdc1b", x"1f19f97b", x"1e56ca1e", x"1d934fe5", x"1ccf8cb3", x"1c0b826a", x"1b4732ef", x"1a82a025", x"19bdcbf3", x"18f8b83c", x"183366e8", x"176dd9de", x"16a81305", x"15e21444", x"151bdf85", x"145576b1", x"138edbb1", x"12c8106e", x"120116d5", x"1139f0cf", x"1072a048", x"0fab272b", x"0ee38766", x"0e1bc2e4", x"0d53db92", x"0c8bd35e", x"0bc3ac35", x"0afb6805", x"0a3308bc", x"096a9049", x"08a2009a", x"07d95b9e", x"0710a345", x"0647d97c", x"057f0035", x"04b6195d", x"03ed26e6", x"03242abf", x"025b26d7", x"01921d20", x"00c90f88", x"00000000", x"ff36f078", x"fe6de2e0", x"fda4d929", x"fcdbd541", x"fc12d91a", x"fb49e6a3", x"fa80ffcb", x"f9b82684", x"f8ef5cbb", x"f826a462", x"f75dff66", x"f6956fb7", x"f5ccf744", x"f50497fb", x"f43c53cb", x"f3742ca2", x"f2ac246e", x"f1e43d1c", x"f11c789a", x"f054d8d5", x"ef8d5fb8", x"eec60f31", x"edfee92b", x"ed37ef92", x"ec71244f", x"ebaa894f", x"eae4207b", x"ea1debbc", x"e957ecfb", x"e8922622", x"e7cc9918", x"e70747c4", x"e642340d", x"e57d5fdb", x"e4b8cd11", x"e3f47d96", x"e330734d", x"e26cb01b", x"e1a935e2", x"e0e60685", x"e02323e5", x"df608fe4", x"de9e4c61", x"dddc5b3b", x"dd1abe51", x"dc597782", x"db9888a9", x"dad7f3a3", x"da17ba4a", x"d957de7b", x"d898620c", x"d7d946d8", x"d71a8eb6", x"d65c3b7b", x"d59e4eff", x"d4e0cb15", x"d423b191", x"d3670446", x"d2aac505", x"d1eef59e", x"d13397e2", x"d078ad9e", x"cfbe38a0", x"cf043ab3", x"ce4ab5a3", x"cd91ab39", x"ccd91d3e", x"cc210d79", x"cb697db1", x"cab26faa", x"c9fbe527", x"c945dfed", x"c89061ba", x"c7db6c50", x"c727016d", x"c67322ce", x"c5bfd22f", x"c50d1149", x"c45ae1d7", x"c3a94590", x"c2f83e2b", x"c247cd5b", x"c197f4d4", x"c0e8b649", x"c03a1369", x"bf8c0de3", x"bedea766", x"be31e19c", x"bd85be30", x"bcda3ecb", x"bc2f6514", x"bb8532b0", x"badba944", x"ba32ca71", x"b98a97d9", x"b8e3131a", x"b83c3dd2", x"b796199c", x"b6f0a812", x"b64beacd", x"b5a7e363", x"b5049369", x"b461fc71", x"b3c0200d", x"b31effcc", x"b27e9d3d", x"b1def9e9", x"b140175c", x"b0a1f71e", x"b0049ab4", x"af6803a2", x"aecc336c", x"ae312b92", x"ad96ed92", x"acfd7ae9", x"ac64d511", x"abccfd83", x"ab35f5b6", x"aa9fbf1e", x"aa0a5b2e", x"a975cb57", x"a8e21107", x"a84f2dab", x"a7bd22ac", x"a72bf174", x"a69b9b69", x"a60c21ee", x"a57d8667", x"a4efca32", x"a462eead", x"a3d6f534", x"a34bdf21", x"a2c1adca", x"a2386285", x"a1affea3", x"a1288377", x"a0a1f24e", x"a01c4c73", x"9f979332", x"9f13c7d1", x"9e90eb95", x"9e0effc2", x"9d8e0598", x"9d0dfe54", x"9c8eeb34", x"9c10cd71", x"9b93a641", x"9b1776db", x"9a9c406f", x"9a22042e", x"99a8c345", x"99307ee1", x"98b93829", x"9842f044", x"97cda856", x"97596180", x"96e61ce1", x"9673db95", x"96029eb6", x"9592675d", x"9523369c", x"94b50d88", x"9447ed30", x"93dbd6a1", x"9370cae5", x"9306cb05", x"929dd807", x"9235f2ec", x"91cf1cb7", x"91695664", x"9104a0ef", x"90a0fd4f", x"903e6c7c", x"8fdcef67", x"8f7c8702", x"8f1d343b", x"8ebef7fc", x"8e61d32f", x"8e05c6b8", x"8daad37c", x"8d50fa5a", x"8cf83c31", x"8ca099db", x"8c4a1430", x"8bf4ac06", x"8ba06230", x"8b4d377d", x"8afb2cbc", x"8aaa42b5", x"8a5a7a32", x"8a0bd3f6", x"89be50c4", x"8971f15b", x"8926b678", x"88dca0d4", x"8893b126", x"884be821", x"88054678", x"87bfccd8", x"877b7bed", x"8738545f", x"86f656d4", x"86b583ef", x"8675dc50", x"86376093", x"85fa1154", x"85bdef28", x"8582faa6", x"8549345d", x"85109cdd", x"84d934b2", x"84a2fc63", x"846df478", x"843a1d71", x"840777d1", x"83d60413", x"83a5c2b1", x"8376b423", x"8348d8dd", x"831c314f", x"82f0bde9", x"82c67f15", x"829d753b", x"8275a0c1", x"824f0209", x"82299972", x"82056759", x"81e26c17", x"81c0a802", x"81a01b6e", x"8180c6aa", x"8162aa05", x"8145c5c8", x"812a1a3b", x"810fa7a1", x"80f66e3d", x"80de6e4d", x"80c7a80b", x"80b21bb0", x"809dc972", x"808ab181", x"8078d40e", x"80683144", x"8058c94d", x"804a9c4e", x"803daa6b", x"8031f3c3", x"80277873", x"801e3896", x"80163441", x"800f6b89", x"8009de7f", x"80058d30", x"800277a7", x"80009deb", x"80000001", x"80009deb", x"800277a7", x"80058d30", x"8009de7f", x"800f6b89", x"80163441", x"801e3896", x"80277873", x"8031f3c3", x"803daa6b", x"804a9c4e", x"8058c94d", x"80683144", x"8078d40e", x"808ab181", x"809dc972", x"80b21bb0", x"80c7a80b", x"80de6e4d", x"80f66e3d", x"810fa7a1", x"812a1a3b", x"8145c5c8", x"8162aa05", x"8180c6aa", x"81a01b6e", x"81c0a802", x"81e26c17", x"82056759", x"82299972", x"824f0209", x"8275a0c1", x"829d753b", x"82c67f15", x"82f0bde9", x"831c314f", x"8348d8dd", x"8376b423", x"83a5c2b1", x"83d60413", x"840777d1", x"843a1d71", x"846df478", x"84a2fc63", x"84d934b2", x"85109cdd", x"8549345d", x"8582faa6", x"85bdef28", x"85fa1154", x"86376093", x"8675dc50", x"86b583ef", x"86f656d4", x"8738545f", x"877b7bed", x"87bfccd8", x"88054678", x"884be821", x"8893b126", x"88dca0d4", x"8926b678", x"8971f15b", x"89be50c4", x"8a0bd3f6", x"8a5a7a32", x"8aaa42b5", x"8afb2cbc", x"8b4d377d", x"8ba06230", x"8bf4ac06", x"8c4a1430", x"8ca099db", x"8cf83c31", x"8d50fa5a", x"8daad37c", x"8e05c6b8", x"8e61d32f", x"8ebef7fc", x"8f1d343b", x"8f7c8702", x"8fdcef67", x"903e6c7c", x"90a0fd4f", x"9104a0ef", x"91695664", x"91cf1cb7", x"9235f2ec", x"929dd807", x"9306cb05", x"9370cae5", x"93dbd6a1", x"9447ed30", x"94b50d88", x"9523369c", x"9592675d", x"96029eb6", x"9673db95", x"96e61ce1", x"97596180", x"97cda856", x"9842f044", x"98b93829", x"99307ee1", x"99a8c345", x"9a22042e", x"9a9c406f", x"9b1776db", x"9b93a641", x"9c10cd71", x"9c8eeb34", x"9d0dfe54", x"9d8e0598", x"9e0effc2", x"9e90eb95", x"9f13c7d1", x"9f979332", x"a01c4c73", x"a0a1f24e", x"a1288377", x"a1affea3", x"a2386285", x"a2c1adca", x"a34bdf21", x"a3d6f534", x"a462eead", x"a4efca32", x"a57d8667", x"a60c21ee", x"a69b9b69", x"a72bf174", x"a7bd22ac", x"a84f2dab", x"a8e21107", x"a975cb57", x"aa0a5b2e", x"aa9fbf1e", x"ab35f5b6", x"abccfd83", x"ac64d511", x"acfd7ae9", x"ad96ed92", x"ae312b92", x"aecc336c", x"af6803a2", x"b0049ab4", x"b0a1f71e", x"b140175c", x"b1def9e9", x"b27e9d3d", x"b31effcc", x"b3c0200d", x"b461fc71", x"b5049369", x"b5a7e363", x"b64beacd", x"b6f0a812", x"b796199c", x"b83c3dd2", x"b8e3131a", x"b98a97d9", x"ba32ca71", x"badba944", x"bb8532b0", x"bc2f6514", x"bcda3ecb", x"bd85be30", x"be31e19c", x"bedea766", x"bf8c0de3", x"c03a1369", x"c0e8b649", x"c197f4d4", x"c247cd5b", x"c2f83e2b", x"c3a94590", x"c45ae1d7", x"c50d1149", x"c5bfd22f", x"c67322ce", x"c727016d", x"c7db6c50", x"c89061ba", x"c945dfed", x"c9fbe527", x"cab26faa", x"cb697db1", x"cc210d79", x"ccd91d3e", x"cd91ab39", x"ce4ab5a3", x"cf043ab3", x"cfbe38a0", x"d078ad9e", x"d13397e2", x"d1eef59e", x"d2aac505", x"d3670446", x"d423b191", x"d4e0cb15", x"d59e4eff", x"d65c3b7b", x"d71a8eb6", x"d7d946d8", x"d898620c", x"d957de7b", x"da17ba4a", x"dad7f3a3", x"db9888a9", x"dc597782", x"dd1abe51", x"dddc5b3b", x"de9e4c61", x"df608fe4", x"e02323e5", x"e0e60685", x"e1a935e2", x"e26cb01b", x"e330734d", x"e3f47d96", x"e4b8cd11", x"e57d5fdb", x"e642340d", x"e70747c4", x"e7cc9918", x"e8922622", x"e957ecfb", x"ea1debbc", x"eae4207b", x"ebaa894f", x"ec71244f", x"ed37ef92", x"edfee92b", x"eec60f31", x"ef8d5fb8", x"f054d8d5", x"f11c789a", x"f1e43d1c", x"f2ac246e", x"f3742ca2", x"f43c53cb", x"f50497fb", x"f5ccf744", x"f6956fb7", x"f75dff66", x"f826a462", x"f8ef5cbb", x"f9b82684", x"fa80ffcb", x"fb49e6a3", x"fc12d91a", x"fcdbd541", x"fda4d929", x"fe6de2e0", x"ff36f078");
  
  --! Signal declaration 
  -- ==============================================================================
  -- ============================== Stimulis signals ==============================
  -- ==============================================================================
  signal addr_stimulis : unsigned(fcw_i'range);
  signal nco_raw       : std_logic_vector(nco_o'range);

  -- ==============================================================================
  -- =============================== TCLink save signals ==========================
  -- ==============================================================================
  signal addr_write    : unsigned(fcw_i'range) := "0000000000";
  signal tclink_ram    : t_memory16b;

  --! Component declaration
  component scaler is
    generic(
      g_DATA_WIDTH    : integer := 32;
  	  g_COEFF_SIZE    : integer := 4;
      g_PRESCALE_MULT : integer range 0 to 31 := 0 --! multiplication by 2 
    );
    port (
      -- User Interface   
      input_i      : in std_logic_vector(g_DATA_WIDTH-1 downto 0);     --! Input to be scaled (signed)
  
      -- Loop dynamics interface
      scale_div_i  : in  std_logic_vector(g_COEFF_SIZE-1 downto 0);    --! Scaling coefficient division by 2 (unsigned)
      scaled_o     : out std_logic_vector(g_DATA_WIDTH-1 downto 0)     --! Scaled output (signed)
  
      );
  end component scaler;

begin
 
  -- Stimulis generation
  --============================================================================
  -- Process p_stimulis
  --!  Stimulis process
  --============================================================================  
  p_stimulis : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(reset_i = '1' or enable_stimulis_i='0') then
        addr_stimulis <= (others => '0');
        nco_raw       <= (others => '0');
      else
        if(clk_en_i='1') then
		  nco_raw       <= nco_rom(to_integer(addr_stimulis));
          addr_stimulis <= addr_stimulis + unsigned(fcw_i);
		end if;
      end if;
    end if;
  end process p_stimulis;

  -- Scale NCO
  cmp_nco_scaler : scaler
    generic map(
      g_DATA_WIDTH    => nco_o'length,
  	  g_COEFF_SIZE    => nco_scale_i'length ,
      g_PRESCALE_MULT => 0
    )
    port map(
      -- User Interface   
      input_i      => nco_raw,
  
      -- Loop dynamics interface
      scale_div_i  => nco_scale_i,
      scaled_o     => nco_o
   );
  --============================================================================  

  --============================================================================
  -- Process p_dpram
  --!  DPRAM to stock TCLink results
  --============================================================================  
  p_dpram : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(clk_en_i='1' and enable_stock_out_i='1') then
        tclink_ram(to_integer(addr_write)) <= tclink_phase_i;
      end if;
      if(clk_en_i='1') then
        data_read_o <= tclink_ram(to_integer(unsigned(addr_read_i)));
      end if;
    end if;
  end process p_dpram;
  
  --============================================================================
  -- Process p_dpram_addr_write
  --!  DPRAM address write
  --============================================================================  
  p_dpram_addr_write : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(reset_i='1') then
          addr_write <= to_unsigned(0, addr_write'length);
      else
        if(clk_en_i='1' and enable_stock_out_i='1') then
          addr_write <= addr_write + 1;
        end if;
      end if;
    end if;
  end process p_dpram_addr_write;

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
