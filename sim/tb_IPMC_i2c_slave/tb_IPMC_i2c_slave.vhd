library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.types.all;

use work.AXIRegPkg.all;


entity tb_IPMC_i2c_slave is
  port (
    clk     : in std_logic;
    reset   : in std_logic);

end entity tb_IPMC_i2c_slave;

architecture behavioral of tb_IPMC_i2c_slave is
  signal counter : integer;

  signal reset_axi_n : std_logic;

  signal readMOSI        : AXIReadMOSI := DefaultAXIReadMOSI;
  signal readMISO        : AXIReadMISO;
  signal writeMOSI       : AXIWriteMOSI := DefaultAXIWriteMOSI;
  signal writeMISO       : AXIWriteMISO;

  signal SDA_o           : std_logic;
  signal SDA_t           : std_logic;
  signal SDA_i           : std_logic;
  signal SCL             : std_logic;

  
begin  -- architecture behavioral

  
  tb: process (clk, reset) is
  begin  -- process tb
    if reset = '1' then              -- asynchronous reset (active high)
      reset_axi_n <= '0';
      SDA_i <= '1';
      SCL   <= '1';
      counter <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;

      case counter is
        when 10 =>
          reset_axi_n <= '1';
        when 96 =>
          SDA_i <= '0';
        when 98 =>
          SCL <= '0';
        --addr bit 7
        when 100 =>
          SCL <= '0';
          SDA_i <= '1';
        when 101 =>
          SCL <= '1';
        when 103 =>
          SCL <= '0';
        --addr bit 6
        when 104 =>
          SCL <= '0';
          SDA_i <= '1';
        when 105 =>
          SCL <= '1';
        when 107 =>
          SCL <= '0';
        --addr bit 5
        when 108 =>
          SCL <= '0';
          SDA_i <= '0';
        when 109 =>
          SCL <= '1';
        when 111 =>
          SCL <= '0';
        --addr bit 4
        when 112 =>
          SCL <= '0';
          SDA_i <= '0';
        when 113 =>
          SCL <= '1';
        when 115 =>
          SCL <= '0';
        --addr bit 3
        when 116 =>
          SCL <= '0';
          SDA_i <= '0';
        when 117 =>
          SCL <= '1';
        when 119 =>
          SCL <= '0';
        --addr bit 2
        when 120 =>
          SCL <= '0';
          SDA_i <= '0';
        when 121 =>
          SCL <= '1';
        when 123 =>
          SCL <= '0';
        --addr bit 1
        when 124 =>
          SCL <= '0';
          SDA_i <= '0';
        when 125 =>
          SCL <= '1';
        when 127 =>
          SCL <= '0';
        --addr bit 0
        when 128 =>
          SCL <= '0';
          SDA_i <= '0';
        when 129 =>
          SCL <= '1';
        when 131 =>
          SCL <= '0';
        --R/W bit to write
        when 132 =>
          SCL <= '0';
          SDA_i <= '0';
        when 133 =>
          SCL <= '1';
        when 135 =>
          SCL <= '0';

        --write reg
        --reg bit 8
        when 200 =>
          SCL <= '0';
          SDA_i <= '0';
        when 201 =>
          SCL <= '1';
        when 203 =>
          SCL <= '0';
        --reg bit 7
        when 204 =>
          SCL <= '0';
          SDA_i <= '0';
        when 205 =>
          SCL <= '1';
        when 207 =>
          SCL <= '0';
        --reg bit 6
        when 208 =>
          SCL <= '0';
          SDA_i <= '0';
        when 209 =>
          SCL <= '1';
        when 211 =>
          SCL <= '0';
        --reg bit 5
        when 212 =>
          SCL <= '0';
          SDA_i <= '0';
        when 213 =>
          SCL <= '1';
        when 215 =>
          SCL <= '0';
        --reg bit 4
        when 216 =>
          SCL <= '0';
          SDA_i <= '0';
        when 217 =>
          SCL <= '1';
        when 219 =>
          SCL <= '0';
        --reg bit 3
        when 220 =>
          SCL <= '0';
          SDA_i <= '0';
        when 221 =>
          SCL <= '1';
        when 223 =>
          SCL <= '0';
        --reg bit 2
        when 224 =>
          SCL <= '0';
          SDA_i <= '0';
        when 225 =>
          SCL <= '1';
        when 227 =>
          SCL <= '0';
        --reg bit 1
        when 228 =>
          SCL <= '0';
          SDA_i <= '0';
        when 229 =>
          SCL <= '1';
        when 231 =>
          SCL <= '0';
        --reg bit 0
        when 232 =>
          SCL <= '0';
          SDA_i <= '0';
        when 233 =>
          SCL <= '1';
        when 235 =>
          SCL <= '0';

                  --write data
        --reg bit 8
        when 300 =>
          SCL <= '0';
          SDA_i <= '1';
        when 301 =>
          SCL <= '1';
        when 303 =>
          SCL <= '0';
        --reg bit 7
        when 304 =>
          SCL <= '0';
          SDA_i <= '1';
        when 305 =>
          SCL <= '1';
        when 307 =>
          SCL <= '0';
        --reg bit 6
        when 308 =>
          SCL <= '0';
          SDA_i <= '0';
        when 309 =>
          SCL <= '1';
        when 311 =>
          SCL <= '0';
        --reg bit 5
        when 312 =>
          SCL <= '0';
          SDA_i <= '0';
        when 313 =>
          SCL <= '1';
        when 315 =>
          SCL <= '0';
        --reg bit 4
        when 316 =>
          SCL <= '0';
          SDA_i <= '0';
        when 317 =>
          SCL <= '1';
        when 319 =>
          SCL <= '0';
        --reg bit 3
        when 320 =>
          SCL <= '0';
          SDA_i <= '0';
        when 321 =>
          SCL <= '1';
        when 323 =>
          SCL <= '0';
        --reg bit 2
        when 324 =>
          SCL <= '0';
          SDA_i <= '0';
        when 325 =>
          SCL <= '1';
        when 327 =>
          SCL <= '0';
        --reg bit 1
        when 328 =>
          SCL <= '0';
          SDA_i <= '0';
        when 329 =>
          SCL <= '1';
        when 331 =>
          SCL <= '0';
        --reg bit 0
        when 332 =>
          SCL <= '0';
          SDA_i <= '0';
        when 333 =>
          SCL <= '1';
        when 335 =>
          SCL <= '0';

        when 400 =>
          SCL <= '1';
        when 402 =>
          SDA_i <= '1';











        --- read transaction





        when 1096 =>
          SDA_i <= '0';
        when 1098 =>
          SCL <= '0';
        --addr bit 7
        when 1100 =>
          SCL <= '0';
          SDA_i <= '1';
        when 1101 =>
          SCL <= '1';
        when 1103 =>
          SCL <= '0';
        --addr bit 6
        when 1104 =>
          SCL <= '0';
          SDA_i <= '1';
        when 1105 =>
          SCL <= '1';
        when 1107 =>
          SCL <= '0';
        --addr bit 5
        when 1108 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1109 =>
          SCL <= '1';
        when 1111 =>
          SCL <= '0';
        --addr bit 4
        when 1112 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1113 =>
          SCL <= '1';
        when 1115 =>
          SCL <= '0';
        --addr bit 3
        when 1116 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1117 =>
          SCL <= '1';
        when 1119 =>
          SCL <= '0';
        --addr bit 2
        when 1120 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1121 =>
          SCL <= '1';
        when 1123 =>
          SCL <= '0';
        --addr bit 1
        when 1124 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1125 =>
          SCL <= '1';
        when 1127 =>
          SCL <= '0';
        --addr bit 0
        when 1128 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1129 =>
          SCL <= '1';
        when 1131 =>
          SCL <= '0';
        --R/W bit to write
        when 1132 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1133 =>
          SCL <= '1';
        when 1135 =>
          SCL <= '0';

        --write reg
        --reg bit 8
        when 1200 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1201 =>
          SCL <= '1';
        when 1203 =>
          SCL <= '0';
        --reg bit 7
        when 1204 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1205 =>
          SCL <= '1';
        when 1207 =>
          SCL <= '0';
        --reg bit 6
        when 1208 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1209 =>
          SCL <= '1';
        when 1211 =>
          SCL <= '0';
        --reg bit 5
        when 1212 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1213 =>
          SCL <= '1';
        when 1215 =>
          SCL <= '0';
        --reg bit 4
        when 1216 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1217 =>
          SCL <= '1';
        when 1219 =>
          SCL <= '0';
        --reg bit 3
        when 1220 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1221 =>
          SCL <= '1';
        when 1223 =>
          SCL <= '0';
        --reg bit 2
        when 1224 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1225 =>
          SCL <= '1';
        when 1227 =>
          SCL <= '0';
        --reg bit 1
        when 1228 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1229 =>
          SCL <= '1';
        when 1231 =>
          SCL <= '0';
        --reg bit 0
        when 1232 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1233 =>
          SCL <= '1';
        when 1235 =>
          SCL <= '0';
          
        when 1300 =>
          SCL <= '1';
        when 1302 =>
          SDA_i <= '1';

          --start read part of read transaction
          
        when 1396 =>
          SDA_i <= '0';
        when 1398 =>
          SCL <= '0';
        --addr bit 7
        when 1400 =>
          SCL <= '0';
          SDA_i <= '1';
        when 1401 =>
          SCL <= '1';
        when 1403 =>
          SCL <= '0';
        --addr bit 6
        when 1404 =>
          SCL <= '0';
          SDA_i <= '1';
        when 1405 =>
          SCL <= '1';
        when 1407 =>
          SCL <= '0';
        --addr bit 5
        when 1408 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1409 =>
          SCL <= '1';
        when 1411 =>
          SCL <= '0';
        --addr bit 4
        when 1412 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1413 =>
          SCL <= '1';
        when 1415 =>
          SCL <= '0';
        --addr bit 3
        when 1416 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1417 =>
          SCL <= '1';
        when 1419 =>
          SCL <= '0';
        --addr bit 2
        when 1420 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1421 =>
          SCL <= '1';
        when 1423 =>
          SCL <= '0';
        --addr bit 1
        when 1424 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1425 =>
          SCL <= '1';
        when 1427 =>
          SCL <= '0';
        --addr bit 0
        when 1428 =>
          SCL <= '0';
          SDA_i <= '0';
        when 1429 =>
          SCL <= '1';
        when 1431 =>
          SCL <= '0';
        --R/W bit to write
        when 1432 =>
          SCL <= '0';
          SDA_i <= '1';
        when 1433 =>
          SCL <= '1';
        when 1435 =>
          SCL <= '0';


        --addr bit 7
        when 1500 =>
          SCL <= '0';
        when 1501 =>
          SCL <= '1';
        when 1503 =>
          SCL <= '0';
        --addr bit 6
        when 1504 =>
          SCL <= '0';
        when 1505 =>
          SCL <= '1';
        when 1507 =>
          SCL <= '0';
        --addr bit 5
        when 1508 =>
          SCL <= '0';
        when 1509 =>
          SCL <= '1';
        when 1511 =>
          SCL <= '0';
        --addr bit 4
        when 1512 =>
          SCL <= '0';
        when 1513 =>
          SCL <= '1';
        when 1515 =>
          SCL <= '0';
        --addr bit 3
        when 1516 =>
          SCL <= '0';
        when 1517 =>
          SCL <= '1';
        when 1519 =>
          SCL <= '0';
        --addr bit 2
        when 1520 =>
          SCL <= '0';
        when 1521 =>
          SCL <= '1';
        when 1523 =>
          SCL <= '0';
        --addr bit 1
        when 1524 =>
          SCL <= '0';
        when 1525 =>
          SCL <= '1';
        when 1527 =>
          SCL <= '0';
        --addr bit 0
        when 1528 =>
          SCL <= '0';
        when 1529 =>
          SCL <= '1';
        when 1531 =>
          SCL <= '0';
        --R/W bit to write
        when 1532 =>
          SCL <= '0';
        when 1533 =>
          SCL <= '1';
        when 1535 =>
          SCL <= '0';

        when 1599 =>
          SDA_i <= '0';
        when 1600 =>
          SCL <= '1';
        when 1602 =>
          SDA_i <= '1';


          
        when others => null;
      end case;
    end if;
  end process tb;

  IPMC_i2c_slave_1: entity work.IPMC_i2c_slave
    port map (
      clk_axi     => clk,
      reset_axi_n => reset_axi_n,
      readMOSI    => readMOSI,
      readMISO    => readMISO,
      writeMOSI   => writeMOSI,
      writeMISO   => writeMISO,
      SDA_o       => SDA_o,
      SDA_t       => SDA_t,
      SDA_i       => SDA_i,
      SCL         => SCL);
  
end architecture behavioral;
