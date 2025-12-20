`timescale 1ns / 1ps

/*
 * Module: mux4
 *
 * Description:
 * This is a 4-to-1 multiplexer used in the MIPS single-cycle
 * processor to select the next value of the Program Counter (PC).
 *
 * In this design, the multiplexer selects one of four possible
 * PC sources:
 *
 *   sel = 2'b00 → PC + 4
 *       Normal sequential execution (next instruction)
 *
 *   sel = 2'b01 → Branch target address
 *       Used by conditional branch instructions
 *       (BEQ, BNE, BLTZ, BGEZ, BLEZ, BGTZ)
 *
 *   sel = 2'b10 → Jump target address
 *       Used by J and JAL instructions
 *
 *   sel = 2'b11 → Register-based jump address
 *       Used by JR and JALR instructions, where the PC
 *       is loaded from a register (typically $ra)
 *
 * This multiplexer is purely combinational and is controlled
 * by the main control unit and branch decision logic.
 */

// big picture of the usage:
// Usage:
// PC ──► +4 ────────────┐
//         Branch Addr ──┼──► mux4 ──► PC
//         Jump Addr ────┤
//         Reg Addr ─────┘


module mux4 #(
    parameter WIDTH = 32  // Width of PC and address buses
)(
    input  wire [WIDTH-1:0] a, // PC + 4
    input  wire [WIDTH-1:0] b, // Branch target address
    input  wire [WIDTH-1:0] c, // Jump target address
    input  wire [WIDTH-1:0] d, // Register jump address (JR/JALR)
    input  wire [1:0]       sel, // PC source select signal
    output reg  [WIDTH-1:0] y    // Selected next PC value
);

    /*
     * Combinational selection of the next PC value
     * based on the select signal.
     */
    always @(*) begin
        case (sel)
            2'b00: y = a;  // Default: PC + 4
            2'b01: y = b;  // Branch target
            2'b10: y = c;  // Jump target (J / JAL)
            2'b11: y = d;  // Register jump (JR / JALR)
            default: y = a;
        endcase
    end

endmodule
