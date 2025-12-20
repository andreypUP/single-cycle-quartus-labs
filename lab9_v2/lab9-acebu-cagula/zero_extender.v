`timescale 1ns / 1ps

/*
 * Module: zero_extender
 *
 * Description:
 * This module performs zero extension of a smaller-width
 * input value to a larger-width output.
 *
 * In a MIPS processor, this is commonly used for immediate
 * values in instructions such as ANDI, ORI, XORI, LUI,
 * and for zero-extended loads (LBU, LHU).
 *
 * Unlike sign extension, the upper bits of the output
 * are always filled with zeros, regardless of the MSB
 * of the input.
 *
 * Example:
 *   in  = 16'h8001
 *   out = 32'h00008001
 */

module zero_extender #(
    parameter IN_WIDTH  = 16, // Width of the input signal
    parameter OUT_WIDTH = 32  // Width of the extended output signal
)(
    input  wire [IN_WIDTH-1:0]  in,  // Input value to be zero-extended
    output wire [OUT_WIDTH-1:0] out  // zero-extended output value
);

    /*
     * Concatenation-based zero extension:
     * - The upper (OUT_WIDTH - IN_WIDTH) bits are filled with 0s
     * - The lower IN_WIDTH bits come directly from the input
     *
     * Equivalent to:
     *   out = { {(OUT_WIDTH-IN_WIDTH){1'b0}}, in };
     *
     * Example (16 → 32 bits):
     *   in  = 16'hFFFF
     *   out = 32'h0000FFFF
     */
    assign out = {{(OUT_WIDTH-IN_WIDTH){1'b0}}, in};

endmodule
