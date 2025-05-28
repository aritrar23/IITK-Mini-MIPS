//module fp_adder (
//    input [31:0] a,
//    input [31:0] b,
//    output reg [31:0] result
//);
//    // Extract sign, exponent, and mantissa
//    wire a_sign = a[31];
//    wire [7:0] a_exp = a[30:23];
//    wire [22:0] a_mant = a[22:0];
    
//    wire b_sign = b[31];
//    wire [7:0] b_exp = b[30:23];
//    wire [22:0] b_mant = b[22:0];
    
//    // Check for zero inputs
//    wire a_zero = (a_exp == 0) && (a_mant == 0);
//    wire b_zero = (b_exp == 0) && (b_mant == 0);
//    reg [7:0] exp_diff;
//    reg [23:0] larger_mant, smaller_mant; // Include hidden bit
//    reg larger_sign, smaller_sign;
//            reg [7:0] larger_exp, smaller_exp;
//    reg [24:0] sum_mant; // Extra bit for carry
//    integer shift;
    
//    // If either input is zero, return the other
//    always @(*) begin
//        if (a_zero) begin
//            result = b;
//        end else if (b_zero) begin
//            result = a;
//        end else begin
//            // Normalize exponents
            
            
//            if (a_exp > b_exp || (a_exp == b_exp && a_mant > b_mant)) begin
//                exp_diff = a_exp - b_exp;
//                larger_mant = {1'b1, a_mant};
//                smaller_mant = {1'b1, b_mant};
//                larger_sign = a_sign;
//                smaller_sign = b_sign;
//                larger_exp = a_exp;
//                smaller_exp = b_exp;
//            end else begin
//                exp_diff = b_exp - a_exp;
//                larger_mant = {1'b1, b_mant};
//                smaller_mant = {1'b1, a_mant};
//                larger_sign = b_sign;
//                smaller_sign = a_sign;
//                larger_exp = b_exp;
//                smaller_exp = a_exp;
//            end
            
//            // Shift smaller mantissa to align exponents
//            smaller_mant = smaller_mant >> exp_diff;
            
//            // Perform addition/subtraction
            
//            if (larger_sign == smaller_sign) begin
//                sum_mant = larger_mant + smaller_mant;
//            end else begin
//                sum_mant = larger_mant - smaller_mant;
//            end
            
//            // Normalize result
//            if (sum_mant[24]) begin
//                sum_mant = sum_mant >> 1;
//                larger_exp = larger_exp + 1;
//            end else if (sum_mant[23]) begin
//                // Already normalized
//            end else begin
//                // Find first 1 and shift
//                for (shift = 22; shift >= 0; shift = shift - 1) begin
//                    if (sum_mant[shift]) begin
//                        sum_mant = sum_mant << (23 - shift);
//                        larger_exp = larger_exp - (23 - shift);
//                        shift=-10;
//                    end
//                end
//                // If all zeros, result is zero
//                if (shift == -1) begin
//                    result = 0;
//                end
//            end
            
