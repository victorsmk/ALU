module non_restoring_division (
    input wire clk,
    input wire rst,        
    input wire start,      
    input wire [15:0] dividend,  
    input wire [7:0] divisor,   
    output reg [7:0] quotient,   
    output reg [7:0] remainder,  
    output reg done              
);

    reg [7:0] A;        
    reg [7:0] Q;        
    reg [7:0] M;        
    reg s;              
    reg [3:0] count;    

    //FSM
    parameter IDLE = 3'b000;
    parameter SHIFT = 3'b001;
    parameter OPERATE = 3'b010;
    parameter CORRECT = 3'b011;  
    parameter DONE = 3'b100;

    reg [2:0] state, next_state;
    reg [7:0] corrected_remainder;

    always @(*) begin
    case (state)
        IDLE: next_state = start ? SHIFT : IDLE;
        SHIFT: next_state = OPERATE;
        OPERATE: next_state = (count == 4'd8) ? CORRECT : SHIFT;
        CORRECT: next_state = DONE;
        DONE: next_state = IDLE;
        default: next_state = IDLE;
    endcase
end

    always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        done <= 0;
        quotient <= 0;
        remainder <= 0;
        A <= 0;
        Q <= 0;
        M <= 0;
        s <= 0;
        count <= 0;
    end else begin
        state <= next_state;

        case (state)
            IDLE: begin
                done <= 0;
                if (start) begin
                    A <= dividend[15:8];
                    Q <= dividend[7:0];
                    M <= divisor;
                    s <= 0;
                    count <= 0;
                end
            end

            SHIFT: begin
                {s, A, Q} <= {s, A, Q} << 1;
            end

            OPERATE: begin
                if (s == 0)
                    {s, A} <= {s, A} - {1'b0, M};
                else
                    {s, A} <= {s, A} + {1'b0, M};

                if (s == 1)
                    Q[0] <= 0;
                else
                    Q[0] <= 1;

                count <= count + 1;
            end

            CORRECT: begin
                if (s == 1)
    			corrected_remainder <= A + M;
		else
    			corrected_remainder <= A;
            end

            DONE: begin
                remainder <= corrected_remainder;
		quotient <= Q;
		done <= 1;
            end
        endcase
    end
end
endmodule
