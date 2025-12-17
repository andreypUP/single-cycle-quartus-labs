//module Mux2(
//    input wire sel,              // Select bit (0 or 1)
//    input wire [31:0] a,    // Input 0
//    input wire [31:0] b,    // Input 1
//    output wire [31:0] out  // Output
//);
//
//    // if bit=0, out=a. if sel=1, out=b.
//    assign out = (sel) ? b : a;
//
//endmodule

module mux2(
    input sel,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] out
);
    always @(*) begin
        if (sel == 1'b0)
            out = a;
        else
            out = b;
    end
endmodule
