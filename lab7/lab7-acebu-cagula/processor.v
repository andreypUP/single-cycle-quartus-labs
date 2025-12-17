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
//	wire [4:0] read_data1_wire;
//	wire [4:0] read_data2_wire;

	wire [31:0] read_data1_wire;
	wire [31:0] read_data2_wire;
	
	// Sign Extender Wire
	wire [31:0] sign_extender_out_wire;
	// ALU wire
	wire [31:0] alu_main_out;
	// MUX wires
	wire [31:0] mux1_writeout_wire;
	wire [31:0] mux2_writeout_wire;
	wire [31:0] mux3_writeout_wire;
	//Data Memory Wires
	wire [31:0] data_mem_out_wire;

	// Serial Wires
	wire [7:0] serial_out_wire;
	wire [7:0] serial_in_wire;
	wire serial_valid_in_wire;
	wire serial_ready_in_wire;
	wire serial_rden_out_wire;
	wire serial_wren_out_wire;


	pc counter(
		.clk(clock), 
		.rst(reset),
		.pc_in(pc_next_wire),
		.pc_out(pc_out_wire)
		);

	alu for_pc(
		.Func_in(6'b000000),
		.A_in(pc_out_wire),
		.B_in(32'd4),
		.O_out(pc_plus_4),
		.Branch_out(),
		.Jump_out()
	);
	
	inst_rom instruction(
		.clock(clock),
		.reset(reset),
		.addr_in(pc_out_wire),
		.data_out(inst_out_wire)
		);
	
	mux2 write(
		.sel(),
		.a(inst_out_wire[20:16]),
		.b(inst_out_wire[15:11]),
		.out(mux1_writeout_wire)
		);
		
	register_file read(
		.clk(clock),
		.rst(reset),
		.reg_write_en(),
		.read_reg1(inst_out_wire[25:21]),
		.read_reg2(inst_out_wire[20:16]),
		.write_reg(mux_writeout_wire),
		.write_data(mux3_writeout_wire),
		.read_data1(read_data1_wire),
		.read_data2(read_data2_wire)
		);
		
	sign_extender extend(
		.in(inst_out_wire[15:0]),
		.out(sign_extender_out_wire)
		);
		
	mux2 data(
		.sel(),
		.a(read_data2_wire),
		.b(sign_extender_out_wire),
		.out(mux2_writeout_wire)
		);
		
	alu main(
		.Func_in(),
		.A_in(read_data1_wire),
		.B_in(mux2_writeout_wire),
		.O_out(alu_main_out),
		.Branch_out(),
		.Jump_out()
		);
		
	data_memory our_data_memory(
		.clock(clock),
		.reset(reset),
		.size_in(),
		.addr_in(alu_main_out),
		.writedata_in(read_data2_wire),
		.readdata_out(data_mem_out_wire),
		.re_in(),
		.we_in(),
		.serial_in(serial_in_wire),
		.serial_valid_in(serial_valid_in_wire),
		.serial_ready_in(serial_ready_in_wire),
		.serial_out(serial_out_wire),
		.serial_rden_out(serial_rden_out_wire),
		.serial_wren_out(serial_wren_out_wire)
	);

	mux2 final(
		.sel(),
		.a(alu_main_out),
		.b(data_mem_out_wire),
		.out(mux3_writeout_wire)
		);
endmodule