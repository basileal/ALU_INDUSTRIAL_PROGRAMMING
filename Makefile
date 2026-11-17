GHDL ?= ghdl
GTKWAVE ?= gtkwave
STD ?= 08
WORKDIR ?= /tmp/alu_tb_work
VCD ?= artifacts/ry-alu.vcd

RTL_SOURCES := src/ry_types.vhd src/ry_alu.vhd
TESTBENCH := src/tb_ry_alu.vhd
SIM := $(GHDL) --std=$(STD) --workdir=$(WORKDIR)

.PHONY: all analyze elaborate test waves view clean

all: test

$(WORKDIR):
	mkdir -p $(WORKDIR)

analyze: | $(WORKDIR)
	$(SIM) -a $(RTL_SOURCES) $(TESTBENCH)

elaborate: analyze
	$(SIM) -e tb_ry_alu

test: elaborate
	$(SIM) -r tb_ry_alu --assert-level=error

waves: elaborate
	mkdir -p $(dir $(VCD))
	$(SIM) -r tb_ry_alu --assert-level=error --vcd=$(VCD)

view: waves
	$(GTKWAVE) $(VCD) artifacts/ry-alu.gtkw

clean:
	rm -rf $(WORKDIR)
	rm -f $(VCD)
