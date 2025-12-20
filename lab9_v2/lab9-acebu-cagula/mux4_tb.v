`timescale 1ns / 1ps

module mux4_tb;

    // Parameter
    localparam WIDTH = 32;

    // DUT signals
    reg  [WIDTH-1:0] a;
    reg  [WIDTH-1:0] b;
    reg  [WIDTH-1:0] c;
    reg  [WIDTH-1:0] d;
    reg  [1:0]       sel;
    wire [WIDTH-1:0] y;

    // Instantiate DUT
    mux4 #(
        .WIDTH(WIDTH)
    ) dut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel(sel),
        .y(y)
    );

    // Test sequence
    initial begin
        // Initialize inputs
        a   = 32'hAAAAAAAA;
        b   = 32'hBBBBBBBB;
        c   = 32'hCCCCCCCC;
        d   = 32'hDDDDDDDD;
        sel = 2'b00;

        #10;

        // Test sel = 00 → a
        sel = 2'b00;
        #10;
        $display("sel=%b y=%h (expected %h)", sel, y, a);

        // Test sel = 01 → b
        sel = 2'b01;
        #10;
        $display("sel=%b y=%h (expected %h)", sel, y, b);

        // Test sel = 10 → c
        sel = 2'b10;
        #10;
        $display("sel=%b y=%h (expected %h)", sel, y, c);

        // Test sel = 11 → d
        sel = 2'b11;
        #10;
        $display("sel=%b y=%h (expected %h)", sel, y, d);

        // Change inputs to verify dynamic behavior
        a = 32'h11111111;
        b = 32'h22222222;
        c = 32'h33333333;
        d = 32'h44444444;

        #10;
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        $display("Dynamic input test completed.");

        // End simulation
        $finish;
    end

endmodule
