module register_file (
    input wire clk,
    input wire rst,
    input wire reg_write_en,     // Write Enable    
    input wire [4:0] read_reg1,  // rs
    input wire [4:0] read_reg2,  // rt
    input wire [4:0] write_reg,  // rd
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] registers [0:31];
    integer i;

    // Asynchronous Read
    // Note: We explicitly force output 0 if reading register 0, 
    // though the write logic also prevents reg[0] from changing.
    assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];

    // Synchronous Write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end
        else begin
            // WRITE PROTECTION: Only write if Write Enable is HIGH 
            // AND the destination is NOT register 0.
            if (reg_write_en && (write_reg != 5'b0)) begin
                registers[write_reg] <= write_data;
            end
        end
    end
endmodule