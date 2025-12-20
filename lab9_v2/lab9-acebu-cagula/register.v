module register (
    input	clk,
    input	we,            		  // Write Enable
    input	[4:0]   r_addr1,       // Read address 1
    input	[4:0]   r_addr2,       // Read address 2
    input	[4:0]   w_addr,        // Write address
    input	[31:0]  w_data,        // Write data
    output	[31:0]  r_data1,       // Read data 1
    output	[31:0]  r_data2        // Read data 2
);

	reg [31:0] regs [31:0];
	
	//Asynchrounous read
	assign r_data1 = (r_addr1 == 0) ? 32'b0 : regs[r_addr1];
	assign r_data2 = (r_addr2 == 0) ? 32'b0 : regs[r_addr2];
	
	//Synchronous write
	always @(posedge clk) begin
		if (we && (w_addr != 0)) begin
			regs[w_addr] <= w_data;
		end
	end

endmodule