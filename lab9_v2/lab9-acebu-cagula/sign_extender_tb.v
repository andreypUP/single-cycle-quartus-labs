`timescale 1ns/1ps

module sign_extender_tb;

    parameter IN_WIDTH  = 16;
    parameter OUT_WIDTH = 32;

    reg  [IN_WIDTH-1:0]  in;
    wire [OUT_WIDTH-1:0] out;

    // Instantiate DUT
    sign_extender #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) uut (
        .in(in),
        .out(out)
    );

    initial begin
        // Test positive number
        in = 16'h1234;     #10;   // No sign extension high bits

        // Test negative number (MSB = 1)
        in = 16'h8000;     #10;   // Should extend to FFFF8000

        // Another negative number
        in = 16'hF234;     #10;

        // Small negative
        in = 16'hFF80;     #10;

        // Small positive
        in = 16'h007F;     #10;

        #10 $finish;
    end

    initial begin
        $monitor("Time=%0t | in=%h | out=%h", $time, in, out);
    end

    initial begin
        $dumpfile("sign_extender.vcd");
        $dumpvars(0, sign_extender_tb);
    end

endmodule
