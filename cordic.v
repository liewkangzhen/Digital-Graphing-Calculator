`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2026 19:41:08
// Design Name: 
// Module Name: cordic
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


module cordic(
    input clk,
    input signed [15:0] angle,
    output signed [15:0] sine,
    output signed [15:0] cosine
    );
    
    parameter WIDTH = 16;
    parameter ITER = 16;
    
    wire signed [15:0] atan_table [0:15];
    
    assign atan_table[0]  = 16'sd201; // atan(2^0)
    assign atan_table[1]  = 16'sd119;
    assign atan_table[2]  = 16'sd63;
    assign atan_table[3]  = 16'sd32;
    assign atan_table[4]  = 16'sd16;
    assign atan_table[5]  = 16'sd8;
    assign atan_table[6]  = 16'sd4;
    assign atan_table[7]  = 16'sd2;
    assign atan_table[8]  = 16'sd1;
    assign atan_table[9]  = 16'sd1;
    assign atan_table[10] = 16'sd0;
    assign atan_table[11] = 16'sd0;
    assign atan_table[12] = 16'sd0;
    assign atan_table[13] = 16'sd0;
    assign atan_table[14] = 16'sd0;
    assign atan_table[15] = 16'sd0;
    
    reg signed [17:0] x [0:ITER-1];
    reg signed [17:0] y [0:ITER-1];
    reg signed [15:0] z [0:ITER-1];
    
    localparam signed [15:0] K = 16'sd155;
    
    always @(posedge clk) begin
        x[0] <= K;
        y[0] <= 0;
        z[0] <= angle;
    end
    
    genvar i;
    generate
        for (i = 0; i < ITER-1; i = i + 1) begin : cordic_iter

            wire signed [17:0] x_shift;
            wire signed [17:0] y_shift;
            wire z_sign;

            assign x_shift = x[i] >>> i;
            assign y_shift = y[i] >>> i;
            assign z_sign = z[i][15];

            always @(posedge clk) begin
                if (z_sign) begin
                    x[i+1] <= x[i] + y_shift;
                    y[i+1] <= y[i] - x_shift;
                    z[i+1] <= z[i] + atan_table[i];
                end else begin
                    x[i+1] <= x[i] - y_shift;
                    y[i+1] <= y[i] + x_shift;
                    z[i+1] <= z[i] - atan_table[i];
                end
            end
        end
    endgenerate
    
    assign cosine = x[ITER-1][15:0];
    assign sine   = y[ITER-1][15:0];

endmodule
