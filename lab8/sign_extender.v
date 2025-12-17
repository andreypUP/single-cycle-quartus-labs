module sign_extender(
	input wire [15:0] in,
	output wire [31:0] out
);

	/* Copy the MSB (15-bit position) and concatenate 16 times
		in front of the 16-bit input 
	*/
	assign out = {{16{in[15]}}, in};
endmodule	