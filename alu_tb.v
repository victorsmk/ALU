`timescale 1ns / 1ps

module alu_tb;

    // Inputs
    reg clk;
    reg reset;
    reg start;
    reg [1:0] op_select; // 00 = add, 01 = sub, 10 = mul, 11 = div
    reg signed [15:0] op1;
    reg signed [7:0] op2;

    // Outputs
    wire signed [15:0] res;
    wire done;

    // Instantiate the ALU
    alu uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .op_select(op_select),
        .op1(op1),
        .op2(op2),
        .res(res),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns clock

    // Task to run a test
    task run_test;
        input signed [15:0] a;
        input signed [7:0] b;
        input [1:0] op; // 00 = add, 01 = sub, 10 = mul, 11 = div
        begin
            @(negedge clk);
            reset = 1;
            start = 0;
            @(negedge clk);
            reset = 0;
            op1 = a;
            op2 = b;
            op_select = op;
            start = 1;
            @(negedge clk);
            start = 0;

            // Wait for done
            while (!done) @(negedge clk);

            case (op)
                2'b00: $display("ADD: A = %0d, B = %0d -> Result = %0d", $signed(a), $signed(b), $signed(res));
                2'b01: $display("SUB: A = %0d, B = %0d -> Result = %0d", $signed(a), $signed(b), $signed(res));
                2'b10: $display("MUL: A = %0d, B = %0d -> Product = %0d", $signed(a), $signed(b), $signed(res));
                2'b11: $display("DIV: A = %0d, B = %0d -> Quotient = %0d, Remainder = %0d", $signed(a), $signed(b), $signed(res[15:8]), $signed(res[7:0]));
            endcase
        end
    endtask

    initial begin
        $display("Starting ALU Testbench...");
        clk = 0;
        reset = 0;
        start = 0;

        #20;

        // Addition tests
        run_test(16'd10, 8'd5, 2'b00);    // 10 + 5 = 15
        run_test(-16'sd8, 8'd3, 2'b00);   // -8 + 3 = -5

        // Subtraction tests
        run_test(16'd20, 8'd4, 2'b01);    // 20 - 4 = 16
        run_test(16'd7, -8'sd2, 2'b01);   // 7 - (-2) = 9

        // Multiplication tests
        run_test(16'd6, 8'd3, 2'b10);     // 6 * 3 = 18
        run_test(-16'sd4, 8'd5, 2'b10);   // -4 * 5 = -20
        run_test(16'd10, -8'sd3, 2'b10);  // 10 * -3 = -30
        run_test(-16'sd7, -8'sd2, 2'b10); // -7 * -2 = 14

        // Division tests
        run_test(16'd1234, 8'd33, 2'b11);    // 20 / 4 = 5, R = 0
        run_test(16'd4112, 8'd40, 2'b11);    // 23 / 5 = 4, R = 3

        $display("ALU Testbench completed.");
        $stop;
    end

endmodule

