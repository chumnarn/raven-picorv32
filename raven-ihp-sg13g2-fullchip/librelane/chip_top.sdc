current_design $::env(DESIGN_NAME)
set_units -time ns

create_clock -name core_clk -period $::env(CLOCK_PERIOD) [get_pins clk_pad/p2c]
set clk [get_clocks core_clk]

set_clock_uncertainty 0.25 $clk
set_clock_transition 0.15 $clk

set_input_delay  -min 0.0 -clock $clk [get_ports {rst_n_PAD input_PAD[0] input_PAD[1]}]
set_input_delay  -max 2.0 -clock $clk [get_ports {rst_n_PAD input_PAD[0] input_PAD[1]}]
set_output_delay -min 0.0 -clock $clk [get_ports {output_PAD[0] output_PAD[1] output_PAD[2] output_PAD[3]}]
set_output_delay -max 4.0 -clock $clk [get_ports {output_PAD[0] output_PAD[1] output_PAD[2] output_PAD[3]}]

set_input_delay  -min 0.0 -clock $clk [get_ports {bidir_PAD[*]}]
set_input_delay  -max 2.0 -clock $clk [get_ports {bidir_PAD[*]}]
set_output_delay -min 0.0 -clock $clk [get_ports {bidir_PAD[*]}]
set_output_delay -max 4.0 -clock $clk [get_ports {bidir_PAD[*]}]

# Configuration SPI is asynchronous to core_clk and is implemented in its own
# SCK domain.  Constrain it for pad delay/capacitance but cut CDC timing paths.
set_false_path -from [get_ports {input_PAD[2] input_PAD[3] input_PAD[4]}]
set_false_path -to   [get_ports {output_PAD[4]}]
set_false_path -from [get_ports rst_n_PAD]

set_load 0.033442 [all_outputs]
set_max_fanout 12 [current_design]
set_max_transition 1.0 [current_design]
set_timing_derate -early 0.95
set_timing_derate -late 1.05
set_propagated_clock $clk
