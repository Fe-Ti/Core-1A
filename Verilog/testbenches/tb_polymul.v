`include "../polymul.v"
`default_nettype none

module tb_polymul;

reg [7:0] a;
wire [7:0] c = 8'd251; // 8-bit decimal 251
wire [8:0] prim_poly = 9'b111000011; // Kuznyechik GF(2^8) primitive poly
wire [7:0] result;

reg [7:0] reference_results [0:255];

polymul mul8bit (
    .a_in (a),
    .b_in (c),
    .prim_poly (prim_poly),
    .result_out (result)
);


// initial begin
//     $dumpfile("tb_.vcd");
//     $dumpvars(0, tb_);
// end
integer i, failures;
initial begin
    failures = 0;
    $display("Reading reference values...");
    $readmemb("tb_polymul_results.txt", reference_results);
    $display("a * c = result");
    for (i = 0; i < 256; i = i+1) begin
        a = i[7:0];
        #10;
        $display("%b * %b == %b", a, c, result);
        if(result != reference_results[i]) begin
            failures = failures + 1;
            $display("Unexpected result! Ref: %b",reference_results[i]);
        end
    end
    $display("Failure count: %d", failures);
    $finish;
end

endmodule
