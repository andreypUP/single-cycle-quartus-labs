`timescale 1ns / 1ps

/*
** -------------------------------------------------------------------
**  Control Unit for Single-Cycle MIPS Processor
**
**  Supports the following instructions:
**  - R-type: ADD, ADDU, SUB, SUBU, AND, OR, NOR, XOR, SLT, SLTU, JR, JALR
**  - I-type: ADDI, ADDIU, ANDI, ORI, XORI, SLTI, SLTIU, LUI
**  - Load:   LW, LB, LH, LBU, LHU
**  - Store:  SW, SB, SH
**  - Branch: BEQ, BNE, BLTZ, BGEZ, BLEZ, BGTZ
**  - Jump:   J, JAL
**
**  Author: Lab 9 - Single-Cycle MIPS Branches
** -------------------------------------------------------------------
*/

module control_unit (
    input  wire [31:0] instruction,
    output reg         RegWrite,
    output reg  [1:0]  RegDst,      // CHANGED: 00=rt, 01=rd, 10=$ra(31)
    output reg         ALUSrc,
    output reg         MemRead,
    output reg         MemWrite,
    output reg  [1:0]  MemToReg,    // CHANGED: 00=ALU, 01=memory, 10=PC+4
    output reg  [5:0]  ALUOp,       // 6-bit to match ALU Func_in
    // NEW SIGNALS FOR LAB 9:
    output reg         Branch,      // Branch instruction
    output reg         Jump,        // J or JAL instruction
    output reg         JumpReg,     // JR or JALR instruction
    output reg         ZeroExtend,  // 0=sign extend, 1=zero extend
    output reg         LUI,         // Load upper immediate
    output reg  [1:0]  MemSize,     // 00=byte, 01=half, 11=word
    output reg  [1:0]  LoadType,    // 00=LB, 01=LH, 10=LBU, 11=LHU
	 output reg         LoadExtend,  // 1=use load extender
    output reg         ALUShift     // 1=use shamt for ALU input A (shift instructions)
);

    // Extract opcode and function fields
    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rt     = instruction[20:16];
    wire [5:0] funct  = instruction[5:0];

    // MIPS Instruction Opcodes
    localparam OP_RTYPE  = 6'b000000;  // R-type instructions
    localparam OP_ADDI   = 6'b001000;  // ADDI - Add Immediate
    localparam OP_ADDIU  = 6'b001001;  // ADDIU - Add Immediate Unsigned
    localparam OP_SLTI   = 6'b001010;  // SLTI - Set Less Than Immediate
    localparam OP_SLTIU  = 6'b001011;  // SLTIU - Set Less Than Immediate Unsigned
    localparam OP_ANDI   = 6'b001100;  // ANDI - AND Immediate
    localparam OP_ORI    = 6'b001101;  // ORI - OR Immediate
    localparam OP_XORI   = 6'b001110;  // XORI - XOR Immediate
    localparam OP_LUI    = 6'b001111;  // LUI - Load Upper Immediate
    localparam OP_LB     = 6'b100000;  // LB - Load Byte
    localparam OP_LH     = 6'b100001;  // LH - Load Halfword
    localparam OP_LW     = 6'b100011;  // LW - Load Word
    localparam OP_LBU    = 6'b100100;  // LBU - Load Byte Unsigned
    localparam OP_LHU    = 6'b100101;  // LHU - Load Halfword Unsigned
    localparam OP_SB     = 6'b101000;  // SB - Store Byte
    localparam OP_SH     = 6'b101001;  // SH - Store Halfword
    localparam OP_SW     = 6'b101011;  // SW - Store Word
    localparam OP_BEQ    = 6'b000100;  // BEQ - Branch if Equal
    localparam OP_BNE    = 6'b000101;  // BNE - Branch if Not Equal
    localparam OP_BLEZ   = 6'b000110;  // BLEZ - Branch if Less Than or Equal to Zero
    localparam OP_BGTZ   = 6'b000111;  // BGTZ - Branch if Greater Than Zero
    localparam OP_REGIMM = 6'b000001;  // REGIMM - BLTZ, BGEZ (use rt to distinguish)
    localparam OP_J      = 6'b000010;  // J - Jump
    localparam OP_JAL    = 6'b000011;  // JAL - Jump and Link

    // MIPS Function Codes for R-type Instructions
    localparam FUNCT_ADD  = 6'b100000; // ADD
    localparam FUNCT_ADDU = 6'b100001; // ADDU
    localparam FUNCT_SUB  = 6'b100010; // SUB
    localparam FUNCT_SUBU = 6'b100011; // SUBU
    localparam FUNCT_AND  = 6'b100100; // AND
    localparam FUNCT_OR   = 6'b100101; // OR
    localparam FUNCT_XOR  = 6'b100110; // XOR
    localparam FUNCT_NOR  = 6'b100111; // NOR
    localparam FUNCT_SLT  = 6'b101010; // SLT
    localparam FUNCT_SLTU = 6'b101011; // SLTU
    localparam FUNCT_JR   = 6'b001000; // JR
    localparam FUNCT_JALR = 6'b001001; // JALR
	 localparam FUNCT_SLL  = 6'b000000; // SLL
    localparam FUNCT_SRL  = 6'b000010; // SRL
    localparam FUNCT_SRA  = 6'b000011; // SRA

    // ALU Operation Codes (matching the ALU module spec from lab manual)
    localparam ALU_ADD  = 6'b100000;   // A + B
    localparam ALU_ADDU = 6'b100001;   // A + B (unsigned)
    localparam ALU_SUB  = 6'b100010;   // A - B
    localparam ALU_SUBU = 6'b100011;   // A - B (unsigned)
    localparam ALU_AND  = 6'b100100;   // A & B
    localparam ALU_OR   = 6'b100101;   // A | B
    localparam ALU_XOR  = 6'b100110;   // A ^ B
    localparam ALU_NOR  = 6'b100111;   // ~(A | B)
    localparam ALU_SLT  = 6'b101010;   // A < B (signed)
    localparam ALU_SLTU = 6'b101011;   // A < B (unsigned)
    
    // Branch/Jump ALU codes (matching ALU Func_in[5:3] = 3'b111)
    localparam ALU_BLTZ = 6'b111000;   // Branch if less than zero
    localparam ALU_BGEZ = 6'b111001;   // Branch if greater than or equal to zero
    localparam ALU_J    = 6'b111010;   // Jump
    localparam ALU_JR   = 6'b111011;   // Jump register
    localparam ALU_BEQ  = 6'b111100;   // Branch if equal
    localparam ALU_BNE  = 6'b111101;   // Branch if not equal
    localparam ALU_BLEZ = 6'b111110;   // Branch if less than or equal to zero
    localparam ALU_BGTZ = 6'b111111;   // Branch if greater than zero

    always @(*) begin
        // Default values (prevent latches)
        RegWrite   = 1'b0;
        RegDst     = 2'b00;
        ALUSrc     = 1'b0;
        MemRead    = 1'b0;
        MemWrite   = 1'b0;
        MemToReg   = 2'b00;
        ALUOp      = 6'b000000;
        Branch     = 1'b0;
        Jump       = 1'b0;
        JumpReg    = 1'b0;
        ZeroExtend = 1'b0;
        LUI        = 1'b0;
        MemSize    = 2'b11;
        LoadType   = 2'b00;
        LoadExtend = 1'b0;
		  ALUShift   = 1'b0;

        case(opcode)
            // ================================================================
            // R-TYPE INSTRUCTIONS (opcode = 000000)
            // ================================================================
            OP_RTYPE: begin
                case(funct)
                    // JR - Jump Register
                    FUNCT_JR: begin
                        RegWrite = 1'b0;        // Don't write to register file
                        JumpReg  = 1'b1;        // Jump to address in register
                        ALUOp    = ALU_JR;      // ALU outputs branch signal
                    end
                    
                    // JALR - Jump and Link Register
						 FUNCT_JALR: begin
							  RegWrite = 1'b1;        // Write return address to register
							  RegDst   = 2'b01;       // Use rd as destination
							  MemToReg = 2'b10;       // Write PC+4 to register
							  JumpReg  = 1'b1;        // Jump to address in register
							  ALUOp    = ALU_JR;      // ALU outputs branch signal
						 end
						 
						 // SLL - Shift Left Logical
						 FUNCT_SLL: begin
							  RegWrite = 1'b1;        // Write result to register file
							  RegDst   = 2'b01;       // Use rd as destination
							  ALUSrc   = 1'b0;        // Use register (rt) for ALU input B
							  MemToReg = 2'b00;       // Write ALU result
							  ALUOp    = funct;       // Pass to ALU
							  ALUShift = 1'b1;        // Use shamt for ALU input A
						 end
						 
						 // SRL - Shift Right Logical
						 FUNCT_SRL: begin
							  RegWrite = 1'b1;
							  RegDst   = 2'b01;
							  ALUSrc   = 1'b0;
							  MemToReg = 2'b00;
							  ALUOp    = funct;
							  ALUShift = 1'b1;
						 end
						 
						 // SRA - Shift Right Arithmetic
						 FUNCT_SRA: begin
							  RegWrite = 1'b1;
							  RegDst   = 2'b01;
							  ALUSrc   = 1'b0;
							  MemToReg = 2'b00;
							  ALUOp    = funct;
							  ALUShift = 1'b1;
						 end
                
						 // All other R-type: ADD, ADDU, SUB, SUBU, AND, OR, XOR, NOR, SLT, SLTU
						 default: begin
                        RegWrite = 1'b1;        // Write result to register file
                        RegDst   = 2'b01;       // Use rd (bits 15-11) as destination
                        ALUSrc   = 1'b0;        // Use register value (rt) for ALU input B
                        MemToReg = 2'b00;       // Write ALU result to register (not memory)
                        MemRead  = 1'b0;        // No memory read
                        MemWrite = 1'b0;        // No memory write
                        
                        // Pass the function code directly to ALU
                        // The ALU will decode it to perform the correct operation
                        ALUOp = funct;
                    end
                endcase
            end

            // ================================================================
            // ADDI - Add Immediate
            // ================================================================
            OP_ADDI: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt (bits 20-16) as destination
                ALUSrc     = 1'b1;        // Use immediate value for ALU input B
                MemToReg   = 2'b00;       // Write ALU result to register
                MemRead    = 1'b0;        // No memory read
                MemWrite   = 1'b0;        // No memory write
                ALUOp      = ALU_ADD;     // Perform addition
                ZeroExtend = 1'b0;        // Sign extend immediate
            end

            // ================================================================
            // ADDIU - Add Immediate Unsigned
            // ================================================================
            OP_ADDIU: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate value for ALU input B
                MemToReg   = 2'b00;       // Write ALU result to register
                ALUOp      = ALU_ADDU;    // Perform unsigned addition
                ZeroExtend = 1'b0;        // Sign extend (ADDIU still sign extends!)
            end

            // ================================================================
            // SLTI - Set Less Than Immediate
            // ================================================================
            OP_SLTI: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate value
                MemToReg   = 2'b00;       // Write ALU result
                ALUOp      = ALU_SLT;     // Signed comparison
                ZeroExtend = 1'b0;        // Sign extend immediate
            end

            // ================================================================
            // SLTIU - Set Less Than Immediate Unsigned
            // ================================================================
            OP_SLTIU: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate value
                MemToReg   = 2'b00;       // Write ALU result
                ALUOp      = ALU_SLTU;    // Unsigned comparison
                ZeroExtend = 1'b0;        // Sign extend immediate
            end

            // ================================================================
            // ANDI - AND Immediate
            // ================================================================
            OP_ANDI: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate value
                MemToReg   = 2'b00;       // Write ALU result
                ALUOp      = ALU_AND;     // Perform AND
                ZeroExtend = 1'b1;        // Zero extend for logical ops
            end

            // ================================================================
            // ORI - OR Immediate
            // ================================================================
            OP_ORI: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate value
                MemToReg   = 2'b00;       // Write ALU result
                ALUOp      = ALU_OR;      // Perform OR
                ZeroExtend = 1'b1;        // Zero extend for logical ops
            end

            // ================================================================
            // XORI - XOR Immediate
            // ================================================================
            OP_XORI: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate value
                MemToReg   = 2'b00;       // Write ALU result
                ALUOp      = ALU_XOR;     // Perform XOR
                ZeroExtend = 1'b1;        // Zero extend for logical ops
            end

            // ================================================================
            // LUI - Load Upper Immediate
            // ================================================================
            OP_LUI: begin
                RegWrite   = 1'b1;        // Write result to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate value
                MemToReg   = 2'b00;       // Write ALU result
                ALUOp      = ALU_OR;      // OR shifted immediate with zero
                ZeroExtend = 1'b1;        // Zero extend (doesn't matter, LUI shifts)
                LUI        = 1'b1;        // Signal to shift immediate << 16
            end

            // ================================================================
            // LW - Load Word
            // ================================================================
            OP_LW: begin
                RegWrite   = 1'b1;        // Write loaded data to register file
                RegDst     = 2'b00;       // Use rt (bits 20-16) as destination
                ALUSrc     = 1'b1;        // Use immediate (offset) for address calculation
                MemToReg   = 2'b01;       // Write memory data to register (not ALU result)
                MemRead    = 1'b1;        // Read from memory
                MemWrite   = 1'b0;        // No memory write
                ALUOp      = ALU_ADD;     // Add base address + offset
                MemSize    = 2'b11;       // Word size
                LoadExtend = 1'b0;        // No byte/half extension needed
            end

            // ================================================================
            // LB - Load Byte (Sign Extended)
            // ================================================================
            OP_LB: begin
                RegWrite   = 1'b1;        // Write loaded data to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate (offset)
                MemToReg   = 2'b01;       // Write memory data to register
                MemRead    = 1'b1;        // Read from memory
                ALUOp      = ALU_ADD;     // Add base + offset
                MemSize    = 2'b11;       // Read full word, extract byte in datapath
                LoadExtend = 1'b1;        // Use load extender
                LoadType   = 2'b00;       // LB - sign extend byte
                ALUShift   = 1'b0;

            end

            // ================================================================
            // LH - Load Halfword (Sign Extended)
            // ================================================================
            OP_LH: begin
                RegWrite   = 1'b1;        // Write loaded data to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate (offset)
                MemToReg   = 2'b01;       // Write memory data to register
                MemRead    = 1'b1;        // Read from memory
                ALUOp      = ALU_ADD;     // Add base + offset
                MemSize    = 2'b11;       // Read full word, extract half in datapath
                LoadExtend = 1'b1;        // Use load extender
                LoadType   = 2'b01;       // LH - sign extend half
            end

            // ================================================================
            // LBU - Load Byte Unsigned (Zero Extended)
            // ================================================================
            OP_LBU: begin
                RegWrite   = 1'b1;        // Write loaded data to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate (offset)
                MemToReg   = 2'b01;       // Write memory data to register
                MemRead    = 1'b1;        // Read from memory
                ALUOp      = ALU_ADD;     // Add base + offset
                MemSize    = 2'b11;       // Read full word, extract byte in datapath
                LoadExtend = 1'b1;        // Use load extender
                LoadType   = 2'b10;       // LBU - zero extend byte
            end

            // ================================================================
            // LHU - Load Halfword Unsigned (Zero Extended)
            // ================================================================
            OP_LHU: begin
                RegWrite   = 1'b1;        // Write loaded data to register file
                RegDst     = 2'b00;       // Use rt as destination
                ALUSrc     = 1'b1;        // Use immediate (offset)
                MemToReg   = 2'b01;       // Write memory data to register
                MemRead    = 1'b1;        // Read from memory
                ALUOp      = ALU_ADD;     // Add base + offset
                MemSize    = 2'b11;       // Read full word, extract half in datapath
                LoadExtend = 1'b1;        // Use load extender
                LoadType   = 2'b11;       // LHU - zero extend half
            end

            // ================================================================
            // SW - Store Word
            // ================================================================
            OP_SW: begin
                RegWrite = 1'b0;        // Don't write to register file
                RegDst   = 2'bxx;       // Don't care (not writing to registers)
                ALUSrc   = 1'b1;        // Use immediate (offset) for address calculation
                MemToReg = 2'bxx;       // Don't care (not writing to registers)
                MemRead  = 1'b0;        // No memory read
                MemWrite = 1'b1;        // Write to memory
                ALUOp    = ALU_ADD;     // Add base address + offset
                MemSize  = 2'b11;       // Word size
            end

            // ================================================================
            // SB - Store Byte
            // ================================================================
            OP_SB: begin
                RegWrite = 1'b0;        // Don't write to register file
                ALUSrc   = 1'b1;        // Use immediate (offset)
                MemWrite = 1'b1;        // Write to memory
                ALUOp    = ALU_ADD;     // Add base + offset
                MemSize  = 2'b00;       // Byte size
            end

            // ================================================================
            // SH - Store Halfword
            // ================================================================
            OP_SH: begin
                RegWrite = 1'b0;        // Don't write to register file
                ALUSrc   = 1'b1;        // Use immediate (offset)
                MemWrite = 1'b1;        // Write to memory
                ALUOp    = ALU_ADD;     // Add base + offset
                MemSize  = 2'b01;       // Halfword size
            end

            // ================================================================
            // BEQ - Branch if Equal
            // ================================================================
            OP_BEQ: begin
                RegWrite = 1'b0;        // Don't write to register file
                ALUSrc   = 1'b0;        // Use register value for comparison
                Branch   = 1'b1;        // This is a branch instruction
                ALUOp    = ALU_BEQ;     // ALU evaluates equality
            end

            // ================================================================
            // BNE - Branch if Not Equal
            // ================================================================
            OP_BNE: begin
                RegWrite = 1'b0;        // Don't write to register file
                ALUSrc   = 1'b0;        // Use register value for comparison
                Branch   = 1'b1;        // This is a branch instruction
                ALUOp    = ALU_BNE;     // ALU evaluates inequality
            end

            // ================================================================
            // BLEZ - Branch if Less Than or Equal to Zero
            // ================================================================
            OP_BLEZ: begin
                RegWrite = 1'b0;        // Don't write to register file
                ALUSrc   = 1'b0;        // Use register value
                Branch   = 1'b1;        // This is a branch instruction
                ALUOp    = ALU_BLEZ;    // ALU evaluates <= 0
            end

            // ================================================================
            // BGTZ - Branch if Greater Than Zero
            // ================================================================
            OP_BGTZ: begin
                RegWrite = 1'b0;        // Don't write to register file
                ALUSrc   = 1'b0;        // Use register value
                Branch   = 1'b1;        // This is a branch instruction
                ALUOp    = ALU_BGTZ;    // ALU evaluates > 0
            end

            // ================================================================
            // REGIMM - BLTZ / BGEZ (distinguished by rt field)
            // ================================================================
            OP_REGIMM: begin
                RegWrite = 1'b0;        // Don't write to register file
                ALUSrc   = 1'b0;        // Use register value
                Branch   = 1'b1;        // This is a branch instruction
                
                case(rt)
                    5'b00000: ALUOp = ALU_BLTZ;  // BLTZ - Branch if less than zero
                    5'b00001: ALUOp = ALU_BGEZ;  // BGEZ - Branch if greater than or equal to zero
                    default:  ALUOp = ALU_BLTZ;  // Default to BLTZ
                endcase
            end

            // ================================================================
            // J - Jump
            // ================================================================
            OP_J: begin
                RegWrite = 1'b0;        // Don't write to register file
                Jump     = 1'b1;        // This is a jump instruction
                ALUOp    = ALU_J;       // ALU outputs jump signal
            end

            // ================================================================
            // JAL - Jump and Link
            // ================================================================
            OP_JAL: begin
                RegWrite = 1'b1;        // Write return address to register file
                RegDst   = 2'b10;       // Use $ra (register 31) as destination
                MemToReg = 2'b10;       // Write PC+4 to register
                Jump     = 1'b1;        // This is a jump instruction
                ALUOp    = ALU_J;       // ALU outputs jump signal
            end

            // ================================================================
            // DEFAULT - Unknown instruction
            // ================================================================
            default: begin
                RegWrite   = 1'b0;
                RegDst     = 2'b00;
                ALUSrc     = 1'b0;
                MemRead    = 1'b0;
                MemWrite   = 1'b0;
                MemToReg   = 2'b00;
                ALUOp      = 6'b000000;
                Branch     = 1'b0;
                Jump       = 1'b0;
                JumpReg    = 1'b0;
                ZeroExtend = 1'b0;
                LUI        = 1'b0;
                MemSize    = 2'b11;
                LoadType   = 2'b00;
                LoadExtend = 1'b0;
            end
        endcase
    end

endmodule