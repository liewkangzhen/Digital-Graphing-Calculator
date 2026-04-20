`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2026 16:55:26
// Design Name: 
// Module Name: BCD_ROM_module
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


module bcd_ROM_module_2 (
    input [4:0] bcd_digit,      // Input 0-9
    input [2:0] row,            // Which row of the 8x8 (0-7)
    output reg [7:0] row_data   // The 8 horizontal pixels for that row
);
    always @(*) begin
        case (bcd_digit)
            // Hex values represent 8 rows of 8 bits
            5'd0: case(row)
                0: row_data = 8'b00111100;
                1: row_data = 8'b01100110;
                2: row_data = 8'b01100110;
                3: row_data = 8'b01100110;
                4: row_data = 8'b01100110;
                5: row_data = 8'b01100110;
                6: row_data = 8'b01100110;
                7: row_data = 8'b00111100;
            endcase
            5'd1: case(row)
                0: row_data = 8'b00011000;
                1: row_data = 8'b00111000;
                2: row_data = 8'b00011000;
                3: row_data = 8'b00011000;
                4: row_data = 8'b00011000;
                5: row_data = 8'b00011000;
                6: row_data = 8'b00011000;
                7: row_data = 8'b00111100;
            endcase
            5'd2: case(row)
                0: row_data = 8'b00111100;
                1: row_data = 8'b01100110;
                2: row_data = 8'b00000110;
                3: row_data = 8'b00001100;
                4: row_data = 8'b00011000;
                5: row_data = 8'b00110000;
                6: row_data = 8'b01100000;
                7: row_data = 8'b01111110;
            endcase
            5'd3: case(row)
                0: row_data = 8'b00111100;
                1: row_data = 8'b01100110;
                2: row_data = 8'b00000110;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00000110;
                5: row_data = 8'b00000110;
                6: row_data = 8'b01100110;
                7: row_data = 8'b00111100;
            endcase
            5'd4: case(row)
                0: row_data = 8'b00001100;
                1: row_data = 8'b00011100;
                2: row_data = 8'b00101100;
                3: row_data = 8'b01001100;
                4: row_data = 8'b01111110;
                5: row_data = 8'b00001100;
                6: row_data = 8'b00001100;
                7: row_data = 8'b00001100;
            endcase
            5'd5: case(row)
                0: row_data = 8'b01111110;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01111100;
                4: row_data = 8'b00000110;
                5: row_data = 8'b00000110;
                6: row_data = 8'b01100110;
                7: row_data = 8'b00111100;
            endcase
            5'd6: case(row)
                0: row_data = 8'b00111100;
                1: row_data = 8'b01100110;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01111100;
                4: row_data = 8'b01100110;
                5: row_data = 8'b01100110;
                6: row_data = 8'b01100110;
                7: row_data = 8'b00111100;
            endcase
            5'd7: case(row)
                0: row_data = 8'b01111110;
                1: row_data = 8'b00000110;
                2: row_data = 8'b00001100;
                3: row_data = 8'b00011000;
                4: row_data = 8'b00110000;
                5: row_data = 8'b00110000;
                6: row_data = 8'b00110000;
                7: row_data = 8'b00110000;
            endcase
            5'd8: case(row)
                0: row_data = 8'b00111100;
                1: row_data = 8'b01100110;
                2: row_data = 8'b01100110;
                3: row_data = 8'b00111100;
                4: row_data = 8'b01100110;
                5: row_data = 8'b01100110;
                6: row_data = 8'b01100110;
                7: row_data = 8'b00111100;
            endcase
            5'd9: case(row)
                0: row_data = 8'b00111100;
                1: row_data = 8'b01100110;
                2: row_data = 8'b01100110;
                3: row_data = 8'b00111110;
                4: row_data = 8'b00000110;
                5: row_data = 8'b00000110;
                6: row_data = 8'b01100110;
                7: row_data = 8'b00111100;
            endcase
            5'd10: case(row) // - 
                0: row_data = 8'b00000000;
                1: row_data = 8'b00000000;
                2: row_data = 8'b00000000;
                3: row_data = 8'b00111100;
                4: row_data = 8'b00111100;
                5: row_data = 8'b00000000;
                6: row_data = 8'b00000000;
                7: row_data = 8'b00000000;
            endcase
            5'd11: case(row) // =
                0: row_data = 8'b00000000;
                1: row_data = 8'b00000000;
                2: row_data = 8'b00111100;
                3: row_data = 8'b00000000;
                4: row_data = 8'b00111100;
                5: row_data = 8'b00000000;
                6: row_data = 8'b00000000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase
            5'd12: case(row) //  
                0: row_data = 8'b00011000;
                1: row_data = 8'b00011000;
                2: row_data = 8'b01111110;
                3: row_data = 8'b00011000;
                4: row_data = 8'b00011000;
                5: row_data = 8'b00000000;
                6: row_data = 8'b01111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase
            5'd13: case(row) // ->
                0: row_data = 8'b00000000;
                1: row_data = 8'b00001100;
                2: row_data = 8'b00000110;
                3: row_data = 8'b01111111;
                4: row_data = 8'b00000110;
                5: row_data = 8'b00001100;
                6: row_data = 8'b00000000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase
            5'd14: case(row) // <-
                0: row_data = 8'b00000000;
                1: row_data = 8'b00110000;
                2: row_data = 8'b01100000;
                3: row_data = 8'b11111110;
                4: row_data = 8'b01100000;
                5: row_data = 8'b00110000;
                6: row_data = 8'b00000000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase
            
            5'd15: case(row) // ^
                0: row_data = 8'b00011000;
                1: row_data = 8'b00111100;
                2: row_data = 8'b01100110;
                3: row_data = 8'b01000010;
                4: row_data = 8'b00000000;
                5: row_data = 8'b00000000;
                6: row_data = 8'b00000000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase
            default: row_data = 8'b00000000;
            
            5'd16: case(row) // +
                0: row_data = 8'b00011000;
                1: row_data = 8'b00011000;
                2: row_data = 8'b00011000;
                3: row_data = 8'b11111111;
                4: row_data = 8'b00011000;
                5: row_data = 8'b00011000;
                6: row_data = 8'b00011000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase
           
           5'd17: case(row) // .
                0: row_data = 8'b00000000;
                1: row_data = 8'b00000000;
                2: row_data = 8'b00000000;
                3: row_data = 8'b00000000;
                4: row_data = 8'b00000000;
                5: row_data = 8'b00000000;
                6: row_data = 8'b00011000;
                7: row_data = 8'b00011000;
                default: row_data = 8'b00000000;
            endcase
            
            5'd18: case(row) // ?
                0: row_data = 8'b00111100; //   ****  
                1: row_data = 8'b01000010; //  *    *
                2: row_data = 8'b00000010; //       *
                3: row_data = 8'b00001100; //     ** 
                4: row_data = 8'b00010000; //    *   
                5: row_data = 8'b00000000; //        
                6: row_data = 8'b00010000; //    *  
                7: row_data = 8'b00000000; //        
                default: row_data = 8'b00000000;
            endcase
        endcase
    end
endmodule
