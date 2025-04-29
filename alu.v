module alu(
    input wire clk,
    input wire reset,
    input wire start, 
    input wire [1:0] op_select,   // 00: add, 01: sub, 10: mul, 11: div
    input wire signed [15:0] op1,             
    input wire signed [7:0] op2,             
    output reg signed [15:0] res,             
    output reg done                           
);

    wire signed [15:0] product;
    wire mult_done;

    wire [7:0] quotient;
    wire [7:0] remainder;
    wire div_done;

    wire [17:0] adder_result;

    wire mult_start = start && (op_select == 2'b10);
    wire div_start  = start && (op_select == 2'b11);

    wire [17:0] op1_ext = {{2{op1[15]}}, op1};
    wire [17:0] op2_ext = {{10{op2[7]}}, op2};
    wire adder_sub = (op_select == 2'b01); // subtraction if op_select == 01

    booth_multiplier mult (
        .clk(clk),
        .reset(reset),
        .start(mult_start),
        .multiplicand(op1[7:0]),
        .multiplier(op2),
        .product(product),
        .done(mult_done)
    );

    non_restoring_division div (
        .clk(clk),
        .rst(reset),
        .start(div_start),
        .dividend(op1),
        .divisor(op2),
        .quotient(quotient),
        .remainder(remainder),
        .done(div_done)
    );

    adder addsub (
        .op1(op1_ext),
        .op2(op2_ext),
        .s(adder_sub),
        .res(adder_result)
    );

    always @(*) begin
        case (op_select)
            2'b00: begin // ADD
                res = adder_result[15:0];
                done = 1'b1;
            end
            2'b01: begin // SUB
                res = adder_result[15:0];
                done = 1'b1;
            end
            2'b10: begin // MUL
                res = product;
                done = mult_done;
            end
            2'b11: begin // DIV
                res = {quotient, remainder};
                done = div_done;
            end
            default: begin
                res = 16'b0;
                done = 1'b0;
            end
        endcase
    end
endmodule


