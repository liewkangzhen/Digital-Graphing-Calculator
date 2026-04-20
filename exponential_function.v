`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 20:38:34
// Design Name: 
// Module Name: Exponential_Graph
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


//module Exponential_Graph(
//    input [8:0] step_index,
//    output [47:0] result
//    );
    
//    wire [15:0] A, B, C;
//    wire [31:0] scaled_x;
//    wire [31:0] exp_AxPB;
//    wire [7:0] lut_index;

//    assign A = 1; //Change here to give different inputs of A
//    assign B = 0; //Change here to give different inputs of B
//    assign lut_index = x + 48;
    
//    reg [31:0] exp_Ax_lut [0:127]; // 128 Ax-values ? precomputed 
//    initial $readmemh("exp_lut_A.mem", exp_Ax_lut);
//    assign scaled_x = A*x + B;
//    assign exp_AxPB = exp_Ax_lut[lut_index];
//    assign result = exp_AxPB;
    
//endmodule

module Exponential_Graph(
    input [8:0] step_index,    // 0 to 383 (x = -1.91 to 1.91)
    input [2:0] a_val,         // Input a (1, 2, 3, 4, 5)
    output signed [47:0] result
);
    // Original 384-entry LUT (-1.91 to 1.91)
    reg [47:0] exp_lut [0:383];
    initial $readmemh("exp_lut_A.mem", exp_lut);

    wire signed [9:0] offset_from_center;
    wire signed [12:0] scaled_offset;
    wire signed [13:0] lookup_addr;
    reg [8:0] final_addr;

    // 1. Center is 191 (where x=0). Calculate how far current pixel is from center.
    assign offset_from_center = $signed({1'b0, step_index}) - 10'sd191;

    // 2. Multiply distance by 'a'. 
    // If a=2, we look 'twice as far' into the LUT for the same pixel.
    assign scaled_offset = offset_from_center * $signed({1'b0, a_val});

    // 3. Add back to center to get the address
    assign lookup_addr = scaled_offset + 14'sd191;

    // 4. Clamping: If the scaled index goes out of the 0-383 range, 
    // stick to the edge of the LUT.
    always @(*) begin
        if (lookup_addr < 0)
            final_addr = 9'd0;
        else if (lookup_addr > 383)
            final_addr = 9'd383;
        else
            final_addr = lookup_addr[8:0];
    end

    assign result = exp_lut[final_addr];

endmodule
