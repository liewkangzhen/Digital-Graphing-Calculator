`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2026 14:36:59
// Design Name: 
// Module Name: angle_normalizer
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


module angle_normalizer (
    input  signed [15:0] angle_in,
    output reg signed [15:0] angle_out,
    output reg flip_sin,
    output reg flip_cos
);

    localparam signed [15:0] PI      = 16'sd804;
    localparam signed [15:0] TWO_PI  = 16'sd1608;
    localparam signed [15:0] HALF_PI = 16'sd402;

    reg signed [15:0] angle_tmp;

    always @(*) begin
        // wrap to [-?, ?]
        angle_tmp = angle_in % TWO_PI;
            
        if (angle_tmp > PI)
            angle_tmp = angle_tmp - TWO_PI;
        else if (angle_tmp < -PI)
            angle_tmp = angle_tmp + TWO_PI;

        // quadrant
        if (angle_tmp >= 0) begin
            if (angle_tmp <= HALF_PI) begin
                // Q1
                angle_out = angle_tmp;
                flip_sin = 0;
                flip_cos = 0;
            end else begin
                // Q2
                angle_out = PI - angle_tmp;
                flip_sin = 0;
                flip_cos = 1;
            end
        end else begin
            if (angle_tmp >= -HALF_PI) begin
                // Q4
                angle_out = -angle_tmp;
                flip_sin = 1;
                flip_cos = 0;
            end else begin
                // Q3
                angle_out = angle_tmp + PI;
                flip_sin = 1;
                flip_cos = 1;
            end
        end
    end
endmodule
