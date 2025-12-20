`timescale 1ns / 1ps

/*
 * Module: shift_left_2
 *
 * Description:
 * This module performs a logical left shift by 2 bits.
 * It is typically used in a MIPS processor to shift
 * branch or jump offsets left by 2 bits, since all
 * instructions are word-aligned (4 bytes).
 *
 * For example:
 *   in  = 0x00000001
 *   out = 0x00000004
 *
 * This operation is purely combinational and does
 * not require a clock.
 */

module shift_left_2 #(
    parameter WIDTH = 32  // Width of input and output buses
)(
    input  wire [WIDTH-1:0] in,   // Input value to be shifted
    output wire [WIDTH-1:0] out   // Shifted output value
);

    /*
     * Left shift the input by 2 bits.
     * The two least significant bits are filled with zeros.
     *
     * Equivalent to:
     *   out = in << 2;
     *
     * Example:
     *   in  = 32'b000...0001
     *   out = 32'b000...0100
     */
    assign out = {in[WIDTH-3:0], 2'b00};

endmodule
