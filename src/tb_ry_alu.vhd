-- Self-checking testbench for ry_alu and the helper functions in ry_types.
-- Compile ry_types.vhd, ry_alu.vhd, then this file (VHDL-2008 for std.env.stop).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ry_types.all;
use std.env.all;

entity tb_ry_alu is
end entity tb_ry_alu;

architecture test of tb_ry_alu is
	 signal x         : std_logic_vector(31 downto 0) := (others => '0');
	 signal y         : std_logic_vector(31 downto 0) := (others => '0');
	 signal result    : std_logic_vector(31 downto 0);
	 signal operation : alu_operation := ALU_NOP;
	 signal operation_code : std_logic_vector(3 downto 0);
begin
	 operation_code <= std_logic_vector(to_unsigned(alu_operation'pos(operation), operation_code'length));

	 dut: entity work.ry_alu(behaviour)
		 port map (
			 x => x,
			 y => y,
			 result => result,
			 operation => operation
		 );

	 stimulus: process
		 procedure check_alu(
			 constant op       : in alu_operation;
			 constant lhs      : in std_logic_vector(31 downto 0);
			 constant rhs      : in std_logic_vector(31 downto 0);
			 constant expected : in std_logic_vector(31 downto 0);
			 constant test_id  : in string
		 ) is
		 begin
			 operation <= op;
			 x <= lhs;
			 y <= rhs;
			 wait for 1 ns;
			 assert result = expected
				 report test_id & ": expected " & to_hstring(expected) &
					 ", got " & to_hstring(result)
				 severity failure;
		 end procedure;

		 variable context_in  : test_context;
		 variable context_out : test_context;
		 variable packed      : std_logic_vector(31 downto 0);
		 variable invalid_packed : std_logic_vector(31 downto 0);
	 begin
		 -- Bitwise operations.
		 check_alu(ALU_AND, x"00000000", x"FFFFFFFF", x"00000000", "AND-01");
		 check_alu(ALU_AND, x"A5A55A5A", x"0F0FF0F0", x"05055050", "AND-02");
		 check_alu(ALU_OR,  x"00000000", x"80000001", x"80000001", "OR-01");
		 check_alu(ALU_OR,  x"A5A55A5A", x"0F0FF0F0", x"AFAFFAFA", "OR-02");
		 check_alu(ALU_XOR, x"FFFFFFFF", x"FFFFFFFF", x"00000000", "XOR-01");
		 check_alu(ALU_XOR, x"A5A55A5A", x"0F0FF0F0", x"AAAAAAAA", "XOR-02");

		 -- Signed and unsigned comparisons.
		 check_alu(ALU_SLT, x"80000000", x"00000000", x"00000001", "SLT-01");
		 check_alu(ALU_SLT, x"7FFFFFFF", x"80000000", x"00000000", "SLT-02");
		 check_alu(ALU_SLT, x"FFFFFFFF", x"00000001", x"00000001", "SLT-03");
		 check_alu(ALU_SLT, x"12345678", x"12345678", x"00000000", "SLT-04");
		 check_alu(ALU_SLTU, x"80000000", x"00000000", x"00000000", "SLTU-01");
		 check_alu(ALU_SLTU, x"00000000", x"80000000", x"00000001", "SLTU-02");
		 check_alu(ALU_SLTU, x"FFFFFFFF", x"FFFFFFFE", x"00000000", "SLTU-03");
		 check_alu(ALU_SLTU, x"12345678", x"12345678", x"00000000", "SLTU-04");

		 -- Modular 32-bit arithmetic.
		 check_alu(ALU_ADD, x"00000000", x"00000000", x"00000000", "ADD-01");
		 check_alu(ALU_ADD, x"00000001", x"00000001", x"00000002", "ADD-02");
		 check_alu(ALU_ADD, x"7FFFFFFF", x"00000001", x"80000000", "ADD-03");
		 check_alu(ALU_ADD, x"FFFFFFFF", x"00000001", x"00000000", "ADD-04");
		 check_alu(ALU_ADD, x"12345678", x"11111111", x"23456789", "ADD-05");
		 check_alu(ALU_SUB, x"00000000", x"00000000", x"00000000", "SUB-01");
		 check_alu(ALU_SUB, x"00000005", x"00000005", x"00000000", "SUB-02");
		 check_alu(ALU_SUB, x"00000000", x"00000001", x"FFFFFFFF", "SUB-03");
		 check_alu(ALU_SUB, x"80000000", x"00000001", x"7FFFFFFF", "SUB-04");
		 check_alu(ALU_SUB, x"12345678", x"11111111", x"01234567", "SUB-05");

		 -- Shifts, including amount truncation to y(4 downto 0).
		 check_alu(ALU_SRL, x"80000001", x"00000000", x"80000001", "SRL-01");
		 check_alu(ALU_SRL, x"80000001", x"00000001", x"40000000", "SRL-02");
		 check_alu(ALU_SRL, x"80000001", x"0000001F", x"00000001", "SRL-03");
		 check_alu(ALU_SRL, x"FFFFFFFF", x"00000008", x"00FFFFFF", "SRL-04");
		 check_alu(ALU_SRL, x"80000001", x"00000020", x"80000001", "SRL-05");
		 check_alu(ALU_SLL, x"80000001", x"00000000", x"80000001", "SLL-01");
		 check_alu(ALU_SLL, x"00000001", x"00000001", x"00000002", "SLL-02");
		 check_alu(ALU_SLL, x"00000001", x"0000001F", x"80000000", "SLL-03");
		 check_alu(ALU_SLL, x"FFFFFFFF", x"00000008", x"FFFFFF00", "SLL-04");
		 check_alu(ALU_SLL, x"80000001", x"00000020", x"80000001", "SLL-05");
		 check_alu(ALU_SRA, x"80000001", x"00000000", x"80000001", "SRA-01");
		 check_alu(ALU_SRA, x"80000001", x"00000001", x"C0000000", "SRA-02");
		 check_alu(ALU_SRA, x"80000001", x"0000001F", x"FFFFFFFF", "SRA-03");
		 check_alu(ALU_SRA, x"7FFFFFFF", x"00000001", x"3FFFFFFF", "SRA-04");
		 check_alu(ALU_SRA, x"80000001", x"00000020", x"80000001", "SRA-05");

		 -- Defined default results for the remaining enum values.
		 check_alu(ALU_NOP, x"DEADBEEF", x"12345678", x"00000000", "NOP-01");
		 check_alu(ALU_INVALID, x"FFFFFFFF", x"FFFFFFFF", x"00000000", "INV-01");

		 -- Change inputs independently to exercise combinational sensitivity.
		 operation <= ALU_XOR;
		 x <= x"00000000";
		 y <= x"00000000";
		 wait for 1 ns;
		 assert result = x"00000000" report "SENS-01: initial XOR" severity failure;
		 x <= x"00000001";
		 wait for 1 ns;
		 assert result = x"00000001" report "SENS-02: x-only change" severity failure;
		y <= x"00000003";
		 wait for 1 ns;
		 assert result = x"00000002" report "SENS-03: y-only change" severity failure;
		operation <= ALU_OR;
		wait for 1 ns;
		assert result = x"00000003" report "SENS-04: operation-only change" severity failure;

		-- memop_is_load: all enum values.
		assert not memop_is_load(MEMOP_TYPE_NONE) report "MEMOP-NONE" severity failure;
		assert not memop_is_load(MEMOP_TYPE_INVALID) report "MEMOP-INVALID" severity failure;
		assert memop_is_load(MEMOP_TYPE_LOAD) report "MEMOP-LOAD" severity failure;
		assert memop_is_load(MEMOP_TYPE_LOAD_UNSIGNED) report "MEMOP-LOAD-UNSIGNED" severity failure;
		assert not memop_is_load(MEMOP_TYPE_STORE) report "MEMOP-STORE" severity failure;

		-- Round-trip representative state/number combinations.
		context_in.state := TEST_IDLE;
		context_in.number := (others => '0');
		packed := test_context_to_std_logic(context_in);
		assert packed = x"00000000" report "CTX-IDLE packed value" severity failure;
		context_out := std_logic_to_test_context(packed);
		assert context_out.state = context_in.state and context_out.number = context_in.number
			report "CTX-IDLE round trip" severity failure;

		context_in.state := TEST_RUNNING;
		context_in.number := std_logic_vector(to_unsigned(1, 30));
		packed := test_context_to_std_logic(context_in);
		assert packed = x"00000005" report "CTX-RUNNING packed value" severity failure;
		context_out := std_logic_to_test_context(packed);
		assert context_out.state = context_in.state and context_out.number = context_in.number
			report "CTX-RUNNING round trip" severity failure;

		context_in.state := TEST_FAILED;
		context_in.number := (others => '1');
		packed := test_context_to_std_logic(context_in);
		assert packed = x"FFFFFFFE" report "CTX-FAILED packed value" severity failure;
		context_out := std_logic_to_test_context(packed);
		assert context_out.state = context_in.state and context_out.number = context_in.number
			report "CTX-FAILED round trip" severity failure;

		context_in.state := TEST_PASSED;
		context_in.number := std_logic_vector(to_unsigned(16#15555555#, 30));
		packed := test_context_to_std_logic(context_in);
		assert packed = x"55555557" report "CTX-PASSED packed value" severity failure;
		context_out := std_logic_to_test_context(packed);
		assert context_out.state = context_in.state and context_out.number = context_in.number
			report "CTX-PASSED round trip" severity failure;

		-- Non-binary state encodings map to TEST_FAILED; number bits pass through.
		invalid_packed := x"A5A55A5A";
		invalid_packed(1 downto 0) := "0X";
		context_out := std_logic_to_test_context(invalid_packed);
		assert context_out.state = TEST_FAILED and context_out.number = invalid_packed(31 downto 2)
			report "CTX-X0 invalid state encoding" severity failure;
		invalid_packed := x"5A5AA5A5";
		invalid_packed(1 downto 0) := "X0";
		context_out := std_logic_to_test_context(invalid_packed);
		assert context_out.state = TEST_FAILED and context_out.number = invalid_packed(31 downto 2)
			report "CTX-0X invalid state encoding" severity failure;
		invalid_packed := x"C3C35A5A";
		invalid_packed(1 downto 0) := "XX";
		context_out := std_logic_to_test_context(invalid_packed);
		assert context_out.state = TEST_FAILED and context_out.number = invalid_packed(31 downto 2)
			report "CTX-XX invalid state encoding" severity failure;

		report "PASS: all ry_alu and ry_types checks completed" severity note;
		stop;
		wait;
	end process stimulus;
end architecture test;
