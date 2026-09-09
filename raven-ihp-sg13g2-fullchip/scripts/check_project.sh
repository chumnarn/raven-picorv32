#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pdk_root="${PDK_ROOT:-${project_dir}/IHP-Open-PDK}"
pdk="${PDK:-ihp-sg13g2}"

required=(
  "rtl/chip_top.sv"
  "rtl/raven_chip_core.sv"
  "rtl/wrappers/raven_sram_1kx32.sv"
  "rtl/upstream/raven_soc.v"
  "rtl/upstream/picorv32.v"
  "librelane/config.yaml"
  "librelane/chip_top.sdc"
  "librelane/pdn_cfg.tcl"
)

for rel in "${required[@]}"; do
  test -s "${project_dir}/${rel}" || { echo "ERROR: missing ${rel}"; exit 1; }
done

macro_base="${pdk_root}/${pdk}/libs.ref/sg13g2_sram"
macro="RM_IHPSG13_1P_1024x32_c2_bm_bist"
for rel in "gds/${macro}.gds" "lef/${macro}.lef" \
  "verilog/${macro}.v" "lib/${macro}_typ_1p20V_25C.lib"; do
  test -s "${macro_base}/${rel}" || {
    echo "ERROR: missing PDK macro view ${macro_base}/${rel}"
    echo "Run: make setup"
    exit 1
  }
done

if command -v librelane >/dev/null 2>&1; then
  echo "LibreLane: $(librelane --version 2>/dev/null || echo installed)"
else
  echo "WARNING: librelane is not on PATH; enter nix-shell first"
fi

echo "PASS: project sources and required IHP SRAM views are present"
