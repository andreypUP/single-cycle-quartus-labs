`timescale 1ns / 1ps

/*
** ------------------------------------------------------------
** Testbench for Load Extender Unit
**
** This testbench verifies:
**  - Byte selection using byte_offset
**  - Halfword selection using byte_offset[1]
**  - Correct sign-extension and zero-extension
**
** Load types:
** 00 = LB  (signed byte)
** 01 = LH  (signed halfword)
** 10 = LBU (unsigned byte)
** 11 = LHU (unsigned halfword)
** ------------------------------------------------------------
*/

module tb_load_extender;

    // --------------------------------------------------------
    // Testbench signals
    // --------------------------------------------------------
    reg  [31:0] mem_data;
    reg  [1:0]  byte_offset;
    reg  [1:0]  load_type;
    wire [31:0] extended_data;

    // --------------------------------------------------------
    // Instantiate the DUT (Device Under Test)
    // --------------------------------------------------------
    load_extender dut (
        .mem_data(mem_data),
        .byte_offset(byte_offset),
        .load_type(load_type),
        .extended_data(extended_data)
    );

    // --------------------------------------------------------
    // Test procedure
    // --------------------------------------------------------
    initial begin
        $display("=================================================");
        $display(" Load Extender Testbench Started");
        $display("=================================================");

        // ----------------------------------------------------
        // Test pattern:
        // mem_data = 0x80FF_7F01
        //
        // Bytes (little-endian):
        // byte[0] = 0x01
        // byte[1] = 0x7F
        // byte[2] = 0xFF
        // byte[3] = 0x80
        //
        // Halfwords:
        // lower = 0x7F01
        // upper = 0x80FF
        // ----------------------------------------------------
        mem_data = 32'h80FF_7F01;

        // ----------------------------------------------------
        // Load Byte (Signed)
        // ----------------------------------------------------
        load_type = 2'b00;

        byte_offset = 2'b00; #10;
        $display("LB offset 00: %h", extended_data); // Expect 0x00000001

        byte_offset = 2'b01; #10;
        $display("LB offset 01: %h", extended_data); // Expect 0x0000007F

        byte_offset = 2'b10; #10;
        $display("LB offset 10: %h", extended_data); // Expect 0xFFFFFFFF (0xFF sign-extended)

        byte_offset = 2'b11; #10;
        $display("LB offset 11: %h", extended_data); // Expect 0xFFFFFF80

        // ----------------------------------------------------
        // Load Halfword (Signed)
        // ----------------------------------------------------
        load_type = 2'b01;

        byte_offset = 2'b00; #10;
        $display("LH lower half: %h", extended_data); // Expect 0x00007F01

        byte_offset = 2'b10; #10;
        $display("LH upper half: %h", extended_data); // Expect 0xFFFF80FF

        // ----------------------------------------------------
        // Load Byte (Unsigned)
        // ----------------------------------------------------
        load_type = 2'b10;

        byte_offset = 2'b10; #10;
        $display("LBU offset 10: %h", extended_data); // Expect 0x000000FF

        byte_offset = 2'b11; #10;
        $display("LBU offset 11: %h", extended_data); // Expect 0x00000080

        // ----------------------------------------------------
        // Load Halfword (Unsigned)
        // ----------------------------------------------------
        load_type = 2'b11;

        byte_offset = 2'b00; #10;
        $display("LHU lower half: %h", extended_data); // Expect 0x00007F01

        byte_offset = 2'b10; #10;
        $display("LHU upper half: %h", extended_data); // Expect 0x000080FF

        // ----------------------------------------------------
        // End simulation
        // ----------------------------------------------------
        $display("=================================================");
        $display(" Load Extender Testbench Finished");
        $display("=================================================");
        $finish;
    end

endmodule
