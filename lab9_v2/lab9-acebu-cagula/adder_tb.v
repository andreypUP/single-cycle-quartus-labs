`timescale 1ns/1ps

module adder_tb;

    parameter WIDTH = 32;

    reg  [WIDTH-1:0] a, b;
    wire [WIDTH-1:0] sum;

    // Instantiate DUT (Device Under Test)
    adder #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        // Initial values
        a = 0;
        b = 0;

        #5  a = 32'h00000001; b = 32'h00000001; // 1 + 1 = 2
        #10 a = 32'h00000010; b = 32'h00000020; // 16 + 32 = 48
        #10 a = 32'hAAAAAAAA; b = 32'h11111111; // pattern add
        #10 a = 32'hFFFFFFFF; b = 32'h00000001; // overflow test
        #10 a = 32'h12345678; b = 32'h87654321; // mixed values

        #10 $finish;
    end

    // Monitor changes to console
    initial begin
        $monitor("Time=%0t | a=%h | b=%h | sum=%h",
                  $time, a, b, sum);
    end

    // GTKWave dump
    initial begin
        $dumpfile("adder.vcd");
        $dumpvars(0, adder_tb);
    end

endmodule
