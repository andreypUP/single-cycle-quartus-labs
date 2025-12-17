`timescale 1ns / 1ps

/*
** -------------------------------------------------------------------
**  Instruction Rom for Single-Cycle MIPS Processor for Altera FPGAs
**
**  Change Log:
**  1/13/2012 - Adrian Caulfield - Initial Implementation
**
**
**  NOTE:  The Provided Modules do NOT follow the course coding standards
*/

module inst_rom(

	input clock,
    input reset,
    input [31:0] addr_in,
    output reg [31:0] data_out 

);
   
	 parameter ADDR_WIDTH = 10;
	parameter INIT_PROGRAM="C:/intelFPGA_lite/18.1/quartus/181.1/lab8-acebu-cagula/lab7-test.inst_rom.memh";
	//sparameter INIT_PROGRAM="C:/intelFPGA_lite/18.1/quartus/181.1/lab8-acebu-cagula/nbhelloworld.inst_rom.memh";
	 parameter DEFAULT_VALUE = 32'h00000000;
	 
    // ROM memory declaration
    reg [31:0] rom [0:2**ADDR_WIDTH-1];
    integer i;
    
    // Initialize ROM from file or with default values
    initial begin
        // First, initialize all locations with default value
        for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
            rom[i] = DEFAULT_VALUE;
        end
        
        // Then try to load from memory file
        if (INIT_PROGRAM != "") begin
            $readmemh(INIT_PROGRAM, rom);
            $display("ROM initialized from file: %s", INIT_PROGRAM);
        end else begin
            $display("ROM initialized with default values");
        end
    end
    
    // Fetch instruction with endian correction
    always @(*) begin
        if (reset) begin
            data_out <= 32'h00000000;
        end else begin
            // Endian swapping for SPIM compatibility
            data_out <= {
                rom[addr_in[ADDR_WIDTH+1:2]][7:0], 
                rom[addr_in[ADDR_WIDTH+1:2]][15:8], 
                rom[addr_in[ADDR_WIDTH+1:2]][23:16], 
                rom[addr_in[ADDR_WIDTH+1:2]][31:24]
            };
        end
    end
    
endmodule

