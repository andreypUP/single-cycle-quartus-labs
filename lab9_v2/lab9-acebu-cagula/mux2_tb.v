`timescale 1ns/1ps   // Time unit = 1ns, precision = 1ps

module mux2_tb;      // Testbench module name changed to avoid confusion with DUT

    parameter WIDTH = 32;  // Width of the multiplexer inputs and output

    // Testbench signals
    reg  [WIDTH-1:0] a, b;  // Inputs to the multiplexer
    reg  sel;                // Select line
    wire [WIDTH-1:0] y;      // Output of the multiplexer

    // Instantiate the Device Under Test (DUT)
    mux2 #(WIDTH) dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    // Apply test stimulus
    initial begin
        // Initialize signals
        a = 0;
        b = 0;
        sel = 0;

        // Test sequence
        #5 a = 8'hAA; b = 8'h55; sel = 0;  // Test with sel=0, y should follow a
        #10 sel = 1;                        // Now select b, y should follow b
        #10 a = 8'hFF; b = 8'h00; sel = 0;  // Test with different inputs, sel=0
        #10 sel = 1;                        // Select b again
        #10 a = 8'h12; b = 8'h34; sel = 1;  // Inputs change, sel=1
        #10 sel = 0;                        // Switch to a
        #10 $finish;                        // End simulation
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t | sel=%b | a=%h | b=%h | y=%h", $time, sel, a, b, y);
        // Prints signal values whenever any change occurs
    end

    // Generate waveform for viewing in GTKWave
    initial begin
        $dumpfile("mux2.vcd");   // Name of the VCD file
        $dumpvars(0, mux2_tb);   // Dump all signals in testbench
    end

endmodule
