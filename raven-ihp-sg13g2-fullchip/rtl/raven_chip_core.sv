// SPDX-License-Identifier: Apache-2.0
`default_nettype none

// Digital IHP port of the silicon-proven Raven PicoSoC subsystem.
// Analog functions remain as memory-mapped registers, but their data/status
// inputs are tied to safe constants until IHP analog macros are integrated.
module raven_chip_core #(
    parameter integer NUM_INPUT_PADS  = 5,
    parameter integer NUM_OUTPUT_PADS = 5,
    parameter integer NUM_BIDIR_PADS  = 20,
    parameter integer NUM_ANALOG_PADS = 8
) (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire [NUM_INPUT_PADS-1:0]   input_in,
    output wire [NUM_OUTPUT_PADS-1:0]  output_out,
    output wire                         cfg_sdo_oe,
    input  wire [NUM_BIDIR_PADS-1:0]   bidir_in,
    output wire [NUM_BIDIR_PADS-1:0]   bidir_out,
    output wire [NUM_BIDIR_PADS-1:0]   bidir_oe,
    inout  wire [NUM_ANALOG_PADS-1:0]  analog
);
    // Input map: 0 UART_RX, 1 IRQ, 2 CFG_SCK, 3 CFG_SDI, 4 CFG_CSB.
    // Output map: 0 UART_TX, 1 TRAP, 2 FLASH_CSB, 3 FLASH_CLK, 4 CFG_SDO.
    // Bidir map: 0..15 GPIO, 16..19 QSPI IO0..IO3.
    wire uart_rx = input_in[0];
    wire irq_pin = input_in[1];
    wire cfg_sck = input_in[2];
    wire cfg_sdi = input_in[3];
    wire cfg_csb = input_in[4];

    wire [15:0] gpio_out;
    wire [15:0] gpio_pullup;
    wire [15:0] gpio_pulldown;
    wire [15:0] gpio_oeb;
    wire [3:0] flash_oeb;
    wire [3:0] flash_do;

    wire uart_tx;
    wire trap;
    wire flash_csb;
    wire flash_clk;

    wire ram_wenb;
    wire [3:0] ram_wstrb;
    wire [9:0] ram_addr;
    wire [31:0] ram_wdata;
    wire [31:0] ram_rdata;

    wire cfg_sdo;
    wire cfg_sdo_enb;
    wire cfg_xtal_ena;
    wire cfg_reg_ena;
    wire cfg_pll_vco_ena;
    wire cfg_pll_cp_ena;
    wire cfg_pll_bias_ena;
    wire [3:0] cfg_pll_trim;
    wire cfg_pll_bypass;
    wire cfg_irq;
    wire cfg_reset;
    wire [11:0] cfg_mfgr_id;
    wire [7:0] cfg_prod_id;
    wire [3:0] cfg_mask_rev;

    wire unused_analog_controls;
    wire adc0_ena, adc0_convert, adc0_clk;
    wire [1:0] adc0_inputsrc;
    wire adc1_ena, adc1_convert, adc1_clk;
    wire [1:0] adc1_inputsrc;
    wire dac_ena;
    wire [9:0] dac_value;
    wire analog_out_sel, opamp_ena, opamp_bias_ena, bg_ena;
    wire comp_ena;
    wire [1:0] comp_ninputsrc, comp_pinputsrc;
    wire rcosc_ena, overtemp_ena;

    raven_spi u_cfg_spi (
        .RST           (~rst_n),
        .SCK           (cfg_sck),
        .SDI           (cfg_sdi),
        .CSB           (cfg_csb),
        .SDO           (cfg_sdo),
        .sdo_enb       (cfg_sdo_enb),
        .xtal_ena      (cfg_xtal_ena),
        .reg_ena       (cfg_reg_ena),
        .pll_vco_ena   (cfg_pll_vco_ena),
        .pll_cp_ena    (cfg_pll_cp_ena),
        .pll_bias_ena  (cfg_pll_bias_ena),
        .pll_trim      (cfg_pll_trim),
        .pll_bypass    (cfg_pll_bypass),
        .irq           (cfg_irq),
        .reset         (cfg_reset),
        .trap          (trap),
        .mfgr_id       (cfg_mfgr_id),
        .prod_id       (cfg_prod_id),
        .mask_rev_in   (4'h0),
        .mask_rev      (cfg_mask_rev)
    );

    raven_soc u_soc (
        .pll_clk              (clk),
        .ext_clk              (clk),
        .ext_clk_sel          (1'b0),
        .ext_reset            (cfg_reset),
        .reset                (~rst_n),
        .ram_wenb             (ram_wenb),
        .ram_wstrb            (ram_wstrb),
        .ram_addr             (ram_addr),
        .ram_wdata            (ram_wdata),
        .ram_rdata            (ram_rdata),
        .gpio_out             (gpio_out),
        .gpio_in              (bidir_in[15:0]),
        .gpio_pullup          (gpio_pullup),
        .gpio_pulldown        (gpio_pulldown),
        .gpio_outenb          (gpio_oeb),
        .adc0_ena             (adc0_ena),
        .adc0_convert         (adc0_convert),
        .adc0_data            (10'b0),
        .adc0_done            (1'b0),
        .adc0_clk             (adc0_clk),
        .adc0_inputsrc        (adc0_inputsrc),
        .adc1_ena             (adc1_ena),
        .adc1_convert         (adc1_convert),
        .adc1_clk             (adc1_clk),
        .adc1_inputsrc        (adc1_inputsrc),
        .adc1_data            (10'b0),
        .adc1_done            (1'b0),
        .dac_ena              (dac_ena),
        .dac_value            (dac_value),
        .analog_out_sel       (analog_out_sel),
        .opamp_ena            (opamp_ena),
        .opamp_bias_ena       (opamp_bias_ena),
        .bg_ena               (bg_ena),
        .comp_ena             (comp_ena),
        .comp_ninputsrc       (comp_ninputsrc),
        .comp_pinputsrc       (comp_pinputsrc),
        .rcosc_ena            (rcosc_ena),
        .overtemp_ena         (overtemp_ena),
        .overtemp             (1'b0),
        .rcosc_in             (1'b0),
        .xtal_in              (1'b0),
        .comp_in              (1'b0),
        .spi_sck              (cfg_sck),
        .spi_ro_config        (8'b0),
        .spi_ro_xtal_ena      (cfg_xtal_ena),
        .spi_ro_reg_ena       (cfg_reg_ena),
        .spi_ro_pll_cp_ena    (cfg_pll_cp_ena),
        .spi_ro_pll_vco_ena   (cfg_pll_vco_ena),
        .spi_ro_pll_bias_ena  (cfg_pll_bias_ena),
        .spi_ro_pll_trim      (cfg_pll_trim),
        .spi_ro_mfgr_id       (cfg_mfgr_id),
        .spi_ro_prod_id       (cfg_prod_id),
        .spi_ro_mask_rev      (cfg_mask_rev),
        .ser_tx               (uart_tx),
        .ser_rx               (uart_rx),
        .irq_pin              (irq_pin),
        .irq_spi              (cfg_irq),
        .trap                 (trap),
        .flash_csb            (flash_csb),
        .flash_clk            (flash_clk),
        .flash_io0_oeb        (flash_oeb[0]),
        .flash_io1_oeb        (flash_oeb[1]),
        .flash_io2_oeb        (flash_oeb[2]),
        .flash_io3_oeb        (flash_oeb[3]),
        .flash_io0_do         (flash_do[0]),
        .flash_io1_do         (flash_do[1]),
        .flash_io2_do         (flash_do[2]),
        .flash_io3_do         (flash_do[3]),
        .flash_io0_di         (bidir_in[16]),
        .flash_io1_di         (bidir_in[17]),
        .flash_io2_di         (bidir_in[18]),
        .flash_io3_di         (bidir_in[19])
    );

    (* keep_hierarchy = "yes" *) raven_sram_1kx32 u_sram (
        .clk   (clk),
        .wen_n (ram_wenb),
        .wstrb (ram_wstrb),
        .addr  (ram_addr),
        .wdata (ram_wdata),
        .rdata (ram_rdata)
    );

    assign output_out[0] = uart_tx;
    assign output_out[1] = trap;
    assign output_out[2] = flash_csb;
    assign output_out[3] = flash_clk;
    assign output_out[4] = cfg_sdo;
    assign cfg_sdo_oe = ~cfg_sdo_enb;
    assign bidir_out[15:0] = gpio_out;
    assign bidir_oe[15:0] = ~gpio_oeb;
    assign bidir_out[19:16] = flash_do;
    assign bidir_oe[19:16] = ~flash_oeb;

    // Prevent aggressive pruning of analog-facing configuration registers.
    assign unused_analog_controls = &{1'b0, analog, gpio_pullup, gpio_pulldown,
        adc0_ena, adc0_convert, adc0_clk, adc0_inputsrc,
        adc1_ena, adc1_convert, adc1_clk, adc1_inputsrc,
        dac_ena, dac_value, analog_out_sel, opamp_ena, opamp_bias_ena,
        bg_ena, comp_ena, comp_ninputsrc, comp_pinputsrc, rcosc_ena,
        overtemp_ena, cfg_pll_bypass};
endmodule

`default_nettype wire
