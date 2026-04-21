
// Copyright 2026 Fe-Ti aka Tim Kravchenko
//
// Magma hardware blocks lib
// 
// Nonlinear bijection
// Version:  1
//

// Pi'_i = (Pi'_i(0), Pi'_i(1), ... , Pi'_i(15)), i = 0, 1, ..., 7:

// Pi'_0 = (12, 4, 6, 2, 10, 5, 11, 9, 14, 8, 13, 7, 0, 3, 15, 1);
// Pi'_1 = (6, 8, 2, 3, 9, 10, 5, 12, 1, 14, 4, 7, 11, 13, 0, 15);
// Pi'_2 = (11, 3, 5, 8, 2, 15, 10, 13, 14, 1, 7, 4, 12, 9, 6, 0);
// Pi'_3 = (12, 8, 2, 1, 13, 4, 15, 6, 7, 0, 10, 5, 3, 14, 9, 11);
// Pi'_4 = (7, 15, 5, 10, 8, 1, 6, 13, 0, 9, 3, 14, 11, 4, 2, 12);
// Pi'_5 = (5, 13, 15, 6, 9, 2, 12, 10, 11, 7, 8, 1, 4, 3, 14, 0);
// Pi'_6 = (8, 14, 2, 5, 6, 9, 1, 12, 15, 4, 11, 0, 13, 10, 3, 7);
// Pi'_7 = (1, 7, 14, 13, 0, 5, 8, 3, 4, 15, 10, 6, 9, 12, 11, 2);

`timescale 1ns/1ns


module magma_pi_0 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd12;
        4'd1 : piresult = 4'd4;
        4'd2 : piresult = 4'd6;
        4'd3 : piresult = 4'd2;
        4'd4 : piresult = 4'd10;
        4'd5 : piresult = 4'd5;
        4'd6 : piresult = 4'd11;
        4'd7 : piresult = 4'd9;
        4'd8 : piresult = 4'd14;
        4'd9 : piresult = 4'd8;
        4'd10 : piresult = 4'd13;
        4'd11 : piresult = 4'd7;
        4'd12 : piresult = 4'd0;
        4'd13 : piresult = 4'd3;
        4'd14 : piresult = 4'd15;
        4'd15 : piresult = 4'd1;
    endcase
end
endmodule

module magma_pi_1 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd6;
        4'd1 : piresult = 4'd8;
        4'd2 : piresult = 4'd2;
        4'd3 : piresult = 4'd3;
        4'd4 : piresult = 4'd9;
        4'd5 : piresult = 4'd10;
        4'd6 : piresult = 4'd5;
        4'd7 : piresult = 4'd12;
        4'd8 : piresult = 4'd1;
        4'd9 : piresult = 4'd14;
        4'd10 : piresult = 4'd4;
        4'd11 : piresult = 4'd7;
        4'd12 : piresult = 4'd11;
        4'd13 : piresult = 4'd13;
        4'd14 : piresult = 4'd0;
        4'd15 : piresult = 4'd15;
    endcase
end
endmodule

module magma_pi_2 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd11;
        4'd1 : piresult = 4'd3;
        4'd2 : piresult = 4'd5;
        4'd3 : piresult = 4'd8;
        4'd4 : piresult = 4'd2;
        4'd5 : piresult = 4'd15;
        4'd6 : piresult = 4'd10;
        4'd7 : piresult = 4'd13;
        4'd8 : piresult = 4'd14;
        4'd9 : piresult = 4'd1;
        4'd10 : piresult = 4'd7;
        4'd11 : piresult = 4'd4;
        4'd12 : piresult = 4'd12;
        4'd13 : piresult = 4'd9;
        4'd14 : piresult = 4'd6;
        4'd15 : piresult = 4'd0;
    endcase
end
endmodule

module magma_pi_3 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd12;
        4'd1 : piresult = 4'd8;
        4'd2 : piresult = 4'd2;
        4'd3 : piresult = 4'd1;
        4'd4 : piresult = 4'd13;
        4'd5 : piresult = 4'd4;
        4'd6 : piresult = 4'd15;
        4'd7 : piresult = 4'd6;
        4'd8 : piresult = 4'd7;
        4'd9 : piresult = 4'd0;
        4'd10 : piresult = 4'd10;
        4'd11 : piresult = 4'd5;
        4'd12 : piresult = 4'd3;
        4'd13 : piresult = 4'd14;
        4'd14 : piresult = 4'd9;
        4'd15 : piresult = 4'd11;
    endcase
end
endmodule

module magma_pi_4 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd7;
        4'd1 : piresult = 4'd15;
        4'd2 : piresult = 4'd5;
        4'd3 : piresult = 4'd10;
        4'd4 : piresult = 4'd8;
        4'd5 : piresult = 4'd1;
        4'd6 : piresult = 4'd6;
        4'd7 : piresult = 4'd13;
        4'd8 : piresult = 4'd0;
        4'd9 : piresult = 4'd9;
        4'd10 : piresult = 4'd3;
        4'd11 : piresult = 4'd14;
        4'd12 : piresult = 4'd11;
        4'd13 : piresult = 4'd4;
        4'd14 : piresult = 4'd2;
        4'd15 : piresult = 4'd12;
    endcase
end
endmodule

module magma_pi_5 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd5;
        4'd1 : piresult = 4'd13;
        4'd2 : piresult = 4'd15;
        4'd3 : piresult = 4'd6;
        4'd4 : piresult = 4'd9;
        4'd5 : piresult = 4'd2;
        4'd6 : piresult = 4'd12;
        4'd7 : piresult = 4'd10;
        4'd8 : piresult = 4'd11;
        4'd9 : piresult = 4'd7;
        4'd10 : piresult = 4'd8;
        4'd11 : piresult = 4'd1;
        4'd12 : piresult = 4'd4;
        4'd13 : piresult = 4'd3;
        4'd14 : piresult = 4'd14;
        4'd15 : piresult = 4'd0;
    endcase
end
endmodule

module magma_pi_6 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd8;
        4'd1 : piresult = 4'd14;
        4'd2 : piresult = 4'd2;
        4'd3 : piresult = 4'd5;
        4'd4 : piresult = 4'd6;
        4'd5 : piresult = 4'd9;
        4'd6 : piresult = 4'd1;
        4'd7 : piresult = 4'd12;
        4'd8 : piresult = 4'd15;
        4'd9 : piresult = 4'd4;
        4'd10 : piresult = 4'd11;
        4'd11 : piresult = 4'd0;
        4'd12 : piresult = 4'd13;
        4'd13 : piresult = 4'd10;
        4'd14 : piresult = 4'd3;
        4'd15 : piresult = 4'd7;
    endcase
end
endmodule

module magma_pi_7 (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
        4'd0 : piresult = 4'd1;
        4'd1 : piresult = 4'd7;
        4'd2 : piresult = 4'd14;
        4'd3 : piresult = 4'd13;
        4'd4 : piresult = 4'd0;
        4'd5 : piresult = 4'd5;
        4'd6 : piresult = 4'd8;
        4'd7 : piresult = 4'd3;
        4'd8 : piresult = 4'd4;
        4'd9 : piresult = 4'd15;
        4'd10 : piresult = 4'd10;
        4'd11 : piresult = 4'd6;
        4'd12 : piresult = 4'd9;
        4'd13 : piresult = 4'd12;
        4'd14 : piresult = 4'd11;
        4'd15 : piresult = 4'd2;
    endcase
end
endmodule

