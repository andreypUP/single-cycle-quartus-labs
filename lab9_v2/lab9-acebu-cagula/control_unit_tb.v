`timescale 1ns / 1ps

module control_unit_tb;

    // Inputs
    reg [31:0] instruction;

    // Outputs
    wire RegWrite;
    wire [1:0] RegDst;
    wire ALUSrc;
    wire MemRead;
    wire MemWrite;
    wire [1:0] MemToReg;
    wire [5:0] ALUOp;

    // Lab 9 signals
    wire Branch;
    wire Jump;
    wire JumpReg;
    wire ZeroExtend;
    wire LUI;
    wire [1:0] MemSize;
    wire [1:0] LoadType;
    wire LoadExtend;
    wire ALUShift;

    // Instantiate UUT
    control_unit uut (
        .instruction(instruction),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .Branch(Branch),
        .Jump(Jump),
        .JumpReg(JumpReg),
        .ZeroExtend(ZeroExtend),
        .LUI(LUI),
        .MemSize(MemSize),
        .LoadType(LoadType),
        .LoadExtend(LoadExtend),
        .ALUShift(ALUShift)
    );

    integer errors;
    integer test_num;

    initial begin
        errors = 0;
        test_num = 1;

        $display("\n========================================");
        $display(" CONTROL UNIT TESTBENCH (LAB 9)");
        $display("========================================");

        // ------------------------------------------------------------
        // R-TYPE: ADD
        // ------------------------------------------------------------
        $display("\nTest %0d: ADD", test_num);
        instruction = 32'b000000_01001_01010_01000_00000_100000;
        #10;

        if (RegWrite !== 1 ||
            RegDst   !== 2'b01 || // rd
            ALUSrc   !== 0 ||
            MemRead  !== 0 ||
            MemWrite !== 0 ||
            MemToReg !== 2'b00 || // ALU
            ALUOp    !== 6'b100000)
        begin
            $display("❌ FAIL");
            errors = errors + 1;
        end
        else $display("✅ PASS");

        test_num = test_num + 1;


        // ------------------------------------------------------------
        // ADDI
        // ------------------------------------------------------------
        $display("\nTest %0d: ADDI", test_num);
        instruction = 32'b001000_01001_01000_0000000001100100;
        #10;

        if (RegWrite !== 1 ||
            RegDst   !== 2'b00 || // rt
            ALUSrc   !== 1 ||
            MemRead  !== 0 ||
            MemWrite !== 0 ||
            MemToReg !== 2'b00 ||
            ALUOp    !== 6'b100000)
        begin
            $display("❌ FAIL");
            errors = errors + 1;
        end
        else $display("✅ PASS");

        test_num = test_num + 1;


        // ------------------------------------------------------------
        // LW
        // ------------------------------------------------------------
        $display("\nTest %0d: LW", test_num);
        instruction = 32'b100011_11101_01000_0000000000001000;
        #10;

        if (RegWrite !== 1 ||
            RegDst   !== 2'b00 ||
            ALUSrc   !== 1 ||
            MemRead  !== 1 ||
            MemWrite !== 0 ||
            MemToReg !== 2'b01 || // memory
            ALUOp    !== 6'b100000)
        begin
            $display("❌ FAIL");
            errors = errors + 1;
        end
        else $display("✅ PASS");

        test_num = test_num + 1;


        // ------------------------------------------------------------
        // SW
        // ------------------------------------------------------------
        $display("\nTest %0d: SW", test_num);
        instruction = 32'b101011_11101_01001_0000000000001100;
        #10;

        if (RegWrite !== 0 ||
            ALUSrc   !== 1 ||
            MemRead  !== 0 ||
            MemWrite !== 1 ||
            ALUOp    !== 6'b100000)
        begin
            $display("❌ FAIL");
            errors = errors + 1;
        end
        else $display("✅ PASS");

        test_num = test_num + 1;


        // ------------------------------------------------------------
        // SUMMARY
        // ------------------------------------------------------------
        $display("\n========================================");
        $display(" SUMMARY");
        $display(" Tests Run : %0d", test_num-1);
        $display(" Errors    : %0d", errors);
        if (errors == 0)
            $display(" 🎉 ALL TESTS PASSED");
        else
            $display(" ⚠️ SOME TESTS FAILED");
        $display("========================================");

        $finish;
    end

endmodule
