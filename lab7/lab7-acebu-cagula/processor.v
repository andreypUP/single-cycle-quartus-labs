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
	
	//  wires
	wire [4:0] mux1_writeout_wire;  // Changed to 5 bits for register address
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

	// PC Register
	pc counter(
		.clk(clock), 
		.rst(reset),
		.pc_in(pc_next_wire),
		.pc_out(pc_out_wire)
	);

	// PC + 4 Adder (SEPARATE MODULE)
	adder pc_adder(
		.a(pc_out_wire),
		.b(32'd4),
		.sum(pc_plus_4)
	);
	
	//  pc_next = pc + 4 
	assign pc_next_wire = pc_plus_4;
	
	// Instruction Memory
	inst_rom instruction(
		.clock(clock),
		.reset(reset),
		.addr_in(pc_out_wire),
		.data_out(inst_out_wire)
	);
	
	// MUX1: Select write register (rt vs rd)
	mux2 #(.WIDTH(5)) write(
		.sel(1'b0),  // Placeholder control signal
		.a(inst_out_wire[20:16]),  // rt
		.b(inst_out_wire[15:11]),  // rd
		.out(mux1_writeout_wire)
	);
		
	// Register File
	register_file read(
		.clk(clock),
		.rst(reset),
		.reg_write_en(1'b0),  // Placeholder control signal
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
		.sel(1'b0),  // Placeholder control signal
		.a(read_data2_wire),
		.b(sign_extender_out_wire),
		.out(mux2_writeout_wire)
	);
		
	// Main ALU
	alu main(
		.Func_in(6'b100000),  // Placeholder: ADD operation
		.A_in(read_data1_wire),
		.B_in(mux2_writeout_wire),
		.O_out(alu_main_out),
		.Branch_out(),
		.Jump_out()
	);
		
	// Data Memory
	data_memory our_data_memory(
		.clock(clock),
		.reset(reset),
		.size_in(2'b11),  // Placeholder: word access
		.addr_in(alu_main_out),
		.writedata_in(read_data2_wire),
		.readdata_out(data_mem_out_wire),
		.re_in(1'b0),  // Placeholder control signal
		.we_in(1'b0),  // Placeholder control signal
		.serial_in(serial_in),
		.serial_valid_in(serial_valid_in),
		.serial_ready_in(serial_ready_in),
		.serial_out(serial_out),
		.serial_rden_out(serial_rden_out),
		.serial_wren_out(serial_wren_out)
	);

	// MUX3: Select write-back data (ALU result vs memory data)
	mux2 #(.WIDTH(32)) final(
		.sel(1'b0),  // Placeholder control signal
		.a(alu_main_out),
		.b(data_mem_out_wire),
		.out(mux3_writeout_wire)
	);
	
endmodule