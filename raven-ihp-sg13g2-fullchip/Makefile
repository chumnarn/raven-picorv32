PROJECT_ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TOP          := chip_top
PDK          ?= ihp-sg13g2
PDK_ROOT     ?= $(PROJECT_ROOT)/IHP-Open-PDK
PDK_COMMIT   ?= 3b5a704ba6738aa686b08706187830e6284d2a10
RUN_TAG      ?= raven_$(shell date +%Y%m%d_%H%M%S)
RISCV_PREFIX ?= riscv32-unknown-elf-

.DEFAULT_GOAL := help

help:
	@echo "Raven IHP SG13G2 full-chip targets"
	@echo "  make setup       Install/enable the pinned PDK"
	@echo "  make check       Run project/PDK preflight checks"
	@echo "  make sim         RTL simulation (requires iverilog)"
	@echo "  make firmware    Rebuild the teaching firmware"
	@echo "  make flow        Complete LibreLane Chip flow"
	@echo "  make flow-50mhz  Bring-up flow at 50 MHz"
	@echo "  make flow-nodrc  Implementation without DRC/antenna/density"
	@echo "  make gui         Open latest run in OpenROAD"
	@echo "  make klayout     Open latest run in KLayout"
	@echo "  make ppa         Print PPA/signoff summary"
	@echo "  make evidence    Collect final implementation evidence"
.PHONY: help

$(PDK_ROOT)/$(PDK):
	ciel enable $(PDK_COMMIT) --pdk-root $(PDK_ROOT) --pdk-family $(PDK)

setup: $(PDK_ROOT)/$(PDK)
.PHONY: setup

check:
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) ./scripts/check_project.sh
.PHONY: check

firmware:
	$(MAKE) -C firmware RISCV_PREFIX=$(RISCV_PREFIX)
.PHONY: firmware

sim:
	$(MAKE) -C sim run
.PHONY: sim

flow: setup check
	librelane --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk \
		--run-tag $(RUN_TAG) --save-views-to final librelane/config.yaml
.PHONY: flow

flow-50mhz: setup check
	librelane --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk \
		--run-tag $(RUN_TAG)_50mhz --override-config CLOCK_PERIOD=20 \
		--save-views-to final librelane/config.yaml
.PHONY: flow-50mhz

flow-nodrc: setup check
	librelane --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk \
		--run-tag $(RUN_TAG)_nodrc --save-views-to final \
		--skip KLayout.DRC --skip Checker.KLayoutDRC \
		--skip Magic.DRC --skip Checker.MagicDRC \
		--skip KLayout.Antenna --skip Checker.KLayoutAntenna \
		--skip KLayout.Density --skip Checker.KLayoutDensity \
		librelane/config.yaml
.PHONY: flow-nodrc

gui: setup
	librelane --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk \
		--last-run --flow OpenInOpenROAD librelane/config.yaml
.PHONY: gui

klayout: setup
	librelane --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk \
		--last-run --flow OpenInKLayout librelane/config.yaml
.PHONY: klayout

ppa:
	python3 scripts/summarize_ppa.py librelane/runs
.PHONY: ppa

evidence:
	./scripts/collect_evidence.sh
.PHONY: evidence
