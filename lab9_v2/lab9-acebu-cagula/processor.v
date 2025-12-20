`timescale 1ns / 1ps

module processor(
    input clk,
    input reset,
    
    // Serial port connections
    input [7:0] serial_in,
    input serial_ready_in,
    input serial_valid_in,
    output [7:0] serial_out,
    output serial_rden_out,
    output serial_wren_out
);

    // ========================================================================
    // Wire Declarations
    // ========================================================================
    
    // Program Counter wires
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    wire [31:0] branch_target;           // NEW: Branch target address
    wire [31:0] jump_target;             // NEW: Jump target address
    wire [31:0] branch_offset_shifted;   // NEW: Sign extended immediate << 2
    
    // Instruction memory wires
    wire [31:0] instruction;
    
    // Instruction fields
    wire [4:0] instr_25_21;   // rs
    wire [4:0] instr_20_16;   // rt
    wire [4:0] instr_15_11;   // rd
    wire [15:0] instr_15_0;   // immediate
    wire [25:0] instr_25_0;   // NEW: jump address field
    wire [4:0]  instr_10_6;   // shamt field (for shift instructions)
	 
    // Register file wires
    wire [4:0] write_register;
    wire [4:0] write_reg_rd_or_rt;       // NEW: intermediate for RegDst mux
    wire [31:0] write_data;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;
    wire reg_write_enable;
    
    // Sign/Zero extender wires
    wire [31:0] sign_extended;
    wire [31:0] zero_extended;           // NEW: for ANDI, ORI, XORI
    wire [31:0] extended_immediate;      // NEW: selected sign or zero extended
    wire [31:0] lui_shifted;             // NEW: immediate << 16 for LUI
    wire [31:0] final_immediate;         // NEW: final immediate to ALU
    
    // ALU wires
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [5:0] alu_func;
    wire alu_branch;
    wire alu_jump;
	 wire [31:0] shamt_extended;     // shamt zero-extended to 32 bits
    wire [31:0] alu_input_a;        // ALU input A (rs or shamt)
    
    // Data memory wires
    wire [31:0] read_data;
    wire [31:0] load_extended_data;      // NEW: byte/half extended data
    wire [31:0] final_mem_data;          // NEW: selected memory data
    wire mem_read_enable;
    wire mem_write_enable;
    wire [1:0] mem_size;
    
    // Write back wires
    wire [31:0] writeback_alu_or_mem;    // NEW: intermediate for MemToReg mux
    
    // Control signal wires
    wire alu_src;
    wire [1:0] mem_to_reg;               // CHANGED: now 2-bit
    wire [1:0] reg_dst;                  // CHANGED: now 2-bit

    // Control unit wires
    wire RegWrite;
    wire [1:0] RegDst_signal;            // CHANGED: now 2-bit
    wire ALUSrc_signal;
    wire MemRead;
    wire MemWrite;
    wire [1:0] MemToReg_signal;          // CHANGED: now 2-bit
    wire [5:0] ALUOp;
    
    // NEW: Control unit wires for Lab 9
    wire Branch;
    wire Jump;
    wire JumpReg;
    wire ZeroExtend;
    wire LUI;
    wire [1:0] MemSize;
    wire [1:0] LoadType;
    wire LoadExtend;
	 wire ALUShift;
    
    // NEW: PC selection wires
    wire [1:0] pc_src;
    wire branch_taken;

    // ========================================================================
    // Instruction Field Extraction
    // ========================================================================
    
    assign instr_25_21 = instruction[25:21];  // rs
    assign instr_20_16 = instruction[20:16];  // rt
    assign instr_15_11 = instruction[15:11];  // rd
    assign instr_15_0  = instruction[15:0];   // immediate
    assign instr_25_0  = instruction[25:0];   // NEW: jump address
	 assign instr_10_6  = instruction[10:6];   // shamt field

    // ========================================================================
    // Program Counter
    // ========================================================================
    
    program_counter #(
        .RESET_ADDR(32'h003FFFFC)
    ) pc (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc_out(pc_current)
    );
    
    // PC + 4 Adder
    adder #(.WIDTH(32)) pc_adder (
        .a(pc_current),
        .b(32'd4),
        .sum(pc_plus4)
    );
    
    // ========================================================================
    // NEW: Branch Target Calculation
    // ========================================================================
    
    // Shift sign-extended immediate left by 2 (multiply by 4)
    shift_left_2 #(.WIDTH(32)) branch_shift (
        .in(sign_extended),
        .out(branch_offset_shifted)
    );
    
    // Branch target = PC + 4 + (sign_extended_immediate << 2)
    adder #(.WIDTH(32)) branch_adder (
        .a(pc_plus4),
        .b(branch_offset_shifted),
        .sum(branch_target)
    );
    
    // ========================================================================
    // NEW: Jump Target Calculation
    // ========================================================================
    
    // Jump target = {PC+4[31:28], instruction[25:0], 2'b00}
    assign jump_target = {pc_plus4[31:28], instr_25_0, 2'b00};
    
    // ========================================================================
    // NEW: PC Source Selection Logic
    // ========================================================================
    
    // Branch is taken when Branch signal is high AND ALU says condition is met
    assign branch_taken = Branch & alu_branch;
    
    // PC source selection:
    // 00 = PC + 4 (sequential execution)
    // 01 = Branch target (BEQ, BNE, BLTZ, BGEZ, BLEZ, BGTZ)
    // 10 = Jump target (J, JAL)
    // 11 = Register value (JR, JALR)
    assign pc_src = JumpReg    ? 2'b11 :
                    Jump       ? 2'b10 :
                    branch_taken ? 2'b01 :
                                 2'b00;
    
    // bag.o ni siya para sa lab9 instructions: PC Next MUX (4-input)
    
    mux4 #(.WIDTH(32)) pc_mux (
        .a(pc_plus4),        // 00: Sequential (PC + 4)
        .b(branch_target),   // 01: Branch target
        .c(jump_target),     // 10: Jump target
        .d(read_data_1),     // 11: Register value (rs) for JR/JALR
        .sel(pc_src),
        .y(pc_next)
    );

    // Instruction Memory
    
    inst_rom #(
        .ADDR_WIDTH(10),   
    //   .INIT_PROGRAM("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\fib\\fib.inst_rom.memh")
        //  .INIT_PROGRAM("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\hello_world\\hello_world.inst_rom.memh")
    .INIT_PROGRAM("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\nbhelloworld\\nbhelloworld.inst_rom.memh")


		  ) instruction_memory (
        .clock(clk),
        .reset(reset),
        .addr_in(pc_next),
        .data_out(instruction)
    );

    // Register File
   
    mux2 #(.WIDTH(5)) write_reg_mux_rt_rd (
        .a(instr_20_16),     // rt
        .b(instr_15_11),     // rd
        .sel(reg_dst[0]),
        .y(write_reg_rd_or_rt)
    );
    
    // Second MUX: select between (rt or rd) and $ra
    mux2 #(.WIDTH(5)) write_reg_mux_ra (
        .a(write_reg_rd_or_rt),
        .b(5'd31),           // $ra = register 31
        .sel(reg_dst[1]),
        .y(write_register)
    );
    
    register register_file (
        .clk(clk),
        .we(reg_write_enable),
        .r_addr1(instr_25_21),
        .r_addr2(instr_20_16),
        .w_addr(write_register),
        .w_data(write_data),
        .r_data1(read_data_1),
        .r_data2(read_data_2)
    );

    // Sign Extender
    
    sign_extender #(.IN_WIDTH(16), .OUT_WIDTH(32)) sign_ext (
        .in(instr_15_0),
        .out(sign_extended)
    );
    
    // NEW: Zero Extender (for ANDI, ORI, XORI)
    
    zero_extender #(.IN_WIDTH(16), .OUT_WIDTH(32)) zero_ext (
        .in(instr_15_0),
        .out(zero_extended)
    );
    
    // NEW: Extension Select MUX
    

    mux2 #(.WIDTH(32)) extend_mux (
        .a(sign_extended),
        .b(zero_extended),
        .sel(ZeroExtend),
        .y(extended_immediate)
    );
    
    // NEW: LUI Shift and MUX
    
    // LUI shifts immediate left by 16 bits
    assign lui_shifted = {instr_15_0, 16'b0};

    mux2 #(.WIDTH(32)) lui_mux (
        .a(extended_immediate),
        .b(lui_shifted),
        .sel(LUI),
        .y(final_immediate)
    );
	 
    // Shift Amount (shamt) Extension and ALU A MUX
    
    // Zero-extend shamt (5 bits) to 32 bits
    assign shamt_extended = {27'b0, instr_10_6};
    
    // Select ALU A input: rs data OR shamt (for shift instructions)
    // ALUShift = 0: Use rs (read_data_1) - normal instructions
    // ALUShift = 1: Use shamt - shift instructions (SLL, SRL, SRA)
    mux2 #(.WIDTH(32)) alu_a_mux (
        .a(read_data_1),
        .b(shamt_extended),
        .sel(ALUShift),
        .y(alu_input_a)
    );
    // ALU Input MUX
    
    mux2 #(.WIDTH(32)) alu_b_mux (
        .a(read_data_2),
        .b(final_immediate),  // CHANGED: now uses final_immediate
        .sel(alu_src),
        .y(alu_input_b)
    );

    // ALU
    
	 alu alu_unit (
        .Func_in(alu_func),
        .A_in(alu_input_a),      // CHANGED: was read_data_1
        .B_in(alu_input_b),
        .O_out(alu_result),
        .Branch_out(alu_branch),
        .Jump_out(alu_jump)
    );
	 
	 
    // Data Memory
    
    data_memory #(
//	 "C:\Mac\Home\Documents\COE181\quartus_codes\lab9_v2\lab9-acebu-cagula\memh\fib\fib.data_ram0.memh"
//	 "C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\fib\\fib.data_ram0.memh"
	// 	.INIT_PROGRAM0("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\fib\\fib.data_ram0.memh"),
    //    .INIT_PROGRAM1("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\fib\\fib.data_ram1.memh"),
    //    .INIT_PROGRAM2("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\fib\\fib.data_ram2.memh"),
    //    .INIT_PROGRAM3("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\fib\\fib.data_ram3.memh")


	//   .INIT_PROGRAM0("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\hello_world\\hello_world.data_ram0.memh"),
	//   .INIT_PROGRAM1("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\hello_world\\hello_world.data_ram1.memh"),
	//   .INIT_PROGRAM2("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\hello_world\\hello_world.data_ram2.memh"),
	//   .INIT_PROGRAM3("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\hello_world\\hello_world.data_ram3.memh")


	  .INIT_PROGRAM0("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\nbhelloworld\\nbhelloworld.data_ram0.memh"),
	  .INIT_PROGRAM1("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\nbhelloworld\\nbhelloworld.data_ram1.memh"),
	  .INIT_PROGRAM2("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\nbhelloworld\\nbhelloworld.data_ram2.memh"),
	  .INIT_PROGRAM3("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab9_v2\\lab9-acebu-cagula\\memh\\nbhelloworld\\nbhelloworld.data_ram3.memh")

	 ) data_mem (
        .clock(clk),
        .reset(reset),
        .addr_in(alu_result),
        .writedata_in(read_data_2),
        .re_in(mem_read_enable),
        .we_in(mem_write_enable),
        .size_in(mem_size),              
        .readdata_out(read_data),
        .serial_in(serial_in),
        .serial_ready_in(serial_ready_in),
        .serial_valid_in(serial_valid_in),
        .serial_out(serial_out),
        .serial_rden_out(serial_rden_out),
        .serial_wren_out(serial_wren_out)
    );

    // NEW: Load Byte/Half Extension
    

    load_extender load_ext (
        .mem_data(read_data),
        .byte_offset(alu_result[1:0]),   // Low 2 bits of address select byte/half
        .load_type(LoadType),
        .extended_data(load_extended_data)
    );
    

    mux2 #(.WIDTH(32)) load_select_mux (
        .a(read_data),
        .b(load_extended_data),
        .sel(LoadExtend),
        .y(final_mem_data)
    );

    // Write Back MUX
    
    
    // First MUX: select between ALU result and memory data
    mux2 #(.WIDTH(32)) write_data_mux_alu_mem (
        .a(alu_result),
        .b(final_mem_data),  // CHANGED: now uses final_mem_data
        .sel(mem_to_reg[0]),
        .y(writeback_alu_or_mem)
    );
    
    // Second MUX: select between (ALU/memory) and PC+4
    mux2 #(.WIDTH(32)) write_data_mux_pc (
        .a(writeback_alu_or_mem),
        .b(pc_plus4),        // PC+4 for JAL, JALR
        .sel(mem_to_reg[1]),
        .y(write_data)
    );

    // ========================================================================
    // Control Unit
    // ========================================================================

    control_unit CU (
        .instruction(instruction),
        .RegWrite(RegWrite),
        .RegDst(RegDst_signal),
        .ALUSrc(ALUSrc_signal),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg_signal),
        .ALUOp(ALUOp),
        // NEW: Lab 9 signals
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

    // ========================================================================
    // Connect Control Unit to Datapath
    // ========================================================================
    
    assign reg_write_enable = RegWrite;
    assign mem_write_enable = MemWrite;
    assign mem_read_enable  = MemRead;
    assign mem_size         = MemSize;           // CHANGED: now from control unit
    assign alu_src          = ALUSrc_signal;
    assign mem_to_reg       = MemToReg_signal;   // CHANGED: now 2-bit
    assign reg_dst          = RegDst_signal;     // CHANGED: now 2-bit
    assign alu_func         = ALUOp;

    // ========================================================================
    // PC Next - NOW WITH BRANCHES AND JUMPS
    // ========================================================================
    // REMOVED: assign pc_next = pc_plus4;
    // pc_next is now driven by the pc_mux above

endmodule	