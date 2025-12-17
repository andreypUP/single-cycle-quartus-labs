module processor(
	input clock,
	input reset,
	//these ports are used for serial IO and 
	//must be wired up to the data_memory module
	input [7:0] serial_in,
	input serial_valid_in,
	input serial_ready_in,
	output [7:0] serial_out,
	output serial_rden_out,
	output serial_wren_out
);
	// PC wire
	wire [31:0] pc_out_wire;
	wire [31:0] pc_next_wire;
	wire [31:0] pc_plus_4;
	
	// Instruction Rom Wire
	wire [31:0] inst_out_wire;
	wire [31:0] read_data1_wire;
	wire [31:0] read_data2_wire;
	
	// Sign Extender Wire
	wire [31:0] sign_extender_out_wire;
	
	// ALU wire
	wire [31:0] alu_main_out;
	
	// MUX wires
	wire [4:0] mux1_writeout_wire;
	wire [31:0] mux2_writeout_wire;
	wire [31:0] mux3_writeout_wire;
	
	// Data Memory Wires
	wire [31:0] data_mem_out_wire;
	
	// Control signals
	wire ctrl_reg_write;
	wire ctrl_mem_to_reg;
	wire ctrl_mem_write;
	wire ctrl_mem_read;
	wire ctrl_alu_src;
	wire ctrl_reg_dst;
	wire [5:0] ctrl_alu_func;
	
	// PC Register
	pc counter(
		.clk(clock), 
		.rst(reset),
		.pc_in(pc_next_wire),
		.pc_out(pc_out_wire)
	);
	
	// PC + 4 Adder
	adder pc_adder(
		.a(pc_out_wire),
		.b(32'd4),
		.sum(pc_plus_4)
	);
	
	// pc_next = pc + 4 (no branches/jumps yet)
	assign pc_next_wire = pc_plus_4;
	
	// Instruction Memory
	inst_rom #(
	.INIT_PROGRAM("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab8\\nb-helloworld\\nbhelloworld.inst_rom.memh")
	) instruction(
		.clock(clock),
		.reset(reset),
		.addr_in(pc_out_wire),
		.data_out(inst_out_wire)
	);
	
	// Control Unit
	control ctrl(
		.instruction(inst_out_wire),
		.reg_write(ctrl_reg_write),
		.mem_to_reg(ctrl_mem_to_reg),
		.mem_write(ctrl_mem_write),
		.mem_read(ctrl_mem_read),
		.alu_src(ctrl_alu_src),
		.reg_dst(ctrl_reg_dst),
		.alu_func(ctrl_alu_func)
	);
	
	// MUX1: Select write register (rt vs rd)
	mux2 #(.WIDTH(5)) write(
		.sel(ctrl_reg_dst),
		.a(inst_out_wire[20:16]),  // rt (I-type)
		.b(inst_out_wire[15:11]),  // rd (R-type)
		.out(mux1_writeout_wire)
	);
		
	// Register File
	register_file read(
		.clk(clock),
		.rst(reset),
		.reg_write_en(ctrl_reg_write),
		.read_reg1(inst_out_wire[25:21]),  // rs
		.read_reg2(inst_out_wire[20:16]),  // rt
		.write_reg(mux1_writeout_wire),
		.write_data(mux3_writeout_wire),
		.read_data1(read_data1_wire),
		.read_data2(read_data2_wire)
	);
		
	// Sign Extender
	sign_extender extend(
		.in(inst_out_wire[15:0]),
		.out(sign_extender_out_wire)
	);
		
	// MUX2: Select ALU B input (register vs immediate)
	mux2 #(.WIDTH(32)) data(
		.sel(ctrl_alu_src),
		.a(read_data2_wire),
		.b(sign_extender_out_wire),
		.out(mux2_writeout_wire)
	);
		
	// Main ALU
	alu main(
		.Func_in(ctrl_alu_func),
		.A_in(read_data1_wire),
		.B_in(mux2_writeout_wire),
		.O_out(alu_main_out),
		.Branch_out(),
		.Jump_out()
	);
		
	// Data Memory "C:\Mac\Home\Documents\COE181\quartus_codes\lab8\nb-helloworld\nbhelloworld.data_ram0.memh"
	data_memory #(
		.INIT_PROGRAM0("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab8\\nb-helloworld\\nbhelloworld.data_ram0.memh"),
		.INIT_PROGRAM1("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab8\\nb-helloworld\\nbhelloworld.data_ram1.memh"),
		.INIT_PROGRAM2("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab8\\nb-helloworld\\nbhelloworld.data_ram2.memh"),
		.INIT_PROGRAM3("C:\\Mac\\Home\\Documents\\COE181\\quartus_codes\\lab8\\nb-helloworld\\nbhelloworld.data_ram3.memh")
	) our_data_memory(
		.clock(clock),
		.reset(reset),
		.size_in(2'b11),  // Word access
		.addr_in(alu_main_out),
		.writedata_in(read_data2_wire),
		.readdata_out(data_mem_out_wire),
		.re_in(ctrl_mem_read),
		.we_in(ctrl_mem_write),
		.serial_in(serial_in),
		.serial_valid_in(serial_valid_in),
		.serial_ready_in(serial_ready_in),
		.serial_out(serial_out),
		.serial_rden_out(serial_rden_out),
		.serial_wren_out(serial_wren_out)
	);
	
	// MUX3: Select write-back data (ALU result vs memory data)
	mux2 #(.WIDTH(32)) final(
		.sel(ctrl_mem_to_reg),
		.a(alu_main_out),
		.b(data_mem_out_wire),
		.out(mux3_writeout_wire)
	);
	
endmodule