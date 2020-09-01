`timescale 1ns / 1ps

module top
(
    input           clk,
    input           reset,
    output  [ 3:0]  vga_b,
    output  [ 3:0]  vga_g,
    output          vga_hs,
    output  [ 3:0]  vga_r,
    output          vga_vs);

    wire       display_on;
    wire [9:0] hpos;
    wire [9:0] vpos;
    wire       clk;
    wire       reset;

    vga i_vga
    (
        .clk        ( clk        ),
        .reset      ( reset      ),
        .hsync      ( vga_hs     ),
        .vsync      ( vga_vs     ),
        .display_on ( display_on ),
        .hpos       ( hpos       ),
        .vpos       ( vpos       )
    );

    wire [2:0] rgb_squares
        = hpos ==  0 || hpos == 639 || vpos ==  0 || vpos == 479 ? 3'b100 :
          hpos ==  5 || hpos == 634 || vpos ==  5 || vpos == 474 ? 3'b010 :
          hpos == 10 || hpos == 629 || vpos == 10 || vpos == 469 ? 3'b001 :
          hpos <  20 || hpos >  619 || vpos <  20 || vpos >= 459 ? 3'b000 :
          { 1'b0, vpos [4], hpos [3] ^ vpos [3] };
    wire        lfsr_enable = ! hpos [9:8] & ! vpos [9:8];
    wire [15:0] lfsr_out;

    lfsr #(16, 16'b1000000001011, 0) i_lfsr
    (
        .clk    ( clk         ),
        .reset  ( reset       ),
        .enable ( lfsr_enable ),
        .out    ( lfsr_out    )
    );

    wire star_on = & lfsr_out [15:9];
    wire [2:0] rgb = lfsr_enable ? (star_on ? lfsr_out [2:0] : 3'b0) : rgb_squares;

    assign vga_r = { 4 { rgb [2] } };
    assign vga_g = { 4 { rgb [1] } };
    assign vga_b = { 4 { rgb [0] } };

endmodule



