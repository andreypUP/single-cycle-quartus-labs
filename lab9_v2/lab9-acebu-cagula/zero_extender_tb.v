`timescale 1ns / 1ps

/*
** ------------------------------------------------------------
** Testbench: Zero Extender
**
** Purpose:
** This testbench verifies that the zero_extender module
** correctly zero-extends a smaller input width to a larger
** output width.
**
** Configuration:
**  - Input width  : 16 bits
**  - Output width : 32 bits
**
** Expected behavior:
**  - Upper bits of the output must always be ZERO
**  - Input bits must appear unchanged in the LSBs
** ------------------------------------------------------------
*/

module zero_extender_tb;

    // --------------------------------------------------------
    // Parameter definitions (must match DUT configuration)
    // --------------------------------------------------------
    localparam IN_WIDTH  = 16;
    localparam OUT_WIDTH = 32;

    // --------------------------------------------------------
    // Testbench signals
    // --------------------------------------------------------
    reg  [IN_WIDTH-1:0]  in;    // Input to DUT
    wire [OUT_WIDTH-1:0] out;   // Output from DUT

    // --------------------------------------------------------
    // Instantiate the Device Under Test (DUT)
    // --------------------------------------------------------
    zero_extender #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) dut (
        .in(in),
        .out(out)
    );

    // --------------------------------------------------------
    // Test sequence
    // --------------------------------------------------------
    initial begin
        // ----------------------------------------------------
        // Waveform dump (useful for GTKWave debugging)
        // ----------------------------------------------------
        $dumpfile("zero_extender.vcd");
        $dumpvars(0, zero_extender_tb);

        $display("==============================================");
        $display(" Zero Extender Testbench Started");
        $display("==============================================");

        // ----------------------------------------------------
        // Test 1: All zeros
        // Expect output to be all zeros
        // ----------------------------------------------------
        in = 16'h0000;
        #10;
        $display("Test 1 | in=%h out=%h | expected=00000000", in, out);

        // ----------------------------------------------------
        // Test 2: Small non-zero value
        // Lower bits should pass through unchanged
        // ----------------------------------------------------
        in = 16'h000F;
        #10;
        $display("Test 2 | in=%h out=%h | expected=0000000F", in, out);

        // ----------------------------------------------------
        // Test 3: MSB of input set
        // Zero-extension means upper output bits stay ZERO
        // ----------------------------------------------------
        in = 16'h8000;
        #10;
        $display("Test 3 | in=%h out=%h | expected=00008000", in, out);

        // ----------------------------------------------------
        // Test 4: All input bits set
        // Upper 16 bits must still be ZERO
        // ----------------------------------------------------
        in = 16'hFFFF;
        #10;
        $display("Test 4 | in=%h out=%h | expected=0000FFFF", in, out);

        // ----------------------------------------------------
        // End of simulation
        // ----------------------------------------------------
        $display("==============================================");
        $display(" Zero Extender Testbench Completed");
        $display("==============================================");

        $finish;
    end

endmodule
