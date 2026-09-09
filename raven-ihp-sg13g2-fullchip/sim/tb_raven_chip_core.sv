`timescale 1ns/1ps
`default_nettype none

module tb_raven_chip_core;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg [4:0] input_in = 5'b10001; // CFG_CSB=1, UART_RX=1
    wire [4:0] output_out;
    wire cfg_sdo_oe;
    tri [19:0] bidir_bus;
    wire [19:0] bidir_out;
    wire [19:0] bidir_oe;
    tri [7:0] analog;

    generate
        for (genvar i = 0; i < 20; i = i + 1)
            assign bidir_bus[i] = bidir_oe[i] ? bidir_out[i] : 1'bz;
    endgenerate
    always #5 clk = ~clk;

    raven_chip_core dut (
        .clk(clk), .rst_n(rst_n), .input_in(input_in),
        .output_out(output_out), .cfg_sdo_oe(cfg_sdo_oe), .bidir_in(bidir_bus),
        .bidir_out(bidir_out), .bidir_oe(bidir_oe), .analog(analog)
    );

    spiflash #(.FILENAME("../firmware/reference_raven_demo.hex")) flash (
        .csb(output_out[2]), .clk(output_out[3]),
        .io0(bidir_bus[16]), .io1(bidir_bus[17]),
        .io2(bidir_bus[18]), .io3(bidir_bus[19])
    );

    integer cycles = 0;
    reg [15:0] previous_gpio = 16'hxxxx;
    integer gpio_changes = 0;

    always @(posedge clk) begin
        cycles <= cycles + 1;
        if (bidir_bus[15:0] !== previous_gpio) begin
            previous_gpio <= bidir_bus[15:0];
            gpio_changes <= gpio_changes + 1;
            $display("[%0t] GPIO=%h", $time, bidir_bus[15:0]);
        end
        if (cycles == 800000) begin
            if (gpio_changes > 1)
                $display("PASS: firmware booted and changed GPIO");
            else
                $display("FAIL: no firmware-visible GPIO activity");
            $finish;
        end
    end

    initial begin
        $dumpfile("raven_core.vcd");
        $dumpvars(0, tb_raven_chip_core);
        repeat (20) @(posedge clk);
        rst_n <= 1'b1;
    end
endmodule

`default_nettype wire
