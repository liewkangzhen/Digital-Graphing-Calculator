`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2026 22:23:15
// Design Name: 
// Module Name: variable_clock
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


module variable_clock(input clk, input [31:0]m, output reg clk_f = 0);
    reg [31:0] count = 0;
    
    always @(posedge clk) begin
        count <= (count==m) ?0 : count + 1;
        clk_f <= (count==0) ?~clk_f : clk_f;
    end
    
endmodule
