`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 01:33:51 PM
// Design Name: 
// Module Name: fp_sub
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fp_subtractor (
    input [31:0] a,
    input [31:0] b,
    output wire [31:0] result
);
    // Floating-point subtraction = addition with the second operand's sign flipped
    wire [31:0] neg_b = {~b[31], b[30:0]};
    
    fp_adder add_inst (
        .a(a),
        .b(neg_b),
        .result(result)
    );
endmodule