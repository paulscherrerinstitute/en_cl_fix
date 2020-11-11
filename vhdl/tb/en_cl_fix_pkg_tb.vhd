---------------------------------------------------------------------------------------------------
--  Copyright (c) 2018 by Paul Scherrer Institute, Switzerland
--  All rights reserved.
--  Authors: Oliver Bründler
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
library std;
	use std.textio.all;
	
use work.en_cl_fix_pkg.all;
	

entity en_cl_fix_pkg_tb is
end entity en_cl_fix_pkg_tb;

architecture sim of en_cl_fix_pkg_tb is

	-- Define VHDL-2008 equivalent for tools that are not VHDL 2008 capable (e.g. vivado simulator)
	function to_string( a: std_logic_vector) return string is
		variable b : string (1 to a'length) := (others => NUL);
		variable stri : integer := 1; 
	begin
		for i in a'range loop
			b(stri) := std_logic'image(a((i)))(2);
			stri := stri+1;
		end loop;
		return b;
	end function;

	procedure CheckStdlv(	expected : std_logic_vector;
							actual	 : std_logic_vector;
							msg		 : string) is
	begin
		assert expected = actual
			report "###ERROR### " & msg & " [expected: " & to_string(expected) & ", got: " & to_string(actual) & "]"
			severity error;
	end procedure;
	
	
	procedure CheckInt(	expected : integer;
						actual	 : integer;
						msg		 : string) is
	begin
		assert expected = actual
			report "###ERROR### " & msg & " [expected: " & integer'image(expected) & ", got: " & integer'image(actual) & "]"
			severity error;
	end procedure;	
	
	procedure CheckReal(	expected : real;
							actual	 : real;
							msg		 : string) is
	begin
		assert expected < actual + 1.0e-12 and expected > actual - 1.0e-12
			report "###ERROR### " & msg & " [expected: " & real'image(expected) & ", got: " & real'image(actual) & "]"
			severity error;
	end procedure;	

	procedure CheckStdl(	expected : std_logic;
							actual	 : std_logic;
							msg		 : string) is
	begin
		assert expected = actual
			report "###ERROR### " & msg & " [expected: " & std_logic'image(expected) & ", got: " & std_logic'image(actual) & "]"
			severity error;
	end procedure;		
	
	procedure CheckBoolean(	expected : boolean;
							actual	 : boolean;
							msg		 : string) is
	begin
		assert expected = actual
			report "###ERROR### " & msg & " [expected: " & boolean'image(expected) & ", got: " & boolean'image(actual) & "]"
			severity error;
	end procedure;		

	procedure print(text : string) is
		variable l : line;
	begin
		write(l, text);
		writeline(output, l);
	end procedure;

begin

	-------------------------------------------------------------------------
	-- TB Control
	-------------------------------------------------------------------------
	p_control : process
	begin
		-- *** cl_fix_width ***
		print("*** cl_fix_width ***");
		CheckInt(3, cl_fix_width((false, 3, 0)), 	"cl_fix_width Wrong: Integer only, Unsigned, NoFractional Bits");
		CheckInt(4, cl_fix_width((true, 3, 0)), 	"cl_fix_width Wrong: Integer only, Signed, NoFractional Bits");
		CheckInt(3, cl_fix_width((false, 0, 3)), 	"cl_fix_width Wrong: Fractional only, Unsigned, No Integer Bits");
		CheckInt(4, cl_fix_width((true, 0, 3)), 	"cl_fix_width Wrong: Fractional only, Signed, No Integer Bits");
		CheckInt(7, cl_fix_width((true, 3, 3)), 	"cl_fix_width Wrong: Integer and Fractional Bits");
		CheckInt(2, cl_fix_width((true, -2, 3)),	"cl_fix_width Wrong: Negative integer bits");
		CheckInt(2, cl_fix_width((true, 3, -2)), 	"cl_fix_width Wrong: Negative fractional bits");
	
		-- *** cl_fix_from_real ***
		print("*** cl_fix_from_real ***");
		CheckStdlv(	"0011", 	
					cl_fix_from_real(	3.0, (true, 3, 0)), 
					"cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
		CheckStdlv(	"1101", 	
					cl_fix_from_real(	-3.0, (true, 3, 0)), 
					"cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Negative");			
		CheckStdlv(	"011", 	
					cl_fix_from_real(	3.0, (false, 3, 0)), 
					"cl_fix_from_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
		CheckStdlv(	"110011", 	
					cl_fix_from_real(	-3.25, (true, 3, 2)), 
					"cl_fix_from_real Wrong: Integer and Fractional");
        CheckStdlv(	"001101", 	
					cl_fix_from_real(	3.24, (true, 3, 2)), 
					"cl_fix_from_real Wrong: Rounding");
        CheckStdlv(	"001100", 	
					cl_fix_from_real(	3.124, (true, 3, 2)), 
					"cl_fix_from_real Wrong: Rounding");	
		CheckStdlv(	"11010", 	
					cl_fix_from_real(	-3.24, (true, 3, 1)), 
					"cl_fix_from_real Wrong: Rounding");	
		CheckStdlv(	"01", 	
					cl_fix_from_real(	0.125, (false, -1, 3)), 
					"cl_fix_from_real Wrong: Negative Integer Bits");	
		CheckStdlv(	"010", 	
					cl_fix_from_real(	4.0, (true, 3, -1)), 
					"cl_fix_from_real Wrong: Negative Fractional Bits");	
					
		-- *** cl_fix_to_real ***
		print("*** cl_fix_to_real ***");
		CheckReal(	3.0, 	
					cl_fix_to_real(cl_fix_from_real(	3.0, (true, 3, 0)), (true, 3, 0)), 
					"cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
		CheckReal(	-3.0, 	
					cl_fix_to_real(cl_fix_from_real(	-3.0, (true, 3, 0)), (true, 3, 0)),
					"cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Negative");			
		CheckReal(	3.0, 	
					cl_fix_to_real(cl_fix_from_real(	3.0, (false, 3, 0)), (false, 3, 0)),
					"cl_fix_to_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
		CheckReal(	-3.25, 	
					cl_fix_to_real(cl_fix_from_real(	-3.25, (true, 3, 2)), (true, 3, 2)),
					"cl_fix_to_real Wrong: Integer and Fractional");	
		CheckReal(	-3.0, 	
					cl_fix_to_real(cl_fix_from_real(	-3.24, (true, 3, 1)), (true, 3, 1)),
					"cl_fix_to_real Wrong: Rounding");	
		CheckReal(	0.125, 	
					cl_fix_to_real(cl_fix_from_real(	0.125, (false, -1, 3)), (false, -1, 3)),
					"cl_fix_to_real Wrong: Negative Integer Bits");	
		CheckReal(	4.0, 	
					cl_fix_to_real(cl_fix_from_real(	4.0, (true, 3, -1)), (true, 3, -1)),
					"cl_fix_to_real Wrong: Negative Fractional Bits");		
					
		-- *** cl_fix_from_bits_as_int ***
		print("*** cl_fix_from_bits_as_int ***");
		CheckStdlv("0011", cl_fix_from_bits_as_int(3, (false, 4, 0)), "cl_fix_from_bits_as_int: Unsigned Positive");
		CheckStdlv("0011", cl_fix_from_bits_as_int(3, (true, 3, 0)), "cl_fix_from_bits_as_int: Signed Positive");
		CheckStdlv("1101", cl_fix_from_bits_as_int(-3, (true, 3, 0)), "cl_fix_from_bits_as_int: Signed Negative");
		CheckStdlv("1101", cl_fix_from_bits_as_int(-3, (true, 1, 2)), "cl_fix_from_bits_as_int: Fractional"); -- binary point position is not important
		CheckStdlv("0001", cl_fix_from_bits_as_int(17, (false, 4, 0)), "cl_fix_from_bits_as_int: Wrap Unsigned");		
		
		-- *** cl_fix_get_bits_as_int ***
		print("*** cl_fix_get_bits_as_int ***");
		CheckInt(3, cl_fix_get_bits_as_int("11", (false,2,0)), "cl_fix_get_bits_as_int: Unsigned Positive");
		CheckInt(3, cl_fix_get_bits_as_int("011", (true,2,0)), "cl_fix_get_bits_as_int: Signed Positive");
		CheckInt(-3, cl_fix_get_bits_as_int("1101", (true,3,0)), "cl_fix_get_bits_as_int: Signed Negative");
		CheckInt(-3, cl_fix_get_bits_as_int("1101", (true,1,2)), "cl_fix_get_bits_as_int: Fractional"); -- binary point position is not important

		-- *** cl_fix_resize ***
		print("*** cl_fix_resize ***");
		CheckStdlv(	"0101", cl_fix_resize("0101", (true, 2, 1), (true, 2, 1)), 
					"cl_fix_resize: No formatchange");
					
		CheckStdlv(	"010", cl_fix_resize("0101", (true, 2, 1), (true, 2, 0), Trunc_s), 
					"cl_fix_resize: Remove Frac Bit 1 Trunc");
		CheckStdlv(	"011", cl_fix_resize("0101", (true, 2, 1), (true, 2, 0), Round_s), 
					"cl_fix_resize: Remove Frac Bit 1 Round");
		CheckStdlv(	"010", cl_fix_resize("0100", (true, 2, 1), (true, 2, 0), Trunc_s), 
					"cl_fix_resize: Remove Frac Bit 0 Trunc");
		CheckStdlv(	"010", cl_fix_resize("0100", (true, 2, 1), (true, 2, 0), Round_s), 
					"cl_fix_resize: Remove Frac Bit 0 Round");	
					
		CheckStdlv(	"01000", cl_fix_resize("0100", (true, 2, 1), (true, 2, 2), Round_s), 
					"cl_fix_resize: Add Fractional Bit Signed");	
		CheckStdlv(	"1000", cl_fix_resize("100", (false, 2, 1), (false, 2, 2), Round_s), 
					"cl_fix_resize: Add Fractional Bit Unsigned");	

		CheckStdlv(	"0111", cl_fix_resize("00111", (true, 3, 1), (true, 2, 1), Trunc_s, None_s), 
					"cl_fix_resize: Remove Integer Bit, Signed, NoSat, Positive");
		CheckStdlv(	"1001", cl_fix_resize("11001", (true, 3, 1), (true, 2, 1), Trunc_s, Sat_s), 
					"cl_fix_resize: Remove Integer Bit, Signed, NoSat, Negative");
		CheckStdlv(	"1011", cl_fix_resize("01011", (true, 3, 1), (true, 2, 1), Trunc_s, None_s), 
					"cl_fix_resize: Remove Integer Bit, Signed, Wrap, Positive");
		CheckStdlv(	"0011", cl_fix_resize("10011", (true, 3, 1), (true, 2, 1), Trunc_s, None_s), 
					"cl_fix_resize: Remove Integer Bit, Signed, Wrap, Negative");			
		CheckStdlv(	"0111", cl_fix_resize("01011", (true, 3, 1), (true, 2, 1), Trunc_s, Sat_s), 
					"cl_fix_resize: Remove Integer Bit, Signed, Sat, Positive");
		CheckStdlv(	"1000", cl_fix_resize("10011", (true, 3, 1), (true, 2, 1), Trunc_s, Sat_s), 
					"cl_fix_resize: Remove Integer Bit, Signed, Sat, Negative");
					
		CheckStdlv(	"111", cl_fix_resize("0111", (false, 3, 1), (false, 2, 1), Trunc_s, None_s), 
					"cl_fix_resize: Remove Integer Bit, Unsigned, NoSat, Positive");
		CheckStdlv(	"011", cl_fix_resize("1011", (false, 3, 1), (false, 2, 1), Trunc_s, None_s), 
					"cl_fix_resize: Remove Integer Bit, Unsigned, Wrap, Positive");		
		CheckStdlv(	"111", cl_fix_resize("1011", (false, 3, 1), (false, 2, 1), Trunc_s, Sat_s), 
					"cl_fix_resize: Remove Integer Bit, Unsigned, Sat, Positive");					
					
		CheckStdlv(	"0111", cl_fix_resize("00111", (true, 3, 1), (false, 3, 1), Trunc_s, None_s), 
					"cl_fix_resize: Remove Sign Bit, Signed, NoSat, Positive");
		CheckStdlv(	"0011", cl_fix_resize("10011", (true, 3, 1), (false, 3, 1), Trunc_s, None_s), 
					"cl_fix_resize: Remove Sign Bit, Signed, Wrap, Negative");			
		CheckStdlv(	"0000", cl_fix_resize("10011", (true, 3, 1), (false, 3, 1), Trunc_s, Sat_s), 
					"cl_fix_resize: Remove Sign Bit, Signed, Sat, Negative");

		CheckStdlv(	"1000", cl_fix_resize("01111", (true, 3, 1), (true, 3, 0), Round_s, None_s), 
					"cl_fix_resize: Overflow due rounding, Signed, Wrap");
		CheckStdlv(	"0111", cl_fix_resize("01111", (true, 3, 1), (true, 3, 0), Round_s, Sat_s), 
					"cl_fix_resize: Overflow due rounding, Signed, Sat");
		CheckStdlv(	"000", cl_fix_resize("1111", (false, 3, 1), (false, 3, 0), Round_s, None_s), 
					"cl_fix_resize: Overflow due rounding, Unsigned, Wrap");
		CheckStdlv(	"111", cl_fix_resize("1111", (false, 3, 1), (false, 3, 0), Round_s, Sat_s), 
					"cl_fix_resize: Overflow due rounding, Unsigned, Sat");
					
		CheckStdlv(	"1111", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s), 
					"cl_fix_resize: NonSymNeg_s -0.5");		
		CheckStdlv(	"1110", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s), 
					"cl_fix_resize: NonSymNeg_s -1.5");		
		CheckStdlv(	"0000", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s), 
					"cl_fix_resize: NonSymNeg_s 0.5");		
		CheckStdlv(	"0001", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s), 
					"cl_fix_resize: NonSymNeg_s 1.5");		
		CheckStdlv(	"0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), NonSymNeg_s, None_s), 
					"cl_fix_resize: NonSymNeg_s 1.75");						

		CheckStdlv(	"1111", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), SymInf_s, None_s), 
					"cl_fix_resize: SymInf_s -0.5");		
		CheckStdlv(	"1110", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), SymInf_s, None_s), 
					"cl_fix_resize: SymInf_s -1.5");		
		CheckStdlv(	"0001", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), SymInf_s, None_s), 
					"cl_fix_resize: SymInf_s 0.5");		
		CheckStdlv(	"0010", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), SymInf_s, None_s), 
					"cl_fix_resize: SymInf_s 1.5");
		CheckStdlv(	"0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), SymInf_s, None_s), 
					"cl_fix_resize: SymInf_s 1.75");						

		CheckStdlv(	"0000", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), SymZero_s, None_s), 
					"cl_fix_resize: SymZero_s -0.5");		
		CheckStdlv(	"1111", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), SymZero_s, None_s), 
					"cl_fix_resize: SymZero_s -1.5");		
		CheckStdlv(	"0000", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), SymZero_s, None_s), 
					"cl_fix_resize: SymZero_s 0.5");		
		CheckStdlv(	"0001", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), SymZero_s, None_s), 
					"cl_fix_resize: SymZero_s 1.5");
		CheckStdlv(	"0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), SymZero_s, None_s), 
					"cl_fix_resize: SymZero_s 1.75");						

		CheckStdlv(	"0000", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s), 
					"cl_fix_resize: ConvEven_s -0.5");		
		CheckStdlv(	"1110", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s), 
					"cl_fix_resize: ConvEven_s -1.5");		
		CheckStdlv(	"0000", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s), 
					"cl_fix_resize: ConvEven_s 0.5");		
		CheckStdlv(	"0010", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s), 
					"cl_fix_resize: ConvEven_s 1.5");	
		CheckStdlv(	"0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), ConvEven_s, None_s), 
					"cl_fix_resize: ConvEven_s 1.75");						

		CheckStdlv(	"1111", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s), 
					"cl_fix_resize: ConvOdd_s -0.5");		
		CheckStdlv(	"1111", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s), 
					"cl_fix_resize: ConvOdd_s -1.5");		
		CheckStdlv(	"0001", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s), 
					"cl_fix_resize: ConvOdd_s 0.5");		
		CheckStdlv(	"0001", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s), 
					"cl_fix_resize: ConvOdd_s 1.5");
		CheckStdlv(	"0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), ConvOdd_s, None_s), 
					"cl_fix_resize: ConvOdd_s 1.75");						

					
		-- error cases
		CheckStdlv(	"0000101000", cl_fix_resize(cl_fix_from_real(2.5, (false, 5, 4)), (false, 5, 4), (false, 6, 4)), 
					"cl_fix_resize: Overflow due rounding, Unsigned, Sat");
		CheckStdlv(	"000010100", cl_fix_resize(cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3), (false, 5, 4)), 
					"cl_fix_resize: Overflow due rounding, Unsigned, Sat");
						
		-- *** cl_fix_add ***
		print("*** cl_fix_add ***");					
		CheckStdlv(	cl_fix_from_real(-2.5+1.25, (true, 5, 3)), 
					cl_fix_add(	cl_fix_from_real(-2.5, (true, 5, 3)), (true, 5, 3),
								cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
								(true, 5, 3)),
					"cl_fix_add: Same Fmt Signed");	
		CheckStdlv(	cl_fix_from_real(2.5+1.25, (false, 5, 3)), 
					cl_fix_add(	cl_fix_from_real(2.5, (false, 5, 3)), (false, 5, 3),
								cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
								(false, 5, 3)),
					"cl_fix_add: Same Fmt Usigned");		
		CheckStdlv(	cl_fix_from_real(-2.5+1.25, (true, 5, 3)), 
					cl_fix_add(	cl_fix_from_real(-2.5, (true, 6, 3)), (true, 6, 3),
								cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
								(true, 5, 3)),
					"cl_fix_add: Different Int Bits Signed");	
		CheckStdlv(	cl_fix_from_real(2.5+1.25, (false, 5, 3)), 
					cl_fix_add(	cl_fix_from_real(2.5, (false, 6, 3)), (false, 6, 3),
								cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
								(false, 5, 3)),
					"cl_fix_add: Different Int Bits Usigned");	
		CheckStdlv(	cl_fix_from_real(-2.5+1.25, (true, 5, 3)), 
					cl_fix_add(	cl_fix_from_real(-2.5, (true, 5, 4)), (true, 5, 4),
								cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
								(true, 5, 3)),
					"cl_fix_add: Different Frac Bits Signed");	
		CheckStdlv(	cl_fix_from_real(2.5+1.25, (false, 5, 3)), 
					cl_fix_add(	cl_fix_from_real(2.5, (false, 5, 4)), (false, 5, 4),
								cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
								(false, 5, 3)),
					"cl_fix_add: Different Frac Bits Usigned");	
		CheckStdlv(	cl_fix_from_real(0.75+4.0, (false, 5, 5)), 
					cl_fix_add(	cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
								cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),
								(false, 5, 5)),
					"cl_fix_add: Different Ranges Unsigned");	
		CheckStdlv(	cl_fix_from_real(5.0, (false, 5, 0)), 
					cl_fix_add(	cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
								cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),
								(false, 5, 0), Round_s),
					"cl_fix_add: Round");		
		CheckStdlv(	cl_fix_from_real(15.0, (false, 4, 0)), 
					cl_fix_add(	cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
								cl_fix_from_real(15.0, (false, 4, 0)), (false, 4, 0),
								(false, 4, 0), Round_s, Sat_s),
					"cl_fix_add: Satturate");
					
		-- *** cl_fix_sub ***
		print("*** cl_fix_sub ***");					
		CheckStdlv(	cl_fix_from_real(-2.5-1.25, (true, 5, 3)), 
					cl_fix_sub(	cl_fix_from_real(-2.5, (true, 5, 3)), (true, 5, 3),
								cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
								(true, 5, 3)),
					"cl_fix_sub: Same Fmt Signed");	
		CheckStdlv(	cl_fix_from_real(2.5-1.25, (false, 5, 3)), 
					cl_fix_sub(	cl_fix_from_real(2.5, (false, 5, 3)), (false, 5, 3),
								cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
								(false, 5, 3)),
					"cl_fix_sub: Same Fmt Usigned");		
		CheckStdlv(	cl_fix_from_real(-2.5-1.25, (true, 5, 3)), 
					cl_fix_sub(	cl_fix_from_real(-2.5, (true, 6, 3)), (true, 6, 3),
								cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
								(true, 5, 3)),
					"cl_fix_sub: Different Int Bits Signed");	
		CheckStdlv(	cl_fix_from_real(2.5-1.25, (false, 5, 3)), 
					cl_fix_sub(	cl_fix_from_real(2.5, (false, 6, 3)), (false, 6, 3),
								cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
								(false, 5, 3)),
					"cl_fix_sub: Different Int Bits Usigned");	
		CheckStdlv(	cl_fix_from_real(-2.5-1.25, (true, 5, 3)), 
					cl_fix_sub(	cl_fix_from_real(-2.5, (true, 5, 4)), (true, 5, 4),
								cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
								(true, 5, 3)),
					"cl_fix_sub: Different Frac Bits Signed");	
		CheckStdlv(	cl_fix_from_real(2.5-1.25, (false, 5, 3)), 
					cl_fix_sub(	cl_fix_from_real(2.5, (false, 5, 4)), (false, 5, 4),
								cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
								(false, 5, 3)),
					"cl_fix_sub: Different Frac Bits Usigned");	
		CheckStdlv(	cl_fix_from_real(4.0-0.75, (false, 5, 5)), 
					cl_fix_sub(	cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),	
								cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),								
								(false, 5, 5)),
					"cl_fix_sub: Different Ranges Unsigned");	
		CheckStdlv(	cl_fix_from_real(4.0, (false, 5, 0)), 
					cl_fix_sub(	cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),
								cl_fix_from_real(0.25, (false, 0, 4)), (false, 0, 4),								
								(false, 5, 0), Round_s),
					"cl_fix_sub: Round");		
		CheckStdlv(	cl_fix_from_real(0.0, (false, 4, 0)), 
					cl_fix_sub(	cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
								cl_fix_from_real(5.0, (false, 4, 0)), (false, 4, 0),
								(false, 4, 0), Round_s, Sat_s),
					"cl_fix_sub: Satturate");
		CheckStdlv(	cl_fix_from_real(-16.0, (true, 4, 0)), 
					cl_fix_sub(	cl_fix_from_real(0.0, (true, 4, 0)), (true, 4, 0),
								cl_fix_from_real(-16.0, (true, 4, 0)), (true, 4, 0),
								(true, 4, 0), Round_s, None_s),
					"cl_fix_sub: Invert most negative signed, noSat");
		CheckStdlv(	cl_fix_from_real(15.0, (true, 4, 0)), 
					cl_fix_sub(	cl_fix_from_real(0.0, (true, 4, 0)), (true, 4, 0),
								cl_fix_from_real(-16.0, (true, 4, 0)), (true, 4, 0),
								(true, 4, 0), Round_s, Sat_s),
					"cl_fix_sub: Invert most negative signed, Sat");		
		CheckStdlv(	cl_fix_from_real(1.0, (false, 4, 0)), 
					cl_fix_sub(	cl_fix_from_real(0.0, (false, 4, 0)), (false, 4, 0),
								cl_fix_from_real(15.0, (false, 4, 0)), (false, 4, 0),
								(false, 4, 0), Round_s, None_s),
					"cl_fix_sub: Invert most negative unsigned, noSat");
		CheckStdlv(	cl_fix_from_real(0.0, (false, 4, 0)), 
					cl_fix_sub(	cl_fix_from_real(0.0, (false, 4, 0)), (false, 4, 0),
								cl_fix_from_real(15.0, (false, 4, 0)), (false, 4, 0),
								(false, 4, 0), Round_s, Sat_s),
					"cl_fix_sub: Invert unsigned, Sat");	

		-- *** cl_fix_mult ***
		print("*** cl_fix_mult ***");					
		CheckStdlv(	cl_fix_from_real(2.5*1.25, (false, 5, 5)), 
					cl_fix_mult(	cl_fix_from_real(2.5, (false, 5, 1)), (false, 5, 1),
								cl_fix_from_real(1.25, (false, 5, 2)), (false, 5, 2),
								(false, 5, 5)),
					"cl_fix_mult: A unsigned positive, B unsigned positive");		
		CheckStdlv(	cl_fix_from_real(2.5*1.25, (true, 3, 3)), 
					cl_fix_mult(	cl_fix_from_real(2.5, (true, 2, 1)), (true, 2, 1),
								cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
								(true, 3, 3)),
					"cl_fix_mult: A signed positive, B signed positive");	
		CheckStdlv(	cl_fix_from_real(2.5*(-1.25), (true, 3, 3)), 
					cl_fix_mult(	cl_fix_from_real(2.5, (true, 2, 1)), (true, 2, 1),
								cl_fix_from_real(-1.25, (true, 1, 2)), (true, 1, 2),
								(true, 3, 3)),
					"cl_fix_mult: A signed positive, B signed negative");	
		CheckStdlv(	cl_fix_from_real((-2.5)*1.25, (true, 3, 3)), 
					cl_fix_mult(	cl_fix_from_real(-2.5, (true, 2, 1)), (true, 2, 1),
								cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
								(true, 3, 3)),
					"cl_fix_mult: A signed negative, B signed positive");		
		CheckStdlv(	cl_fix_from_real((-2.5)*(-1.25), (true, 3, 3)), 
					cl_fix_mult(	cl_fix_from_real(-2.5, (true, 2, 1)), (true, 2, 1),
								cl_fix_from_real(-1.25, (true, 1, 2)), (true, 1, 2),
								(true, 3, 3)),
					"cl_fix_mult: A signed negative, B signed negative");
		CheckStdlv(	cl_fix_from_real(2.5*1.25, (true, 3, 3)), 
					cl_fix_mult(	cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
								cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
								(true, 3, 3)),
					"cl_fix_mult: A unsigned positive, B signed positive");
		CheckStdlv(	cl_fix_from_real(2.5*(-1.25), (true, 3, 3)), 
					cl_fix_mult(	cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
								cl_fix_from_real(-1.25, (true, 1, 2)), (true, 1, 2),
								(true, 3, 3)),
					"cl_fix_mult: A unsigned positive, B signed negative");	
		CheckStdlv(	cl_fix_from_real(2.5*1.25, (false, 3, 3)), 
					cl_fix_mult(	cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
								cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
								(false, 3, 3)),
					"cl_fix_mult: A unsigned positive, B signed positive, result unsigned");			
		CheckStdlv(	cl_fix_from_real(1.875, (false, 1, 3)), 
					cl_fix_mult(	cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
								cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
								(false, 1, 3), Trunc_s, Sat_s),
					"cl_fix_mult: A unsigned positive, B signed positive, saturate");			

		-- *** cl_fix_abs ***
		print("*** cl_fix_abs ***");					
		CheckStdlv(	cl_fix_from_real(2.5, (false, 5, 5)), 
					cl_fix_abs(	cl_fix_from_real(2.5, (false, 5, 1)), (false, 5, 1),
								(false, 5, 5)),
					"cl_fix_abs: positive stay positive");		
		CheckStdlv(	cl_fix_from_real(4.0, (true, 3, 3)), 
					cl_fix_abs(	cl_fix_from_real(-4.0, (true, 2, 2)), (true, 2, 2),
								(true, 3, 3)),
					"cl_fix_abs: negative becomes positive");	
		CheckStdlv(	cl_fix_from_real(3.75, (true, 2, 2)), 
					cl_fix_abs(	cl_fix_from_real(-4.0, (true, 2, 2)), (true, 2, 2),
								(true, 2, 2), Trunc_s, Sat_s),
					"cl_fix_abs: most negative value sat");		
					
		-- *** cl_fix_neg ***
		print("*** cl_fix_neg ***");
		CheckStdlv(	cl_fix_from_real(-2.5, (true, 5, 5)), 
					cl_fix_neg(	cl_fix_from_real(2.5, (true, 5, 1)), (true, 5, 1), '1',
								(true, 5, 5)),
					"cl_fix_neg: positive to negative (signed -> signed)");	
		CheckStdlv(	cl_fix_from_real(-2.5, (true, 5, 5)), 
					cl_fix_neg(	cl_fix_from_real(2.5, (false, 5, 1)), (false, 5, 1), '1',
								(true, 5, 5)),
					"cl_fix_neg: positive to negative (unsigned -> signed)");	
		CheckStdlv(	cl_fix_from_real(2.5, (true, 5, 5)), 
					cl_fix_neg(	cl_fix_from_real(-2.5, (true, 5, 1)), (true, 5, 1), '1',
								(true, 5, 5)),
					"cl_fix_neg: negative to positive (signed -> signed)");			
		CheckStdlv(	cl_fix_from_real(2.5, (false, 5, 5)), 
					cl_fix_neg(	cl_fix_from_real(-2.5, (true, 5, 1)), (true, 5, 1), '1',
								(false, 5, 5)),
					"cl_fix_neg: negative to positive (signed -> unsigned)");		
		CheckStdlv(	cl_fix_from_real(3.75, (true, 2, 2)), 
					cl_fix_neg(	cl_fix_from_real(-4.0, (true, 2, 4)), (true, 2, 4), '1',
								(true, 2, 2), Trunc_s, Sat_s),
					"cl_fix_neg: saturation (signed -> signed)");			
		CheckStdlv(	cl_fix_from_real(-4.0, (true, 2, 2)), 
					cl_fix_neg(	cl_fix_from_real(-4.0, (true, 2, 4)), (true, 2, 4), '1',
								(true, 2, 2), Trunc_s, None_s),
					"cl_fix_neg: wrap (signed -> signed)");	
		CheckStdlv(	cl_fix_from_real(0.0, (false, 5, 5)), 
					cl_fix_neg(	cl_fix_from_real(2.5, (true, 5, 1)), (true, 5, 1), '1',
								(false, 5, 5), Trunc_s, Sat_s),
					"cl_fix_neg: positive to negative saturate (signed -> unsigned)");	
		
		-- *** cl_fix_shift left***
		print("*** cl_fix_shift left ***");
		CheckStdlv(	cl_fix_from_real(2.5, (false, 3, 2)), 
					cl_fix_shift(	cl_fix_from_real(1.25, (false, 3, 2)),	(false, 3, 2),
									1,
									(false, 3, 2)),
									"Shift same format unsigned");
		CheckStdlv(	cl_fix_from_real(2.5, (true, 3, 2)), 
					cl_fix_shift(	cl_fix_from_real(1.25, (true, 3, 2)),	(true, 3, 2),
									1,
									(true, 3, 2)),
									"Shift same format signed");			
		CheckStdlv(	cl_fix_from_real(2.5, (false, 3, 2)), 
					cl_fix_shift(	cl_fix_from_real(1.25, (true, 1, 2)),	(true, 1, 2),
									1,
									(false, 3, 2)),
									"Shift format change");	
		CheckStdlv(	cl_fix_from_real(3.75, (true, 2, 2)), 
					cl_fix_shift(	cl_fix_from_real(2.0, (true, 2, 2)),	(true, 2, 2),
									1,
									(true, 2, 2), Trunc_s, Sat_s),
									"saturation signed");
		CheckStdlv(	cl_fix_from_real(3.75, (true, 2, 2)), 
					cl_fix_shift(	cl_fix_from_real(2.0, (false, 3, 2)),	(false, 3, 2),
									1,
									(true, 2, 2), Trunc_s, Sat_s),
									"saturation unsigned to signed");		
		CheckStdlv(	cl_fix_from_real(0.0, (false, 2, 2)), 
					cl_fix_shift(	cl_fix_from_real(-0.5, (true, 3, 2)),	(true, 3, 2),
									1,
									(false, 2, 2), Trunc_s, Sat_s),
									"saturation signed to unsigned");		
		CheckStdlv(	cl_fix_from_real(-4.0, (true, 2, 2)), 
					cl_fix_shift(	cl_fix_from_real(2.0, (true, 2, 2)),	(true, 2, 2),
									1,
									(true, 2, 2), Trunc_s, None_s),
									"wrap signed");		
		CheckStdlv(	cl_fix_from_real(-4.0, (true, 2, 2)), 
					cl_fix_shift(	cl_fix_from_real(2.0, (false, 3, 2)),	(false, 3, 2),
									1,
									(true, 2, 2), Trunc_s, None_s),
									"wrap unsigned to signed");	
		CheckStdlv(	cl_fix_from_real(3.0, (false, 2, 2)), 
					cl_fix_shift(	cl_fix_from_real(-0.5, (true, 3, 2)), (true, 3, 2),
									1,
									(false, 2, 2), Trunc_s, None_s),
									"wrap signed to unsigned");	
		CheckStdlv(	cl_fix_from_real(0.5, (true, 5, 5)), 
					cl_fix_shift(	cl_fix_from_real(0.5, (true, 5, 5)), (true, 5, 5),
									0,
									(true, 5, 5), Trunc_s, None_s),
									"shift 0");		
		CheckStdlv(	cl_fix_from_real(-4.0, (true, 5, 5)), 
					cl_fix_shift(	cl_fix_from_real(-0.5, (true, 5, 5)), (true, 5, 5),
									3,
									(true, 5, 5), Trunc_s, None_s),
									"shift 3");			
		
		-- *** cl_fix_shift right ***
		print("*** cl_fix_shift right  ***");
		CheckStdlv(	cl_fix_from_real(1.25, (false, 3, 2)), 
					cl_fix_shift(	cl_fix_from_real(2.5, (false, 3, 2)),	(false, 3, 2),
									-1, 
									(false, 3, 2)),
									"Shift same format unsigned");
		CheckStdlv(	cl_fix_from_real(1.25, (true, 3, 2)), 
					cl_fix_shift(	cl_fix_from_real(2.5, (true, 3, 2)),	(true, 3, 2),
									-1, 
									(true, 3, 2)),
									"Shift same format signed");			
		CheckStdlv(	cl_fix_from_real(1.25, (true, 1, 2)), 
					cl_fix_shift(	cl_fix_from_real(2.5, (false, 3, 2)),	(false, 3, 2),
									-1,
									(true, 1, 2)),
									"Shift format change");		
		CheckStdlv(	cl_fix_from_real(0.0, (false, 2, 2)), 
					cl_fix_shift(	cl_fix_from_real(-0.5, (true, 3, 2)),	(true, 3, 2),
									-1,
									(false, 2, 2), Trunc_s, Sat_s),
									"saturation signed to unsigned");		
		CheckStdlv(	cl_fix_from_real(0.5, (true, 5, 5)), 
					cl_fix_shift(	cl_fix_from_real(0.5, (true, 5, 5)), (true, 5, 5),
									0,
									(true, 5, 5), Trunc_s, None_s),
									"shift 0");		
		CheckStdlv(	cl_fix_from_real(-0.5, (true, 5, 5)), 
					cl_fix_shift(	cl_fix_from_real(-4.0, (true, 5, 5)), (true, 5, 5),
									-3,
									(true, 5, 5), Trunc_s, None_s),
									"shift 3");	
										
		-- *** cl_fix_max_value ***
		print("*** cl_fix_max_value ***");		
		CheckStdlv(	"1111", cl_fix_max_value((false,2,2)), "unsigned");
		CheckStdlv(	"0111", cl_fix_max_value((true,1,2)), "signed");
		
		-- *** cl_fix_min_value ***
		print("*** cl_fix_min_value ***");		
		CheckStdlv(	"0000", cl_fix_min_value((false,2,2)), "unsigned");
		CheckStdlv(	"1000", cl_fix_min_value((true,1,2)), "signed");
		
		-- *** cl_fix_max_real ***
		print("*** cl_fix_max_real ***");		
		CheckReal(	3.75, cl_fix_max_real((false,2,2)), "unsigned");
		CheckReal(	1.75, cl_fix_max_real((true,1,2)), "signed");
		
		-- *** cl_fix_min_real ***
		print("*** cl_fix_min_real ***");		
		CheckReal(	0.0, cl_fix_min_real((false,2,2)), "unsigned");
		CheckReal(	-2.0, cl_fix_min_real((true,1,2)), "signed");
		
		-- *** cl_fix_in_range ***
		print("*** cl_fix_in_range ***");	
		CheckBoolean(	true, 
						cl_fix_in_range(cl_fix_from_real(1.25, (true, 4, 2)), (true, 4, 2),
										(true, 2, 4), Trunc_s),
						"In Range Normal");
		CheckBoolean(	false, 
						cl_fix_in_range(cl_fix_from_real(6.25, (true, 4, 2)), (true, 4, 2),
										(true, 2, 4), Trunc_s),
						"Out Range Normal");
		CheckBoolean(	false, 
						cl_fix_in_range(cl_fix_from_real(-1.25, (true, 4, 2)), (true, 4, 2),
										(false, 5, 2), Trunc_s),
						"signed -> unsigned OOR");
		CheckBoolean(	false, 
						cl_fix_in_range(cl_fix_from_real(15.0, (false, 4, 2)), (false, 4, 2),
										(true, 3, 2), Trunc_s),
						"unsigned -> signed OOR");		
		CheckBoolean(	true, 
						cl_fix_in_range(cl_fix_from_real(15.0, (false, 4, 2)), (false, 4, 2),
										(true, 4, 2), Trunc_s),
						"unsigned -> signed OK");	
		CheckBoolean(	false, 
						cl_fix_in_range(cl_fix_from_real(15.5, (false, 4, 2)), (false, 4, 2),
										(true, 4, 0), Round_s),
						"rounding OOR");			
		CheckBoolean(	true, 
						cl_fix_in_range(cl_fix_from_real(15.5, (false, 4, 2)), (false, 4, 2),
										(true, 4, 1), Round_s),
						"rounding OK 1");	
		CheckBoolean(	true, 
						cl_fix_in_range(cl_fix_from_real(15.5, (false, 4, 2)), (false, 4, 2),
										(false, 5, 0), Round_s),
						"rounding OK 2");	

		-- *** cl_fix_compare ***
		print("*** cl_fix_compare ***");		
		CheckBoolean(	true, 
						cl_fix_compare(	"a<b",
										cl_fix_from_real(1.25, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a<b unsigned unsigned true");		
		CheckBoolean(	false, 
						cl_fix_compare(	"a<b",
										cl_fix_from_real(1.5, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a<b unsigned unsigned false");	
		CheckBoolean(	true, 
						cl_fix_compare(	"a<b",
										cl_fix_from_real(1.25, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a<b signed unsigned true");		
		CheckBoolean(	false, 
						cl_fix_compare(	"a<b",
										cl_fix_from_real(2.5, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(1.5, (true, 2, 1)), (true, 2, 1)),
						"a<b unsigned signed false");	
		CheckBoolean(	true, 
						cl_fix_compare(	"a<b",
										cl_fix_from_real(-1.25, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(-1.0, (true, 2, 1)), (true, 2, 1)),
						"a<b signed signed true");		
		CheckBoolean(	false, 
						cl_fix_compare(	"a<b",
										cl_fix_from_real(-0.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
						"a<b signed signed false");		
						
		CheckBoolean(	true, 
						cl_fix_compare(	"a=b",
										cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a=b signed unsigned true");		
		CheckBoolean(	false, 
						cl_fix_compare(	"a=b",
										cl_fix_from_real(2.5, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
						"a=b unsigned signed false");	

		CheckBoolean(	true, 
						cl_fix_compare(	"a>b",
										cl_fix_from_real(2.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a>b signed unsigned true");		
		CheckBoolean(	false, 
						cl_fix_compare(	"a>b",
										cl_fix_from_real(1.5, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(1.5, (true, 2, 1)), (true, 2, 1)),
						"a>b unsigned signed false");	

		CheckBoolean(	true, 
						cl_fix_compare(	"a>=b",
										cl_fix_from_real(2.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a>=b signed unsigned true 1");	
		CheckBoolean(	true, 
						cl_fix_compare(	"a>=b",
										cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a>=b signed unsigned true 2");							
		CheckBoolean(	false, 
						cl_fix_compare(	"a>=b",
										cl_fix_from_real(1.25, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(1.5, (true, 2, 1)), (true, 2, 1)),
						"a>=b unsigned signed false 1");

		CheckBoolean(	true, 
						cl_fix_compare(	"a<=b",
										cl_fix_from_real(-2.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a<=b signed unsigned true 1");	
		CheckBoolean(	true, 
						cl_fix_compare(	"a<=b",
										cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a<=b signed unsigned true 2");							
		CheckBoolean(	false, 
						cl_fix_compare(	"a<=b",
										cl_fix_from_real(0.25, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
						"a<=b unsigned signed false 1");						
						
		CheckBoolean(	false, 
						cl_fix_compare(	"a!=b",
										cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
										cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
						"a!=b signed unsigned false");		
		CheckBoolean(	true, 
						cl_fix_compare(	"a!=b",
										cl_fix_from_real(2.5, (false, 4, 2)), (false, 4, 2),
										cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
						"a!=b unsigned signed true");	

		-- *** cl_fix_sign ***
		print("*** cl_fix_sign ***");
		CheckStdl(	'0', cl_fix_sign(cl_fix_from_real(3.25, (false, 2, 2)), (false,2,2)), "Unsigned"); 
		CheckStdl(	'1', cl_fix_sign(cl_fix_from_real(-1.25, (true, 2, 2)), (true,2,2)), "SignedOne"); 
		CheckStdl(	'0', cl_fix_sign(cl_fix_from_real(3.25, (true, 2, 2)), (true,2,2)), "SignedZero"); 
		
		-- *** cl_fix_int ***
		print("*** cl_fix_int ***");
		CheckStdlv(	"11", cl_fix_int(cl_fix_from_real(3.25, (false, 2, 2)), (false,2,2)), "Unsigned"); 
		CheckStdlv(	"11", cl_fix_int(cl_fix_from_real(3.25, (true, 2, 2)), (true,2,2)), "SignedOne"); 
		CheckStdlv(	"10", cl_fix_int(cl_fix_from_real(-1.25, (true, 2, 2)), (true,2,2)), "SignedZero"); 

		-- *** cl_fix_frac ***
		print("*** cl_fix_frac ***");
		CheckStdlv(	"010", cl_fix_frac(cl_fix_from_real(3.25, (false, 2, 3)), (false,2,3)), "Test"); 		
		
		-- *** cl_fix_combine ***
		print("*** cl_fix_combine ***");
		CheckStdlv(	cl_fix_from_real(-3.25, (True,2,2)), 
					cl_fix_combine('1', "00", "11", (True,2,2)), "Test");	

		-- *** cl_fix_get_msb ***
		print("*** cl_fix_get_msb ***");
		CheckStdl(	'1', cl_fix_get_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2), "One"); 				
		CheckStdl(	'0', cl_fix_get_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1), "Zero"); 	

		-- *** cl_fix_get_lsb ***
		print("*** cl_fix_get_lsb ***");
		CheckStdl(	'1', cl_fix_get_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1), "One"); 				
		CheckStdl(	'0', cl_fix_get_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2), "Zero"); 	

		-- *** cl_fix_set_msb ***
		print("*** cl_fix_set_msb ***");
		CheckStdlv(	cl_fix_from_real(2.25, (true,3,3)),
					cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '1'), "SetOne"); 
		CheckStdlv(	cl_fix_from_real(6.25, (true,3,3)),
					cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '1'), "SetZero"); 
		CheckStdlv(	cl_fix_from_real(0.25, (true,3,3)),
					cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '0'), "ClearOne"); 
		CheckStdlv(	cl_fix_from_real(2.25, (true,3,3)),
					cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '0'), "ClearZero"); 

		-- *** cl_fix_set_lsb ***
		print("*** cl_fix_set_lsb ***");
		CheckStdlv(	cl_fix_from_real(2.25, (true,3,3)),
					cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '1'), "SetOne"); 
		CheckStdlv(	cl_fix_from_real(2.75, (true,3,3)),
					cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '1'), "SetZero"); 
		CheckStdlv(	cl_fix_from_real(2.0, (true,3,3)),
					cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '0'), "ClearOne"); 
		CheckStdlv(	cl_fix_from_real(2.25, (true,3,3)),
					cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '0'), "ClearZero"); 

		-- *** cl_fix_sabs ***
		print("*** cl_fix_sabs ***");
		CheckStdlv(	cl_fix_from_real(2.25, (false,2,2)),
					cl_fix_sabs(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), (false,2,2)), "Positive"); 					
		CheckStdlv(	cl_fix_from_real(2.0, (false,2,2)),
					cl_fix_sabs(cl_fix_from_real(-2.25, (true, 3, 3)), (true,3,3), (false,2,2)), "Negative");
					
		-- *** cl_fix_sneg ***
		print("*** cl_fix_sneg ***");
		CheckStdlv(	cl_fix_from_real(-2.5, (true,3,2)),
					cl_fix_sneg(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), '1', (true,3,2)), "Pos"); 					
		CheckStdlv(	cl_fix_from_real(2.0, (true,3,2)),
					cl_fix_sneg(cl_fix_from_real(-2.25, (true, 3, 3)), (true,3,3), '1', (true,3,2)), "Neg"); 

		-- *** cl_fix_addsub ***
		print("*** cl_fix_addsub ***");
		CheckStdlv(	cl_fix_from_real(1.75, (true,3,3)),
					cl_fix_addsub(	cl_fix_from_real(1.0, (true,3,3)), (true,3,3),
									cl_fix_from_real(0.75, (true,3,3)), (true,3,3), '1', (true,3,3)), "Add");	
		CheckStdlv(	cl_fix_from_real(1.0, (true,3,3)),
					cl_fix_addsub(	cl_fix_from_real(1.25, (true,3,3)), (true,3,3),
									cl_fix_from_real(0.25, (true,3,3)), (true,3,3), '0', (true,3,3)), "Sub");		

		-- *** cl_fix_saddsub ***
        print("*** cl_fix_saddsub ***");
		CheckStdlv(	cl_fix_from_real(1.75, (true,3,2)),
					cl_fix_saddsub(	cl_fix_from_real(1.0, (true,3,2)), (true,3,2),
									cl_fix_from_real(0.75, (true,3,2)), (true,3,2), '1', (true,3,2)), "Add");	
		CheckStdlv(	cl_fix_from_real(0.75, (true,3,2)),
					cl_fix_saddsub(	cl_fix_from_real(1.25, (true,3,2)), (true,3,2),
									cl_fix_from_real(0.25, (true,3,2)), (true,3,2), '0', (true,3,2)), "Sub");

        -- *** cl_fix_from_real ***
        print("*** cl_fix_from_real big nums ***");

        CheckStdlv("011", cl_fix_from_real(1.5, (true, 1, 1)), "cl_fix_from_real: 1+2^-1");
        CheckStdlv("0101", cl_fix_from_real(1.25, (true, 1, 2)), "cl_fix_from_real: 1+2^-2");
        CheckStdlv("01001", cl_fix_from_real(1.125, (true, 1, 3)), "cl_fix_from_real: 1+2^-3");
        CheckStdlv("010001", cl_fix_from_real(1.0625, (true, 1, 4)), "cl_fix_from_real: 1+2^-4");
        CheckStdlv("0100001", cl_fix_from_real(1.03125, (true, 1, 5)), "cl_fix_from_real: 1+2^-5");
        CheckStdlv("01000001", cl_fix_from_real(1.015625, (true, 1, 6)), "cl_fix_from_real: 1+2^-6");
        CheckStdlv("010000001", cl_fix_from_real(1.0078125, (true, 1, 7)), "cl_fix_from_real: 1+2^-7");
        CheckStdlv("0100000001", cl_fix_from_real(1.00390625, (true, 1, 8)), "cl_fix_from_real: 1+2^-8");
        CheckStdlv("01000000001", cl_fix_from_real(1.001953125, (true, 1, 9)), "cl_fix_from_real: 1+2^-9");
        CheckStdlv("010000000001", cl_fix_from_real(1.0009765625, (true, 1, 10)), "cl_fix_from_real: 1+2^-10");
        CheckStdlv("0100000000001", cl_fix_from_real(1.00048828125, (true, 1, 11)), "cl_fix_from_real: 1+2^-11");
        CheckStdlv("01000000000001", cl_fix_from_real(1.000244140625, (true, 1, 12)), "cl_fix_from_real: 1+2^-12");
        CheckStdlv("010000000000001", cl_fix_from_real(1.0001220703125, (true, 1, 13)), "cl_fix_from_real: 1+2^-13");
        CheckStdlv("0100000000000001", cl_fix_from_real(1.00006103515625, (true, 1, 14)), "cl_fix_from_real: 1+2^-14");
        CheckStdlv("01000000000000001", cl_fix_from_real(1.000030517578125, (true, 1, 15)), "cl_fix_from_real: 1+2^-15");
        CheckStdlv("010000000000000001", cl_fix_from_real(1.0000152587890625, (true, 1, 16)), "cl_fix_from_real: 1+2^-16");
        CheckStdlv("0100000000000000001", cl_fix_from_real(1.0000076293945312, (true, 1, 17)), "cl_fix_from_real: 1+2^-17");
        CheckStdlv("01000000000000000001", cl_fix_from_real(1.0000038146972656, (true, 1, 18)), "cl_fix_from_real: 1+2^-18");
        CheckStdlv("010000000000000000001", cl_fix_from_real(1.0000019073486328, (true, 1, 19)), "cl_fix_from_real: 1+2^-19");
        CheckStdlv("0100000000000000000001", cl_fix_from_real(1.0000009536743164, (true, 1, 20)), "cl_fix_from_real: 1+2^-20");
        CheckStdlv("01000000000000000000001", cl_fix_from_real(1.0000004768371582, (true, 1, 21)), "cl_fix_from_real: 1+2^-21");
        CheckStdlv("010000000000000000000001", cl_fix_from_real(1.000000238418579, (true, 1, 22)), "cl_fix_from_real: 1+2^-22");
        CheckStdlv("0100000000000000000000001", cl_fix_from_real(1.0000001192092896, (true, 1, 23)), "cl_fix_from_real: 1+2^-23");
        CheckStdlv("01000000000000000000000001", cl_fix_from_real(1.0000000596046448, (true, 1, 24)), "cl_fix_from_real: 1+2^-24");
        CheckStdlv("010000000000000000000000001", cl_fix_from_real(1.0000000298023224, (true, 1, 25)), "cl_fix_from_real: 1+2^-25");
        CheckStdlv("0100000000000000000000000001", cl_fix_from_real(1.0000000149011612, (true, 1, 26)), "cl_fix_from_real: 1+2^-26");
        CheckStdlv("01000000000000000000000000001", cl_fix_from_real(1.0000000074505806, (true, 1, 27)), "cl_fix_from_real: 1+2^-27");
        CheckStdlv("010000000000000000000000000001", cl_fix_from_real(1.0000000037252903, (true, 1, 28)), "cl_fix_from_real: 1+2^-28");
        CheckStdlv("0100000000000000000000000000001", cl_fix_from_real(1.0000000018626451, (true, 1, 29)), "cl_fix_from_real: 1+2^-29");
        CheckStdlv("01000000000000000000000000000001", cl_fix_from_real(1.0000000009313226, (true, 1, 30)), "cl_fix_from_real: 1+2^-30");
        CheckStdlv("010000000000000000000000000000001", cl_fix_from_real(1.0000000004656613, (true, 1, 31)), "cl_fix_from_real: 1+2^-31");
        CheckStdlv("0100000000000000000000000000000001", cl_fix_from_real(1.0000000002328306, (true, 1, 32)), "cl_fix_from_real: 1+2^-32");
        CheckStdlv("01000000000000000000000000000000001", cl_fix_from_real(1.0000000001164153, (true, 1, 33)), "cl_fix_from_real: 1+2^-33");
        CheckStdlv("010000000000000000000000000000000001", cl_fix_from_real(1.0000000000582077, (true, 1, 34)), "cl_fix_from_real: 1+2^-34");
        CheckStdlv("0100000000000000000000000000000000001", cl_fix_from_real(1.0000000000291038, (true, 1, 35)), "cl_fix_from_real: 1+2^-35");
        CheckStdlv("01000000000000000000000000000000000001", cl_fix_from_real(1.000000000014552, (true, 1, 36)), "cl_fix_from_real: 1+2^-36");
        CheckStdlv("010000000000000000000000000000000000001", cl_fix_from_real(1.000000000007276, (true, 1, 37)), "cl_fix_from_real: 1+2^-37");
        CheckStdlv("0100000000000000000000000000000000000001", cl_fix_from_real(1.000000000003638, (true, 1, 38)), "cl_fix_from_real: 1+2^-38");
        CheckStdlv("01000000000000000000000000000000000000001", cl_fix_from_real(1.000000000001819, (true, 1, 39)), "cl_fix_from_real: 1+2^-39");
        CheckStdlv("010000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000009095, (true, 1, 40)), "cl_fix_from_real: 1+2^-40");
        CheckStdlv("0100000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000004547, (true, 1, 41)), "cl_fix_from_real: 1+2^-41");
        CheckStdlv("01000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000002274, (true, 1, 42)), "cl_fix_from_real: 1+2^-42");
        CheckStdlv("010000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000001137, (true, 1, 43)), "cl_fix_from_real: 1+2^-43");
        CheckStdlv("0100000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000000568, (true, 1, 44)), "cl_fix_from_real: 1+2^-44");
        CheckStdlv("01000000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000000284, (true, 1, 45)), "cl_fix_from_real: 1+2^-45");
        CheckStdlv("010000000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000000142, (true, 1, 46)), "cl_fix_from_real: 1+2^-46");
        CheckStdlv("0100000000000000000000000000000000000000000000001", cl_fix_from_real(1.000000000000007, (true, 1, 47)), "cl_fix_from_real: 1+2^-47");
        CheckStdlv("01000000000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000000036, (true, 1, 48)), "cl_fix_from_real: 1+2^-48");
        CheckStdlv("010000000000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000000018, (true, 1, 49)), "cl_fix_from_real: 1+2^-49");
        CheckStdlv("0100000000000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000000009, (true, 1, 50)), "cl_fix_from_real: 1+2^-50");
        CheckStdlv("01000000000000000000000000000000000000000000000000001", cl_fix_from_real(1.0000000000000004, (true, 1, 51)), "cl_fix_from_real: 1+2^-51");
        CheckStdlv("11", cl_fix_from_real(-1.0, (true, 1, 0)), "cl_fix_from_real: 2^-0");
        CheckStdlv("101", cl_fix_from_real(-1.5, (true, 1, 1)), "cl_fix_from_real: 2^-1");
        CheckStdlv("1001", cl_fix_from_real(-1.75, (true, 1, 2)), "cl_fix_from_real: 2^-2");
        CheckStdlv("10001", cl_fix_from_real(-1.875, (true, 1, 3)), "cl_fix_from_real: 2^-3");
        CheckStdlv("100001", cl_fix_from_real(-1.9375, (true, 1, 4)), "cl_fix_from_real: 2^-4");
        CheckStdlv("1000001", cl_fix_from_real(-1.96875, (true, 1, 5)), "cl_fix_from_real: 2^-5");
        CheckStdlv("10000001", cl_fix_from_real(-1.984375, (true, 1, 6)), "cl_fix_from_real: 2^-6");
        CheckStdlv("100000001", cl_fix_from_real(-1.9921875, (true, 1, 7)), "cl_fix_from_real: 2^-7");
        CheckStdlv("1000000001", cl_fix_from_real(-1.99609375, (true, 1, 8)), "cl_fix_from_real: 2^-8");
        CheckStdlv("10000000001", cl_fix_from_real(-1.998046875, (true, 1, 9)), "cl_fix_from_real: 2^-9");
        CheckStdlv("100000000001", cl_fix_from_real(-1.9990234375, (true, 1, 10)), "cl_fix_from_real: 2^-10");
        CheckStdlv("1000000000001", cl_fix_from_real(-1.99951171875, (true, 1, 11)), "cl_fix_from_real: 2^-11");
        CheckStdlv("10000000000001", cl_fix_from_real(-1.999755859375, (true, 1, 12)), "cl_fix_from_real: 2^-12");
        CheckStdlv("100000000000001", cl_fix_from_real(-1.9998779296875, (true, 1, 13)), "cl_fix_from_real: 2^-13");
        CheckStdlv("1000000000000001", cl_fix_from_real(-1.99993896484375, (true, 1, 14)), "cl_fix_from_real: 2^-14");
        CheckStdlv("10000000000000001", cl_fix_from_real(-1.999969482421875, (true, 1, 15)), "cl_fix_from_real: 2^-15");
        CheckStdlv("100000000000000001", cl_fix_from_real(-1.9999847412109375, (true, 1, 16)), "cl_fix_from_real: 2^-16");
        CheckStdlv("1000000000000000001", cl_fix_from_real(-1.9999923706054688, (true, 1, 17)), "cl_fix_from_real: 2^-17");
        CheckStdlv("10000000000000000001", cl_fix_from_real(-1.9999961853027344, (true, 1, 18)), "cl_fix_from_real: 2^-18");
        CheckStdlv("100000000000000000001", cl_fix_from_real(-1.9999980926513672, (true, 1, 19)), "cl_fix_from_real: 2^-19");
        CheckStdlv("1000000000000000000001", cl_fix_from_real(-1.9999990463256836, (true, 1, 20)), "cl_fix_from_real: 2^-20");
        CheckStdlv("10000000000000000000001", cl_fix_from_real(-1.9999995231628418, (true, 1, 21)), "cl_fix_from_real: 2^-21");
        CheckStdlv("100000000000000000000001", cl_fix_from_real(-1.999999761581421, (true, 1, 22)), "cl_fix_from_real: 2^-22");
        CheckStdlv("1000000000000000000000001", cl_fix_from_real(-1.9999998807907104, (true, 1, 23)), "cl_fix_from_real: 2^-23");
        CheckStdlv("10000000000000000000000001", cl_fix_from_real(-1.9999999403953552, (true, 1, 24)), "cl_fix_from_real: 2^-24");
        CheckStdlv("100000000000000000000000001", cl_fix_from_real(-1.9999999701976776, (true, 1, 25)), "cl_fix_from_real: 2^-25");
        CheckStdlv("1000000000000000000000000001", cl_fix_from_real(-1.9999999850988388, (true, 1, 26)), "cl_fix_from_real: 2^-26");
        CheckStdlv("10000000000000000000000000001", cl_fix_from_real(-1.9999999925494194, (true, 1, 27)), "cl_fix_from_real: 2^-27");
        CheckStdlv("100000000000000000000000000001", cl_fix_from_real(-1.9999999962747097, (true, 1, 28)), "cl_fix_from_real: 2^-28");
        CheckStdlv("1000000000000000000000000000001", cl_fix_from_real(-1.9999999981373549, (true, 1, 29)), "cl_fix_from_real: 2^-29");
        CheckStdlv("10000000000000000000000000000001", cl_fix_from_real(-1.9999999990686774, (true, 1, 30)), "cl_fix_from_real: 2^-30");
        CheckStdlv("100000000000000000000000000000001", cl_fix_from_real(-1.9999999995343387, (true, 1, 31)), "cl_fix_from_real: 2^-31");
        CheckStdlv("1000000000000000000000000000000001", cl_fix_from_real(-1.9999999997671694, (true, 1, 32)), "cl_fix_from_real: 2^-32");
        CheckStdlv("10000000000000000000000000000000001", cl_fix_from_real(-1.9999999998835847, (true, 1, 33)), "cl_fix_from_real: 2^-33");
        CheckStdlv("100000000000000000000000000000000001", cl_fix_from_real(-1.9999999999417923, (true, 1, 34)), "cl_fix_from_real: 2^-34");
        CheckStdlv("1000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999708962, (true, 1, 35)), "cl_fix_from_real: 2^-35");
        CheckStdlv("10000000000000000000000000000000000001", cl_fix_from_real(-1.999999999985448, (true, 1, 36)), "cl_fix_from_real: 2^-36");
        CheckStdlv("100000000000000000000000000000000000001", cl_fix_from_real(-1.999999999992724, (true, 1, 37)), "cl_fix_from_real: 2^-37");
        CheckStdlv("1000000000000000000000000000000000000001", cl_fix_from_real(-1.999999999996362, (true, 1, 38)), "cl_fix_from_real: 2^-38");
        CheckStdlv("10000000000000000000000000000000000000001", cl_fix_from_real(-1.999999999998181, (true, 1, 39)), "cl_fix_from_real: 2^-39");
        CheckStdlv("100000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999990905, (true, 1, 40)), "cl_fix_from_real: 2^-40");
        CheckStdlv("1000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999995453, (true, 1, 41)), "cl_fix_from_real: 2^-41");
        CheckStdlv("10000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999997726, (true, 1, 42)), "cl_fix_from_real: 2^-42");
        CheckStdlv("100000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999998863, (true, 1, 43)), "cl_fix_from_real: 2^-43");
        CheckStdlv("1000000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999999432, (true, 1, 44)), "cl_fix_from_real: 2^-44");
        CheckStdlv("10000000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999999716, (true, 1, 45)), "cl_fix_from_real: 2^-45");
        CheckStdlv("100000000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999999858, (true, 1, 46)), "cl_fix_from_real: 2^-46");
        CheckStdlv("1000000000000000000000000000000000000000000000001", cl_fix_from_real(-1.999999999999993, (true, 1, 47)), "cl_fix_from_real: 2^-47");
        CheckStdlv("10000000000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999999964, (true, 1, 48)), "cl_fix_from_real: 2^-48");
        CheckStdlv("100000000000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999999982, (true, 1, 49)), "cl_fix_from_real: 2^-49");
        CheckStdlv("1000000000000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999999991, (true, 1, 50)), "cl_fix_from_real: 2^-50");
        CheckStdlv("10000000000000000000000000000000000000000000000000001", cl_fix_from_real(-1.9999999999999996, (true, 1, 51)), "cl_fix_from_real: 2^-51");
        CheckStdlv("10000000000000000000000000000000000000000000000000001", cl_fix_from_real(0.5000000000000001, (false, 0, 53)), "cl_fix_from_real: 0.5+2^-53");

        wait;
	end process;

    
end sim;
