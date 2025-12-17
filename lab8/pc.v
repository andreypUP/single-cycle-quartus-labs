module pc(
    input wire clk,
    input wire rst,
    input wire [31:0] pc_in,
    output reg [31:0] pc_out
);
    // MIPS Text Segment usually starts at 0x00400000
    parameter RESET_ADDRESS = 32'h00400000;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= RESET_ADDRESS;
        end
        else begin
            pc_out <= pc_in;
        end
    end
endmodule