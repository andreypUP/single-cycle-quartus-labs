`timescale 1ns / 1ps

module reg_file_tb;

    // Inputs
    reg clk;
    reg we;
    reg [4:0] ra1, ra2, rw;
    reg [31:0] wd;

    // Outputs
    wire [31:0] rd1, rd2;

    // Instantiate the reg_file module
    reg_file uut (
        .clk(clk),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .rw(rw),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        we = 0;
        ra1 = 0;
        ra2 = 0;
        rw = 0;
        wd = 0;

        // Wait a little
        #10;

        $display("=== Test 1: Write and read registers ===");

        // Write 123 to register 1
        we = 1;
        rw = 1;
        wd = 32'd123;
        #10; // wait for posedge clock

        // Read register 1 and 0
        ra1 = 1; 
        ra2 = 0;
        #1;
        $display("rd1 = %d (expect 123), rd2 = %d (expect 0)", rd1, rd2);

        // Write 456 to register 2
        rw = 2;
        wd = 32'd456;
        #10; // wait for posedge clock

        // Read register 1 and 2
        ra1 = 1;
        ra2 = 2;
        #1;
        $display("rd1 = %d (expect 123), rd2 = %d (expect 456)", rd1, rd2);

        // Attempt to write to register zero
        rw = 0;
        wd = 32'd999;
        #10;

        // Read register zero
        ra1 = 0;
        ra2 = 1;
        #1;
        $display("rd1 = %d (expect 0), rd2 = %d (expect 123)", rd1, rd2);

        // Disable write
        we = 0;
        rw = 1;
        wd = 32'd111;
        #10;

        // Read register 1 (should remain 123)
        ra1 = 1;
        ra2 = 2;
        #1;
        $display("rd1 = %d (expect 123), rd2 = %d (expect 456)", rd1, rd2);

        $display("=== Testbench complete ===");

        $stop;
    end

endmodule
