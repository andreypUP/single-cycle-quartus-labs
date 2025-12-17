module mux2 #(parameter WIDTH = 32)(
    input sel,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [WIDTH-1:0] out
);
    always @(*) begin
        if (sel == 1'b0)
            out = a;
        else
            out = b;
    end
endmodule