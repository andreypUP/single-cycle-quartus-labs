`timescale 1ns / 1ps

module control (
    input [31:0] instruction,  // Full 32-bit instruction
    output reg RegDst,         // Selects destination register
    output reg ALUSrc,         // Selects ALU input source
    output reg MemToReg,       // Selects data to write back to the register
    output reg RegWrite,       // Enables writing to the register file
    output reg MemRead,        // Enables memory read
    output reg MemWrite,       // Enables memory write
    output reg [5:0] ALUOp     // ALU operation code
);

    // Extract opcode and funct fields
    wire [5:0] opcode = instruction[31:26];
    wire [5:0] funct  = instruction[5:0];

    // Opcode constants
    localparam OP_RTYPE = 6'b000000;
    localparam OP_LW    = 6'b100011;
    localparam OP_SW    = 6'b101011;
    localparam OP_ADDI  = 6'b001000;

    // Funct constants for R-type
    localparam FUNC_ADD = 6'b100000;
    localparam FUNC_SUB = 6'b100010;
    localparam FUNC_AND = 6'b100100;
    localparam FUNC_OR  = 6'b100101;
    localparam FUNC_NOR = 6'b100111;
    localparam FUNC_XOR = 6'b100110;

    // Control logic
    always @(*) begin
        // Set safe defaults
        RegDst   = 0;
        ALUSrc   = 0;
        MemToReg = 0;
        RegWrite = 0;
        MemRead  = 0;
        MemWrite = 0;
        ALUOp    = 6'b000000;

        case (opcode)
            OP_LW: begin
                RegDst   = 0;              // rt
                ALUSrc   = 1;              // immediate
                MemToReg = 1;              // from memory
                RegWrite = 1;              // write to reg
                MemRead  = 1;              // read memory
                MemWrite = 0;
                ALUOp    = FUNC_ADD;       // address = base + offset
            end

            OP_SW: begin
                ALUSrc   = 1;              // immediate
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 1;              // write to memory
                ALUOp    = FUNC_ADD;       // address = base + offset
            end

            OP_ADDI: begin
                RegDst   = 0;              // rt
                ALUSrc   = 1;              // immediate
                MemToReg = 0;              // from ALU
                RegWrite = 1;              // write to reg
                MemRead  = 0;
                MemWrite = 0;
                ALUOp    = FUNC_ADD;
            end

            OP_RTYPE: begin
                RegDst   = 1;              // rd
                ALUSrc   = 0;              // register
                MemToReg = 0;              // from ALU
                RegWrite = 1;              // write to reg
                MemRead  = 0;
                MemWrite = 0;

                case (funct)
                    FUNC_ADD: ALUOp = FUNC_ADD;
                    FUNC_SUB: ALUOp = FUNC_SUB;
                    FUNC_AND: ALUOp = FUNC_AND;
                    FUNC_OR : ALUOp = FUNC_OR;
                    FUNC_NOR: ALUOp = FUNC_NOR;
                    FUNC_XOR: ALUOp = FUNC_XOR;
                    default : ALUOp = 6'b000000;  // no-op
                endcase
            end

            default: begin
                // Leave all control signals as default
                ALUOp = 6'b000000;
            end
        endcase
    end

endmodule
