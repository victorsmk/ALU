module fac (
    input  A,
    input  B,
    input  Cin,
    output Sum,
    output Cout
);
    assign Sum  = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (A & Cin);
endmodule


module adder (
    input  [17:0] op1,
    input  [17:0] op2,
    input         s,     
    output [17:0] res
);
    wire [17:0] op2_xor;
    wire [17:0] carry;

    assign op2_xor = op2 ^ {18{s}};

    fac fac0 (
        .A(op1[0]), .B(op2_xor[0]), .Cin(s),  // s = 0 (addition), 1 (subtraction)
        .Sum(res[0]), .Cout(carry[0])
    );

    genvar i;
    generate
        for (i = 1; i < 18; i = i + 1) begin : rca_loop
            fac fac (
                .A(op1[i]), .B(op2_xor[i]), .Cin(carry[i-1]),
                .Sum(res[i]), .Cout(carry[i])
            );
        end
    endgenerate

endmodule
