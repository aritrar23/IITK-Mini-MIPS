//`timescale 1ns / 1ps
//module ALU
//(
//    input wire signed [31:0] A,
//    input wire signed [31:0] B,
//    input wire [3:0] ALUop,
//    output reg signed [31:0] ALUout
//);

//always @(ALUop,A,B)
//begin
//    case(ALUop)
//        4'b0000: ALUout = 32'b0;
//        4'b0001: ALUout = A+B;
//        4'b0010: ALUout = A-B;
//        4'b0011: ALUout = A&B;
//        4'b0100: ALUout = A|B;
//        4'b0101: ALUout = A<<B;
//        4'b0110: ALUout = A>>B;
//        4'b0111: ALUout = (A==B);
//        4'b1000: ALUout = (A<B);
//        4'b1001: ALUout = (A>B);
//        default : ALUout = 32'b0;
//    endcase
//end
//endmodule 

`timescale 1ns / 1ps
module ALU
(
    input wire signed [31:0] A,
    input wire signed [31:0] B,
    input wire [3:0] ALUop,
    output reg signed [31:0] ALUout
);

// Floating-point addition/subtraction wires
wire [31:0] fp_add_out;
wire [31:0] fp_sub_out;

fp_adder fp_add (
    .a(A),
    .b(B),
    .result(fp_add_out)
);

fp_subtractor fp_sub (
    .a(A),
    .b(B),
    .result(fp_sub_out)
);

function [1:0] fp_compare;
    input [31:0] a, b;
    begin
        // Check for NaN
        if ((a[30:23] == 8'hFF && a[22:0] != 0) || (b[30:23] == 8'hFF && b[22:0] != 0)) begin
            fp_compare = 2'b11; 
        end
        // Check for zero
        else if (a[30:0] == 0 && b[30:0] == 0) begin
            fp_compare = 2'b00; 
        end
        // Compare signs
        else if (a[31] && !b[31]) begin
            fp_compare = 2'b01; // A < B
        end
        else if (!a[31] && b[31]) begin
            fp_compare = 2'b10; // A > B
        end
        // Same sign - compare magnitudes
        else if (!a[31]) begin // Both positive
            if (a[30:23] < b[30:23] || 
                (a[30:23] == b[30:23] && a[22:0] < b[22:0])) begin
                fp_compare = 2'b01; // A < B
            end
            else if (a[30:23] == b[30:23] && a[22:0] == b[22:0]) begin
                fp_compare = 2'b00; // Equal
            end
            else begin
                fp_compare = 2'b10; // A > B
            end
        end
        else begin // Both negative
            if (a[30:23] > b[30:23] || 
                (a[30:23] == b[30:23] && a[22:0] > b[22:0])) begin
                fp_compare = 2'b01; // A < B (more negative)
            end
            else if (a[30:23] == b[30:23] && a[22:0] == b[22:0]) begin
                fp_compare = 2'b00; // Equal
            end
            else begin
                fp_compare = 2'b10; // A > B
            end
        end
    end
endfunction

always @(ALUop,A,B)
begin
    case(ALUop)
        4'b0000: ALUout = 32'b0;
        4'b0001: ALUout = A+B;
        4'b0010: ALUout = A-B;
        4'b0011: ALUout = A&B;
        4'b0100: ALUout = A|B;
        4'b0101: ALUout = A<<B;
        4'b0110: ALUout = A>>B;
        4'b0111: ALUout = (A==B);
        4'b1000: ALUout = (A<B);
        4'b1001: ALUout = (A>B);
        4'b1100: ALUout = fp_add_out;  
        4'b1101: ALUout = fp_sub_out;  
        4'b1110: begin // Floating-point less than
    ALUout = (fp_compare(A, B) == 2'b01) ? 32'b1 : 32'b0;
end
4'b1111: begin // Floating-point equal
    ALUout = (fp_compare(A, B) == 2'b00 ? 32'b1 : 32'b0);
end
        default : ALUout = 32'b0;
    endcase
end
endmodule