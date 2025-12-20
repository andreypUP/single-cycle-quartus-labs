`timescale 1ns / 1ps

/*
** -------------------------------------------------------------------
**  Load Extender Unit
**
**  Purpose:
**  This module processes data read from memory for load instructions.
**  It selects the correct byte or halfword from a 32-bit memory word
**  and performs either sign-extension or zero-extension depending
**  on the load instruction type.
**
**  Supported load instructions:
**   - LB  : Load Byte (signed)
**   - LH  : Load Halfword (signed)
**   - LBU : Load Byte Unsigned
**   - LHU : Load Halfword Unsigned
**
**  This unit is purely combinational.
** -------------------------------------------------------------------
*/

module load_extender (
    input wire [31:0] mem_data,      // 32-bit word read from data memory
    input wire [1:0]  byte_offset,    // Lower 2 bits of address (addr[1:0])
                                      // Selects byte or halfword position
    input wire [1:0]  load_type,      // Determines signed/unsigned load type
                                      // 00 = LB, 01 = LH, 10 = LBU, 11 = LHU
    output reg [31:0] extended_data   // Final 32-bit value written to register
);

    // Holds the selected 8-bit byte from mem_data
    reg [7:0]  selected_byte;

    // Holds the selected 16-bit halfword from mem_data
    reg [15:0] selected_half;
    
    always @(*) begin
        // -----------------------------------------------------------
        // Byte selection based on byte offset
        // -----------------------------------------------------------
        // byte_offset comes from the lowest two bits of the address
        // and determines which byte of the 32-bit word is accessed
        case (byte_offset)
            2'b00: selected_byte = mem_data[7:0];    // Lowest byte
            2'b01: selected_byte = mem_data[15:8];
            2'b10: selected_byte = mem_data[23:16];
            2'b11: selected_byte = mem_data[31:24]; // Highest byte
        endcase
        
        // -----------------------------------------------------------
        // Halfword selection based on address bit [1]
        // -----------------------------------------------------------
        // 0 selects lower halfword, 1 selects upper halfword
        case (byte_offset[1])
            1'b0: selected_half = mem_data[15:0];    // Lower 16 bits
            1'b1: selected_half = mem_data[31:16];   // Upper 16 bits
        endcase
        
        // -----------------------------------------------------------
        // Extension logic based on load instruction type
        // -----------------------------------------------------------
        case (load_type)
            // Load Byte (signed): sign-extend 8-bit value to 32 bits
            2'b00: extended_data = {{24{selected_byte[7]}}, selected_byte};

            // Load Halfword (signed): sign-extend 16-bit value to 32 bits
            2'b01: extended_data = {{16{selected_half[15]}}, selected_half};

            // Load Byte Unsigned: zero-extend 8-bit value to 32 bits
            2'b10: extended_data = {24'b0, selected_byte};

            // Load Halfword Unsigned: zero-extend 16-bit value to 32 bits
            2'b11: extended_data = {16'b0, selected_half};

            // Default case (safety fallback)
            default: extended_data = mem_data;
        endcase
    end

endmodule
