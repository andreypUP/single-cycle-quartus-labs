`timescale 1ns / 1ps

module shift_left_2_tb;

    localparam WIDTH = 32;

    reg  [WIDTH-1:0] in;
    wire [WIDTH-1:0] out;

    // Instantiate the DUT (Device Under Test)
    shift_left_2 #(
        .WIDTH(WIDTH)
    ) dut (
        .in(in),
        .out(out)
    );

    initial begin
        // Optional: waveform dump for GTKWave
        $dumpfile("shift_left_2.vcd");
        $dumpvars(0, shift_left_2_tb);

        // Test 1: Zero input
        in = 32'h00000000;
        #10;
        $display("in=%h out=%h (expected 00000000)", in, out);

        // Test 2: Small value
        in = 32'h00000001;
        #10;
        $display("in=%h out=%h (expected 00000004)", in, out);

        // Test 3: Larger value
        in = 32'h0000000F;
        #10;
        $display("in=%h out=%h (expected 0000003C)", in, out);

        // Test 4: MSB edge case
        in = 32'h40000000;
        #10;
        $display("in=%h out=%h (expected 00000000)", in, out);

        // Test 5: All ones
        in = 32'hFFFFFFFF;
        #10;
        $display("in=%h out=%h (expected FFFFFFFC)", in, out);

        $display("Shift-left-by-2 test completed.");
        $finish;
    end

endmodule
