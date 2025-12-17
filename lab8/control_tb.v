`timescale 1ns / 1ps

module control_tb;
    // Inputs
    reg [31:0] instruction;
    
    // Outputs
    wire reg_write;
    wire mem_to_reg;
    wire mem_write;
    wire mem_read;
    wire alu_src;
    wire reg_dst;
    wire [5:0] alu_func;
    
    // Instantiate the Unit Under Test (UUT)
    control uut (
        .instruction(instruction),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_src(alu_src),
        .reg_dst(reg_dst),
        .alu_func(alu_func)
    );
    
    // Task to display results
    task display_signals;
        input [79:0] instr_name;
        begin
            $display("\n=== Testing: %s ===", instr_name);
            $display("Instruction: %h", instruction);
            $display("reg_write=%b, mem_to_reg=%b, mem_write=%b, mem_read=%b", 
                     reg_write, mem_to_reg, mem_write, mem_read);
            $display("alu_src=%b, reg_dst=%b, alu_func=%b", 
                     alu_src, reg_dst, alu_func);
        end
    endtask
    
    // Task to check expected values
    task check_control;
        input [79:0] instr_name;
        input exp_reg_write;
        input exp_mem_to_reg;
        input exp_mem_write;
        input exp_mem_read;
        input exp_alu_src;
        input exp_reg_dst;
        input [5:0] exp_alu_func;
        begin
            #10; // Wait for combinational logic
            
            if (reg_write === exp_reg_write &&
                mem_to_reg === exp_mem_to_reg &&
                mem_write === exp_mem_write &&
                mem_read === exp_mem_read &&
                alu_src === exp_alu_src &&
                reg_dst === exp_reg_dst &&
                alu_func === exp_alu_func) begin
                $display("[PASS] %s", instr_name);
            end else begin
                $display("[FAIL] %s", instr_name);
                $display("Expected: rw=%b, m2r=%b, mw=%b, mr=%b, as=%b, rd=%b, af=%b",
                         exp_reg_write, exp_mem_to_reg, exp_mem_write, exp_mem_read,
                         exp_alu_src, exp_reg_dst, exp_alu_func);
                $display("Got:      rw=%b, m2r=%b, mw=%b, mr=%b, as=%b, rd=%b, af=%b",
                         reg_write, mem_to_reg, mem_write, mem_read,
                         alu_src, reg_dst, alu_func);
            end
        end
    endtask
    
    initial begin
        $display("Starting Control Unit Test...");
        
        // Test 1: ADD (R-Type)
        // Format: add $t0, $t1, $t2  =>  000000 01001 01010 01000 00000 100000
        instruction = 32'b000000_01001_01010_01000_00000_100000;
        display_signals("ADD $t0, $t1, $t2");
        check_control("ADD", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 6'b100000);
        
        // Test 2: SUB (R-Type)
        // Format: sub $t3, $t4, $t5  =>  000000 01100 01101 01011 00000 100010
        instruction = 32'b000000_01100_01101_01011_00000_100010;
        display_signals("SUB $t3, $t4, $t5");
        check_control("SUB", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 6'b100010);
        
        // Test 3: AND (R-Type)
        // Format: and $s0, $s1, $s2  =>  000000 10001 10010 10000 00000 100100
        instruction = 32'b000000_10001_10010_10000_00000_100100;
        display_signals("AND $s0, $s1, $s2");
        check_control("AND", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 6'b100100);
        
        // Test 4: OR (R-Type)
        // Format: or $s3, $s4, $s5  =>  000000 10100 10101 10011 00000 100101
        instruction = 32'b000000_10100_10101_10011_00000_100101;
        display_signals("OR $s3, $s4, $s5");
        check_control("OR", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 6'b100101);
        
        // Test 5: NOR (R-Type)
        // Format: nor $s6, $s7, $t0  =>  000000 10111 01000 10110 00000 100111
        instruction = 32'b000000_10111_01000_10110_00000_100111;
        display_signals("NOR $s6, $s7, $t0");
        check_control("NOR", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 6'b100111);
        
        // Test 6: XOR (R-Type)
        // Format: xor $t1, $t2, $t3  =>  000000 01010 01011 01001 00000 100110
        instruction = 32'b000000_01010_01011_01001_00000_100110;
        display_signals("XOR $t1, $t2, $t3");
        check_control("XOR", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 6'b100110);
        
        // Test 7: ADDI (I-Type)
        // Format: addi $t0, $t1, 100  =>  001000 01001 01000 0000000001100100
        instruction = 32'b001000_01001_01000_0000000001100100;
        display_signals("ADDI $t0, $t1, 100");
        check_control("ADDI", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 6'b100000);
        
        // Test 8: LW (Load Word)
        // Format: lw $t0, 8($t1)  =>  100011 01001 01000 0000000000001000
        instruction = 32'b100011_01001_01000_0000000000001000;
        display_signals("LW $t0, 8($t1)");
        check_control("LW", 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 6'b100000);
        
        // Test 9: SW (Store Word)
        // Format: sw $t0, 12($t1)  =>  101011 01001 01000 0000000000001100
        instruction = 32'b101011_01001_01000_0000000000001100;
        display_signals("SW $t0, 12($t1)");
        check_control("SW", 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 6'b100000);
        
        $display("\n=== Control Unit Test Complete ===");
        $finish;
    end

endmodule