`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 10:04:20
// Design Name: 
// Module Name: dual_port_bram
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

module dual_port_bram (
    // Port A - Writing (Math Engine)
    input clk_a,
    input we_a,               // Write Enable
    input [8:0] addr_a,       // 0 to 95 (for OLED x-axis)
    input signed [47:0] din_a,        // Calculated Y value
    
    // Port B - Reading (Display Logic)
    input clk_b,
    input [8:0] addr_b,       // Current x-coordinate from OLED
    output reg signed [47:0] dout_b   // Y value to be displayed
);

    // Declare the RAM: 128 depth (to cover 96) x 6 bits width
    reg signed [47:0] ram [0:383];

    // Port A: Synchronous Write
    always @(posedge clk_a) begin
        if (we_a) begin
            ram[addr_a] <= din_a;
        end
    end

    // Port B: Synchronous Read
    always @(posedge clk_b) begin
        dout_b <= ram[addr_b];
    end

endmodule