//            // Check for overflow/underflow
//            if (larger_exp[7] && !larger_exp[6]) begin // Overflow
//                result = {larger_sign, 8'hFF, 23'h0};
//            end else if (larger_exp == 0) begin // Underflow
//                result = 0;
//            end else begin
//                result = {larger_sign, larger_exp, sum_mant[22:0]};
//            end
//        end
//    end
//endmodule



          
`timescale 1ns/1ps


module fp_adder (
    input wire [31:0] a , input [31:0] b , output reg[31:0] result
);
    reg signa , signb;
    reg [7:0] exponenta, exponentb ;
    reg [7:0] diff;
    reg [24:0] ruffa , ruffb;
  reg[24:0] ans;
  reg[24:0] manta, mantb ;
    reg into;
    always @(a or b) begin
      into = 0;
        signa = a[31]; signb = b[31];
        exponenta = a[31:23]; exponentb = b[31:23];
        manta = {1'b1, a[22:0]}; mantb = {1'b1, b[22:0]};
        if(signa == signb) begin
            if(exponenta > exponentb) begin
                diff = exponenta - exponentb;
                ruffb = mantb >> diff;
                ans = ruffb + manta;
              if(ans[24] == 1) begin
                    ans = ans >> 1;
                    exponenta = exponenta + 1;
                end
                else begin
                    ans = ans;
                end
                result = {signa , exponenta , ans[22:0]};
            end
            else begin
                diff = exponentb - exponenta;
                ruffa = manta >> diff;
                ans = ruffa + mantb;
              if(ans[24] == 1) begin
                    ans = ans >> 1;
                    exponentb = exponentb + 1;
                end
                else begin
                    ans = ans;
                end
                result = {signb, exponentb , ans[22:0]};
            end
        end
        else begin
            if(a[30:0] > b[30:0]) begin
                diff = exponenta - exponentb;
                ruffb = mantb >> diff;
                manta = manta - ruffb;
              if(manta[22] == 1) begin
                exponenta = exponenta - 1;
                manta = manta << 1;
              end 
              else if(manta[21] == 1) begin
                exponenta = exponenta - 2;
                manta = manta << 2;
              end
              else if(manta[20] == 1) begin
                exponenta = exponenta - 3;
                manta = manta << 3;
              end
              else if(manta[19] == 1) begin
                exponenta = exponenta - 4;
                manta = manta << 4;
              end
              else if(manta[18] == 1) begin
                exponenta = exponenta - 5;
                manta = manta << 5;
              end
              else if(manta[17] == 1) begin
                exponenta = exponenta - 6;
                manta = manta << 6;
              end
              else if(manta[16] == 1) begin
                exponenta = exponenta - 7;
                manta = manta << 7;
              end
              else if(manta[15] == 1) begin
                exponenta = exponenta - 8;
                manta = manta << 8;
              end
              else if(manta[14] == 1) begin
                exponenta = exponenta - 9;
                manta = manta << 9;
              end
              else if(manta[13] == 1) begin
                exponenta = exponenta - 10;
                manta = manta << 10;
              end
              else if(manta[12] == 1) begin
                exponenta = exponenta - 11;
                manta = manta << 11;
              end
              else if(manta[11] == 1) begin
                exponenta = exponenta - 12;
                manta = manta << 12;
              end
              else if(manta[10] == 1) begin
                exponenta = exponenta - 13;
                manta = manta << 13;
              end
              else if(manta[9] == 1) begin
                exponenta = exponenta - 14;
                manta = manta << 14;
              end
              else if(manta[8] == 1) begin
                exponenta = exponenta - 15;
                manta = manta << 15;
              end
              else if(manta[7] == 1) begin
                exponenta = exponenta - 16;
                manta = manta << 16;
              end
              else if(manta[6] == 1) begin
                exponenta = exponenta - 17;
                manta = manta << 17;
              end
              else if(manta[5] == 1) begin
                exponenta = exponenta - 18;
                manta = manta << 18;
              end
              else if(manta[4] == 1) begin
                exponenta = exponenta - 19;
                manta = manta << 19;
              end
              else if(manta[3] == 1) begin
                exponenta = exponenta - 20;
                manta = manta << 20;
              end
              else if(manta[2] == 1) begin
                exponenta = exponenta - 21;
                manta = manta << 21;
              end
              else if(manta[1] == 1) begin
                exponenta = exponenta - 22;
                manta = manta << 22;
              end
              else if(manta[0] == 1) begin
                exponenta = exponenta - 23;
                manta = manta << 23;
              end
              else begin
                exponenta = exponenta;
                manta = manta;
              end


              result = {signa , exponenta , manta[22:0]};
            end 
            else begin
                diff = exponentb - exponenta;
                ruffb = manta >> diff;
                manta = mantb - ruffb;
                exponenta = exponentb;
                if(manta[22] == 1) begin
                exponenta = exponenta - 1;
                manta = manta << 1;
              end 
              else if(manta[21] == 1) begin
                exponenta = exponenta - 2;
                manta = manta << 2;
              end
              else if(manta[20] == 1) begin
                exponenta = exponenta - 3;
                manta = manta << 3;
              end
              else if(manta[19] == 1) begin
                exponenta = exponenta - 4;
                manta = manta << 4;
              end
              else if(manta[18] == 1) begin
                exponenta = exponenta - 5;
                manta = manta << 5;
              end
              else if(manta[17] == 1) begin
                exponenta = exponenta - 6;
                manta = manta << 6;
              end
              else if(manta[16] == 1) begin
                exponenta = exponenta - 7;
                manta = manta << 7;
              end
              else if(manta[15] == 1) begin
                exponenta = exponenta - 8;
                manta = manta << 8;
              end
              else if(manta[14] == 1) begin
                exponenta = exponenta - 9;
                manta = manta << 9;
              end
              else if(manta[13] == 1) begin
                exponenta = exponenta - 10;
                manta = manta << 10;
              end
              else if(manta[12] == 1) begin
                exponenta = exponenta - 11;
                manta = manta << 11;
              end
              else if(manta[11] == 1) begin
                exponenta = exponenta - 12;
                manta = manta << 12;
              end
              else if(manta[10] == 1) begin
                exponenta = exponenta - 13;
                manta = manta << 13;
              end
              else if(manta[9] == 1) begin
                exponenta = exponenta - 14;
                manta = manta << 14;
              end
              else if(manta[8] == 1) begin
                exponenta = exponenta - 15;
                manta = manta << 15;
              end
              else if(manta[7] == 1) begin
                exponenta = exponenta - 16;
                manta = manta << 16;
              end
              else if(manta[6] == 1) begin
                exponenta = exponenta - 17;
                manta = manta << 17;
              end
              else if(manta[5] == 1) begin
                exponenta = exponenta - 18;
                manta = manta << 18;
              end
              else if(manta[4] == 1) begin
                exponenta = exponenta - 19;
                manta = manta << 19;
              end
              else if(manta[3] == 1) begin
                exponenta = exponenta - 20;
                manta = manta << 20;
              end
              else if(manta[2] == 1) begin
                exponenta = exponenta - 21;
                manta = manta << 21;
              end
              else if(manta[1] == 1) begin
                exponenta = exponenta - 22;
                manta = manta << 22;
              end
              else if(manta[0] == 1) begin
                exponenta = exponenta - 23;
                manta = manta << 23;
              end
              else begin
                exponenta = exponenta;
                manta = manta;
              end

                result = {signb , exponenta , manta[22:0]};
            end
            //Write the code when both are opposite signs
            
        end
    end
endmodule