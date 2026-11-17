# RISCY ALU RTL

A small VHDL project containing a 32-bit combinational ALU, shared processor types, and a self-checking testbench. The repository currently covers the ALU and utility types; it does not include a complete processor top level.

## Contents

- `src/ry_types.vhd` — shared enumerations, records, and helper functions.
- `src/ry_alu.vhd` — combinational 32-bit ALU.
- `src/tb_ry_alu.vhd` — self-checking testbench for the ALU and `ry_types` helpers.
- `artifacts/ry-alu.vcd` — VCD waveform trace from the passing simulation.
- `artifacts/ry-alu.gtkw` — GTKWave layout with the operation code, operands, and result selected.
- `artifacts/alu-waveforms.html` — interactive waveform view of the recorded testbench samples.

## ALU operations

| Operation | Behavior |
|---|---|
| `ALU_AND`, `ALU_OR`, `ALU_XOR` | Bitwise logic |
| `ALU_SLT`, `ALU_SLTU` | Signed and unsigned less-than; result is 0 or 1 |
| `ALU_ADD`, `ALU_SUB` | 32-bit modular arithmetic; carry/borrow is discarded |
| `ALU_SRL`, `ALU_SLL`, `ALU_SRA` | Logical right, logical left, and arithmetic right shifts |
| `ALU_NOP`, `ALU_INVALID` | Return zero |

Shift amounts come from `y(4 downto 0)`. The ALU is combinational and has no clock or reset input.

## Requirements

- GHDL with VHDL-2008 support for compiling and running the testbench.
- GTKWave to inspect the VCD trace.

## Compile and simulate

Run these commands from the repository root. The GHDL work library is placed under `/tmp` so generated simulator files do not appear in the source tree.

```sh
make test
```

A successful run prints `PASS: all ry_alu and ry_types checks completed` and stops at 45 ns. Assertion failures terminate the run with an error.

Use `make analyze` to analyze the sources, `make elaborate` to elaborate the testbench, or `make waves` to run the checks and write the VCD trace. Override `GHDL`, `STD`, `WORKDIR`, or `VCD` on the make command line when needed. For example: `make waves GHDL=ghdl VCD=artifacts/ry-alu.vcd`.

## Inspect waveforms

Open the generated trace with the saved signal layout:

```sh
make view
```

`make view` regenerates the passing trace, then opens GTKWave with the saved signal layout. `make clean` removes the GHDL work library and generated VCD trace.

`operation_code` is the zero-based position of the `alu_operation` enum: `0` through `9` are the active ALU operations, `10` is `ALU_NOP`, and `11` is `ALU_INVALID`.

## Testbench coverage

The testbench checks every ALU operation with directed input vectors, including signed/unsigned comparison differences, arithmetic wraparound, shift boundaries, and truncation of shift amounts to five bits. It also checks combinational response to operand and operation changes, all `memop_is_load` enum cases, test-context conversion round trips, and invalid test-state encodings with nonzero payloads.

This is directed verification, not exhaustive verification. It does not test processor integration or unknown-value behavior for ALU operands.
