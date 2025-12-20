`timescale 1ns/1ps

module reg_file_tb;

    reg clk;
    reg we;
    reg [4:0] r_addr1, r_addr2, w_addr;
    reg [31:0] w_data;
    wire [31:0] r_data1, r_data2;

    // DUT = Device Under Test
    register dut (
        .clk(clk),
        .we(we),
        .r_addr1(r_addr1),
        .r_addr2(r_addr2),
        .w_addr(w_addr),
        .w_data(w_data),
        .r_data1(r_data1),
        .r_data2(r_data2)
    );
	 
initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0, reg_file_tb);
end


    // Simple clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        we = 0;
        r_addr1 = 0;
        r_addr2 = 0;
        w_addr  = 0;
        w_data  = 0;

        // ------------------------------
        // Test 1: Register 0 is always 0
        // ------------------------------
        r_addr1 = 0;
        #1;
        $display("Test 1: r0 = %d (expected 0)", r_data1);

        // ------------------------------
        // Test 2: Write to r0 (should ignore)
        // ------------------------------
        w_addr = 0;
        w_data = 32'h1234ABCD;
        we = 1;
        #10;           // wait for posedge clock
        we = 0;

        r_addr1 = 0;
        #1;
        $display("Test 2: r0 after write = %d (expected 0)", r_data1);

        // ------------------------------
        // Test 3: Write to r5
        // ------------------------------
        w_addr = 5;
        w_data = 32'hAAAA5555;
        we = 1;
        #10;           // write occurs here
        we = 0;

        r_addr1 = 5;
        #1;
        $display("Test 3: r5 = %h (expected AAAA5555)", r_data1);

        // ------------------------------
        // Test 4: Write to r10
        // ------------------------------
        w_addr = 10;
        w_data = 32'hDEADBEEF;
        we = 1;
        #10;
        we = 0;

        r_addr2 = 10;
        #1;
        $display("Test 4: r10 = %h (expected DEADBEEF)", r_data2);

        // ------------------------------
        // Test 5: Dual reads at same time
        // ------------------------------
        r_addr1 = 5;
        r_addr2 = 10;
        #1;
        $display("Test 5: r5=%h  r10=%h", r_data1, r_data2);

		  $finish;

    end

endmodule
