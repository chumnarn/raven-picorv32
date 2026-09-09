IVERILOG ?= iverilog
VVP      ?= vvp

RTL = ../rtl/raven_chip_core.sv \
      ../rtl/wrappers/raven_sram_1kx32.sv \
      ../rtl/upstream/raven_soc.v \
      ../rtl/upstream/raven_spi.v \
      ../rtl/upstream/spi_slave.v

run: raven_core.vvp
	$(VVP) $<

raven_core.vvp: tb_raven_chip_core.sv spiflash.v $(RTL)
	$(IVERILOG) -g2012 -Wall -I../rtl/upstream -o $@ tb_raven_chip_core.sv spiflash.v $(RTL)

clean:
	rm -f raven_core.vvp raven_core.vcd

.PHONY: run clean
