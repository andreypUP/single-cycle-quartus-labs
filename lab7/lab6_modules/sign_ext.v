// sign_ext.v
// 16-bit to 32-bit sign extender for MIPS immediates

module sign_ext (
    input  [15:0] in,   // 16-bit immediate from instruction
    output [31:0] out   // 32-bit sign-extended value
);

    // Replicate the MSB (sign bit) 16 times
    assign out = {{16{in[15]}}, in};

endmodule
