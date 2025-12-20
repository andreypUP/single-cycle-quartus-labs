module program_counter #(
    parameter RESET_ADDR = 32'h00400000
)(
    input        clk,
    input        reset,
    input  [31:0] next_pc,
    output reg [31:0] pc_out
);

    always @(posedge clk) begin
        if(reset)
            pc_out <= RESET_ADDR;   // start at MIPS default
        else
            pc_out <= next_pc;
    end

endmodule
