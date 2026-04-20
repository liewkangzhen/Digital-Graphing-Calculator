`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2026 20:19:47
// Design Name: 
// Module Name: quadratic_func
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


module quadratic_func(
    input signed [15:0] x,
    input signed [7:0] a,
    input signed [7:0] b,
    input signed [7:0] c,
    
    // setting output to be 32.16, is to have bigger integer range so overflow wont happen, but i think this add more resources
    output signed [47:0] y,
    output [32:0] y_int,
    output [15:0] y_frac
);
    // y = ax**2 + bx + c
    
    // temporary wires
    wire signed [47:0] temporary_y;
    wire signed [47:0] magnitude_y;
    wire signed [95:0] temp1_full;
    wire signed [95:0] temp2_full;
    wire signed [95:0] temp3_full;
    wire signed [47:0] temp1;
    wire signed [47:0] temp2;
    wire signed [47:0] temp3;
    
    // format all inputs to 32.16
//    wire signed [31:0] x_16p16;
//    wire signed [31:0] a_16p16;
//    wire signed [31:0] b_16p16;
//    wire signed [31:0] c_16p16;
//    assign x_16p16 = x <<< 8;
//    assign a_16p16 = a <<< 16;
//    assign b_16p16 = b <<< 16;
//    assign c_16p16 = c <<< 16;
    wire signed [47:0] x_32p16;
    wire signed [47:0] a_32p16;
    wire signed [47:0] b_32p16;
    wire signed [47:0] c_32p16;
    
    assign x_32p16 = x <<< 16;
    assign a_32p16 = a <<< 16;
    assign b_32p16 = b <<< 16;
    assign c_32p16 = c <<< 16;

    // x^2
//    assign temp1_full = x_32p16 * x_32p16;          // 32.32
//    assign temp1 = temp1_full >>> 16;               // 16.16
    
//    // ax^2
//    assign temp2_full = a_32p16 * temp1;            // 32.32
//    assign temp2 = temp2_full >>> 16;               // 16.16
    
//    // bx
//    assign temp3_full = b_32p16 * x_32p16;          // 32.32
//    assign temp3 = temp3_full >>> 16;               // 16.16
    
//    // ax^2 + bx + c
//    assign temporary_y = temp2 + temp3 + c_32p16;   // 16.16
////    assign y = temporary_y;

    // treat x as plain integer, compute x^2 as integer
    wire signed [47:0] x_sq;
    assign x_sq = x * x;                        // plain integer x²
    
    wire signed [47:0] ax2;
    assign ax2 = a * x_sq;                      // a * x²
    
    wire signed [47:0] bx;
    assign bx = b * x;                          // b * x
    
    // shift left 16 at the END to produce Q32.16 output
    assign y = (ax2 + bx + c);
    
    // format to get y_int and y_frac 
    assign magnitude_y = temporary_y[47] ? (~temporary_y + 1'b1) : temporary_y;
    assign y_int = temporary_y[47] ? -$signed(magnitude_y[47:16]) : $signed(magnitude_y[47:16]);
    assign y_frac = magnitude_y[15:0] * 100 >> 16;
endmodule
