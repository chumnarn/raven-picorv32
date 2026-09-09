source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl
set_global_connections

set_voltage_domain -name CORE -power $::env(VDD_NET) -ground $::env(GND_NET)

define_pdn_grid -name stdcell_grid -starts_with POWER -voltage_domain CORE
add_pdn_stripe -grid stdcell_grid -layer $::env(PDN_VERTICAL_LAYER) \
    -width $::env(PDN_VWIDTH) -pitch $::env(PDN_VPITCH) \
    -offset $::env(PDN_VOFFSET) -spacing $::env(PDN_VSPACING) \
    -starts_with POWER -extend_to_core_ring
add_pdn_stripe -grid stdcell_grid -layer $::env(PDN_HORIZONTAL_LAYER) \
    -width $::env(PDN_HWIDTH) -pitch $::env(PDN_HPITCH) \
    -offset $::env(PDN_HOFFSET) -spacing $::env(PDN_HSPACING) \
    -starts_with POWER -extend_to_core_ring
add_pdn_connect -grid stdcell_grid \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_stripe -grid stdcell_grid -layer $::env(PDN_RAIL_LAYER) \
    -width $::env(PDN_RAIL_WIDTH) -followpins
add_pdn_connect -grid stdcell_grid \
    -layers "$::env(PDN_RAIL_LAYER) $::env(PDN_VERTICAL_LAYER)"

add_pdn_ring -grid stdcell_grid \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)" \
    -widths "$::env(PDN_CORE_RING_VWIDTH) $::env(PDN_CORE_RING_HWIDTH)" \
    -spacings "$::env(PDN_CORE_RING_VSPACING) $::env(PDN_CORE_RING_HSPACING)" \
    -core_offset "$::env(PDN_CORE_RING_VOFFSET) $::env(PDN_CORE_RING_HOFFSET)" \
    -connect_to_pads

define_pdn_grid -macro -instances "u_core.u_sram.u_sram" \
    -name raven_sram -starts_with POWER
add_pdn_stripe -grid raven_sram -layer Metal5 -width 2.81 \
    -pitch 11.24 -offset 2.81 -spacing 2.81 \
    -nets "VSS VDD" -starts_with POWER
add_pdn_connect -grid raven_sram -layers "Metal4 Metal5"
add_pdn_connect -grid raven_sram -layers "Metal5 TopMetal1"
