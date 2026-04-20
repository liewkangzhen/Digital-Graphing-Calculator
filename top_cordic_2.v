`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2026 20:04:19
// Design Name: 
// Module Name: top_cordic
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


module top_cordic_2 (
    input clk,
    input signed [15:0] angle,
    output signed [15:0] sine,
    output signed [15:0] cosine
    );

    wire signed [15:0] angle_norm;
    wire signed [15:0] sin_raw, cos_raw;
    wire flip_sin, flip_cos;

    reg flip_sin_pipe [15:0];
    reg flip_cos_pipe [15:0];
    integer i;

    always @(posedge clk) begin
        flip_sin_pipe[0] <= flip_sin;
        flip_cos_pipe[0] <= flip_cos;
        for (i = 1; i < 16; i = i + 1) begin
            flip_sin_pipe[i] <= flip_sin_pipe[i-1];
            flip_cos_pipe[i] <= flip_cos_pipe[i-1];
        end
    end
    
    assign sine   = flip_sin_pipe[15] ? -sin_raw : sin_raw;
    assign cosine = flip_cos_pipe[15] ? -cos_raw : cos_raw;
    
    // Normalize angle
    angle_normalizer_2 norm (
        .angle_in(angle),
        .angle_out(angle_norm),
        .flip_sin(flip_sin),
        .flip_cos(flip_cos)
    );

    // CORDIC core
    cordic cordic (
        .clk(clk),
        .angle(angle_norm),
        .sine(sin_raw),
        .cosine(cos_raw)
    );

//    // Sign correction
//    assign sine   = flip_sin ? -sin_raw : sin_raw;
//    assign cosine = flip_cos ? -cos_raw : cos_raw;

endmodule
