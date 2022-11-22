-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief N15K13 Reed-Solomon decoder
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief rs_decoder_N15K13 - N15K13 Reed-Solomon decoder
ENTITY rs_decoder_N15K13 IS
   GENERIC (
		N								: integer := 15;
		K 								: integer := 13;
		SYMB_BITWIDTH					: integer := 4
   );
   PORT (
        payloadData_i                   : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);       --! Message to be decoded
        fecData_i                       : in  std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0);   --! FEC USEd to decode

        data_o                          : out std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0)        --! Decoded / corrected data
   );
END rs_decoder_N15K13;

--! @brief rs_decoder_N15K13 ARCHITECTURE - N15K13 Reed-Solomon encoder
ARCHITECTURE behavioral OF rs_decoder_N15K13 IS

    -- Functions
    FUNCTION gf_multBy2_4 (
        op : in std_logic_vector(3 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(3 downto 0);
    BEGIN
        tmp(0) := op(3);
        tmp(1) := op(0) xor op(3);
        tmp(2) := op(1);
        tmp(3) := op(2);

        RETURN tmp;
    END;

    FUNCTION gf_mult_4 (
        op1 : in std_logic_vector(3 downto 0);
        op2 : in std_logic_vector(3 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(3 downto 0);
    BEGIN
        tmp(0) := (op1(1) and op2(3)) xor (op1(2) and op2(2)) xor (op1(3) and op2(1)) xor (op1(0) and op2(0));
        tmp(1) := (op1(1) and op2(0)) xor (op1(0) and op2(1)) xor (op1(3) and op2(1)) xor (op1(2) and op2(2)) xor (op1(3) and op2(2)) xor (op1(1) and op2(3)) xor (op1(2) and op2(3));
        tmp(2) := (op1(2) and op2(0)) xor (op1(1) and op2(1)) xor (op1(0) and op2(2)) xor (op1(3) and op2(2)) xor (op1(2) and op2(3)) xor (op1(3) and op2(3));
        tmp(3) := (op1(3) and op2(0)) xor (op1(2) and op2(1)) xor (op1(1) and op2(2)) xor (op1(0) and op2(3)) xor (op1(3) and op2(3));
        RETURN tmp;
    END;

    FUNCTION gf_inv_4 (
        op : in std_logic_vector(3 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(3 downto 0);
    BEGIN

        CASE op IS
            WHEN "0000"  => tmp := "0000"; -- 0
            WHEN "0001"  => tmp := "0001"; -- 1
            WHEN "0010"  => tmp := "1001"; -- 9
            WHEN "0011"  => tmp := "1110"; -- 14
            WHEN "0100"  => tmp := "1101"; -- 13
            WHEN "0101"  => tmp := "1011"; -- 11
            WHEN "0110"  => tmp := "0111"; -- 7
            WHEN "0111"  => tmp := "0110"; -- 6
            WHEN "1000"  => tmp := "1111"; -- 15
            WHEN "1001"  => tmp := "0010"; -- 2
            WHEN "1010"  => tmp := "1100"; -- 12
            WHEN "1011"  => tmp := "0101"; -- 5
            WHEN "1100"  => tmp := "1010"; -- 10
            WHEN "1101"  => tmp := "0100"; -- 4
            WHEN "1110"  => tmp := "0011"; -- 3
            WHEN "1111"  => tmp := "1000"; -- 8
            WHEN OTHERS  => tmp := "0000"; -- 0
        END CASE;

        RETURN tmp;
    END;

    FUNCTION gf_log_4 (
        op : in std_logic_vector(3 downto 0)
    )
    RETURN std_logic_vector IS
        VARIABLE tmp: std_logic_vector(3 downto 0);
    BEGIN

        CASE op IS

            WHEN "0000"  => tmp := "0000"; -- 0
            WHEN "0001"  => tmp := "0000"; -- 0
            WHEN "0010"  => tmp := "0001"; -- 1
            WHEN "0011"  => tmp := "0100"; -- 4
            WHEN "0100"  => tmp := "0010"; -- 2
            WHEN "0101"  => tmp := "1000"; -- 8
            WHEN "0110"  => tmp := "0101"; -- 5
            WHEN "0111"  => tmp := "1010"; -- 10
            WHEN "1000"  => tmp := "0011"; -- 3
            WHEN "1001"  => tmp := "1110"; -- 14
            WHEN "1010"  => tmp := "1001"; -- 9
            WHEN "1011"  => tmp := "0111"; -- 7
            WHEN "1100"  => tmp := "0110"; -- 6
            WHEN "1101"  => tmp := "1101"; -- 13
            WHEN "1110"  => tmp := "1011"; -- 11
            WHEN "1111"  => tmp := "1100"; -- 12
            WHEN OTHERS  => tmp := "0000"; -- 0
        END CASE;

        RETURN tmp;
    END;

    -- Signals
    SIGNAL msg              : std_logic_vector((N*SYMB_BITWIDTH)-1 downto 0);
    SIGNAL decMsg           : std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);

    SIGNAL outSt1           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt2           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt3           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt4           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt5           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt6           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt7           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt8           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt9           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt10          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt11          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt12          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outSt13          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd0          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd1          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd2          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd3          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd4          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd5          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd6          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd7          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd8          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd9          : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd10         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd11         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outAdd12         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult0         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult1         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult2         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult3         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult4         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult5         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult6         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult7         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult8         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult9         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult10        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult11        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult12        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL outMult13        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndr0           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndr1           : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndr0_inv       : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL syndrProd        : std_logic_vector((SYMB_BITWIDTH-1) downto 0);
    SIGNAL errorPos         : std_logic_vector((SYMB_BITWIDTH-1) downto 0);

BEGIN                 --========####   Architecture Body   ####========--

	-- ---------------- The Parallel LFSR HDL description  ---------------- --

    -- MSG mapping
    msg     <=  fecData_i & payloadData_i;

	-- Evaluates the first syndrom
    outSt1  <=  msg(((SYMB_BITWIDTH + 0)-1) downto 0) xor msg(((2*SYMB_BITWIDTH)-1) downto SYMB_BITWIDTH);
	outSt2  <=  msg(((SYMB_BITWIDTH + 2*SYMB_BITWIDTH)-1) downto (2*SYMB_BITWIDTH)) xor outSt1;
	outSt3  <=  msg(((SYMB_BITWIDTH + 3*SYMB_BITWIDTH)-1) downto (3*SYMB_BITWIDTH)) xor outSt2;
	outSt4  <=  msg(((SYMB_BITWIDTH + 4*SYMB_BITWIDTH)-1) downto (4*SYMB_BITWIDTH)) xor outSt3;
	outSt5  <=  msg(((SYMB_BITWIDTH + 5*SYMB_BITWIDTH)-1) downto (5*SYMB_BITWIDTH)) xor outSt4;
	outSt6  <=  msg(((SYMB_BITWIDTH + 6*SYMB_BITWIDTH)-1) downto (6*SYMB_BITWIDTH)) xor outSt5;
	outSt7  <=  msg(((SYMB_BITWIDTH + 7*SYMB_BITWIDTH)-1) downto (7*SYMB_BITWIDTH)) xor outSt6;
	outSt8  <=  msg(((SYMB_BITWIDTH + 8*SYMB_BITWIDTH)-1) downto (8*SYMB_BITWIDTH)) xor outSt7;
	outSt9  <=  msg(((SYMB_BITWIDTH + 9*SYMB_BITWIDTH)-1) downto (9*SYMB_BITWIDTH)) xor outSt8;
	outSt10 <=  msg(((SYMB_BITWIDTH + 10*SYMB_BITWIDTH)-1) downto (10*SYMB_BITWIDTH)) xor outSt9;
	outSt11 <=  msg(((SYMB_BITWIDTH + 11*SYMB_BITWIDTH)-1) downto (11*SYMB_BITWIDTH)) xor outSt10;
	outSt12 <=  msg(((SYMB_BITWIDTH + 12*SYMB_BITWIDTH)-1) downto (12*SYMB_BITWIDTH)) xor outSt11;
	outSt13 <=  msg(((SYMB_BITWIDTH + 13*SYMB_BITWIDTH)-1) downto (13*SYMB_BITWIDTH)) xor outSt12;
	syndr0  <=  msg(((SYMB_BITWIDTH + 14*SYMB_BITWIDTH)-1) downto (14*SYMB_BITWIDTH)) xor outSt13;

    -- Evaluates the second syndrom
    outMult0   <= gf_multBy2_4(msg(SYMB_BITWIDTH-1 downto 0));
	outMult1   <= gf_multBy2_4(outAdd0);
	outMult2   <= gf_multBy2_4(outAdd1);
	outMult3   <= gf_multBy2_4(outAdd2);
	outMult4   <= gf_multBy2_4(outAdd3);
	outMult5   <= gf_multBy2_4(outAdd4);
	outMult6   <= gf_multBy2_4(outAdd5);
	outMult7   <= gf_multBy2_4(outAdd6);
	outMult8   <= gf_multBy2_4(outAdd7);
	outMult9   <= gf_multBy2_4(outAdd8);
	outMult10  <= gf_multBy2_4(outAdd9);
	outMult11  <= gf_multBy2_4(outAdd10);
	outMult12  <= gf_multBy2_4(outAdd11);
	outMult13  <= gf_multBy2_4(outAdd12);

	outAdd0    <= outMult0 xor msg(((SYMB_BITWIDTH+SYMB_BITWIDTH)-1) downto SYMB_BITWIDTH);
	outAdd1    <= outMult1 xor msg(((SYMB_BITWIDTH+2*SYMB_BITWIDTH)-1) downto (2*SYMB_BITWIDTH));
	outAdd2    <= outMult2 xor msg(((SYMB_BITWIDTH+3*SYMB_BITWIDTH)-1) downto (3*SYMB_BITWIDTH));
	outAdd3    <= outMult3 xor msg(((SYMB_BITWIDTH+4*SYMB_BITWIDTH)-1) downto (4*SYMB_BITWIDTH));
	outAdd4    <= outMult4 xor msg(((SYMB_BITWIDTH+5*SYMB_BITWIDTH)-1) downto (5*SYMB_BITWIDTH));
	outAdd5    <= outMult5 xor msg(((SYMB_BITWIDTH+6*SYMB_BITWIDTH)-1) downto (6*SYMB_BITWIDTH));
	outAdd6    <= outMult6 xor msg(((SYMB_BITWIDTH+7*SYMB_BITWIDTH)-1) downto (7*SYMB_BITWIDTH));
	outAdd7    <= outMult7 xor msg(((SYMB_BITWIDTH+8*SYMB_BITWIDTH)-1) downto (8*SYMB_BITWIDTH));
	outAdd8    <= outMult8 xor msg(((SYMB_BITWIDTH+9*SYMB_BITWIDTH)-1) downto (9*SYMB_BITWIDTH));
	outAdd9    <= outMult9 xor msg(((SYMB_BITWIDTH+10*SYMB_BITWIDTH)-1) downto (10*SYMB_BITWIDTH));
	outAdd10   <= outMult10 xor msg(((SYMB_BITWIDTH+11*SYMB_BITWIDTH)-1) downto (11*SYMB_BITWIDTH));
	outAdd11   <= outMult11 xor msg(((SYMB_BITWIDTH+12*SYMB_BITWIDTH)-1) downto (12*SYMB_BITWIDTH));
	outAdd12   <= outMult12 xor msg(((SYMB_BITWIDTH+13*SYMB_BITWIDTH)-1) downto (13*SYMB_BITWIDTH));
	syndr1     <= outMult13 xor msg(((SYMB_BITWIDTH+14*SYMB_BITWIDTH)-1) downto (14*SYMB_BITWIDTH));

	-- Evaluates position of error
    syndr0_inv   <= gf_inv_4(syndr0);
    syndrProd    <= gf_mult_4(syndr0_inv, syndr1);
    errorPos     <= gf_log_4(syndrProd);

    -- Correct message.. Correction on parity bits is ignored!
    decMsg(((SYMB_BITWIDTH+12*SYMB_BITWIDTH)-1) downto (12*SYMB_BITWIDTH)) <= msg(((SYMB_BITWIDTH+12*SYMB_BITWIDTH)-1) downto (12*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0010" ELSE
                                                                              msg(((SYMB_BITWIDTH+12*SYMB_BITWIDTH)-1) downto (12*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+11*SYMB_BITWIDTH)-1) downto (11*SYMB_BITWIDTH)) <= msg(((SYMB_BITWIDTH+11*SYMB_BITWIDTH)-1) downto (11*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0011" ELSE
                                                                              msg(((SYMB_BITWIDTH+11*SYMB_BITWIDTH)-1) downto (11*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+10*SYMB_BITWIDTH)-1) downto (10*SYMB_BITWIDTH)) <= msg(((SYMB_BITWIDTH+10*SYMB_BITWIDTH)-1) downto (10*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0100" ELSE
                                                                              msg(((SYMB_BITWIDTH+10*SYMB_BITWIDTH)-1) downto (10*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+9*SYMB_BITWIDTH)-1) downto (9*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+9*SYMB_BITWIDTH)-1) downto (9*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0101" ELSE
                                                                              msg(((SYMB_BITWIDTH+9*SYMB_BITWIDTH)-1) downto (9*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+8*SYMB_BITWIDTH)-1) downto (8*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+8*SYMB_BITWIDTH)-1) downto (8*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0110" ELSE
                                                                              msg(((SYMB_BITWIDTH+8*SYMB_BITWIDTH)-1) downto (8*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+7*SYMB_BITWIDTH)-1) downto (7*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+7*SYMB_BITWIDTH)-1) downto (7*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "0111" ELSE
                                                                              msg(((SYMB_BITWIDTH+7*SYMB_BITWIDTH)-1) downto (7*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+6*SYMB_BITWIDTH)-1) downto (6*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+6*SYMB_BITWIDTH)-1) downto (6*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1000" ELSE
                                                                              msg(((SYMB_BITWIDTH+6*SYMB_BITWIDTH)-1) downto (6*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+5*SYMB_BITWIDTH)-1) downto (5*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+5*SYMB_BITWIDTH)-1) downto (5*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1001" ELSE
                                                                              msg(((SYMB_BITWIDTH+5*SYMB_BITWIDTH)-1) downto (5*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+4*SYMB_BITWIDTH)-1) downto (4*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+4*SYMB_BITWIDTH)-1) downto (4*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1010" ELSE
                                                                              msg(((SYMB_BITWIDTH+4*SYMB_BITWIDTH)-1) downto (4*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+3*SYMB_BITWIDTH)-1) downto (3*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+3*SYMB_BITWIDTH)-1) downto (3*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1011" ELSE
                                                                              msg(((SYMB_BITWIDTH+3*SYMB_BITWIDTH)-1) downto (3*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+2*SYMB_BITWIDTH)-1) downto (2*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+2*SYMB_BITWIDTH)-1) downto (2*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1100" ELSE
                                                                              msg(((SYMB_BITWIDTH+2*SYMB_BITWIDTH)-1) downto (2*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+1*SYMB_BITWIDTH)-1) downto (1*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+1*SYMB_BITWIDTH)-1) downto (1*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1101" ELSE
                                                                              msg(((SYMB_BITWIDTH+1*SYMB_BITWIDTH)-1) downto (1*SYMB_BITWIDTH));

    decMsg(((SYMB_BITWIDTH+0*SYMB_BITWIDTH)-1) downto (0*SYMB_BITWIDTH))   <= msg(((SYMB_BITWIDTH+0*SYMB_BITWIDTH)-1) downto (0*SYMB_BITWIDTH)) xor syndr0 WHEN errorPos = "1110" ELSE
                                                                              msg(((SYMB_BITWIDTH+0*SYMB_BITWIDTH)-1) downto (0*SYMB_BITWIDTH));

    data_o <= decMsg;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--