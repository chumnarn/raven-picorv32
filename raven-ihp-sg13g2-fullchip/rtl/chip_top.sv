// SPDX-License-Identifier: Apache-2.0
`default_nettype none

module chip_top #(
    parameter integer NUM_INPUT_PADS  = 5,
    parameter integer NUM_OUTPUT_PADS = 5,
    parameter integer NUM_BIDIR_PADS  = 20,
    parameter integer NUM_ANALOG_PADS = 8
) (
    inout wire IOVDD,
    inout wire IOVSS,
    inout wire VDD,
    inout wire VSS,
    inout wire clk_PAD,
    inout wire rst_n_PAD,
    inout wire [NUM_INPUT_PADS-1:0] input_PAD,
    inout wire [NUM_OUTPUT_PADS-1:0] output_PAD,
    inout wire [NUM_BIDIR_PADS-1:0] bidir_PAD,
    inout wire [NUM_ANALOG_PADS-1:0] analog_PAD
);
    wire clk_core;
    wire rst_n_core;
    wire [NUM_INPUT_PADS-1:0] input_core;
    wire [NUM_OUTPUT_PADS-1:0] output_core;
    wire cfg_sdo_oe;
    wire [NUM_BIDIR_PADS-1:0] bidir_in;
    wire [NUM_BIDIR_PADS-1:0] bidir_out;
    wire [NUM_BIDIR_PADS-1:0] bidir_oe;
    wire [NUM_ANALOG_PADS-1:0] analog_core;

    (* keep *) sg13g2_IOPadIOVdd iovdd_pad_0 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));
    (* keep *) sg13g2_IOPadIOVdd iovdd_pad_1 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));
    (* keep *) sg13g2_IOPadIOVss iovss_pad_0 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));
    (* keep *) sg13g2_IOPadIOVss iovss_pad_1 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));
    (* keep *) sg13g2_IOPadVdd vdd_pad_0 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));
    (* keep *) sg13g2_IOPadVdd vdd_pad_1 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));
    (* keep *) sg13g2_IOPadVss vss_pad_0 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));
    (* keep *) sg13g2_IOPadVss vss_pad_1 (.iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS));

    (* keep *) sg13g2_IOPadIn clk_pad (
        .iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS),
        .p2c(clk_core), .pad(clk_PAD)
    );
    (* keep *) sg13g2_IOPadIn rst_n_pad (
        .iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS),
        .p2c(rst_n_core), .pad(rst_n_PAD)
    );

    generate
        for (genvar i = 0; i < NUM_INPUT_PADS; i = i + 1) begin : inputs
            (* keep *) sg13g2_IOPadIn pad (
                .iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS),
                .p2c(input_core[i]), .pad(input_PAD[i])
            );
        end
        for (genvar i = 0; i < NUM_OUTPUT_PADS-1; i = i + 1) begin : outputs
            (* keep *) sg13g2_IOPadOut30mA pad (
                .iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS),
                .c2p(output_core[i]), .pad(output_PAD[i])
            );
        end
        for (genvar i = 0; i < NUM_BIDIR_PADS; i = i + 1) begin : bidirs
            (* keep *) sg13g2_IOPadInOut30mA pad (
                .iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS),
                .c2p(bidir_out[i]), .c2p_en(bidir_oe[i]),
                .p2c(bidir_in[i]), .pad(bidir_PAD[i])
            );
        end
        for (genvar i = 0; i < NUM_ANALOG_PADS; i = i + 1) begin : analogs
            (* keep *) sg13g2_IOPadAnalog pad (
                .iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS),
                .padres(analog_core[i]), .pad(analog_PAD[i])
            );
        end
    endgenerate

    (* keep *) sg13g2_IOPadTriOut30mA cfg_sdo_pad (
        .iovdd(IOVDD), .iovss(IOVSS), .vdd(VDD), .vss(VSS),
        .c2p(output_core[4]), .c2p_en(cfg_sdo_oe), .pad(output_PAD[4])
    );

    (* keep_hierarchy = "yes" *) raven_chip_core u_core (
        .clk        (clk_core),
        .rst_n      (rst_n_core),
        .input_in   (input_core),
        .output_out (output_core),
        .cfg_sdo_oe (cfg_sdo_oe),
        .bidir_in   (bidir_in),
        .bidir_out  (bidir_out),
        .bidir_oe   (bidir_oe),
        .analog     (analog_core)
    );
endmodule

`default_nettype wire
