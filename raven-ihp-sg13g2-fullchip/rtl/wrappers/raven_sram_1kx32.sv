// SPDX-License-Identifier: Apache-2.0
`default_nettype none

// Adapter between Raven's scratchpad interface and the IHP 1 Ki x 32 SRAM.
// Raven acknowledges a RAM request one cycle after it is presented.  The IHP
// macro is synchronous, so A_DOUT is updated on the request clock edge.
   module raven_sram_1kx32 (
    input  wire        clk,
    input  wire        wen_n,
    input  wire [3:0]  wstrb,
    input  wire [9:0]  addr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);
    wire [31:0] bit_mask = {
        {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}}
    };

`ifdef USE_IHP_SRAM
    (* keep *) RM_IHPSG13_1P_1024x32_c2_bm_bist u_sram (
        .A_CLK       (clk),
        .A_MEN       (1'b1),
        .A_WEN       (~wen_n),
        .A_REN       (1'b1),
        .A_ADDR      (addr),
        .A_DIN       (wdata),
        .A_DLY       (1'b1),
        .A_DOUT      (rdata),
        .A_BM        (bit_mask),
        .A_BIST_CLK  (1'b0),
        .A_BIST_EN   (1'b0),
        .A_BIST_MEN  (1'b0),
        .A_BIST_WEN  (1'b0),
        .A_BIST_REN  (1'b0),
        .A_BIST_ADDR (10'b0),
        .A_BIST_DIN  (32'b0),
        .A_BIST_BM   (32'b0)
    );
`else
    reg [31:0] mem [0:1023];
    reg [31:0] rdata_q;
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'b0;
    end
    always @(posedge clk) begin
        if (!wen_n) begin
            mem[addr] <= (mem[addr] & ~bit_mask) | (wdata & bit_mask);
            rdata_q <= (mem[addr] & ~bit_mask) | (wdata & bit_mask);
        end else begin
            rdata_q <= mem[addr];
        end
    end
    assign rdata = rdata_q;
`endif
endmodule

`default_nettype wire
