`timescale 1ns/1ps

/*
 * Testbench: tb_program_counter
 *
 * Description:
 * This testbench verifies the operation of the Program Counter (PC)
 * module in a single-cycle MIPS processor.
 *
 * The PC is expected to:
 *  - Reset to 0 when reset is asserted
 *  - Load the value of next_pc on the rising edge of the clock
 *
 * The next_pc input is assumed to come from the PC source multiplexer
 * (PC+4, branch target, jump target, or register-based jump).
 */

module tb_program_counter;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] next_pc;

    // Output
    wire [31:0] pc_out;

    // Instantiate the Program Counter
    program_counter uut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc_out(pc_out)
    );

    // ------------------------------------------------------------------
    // Clock generation: 10 ns period (100 MHz)
    // ------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ------------------------------------------------------------------
    // Test procedure
    // ------------------------------------------------------------------
    initial begin
        // Initialize inputs
        reset   = 1'b1;
        next_pc = 32'h00000000;

        // Hold reset for one clock cycle
        #12;
        reset = 1'b0;

        // --------------------------------------------------------------
        // Normal execution: PC + 4
        // --------------------------------------------------------------
        next_pc = 32'h00400000;  // initial PC
        @(posedge clk);

        next_pc = 32'h00400004;
        @(posedge clk);

        next_pc = 32'h00400008;
        @(posedge clk);

        // --------------------------------------------------------------
        // Branch target simulation
        // --------------------------------------------------------------
        next_pc = 32'h00400020;  // branch taken
        @(posedge clk);

        // --------------------------------------------------------------
        // Jump instruction simulation (J / JAL)
        // --------------------------------------------------------------
        next_pc = 32'h00401000;
        @(posedge clk);

        // --------------------------------------------------------------
        // Register-based jump (JR / JALR)
        // Example: returning using $ra
        // --------------------------------------------------------------
        next_pc = 32'h0040000C;
        @(posedge clk);

        // --------------------------------------------------------------
        // Apply reset again
        // --------------------------------------------------------------
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;

        // Continue execution after reset
        next_pc = 32'h00400004;
        @(posedge clk);

        // End simulation
        #10;
        $finish;
    end

    // ------------------------------------------------------------------
    // Monitor output
    // ------------------------------------------------------------------
    initial begin
        $monitor("Time=%0t | reset=%b | next_pc=%h | pc_out=%h",
                 $time, reset, next_pc, pc_out);
    end

    // ------------------------------------------------------------------
    // GTKWave dump
    // ------------------------------------------------------------------
    initial begin
        $dumpfile("pc.vcd");
        $dumpvars(0, tb_program_counter);
    end

endmodule
