module control(
    input [31:0] instruction,
    output reg reg_write,        // Register file write enable
    output reg mem_to_reg,       // MUX3: 0=ALU result, 1=Memory data
    output reg mem_write,        // Data memory write enable
    output reg mem_read,         // Data memory read enable
    output reg alu_src,          // MUX2: 0=register, 1=immediate
    output reg reg_dst,          // MUX1: 0=rt, 1=rd
    output reg [5:0] alu_func    // ALU function code
);

    // Extract instruction fields
    wire [5:0] opcode;
    wire [5:0] funct;
    
    assign opcode = instruction[31:26];
    assign funct = instruction[5:0];
    
    // Instruction decode
    always @(*) begin
        // Default values (prevent latches)
        reg_write = 1'b0;
        mem_to_reg = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        alu_src = 1'b0;
        reg_dst = 1'b0;
        alu_func = 6'b100000; // Default: ADD
        
        case (opcode)
            6'b000000: begin // R-Type instructions (ADD, SUB, AND, OR, NOR, XOR)
                reg_write = 1'b1;
                reg_dst = 1'b1;      // Write to rd
                alu_src = 1'b0;      // Use register for ALU input B
                mem_to_reg = 1'b0;   // Write ALU result to register
                mem_write = 1'b0;
                mem_read = 1'b0;
                
                case (funct)
                    6'b100000: alu_func = 6'b100000; // ADD: Func_in = 100000
                    6'b100010: alu_func = 6'b100010; // SUB: Func_in = 100010
                    6'b100100: alu_func = 6'b100100; // AND: Func_in = 100100
                    6'b100101: alu_func = 6'b100101; // OR:  Func_in = 100101
                    6'b100111: alu_func = 6'b100111; // NOR: Func_in = 100111
                    6'b100110: alu_func = 6'b100110; // XOR: Func_in = 100110
                    default:   alu_func = 6'b100000; // Default to ADD
                endcase
            end
            
            6'b001000: begin // ADDI - Add Immediate
                reg_write = 1'b1;
                reg_dst = 1'b0;      // Write to rt
                alu_src = 1'b1;      // Use immediate for ALU input B
                mem_to_reg = 1'b0;   // Write ALU result to register
                mem_write = 1'b0;
                mem_read = 1'b0;
                alu_func = 6'b100000; // ADD
            end
            
            6'b100011: begin // LW - Load Word
                reg_write = 1'b1;
                reg_dst = 1'b0;      // Write to rt
                alu_src = 1'b1;      // Use immediate (offset) for address calc
                mem_to_reg = 1'b1;   // Write memory data to register
                mem_write = 1'b0;
                mem_read = 1'b1;     // Read from memory
                alu_func = 6'b100000; // ADD (base + offset)
            end
            
            6'b101011: begin // SW - Store Word
                reg_write = 1'b0;    // Don't write to register
                reg_dst = 1'b0;      // Don't care (not writing)
                alu_src = 1'b1;      // Use immediate (offset) for address calc
                mem_to_reg = 1'b0;   // Don't care (not writing to register)
                mem_write = 1'b1;    // Write to memory
                mem_read = 1'b0;
                alu_func = 6'b100000; // ADD (base + offset)
            end
            
            default: begin
                // For unsupported instructions, set safe defaults
                reg_write = 1'b0;
                mem_to_reg = 1'b0;
                mem_write = 1'b0;
                mem_read = 1'b0;
                alu_src = 1'b0;
                reg_dst = 1'b0;
                alu_func = 6'b100000;
            end
        endcase
    end

endmodule