
module polymul #(parameter  WIDTH = 8) (input wire [WIDTH-1:0] a_in, b_in,
    input wire [WIDTH:0] prim_poly,
    output wire [WIDTH-1:0] result_out);
reg [WIDTH-1:0] a, b, result;
reg msbit;

always @(*) begin
    integer i;
    result = 0;
    a = a_in;
    b = b_in;
    for (i = 0; i < WIDTH; i = i+1) begin
        if (b[0]) begin
            result = result ^ a;
        end
        msbit = a[WIDTH-1];
        a = {a[WIDTH-2:0], 1'b0};
        if (msbit) begin
            a = a ^ prim_poly[WIDTH-1:0];
        end
        b = {1'b0, b[WIDTH-1:1]};
    end
end

assign result_out = result;

endmodule
