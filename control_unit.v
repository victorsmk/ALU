module control_unit(
    input wire [2:0] booth_bits,
    output reg [2:0] operation
);
    always @(*) begin
        case (booth_bits)
            3'b000, 3'b111: operation = 3'b000; // 0
            3'b001, 3'b010: operation = 3'b001; // +M
            3'b011:         operation = 3'b011; // +2M
            3'b100:         operation = 3'b100; // -2M
            3'b101, 3'b110: operation = 3'b101; // -M
            default:        operation = 3'b000;
        endcase
    end
endmodule
