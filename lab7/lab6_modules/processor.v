module processor(
    input clock,
    input reset,

    input [7:0] serial_in,
    input serial_valid_in,
    input serial_ready_in,
    output [7:0] serial_out,
    output serial_rden_out,
    output serial_wren_out
);

    wire [31:0] pc_current, pc_next;
    wire [31:0] instruction;
    wire [31:0] reg_rd1, reg_rd2;
    wire [31:0] alu_out;
    wire [31:0] reg_wd;
    wire [31:0] alu_b_input;        // Output of MUX1 (ALU B input)
    wire [4:0] write_reg;           // Output of MUX2 (write register address)
    wire [31:0] sign_extended_imm;  // Sign-extended immediate
    wire [31:0] dmem_read_data;     // Data memory read output

    // Control placeholders (Lab 7)
    wire reg_write = 1'b0;
    wire alu_src = 1'b0;      // Control for MUX1: 0=register, 1=immediate
    wire reg_dst = 1'b0;      // Control for MUX2: 0=rt, 1=rd
    wire mem_to_reg = 1'b0;   // Control for MUX3: 0=ALU, 1=memory

    // PC
    pc PC(
        .clk(clock),
        .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_current)
    );

    // PC + 4
    adder pcAdder(
        .a(pc_current),
        .b(32'd4),
        .sum(pc_next)
    );

    // Instruction Memory (LAB SPEC: addr_in = PC_next)
    inst_rom #(
        .INIT_PROGRAM("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab7\\lab6_modules\\blank.memh")
    ) IMEM (
        .clock(clock),
        .reset(reset),
        .addr_in(pc_next),
        .data_out(instruction)
    );

    // Sign-extend immediate field (Instruction[15:0])
    assign sign_extended_imm = {{16{instruction[15]}}, instruction[15:0]};

    // MUX1: Select ALU B input (register vs immediate)
    mux2 #(.WIDTH(32)) ALU_B_MUX (
        .sel(alu_src),
        .a(reg_rd2),              // 0: Register data
        .b(sign_extended_imm),    // 1: Sign-extended immediate
        .out(alu_b_input)
    );

    // MUX2: Select write register address (rt vs rd)
    mux2 #(.WIDTH(5)) REG_DST_MUX (
        .sel(reg_dst),
        .a(instruction[20:16]),   // 0: rt (bits 20-16)
        .b(instruction[15:11]),   // 1: rd (bits 15-11)
        .out(write_reg)
    );

    // Register File
    reg_file RF(
        .clk(clock),
        .we(reg_write),
        .ra1(instruction[25:21]),
        .ra2(instruction[20:16]),
        .rw(write_reg),           // From MUX2
        .wd(reg_wd),              // From MUX3
        .rd1(reg_rd1),
        .rd2(reg_rd2)
    );

    // ALU (Func_in placeholder)
    alu ALU(
        .Func_in(instruction[5:0]),
        .A_in(reg_rd1),
        .B_in(alu_b_input),       // From MUX1
        .O_out(alu_out),
        .Branch_out(),
        .Jump_out()
    );

    // Data Memory
    data_memory #(
        .INIT_PROGRAM0("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab7\\lab6_modules\\blank.memh"),
        .INIT_PROGRAM1("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab7\\lab6_modules\\blank.memh"),
        .INIT_PROGRAM2("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab7\\lab6_modules\\blank.memh"),
        .INIT_PROGRAM3("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab7\\lab6_modules\\blank.memh")
    ) DMEM (
        .clock(clock),
        .reset(reset),
        .addr_in(alu_out),
        .writedata_in(reg_rd2),
        .re_in(1'b0),
        .we_in(1'b0),
        .readdata_out(dmem_read_data),
        .size_in(2'b11),
        .serial_in(serial_in),
        .serial_ready_in(serial_ready_in),
        .serial_valid_in(serial_valid_in),
        .serial_out(serial_out),
        .serial_rden_out(serial_rden_out),
        .serial_wren_out(serial_wren_out)
    );

    // MUX3: Select write-back data (ALU result vs memory data)
    mux2 #(.WIDTH(32)) MEM_TO_REG_MUX (
        .sel(mem_to_reg),
        .a(alu_out),              // 0: ALU result
        .b(dmem_read_data),       // 1: Memory read data
        .out(reg_wd)
    );

endmodule