module booth_multiplier(
    input wire clk,
    input wire reset,
    input wire start,
    input wire signed [7:0] multiplicand,
    input wire signed [7:0] multiplier,
    output reg signed [15:0] product,
    output reg done
);

    reg [1:0] state, next_state;
    reg signed [17:0] A, next_A;
    reg signed [8:0] M;
    reg signed [8:0] Q;
    wire [2:0] booth_bits;
    wire [2:0] operation;
    reg [2:0] count;

    wire signed [17:0] op1, op2;
    wire signed [17:0] adder_res;
    reg adder_s;
    reg [17:0] M_shifted;

    localparam IDLE = 2'b00, WORK = 2'b01, DONE = 2'b10;

    assign booth_bits = Q[2:0];
    assign op1 = A;
    assign op2 = M_shifted;

    control_unit CU (
        .booth_bits(booth_bits),
        .operation(operation)
    );

    adder ADDER (
        .op1(op1),
        .op2(op2),
        .s(adder_s),
        .res(adder_res)
    );

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: next_state = start ? WORK : IDLE;
            WORK: next_state = (count == 3) ? DONE : WORK;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A <= 0;
            count <= 0;
            done <= 0;
            product <= 0;
            M <= 0;
            Q <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    A <= 18'd0;
                    count <= 0;
                    done <= 0;
                    M <= {multiplicand[7], multiplicand}; // sign-extended to 9 bits
                    Q <= {multiplier, 1'b0};              // 9 bits + appended 0
                end
                WORK: begin
                    A <= next_A;
                    Q <= Q >>> 2;
                    count <= count + 1;
                end
                DONE: begin
                    product <= A[15:0];
                    done <= 1;
                end
            endcase
        end
    end

    always @(*) begin
        M_shifted = 0;
        adder_s = 0;
        next_A = A;

        case (operation)
            3'b001, 3'b010: begin // +M
                M_shifted = {{9{M[8]}}, M} <<< (count * 2);
                adder_s = 0;
                next_A = adder_res;
            end
            3'b011: begin // +2M
                M_shifted = ({{9{M[8]}}, M} <<< 1) <<< (count * 2);
                adder_s = 0;
                next_A = adder_res;
            end
            3'b100: begin // -2M
                M_shifted = ({{9{M[8]}}, M} <<< 1) <<< (count * 2);
                adder_s = 1;
                next_A = adder_res;
            end
            3'b101, 3'b110: begin // -M
                M_shifted = {{9{M[8]}}, M} <<< (count * 2);
                adder_s = 1;
                next_A = adder_res;
            end
            default: begin
                next_A = A; // no operation
            end
        endcase
    end

endmodule
