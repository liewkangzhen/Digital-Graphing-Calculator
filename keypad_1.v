`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2026 23:50:21
// Design Name: 
// Module Name: keypad
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


module keypad(
    input clk, clk_1kHz,
    input btnU_pulse, btnL_pulse, btnR_pulse, btnD_pulse, btnC_pulse,
    input [12:0] pixel_index,
    input [1:0] func_selected,
    input rst,
    output reg [15:0] oled_colour = 16'h0000,
    output reg signed [7:0] coefficient_a,
    output reg signed [7:0] coefficient_b,
    output reg signed [7:0] coefficient_c,
    output reg graph_enable = 0,
    output reg Done = 0
);

    wire [6:0] x;
    wire [5:0] y;
        
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    
    // {       display the equation       }
    //     col1 col2 col3       col4
    // row1 7    8    9         Graph       {box0   box1    box2    box3        }
    // row2 4    5    6         <- ->       {box4   box5    box6    box7 box8   }
    // row3 1    2    3         Delete      {box9   box10   box11   box12       }
    // row4 0   +/-             Enter       {box13  box14   box15   box16       }
    //
    // Notes: row1, row2, row3, row4 difference by 4 pixels 
    //        col1, col2, col3 difference by 4 pixels 
    //        col3, col4 difference by 4 pixels
    //        Box: width = 15 pixels, height = 10 pixels
    //        Boxes at col4: width = 31 pixels, height = 10 pixels
    //        <- and -> is in different box
    //        Box 15 is not used (Reserve for future used)
    
    // Each row top border and bottom border
    localparam row1_y_top_border = 16;
    localparam row1_y_bottom_border = 25;
    localparam row2_y_top_border = 28;
    localparam row2_y_bottom_border = 37;
    localparam row3_y_top_border = 40;
    localparam row3_y_bottom_border = 49;
    localparam row4_y_top_border = 52;
    localparam row4_y_bottom_border = 61;
    
    // Each col left border and right border
    localparam col1_x_left_border = 4;
    localparam col1_x_right_border = 18;
    localparam col2_x_left_border = 21;
    localparam col2_x_right_border = 35;
    localparam col3_x_left_border = 38;
    localparam col3_x_right_border = 52;
    localparam col4_x_left_border = 55;
    localparam col4p5_x_right_border = 69;  // box 7 right border
    localparam col4p5_x_left_border = 71;   // box 8 left border
    localparam col4_x_right_border = 85;
    
    // box for the display digits
    localparam display_digit_box_y_top_border = 2;
    localparam display_digit_box_y_bottom_border = 12;
    localparam display_digit_box_x_left_border = 4;
    localparam display_digit_box_x_right_border = 91;
    
    wire display_digit_area_in_box_interior;
    assign display_digit_area_in_box_interior = (x >= display_digit_box_x_left_border && x <= display_digit_box_x_right_border) && (y >= display_digit_box_y_top_border && y <= display_digit_box_y_bottom_border);
    
    localparam NUMBER_BOX = 16; // If want add box, modify this 
    wire [NUMBER_BOX:0] in_box_interior;
    assign in_box_interior[0]  = (x >= col1_x_left_border && x <= col1_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border);
    assign in_box_interior[1]  = (x >= col2_x_left_border && x <= col2_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border);
    assign in_box_interior[2]  = (x >= col3_x_left_border && x <= col3_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border);
    assign in_box_interior[3]  = (x >= col4_x_left_border && x <= col4_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border);
    assign in_box_interior[4]  = (x >= col1_x_left_border && x <= col1_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border);
    assign in_box_interior[5]  = (x >= col2_x_left_border && x <= col2_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border);
    assign in_box_interior[6]  = (x >= col3_x_left_border && x <= col3_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border);
    // special for box7 and box 8
    assign in_box_interior[7]  = (x >= col4_x_left_border && x <= col4p5_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border);
    assign in_box_interior[8]  = (x >= col4p5_x_left_border && x <= col4_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border);
    assign in_box_interior[9]  = (x >= col1_x_left_border && x <= col1_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border);
    assign in_box_interior[10] = (x >= col2_x_left_border && x <= col2_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border);
    assign in_box_interior[11] = (x >= col3_x_left_border && x <= col3_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border);
    assign in_box_interior[12] = (x >= col4_x_left_border && x <= col4_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border);
    assign in_box_interior[13] = (x >= col1_x_left_border && x <= col1_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border);
    assign in_box_interior[14] = (x >= col2_x_left_border && x <= col2_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border);
    assign in_box_interior[15] = (x >= col3_x_left_border && x <= col3_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border);
    assign in_box_interior[16] = (x >= col4_x_left_border && x <= col4_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border);
    
    
    wire [NUMBER_BOX:0] on_box_border;
    assign on_box_border[0]  = ((x == col1_x_left_border || x == col1_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border)) || ((y == row1_y_top_border || y == row1_y_bottom_border) && (x >= col1_x_left_border && x <= col1_x_right_border));
    assign on_box_border[1]  = ((x == col2_x_left_border || x == col2_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border)) || ((y == row1_y_top_border || y == row1_y_bottom_border) && (x >= col2_x_left_border && x <= col2_x_right_border));
    assign on_box_border[2]  = ((x == col3_x_left_border || x == col3_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border)) || ((y == row1_y_top_border || y == row1_y_bottom_border) && (x >= col3_x_left_border && x <= col3_x_right_border));
    assign on_box_border[3]  = ((x == col4_x_left_border || x == col4_x_right_border) && (y >= row1_y_top_border && y <= row1_y_bottom_border)) || ((y == row1_y_top_border || y == row1_y_bottom_border) && (x >= col4_x_left_border && x <= col4_x_right_border));
    assign on_box_border[4]  = ((x == col1_x_left_border || x == col1_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border)) || ((y == row2_y_top_border || y == row2_y_bottom_border) && (x >= col1_x_left_border && x <= col1_x_right_border));
    assign on_box_border[5]  = ((x == col2_x_left_border || x == col2_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border)) || ((y == row2_y_top_border || y == row2_y_bottom_border) && (x >= col2_x_left_border && x <= col2_x_right_border));
    assign on_box_border[6]  = ((x == col3_x_left_border || x == col3_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border)) || ((y == row2_y_top_border || y == row2_y_bottom_border) && (x >= col3_x_left_border && x <= col3_x_right_border));
    //special for box 7 and box 8
    assign on_box_border[7]  = ((x == col4_x_left_border || x == col4p5_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border)) || ((y == row2_y_top_border || y == row2_y_bottom_border) && (x >= col4_x_left_border && x <= col4p5_x_right_border));
    assign on_box_border[8]  = ((x == col4p5_x_left_border || x == col4_x_right_border) && (y >= row2_y_top_border && y <= row2_y_bottom_border)) || ((y == row2_y_top_border || y == row2_y_bottom_border) && (x >= col4p5_x_left_border && x <= col4_x_right_border));
    assign on_box_border[9]  = ((x == col1_x_left_border || x == col1_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border)) || ((y == row3_y_top_border || y == row3_y_bottom_border) && (x >= col1_x_left_border && x <= col1_x_right_border));
    assign on_box_border[10] = ((x == col2_x_left_border || x == col2_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border)) || ((y == row3_y_top_border || y == row3_y_bottom_border) && (x >= col2_x_left_border && x <= col2_x_right_border));
    assign on_box_border[11] = ((x == col3_x_left_border || x == col3_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border)) || ((y == row3_y_top_border || y == row3_y_bottom_border) && (x >= col3_x_left_border && x <= col3_x_right_border));
    assign on_box_border[12] = ((x == col4_x_left_border || x == col4_x_right_border) && (y >= row3_y_top_border && y <= row3_y_bottom_border)) || ((y == row3_y_top_border || y == row3_y_bottom_border) && (x >= col4_x_left_border && x <= col4_x_right_border));
    assign on_box_border[13] = ((x == col1_x_left_border || x == col1_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border)) || ((y == row4_y_top_border || y == row4_y_bottom_border) && (x >= col1_x_left_border && x <= col1_x_right_border));
    assign on_box_border[14] = ((x == col2_x_left_border || x == col2_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border)) || ((y == row4_y_top_border || y == row4_y_bottom_border) && (x >= col2_x_left_border && x <= col2_x_right_border));
    assign on_box_border[15] = ((x == col3_x_left_border || x == col3_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border)) || ((y == row4_y_top_border || y == row4_y_bottom_border) && (x >= col3_x_left_border && x <= col3_x_right_border));
    assign on_box_border[16] = ((x == col4_x_left_border || x == col4_x_right_border) && (y >= row4_y_top_border && y <= row4_y_bottom_border)) || ((y == row4_y_top_border || y == row4_y_bottom_border) && (x >= col4_x_left_border && x <= col4_x_right_border));
    
    
    // Button control (Left, Right, Top, Bottom)
    reg [$clog2(NUMBER_BOX):0] current_box = 0;
    always @(posedge clk) begin
        if (rst) begin 
            current_box <= 0;
        end else begin
            case (current_box)
                0: begin
                    if (btnR_pulse) current_box <= 1;
                    else if (btnD_pulse) current_box <= 4;
                    else current_box <= 0;
                end
                
                1: begin
                    if (btnR_pulse) current_box <= 2;
                    else if (btnD_pulse) current_box <= 5;
                    else if (btnL_pulse) current_box <= 0;
                    else current_box <= 1;
                end
                
                2: begin
                    if (btnR_pulse) current_box <= 3;
                    else if (btnD_pulse) current_box <= 6;
                    else if (btnL_pulse) current_box <= 1;
                    else current_box <= 2;
                end
                
                3: begin
                    if (btnD_pulse) current_box <= 7;
                    else if (btnL_pulse) current_box <= 2;
                    else current_box <= 3;
                end
                
                4: begin
                    if (btnR_pulse) current_box <= 5;
                    else if (btnD_pulse) current_box <= 9;
                    else if (btnU_pulse) current_box <= 0;
                    else current_box <= 4;
                end
                
                5: begin
                    if (btnR_pulse) current_box <= 6;
                    else if (btnD_pulse) current_box <= 10;
                    else if (btnL_pulse) current_box <= 4;
                    else if (btnU_pulse) current_box <= 1;
                    else current_box <= 5;
                end
                
                6: begin
                    if (btnR_pulse) current_box <= 7;
                    else if (btnD_pulse) current_box <= 11;
                    else if (btnL_pulse) current_box <= 5;
                    else if (btnU_pulse) current_box <= 2;
                    else current_box <= 6;
                end
                
                7: begin
                    if (btnR_pulse) current_box <= 8;
                    else if (btnD_pulse) current_box <= 12;
                    else if (btnL_pulse) current_box <= 6;
                    else if (btnU_pulse) current_box <= 3;
                    else current_box <= 7;
                end
                
                8: begin
                    if (btnD_pulse) current_box <= 12;
                    else if (btnL_pulse) current_box <= 7;
                    else if (btnU_pulse) current_box <= 3;
                    else current_box <= 8;
                end
                
                9: begin
                    if (btnR_pulse) current_box <= 10;
                    else if (btnD_pulse) current_box <= 13;
                    else if (btnU_pulse) current_box <= 4;
                    else current_box <= 9;
                end
                
                10: begin
                    if (btnR_pulse) current_box <= 11;
                    else if (btnD_pulse) current_box <= 14;
                    else if (btnL_pulse) current_box <= 9;
                    else if (btnU_pulse) current_box <= 5;
                    else current_box <= 10;
                end
                
                11: begin
                    if (btnR_pulse) current_box <= 12;
                    else if (btnD_pulse) current_box <= 14;
                    else if (btnL_pulse) current_box <= 10;
                    else if (btnU_pulse) current_box <= 6;
                    else current_box <= 11;
                end
                
                12: begin
                    if (btnD_pulse) current_box <= 16;
                    else if (btnL_pulse) current_box <= 11;
                    else if (btnU_pulse) current_box <= 8;
                    else current_box <= 12;
                end
                
                13: begin
                    if (btnR_pulse) current_box <= 14;
                    else if (btnU_pulse) current_box <= 9;
                    else current_box <= 13;
                end
                
                14: begin
                    if (btnR_pulse) current_box <= 16;
                    else if (btnL_pulse) current_box <= 13;
                    else if (btnU_pulse) current_box <= 10;
                    else current_box <= 14;
                end
                
    //            15: begin
    //                if (btnR_pulse) current_box <= 16;
    //                else if (btnL_pulse) current_box <= 14;
    //                else if (btnU_pulse) current_box <= 11;
    //                else current_box <= 15;
    //            end
                
                16: begin 
                    if (btnL_pulse) current_box <= 14;
                    else if (btnU_pulse) current_box <= 12;
                    else current_box <= 16;
                end
                
                default: current_box <= 0;
            endcase
        end
    end
    
    localparam display_digit_y_top_border = 4;
    localparam display_digit_y_bottom_border = 11;
    
    localparam disp0_x_left_border = 10;
    localparam disp0_x_right_border = 17;
    localparam disp1_x_left_border = 19;
    localparam disp1_x_right_border = 26;
    localparam disp2_x_left_border = 28;
    localparam disp2_x_right_border = 35;
    localparam disp3_x_left_border = 37;
    localparam disp3_x_right_border = 44;
    localparam disp4_x_left_border = 46;
    localparam disp4_x_right_border = 53;
    localparam disp5_x_left_border = 55;
    localparam disp5_x_right_border = 62;
    localparam disp6_x_left_border = 64;
    localparam disp6_x_right_border = 71;
    localparam disp7_x_left_border = 73;
    localparam disp7_x_right_border = 80;
    localparam disp8_x_left_border = 82;
    localparam disp8_x_right_border = 89;
    
    localparam NUMBER_DISPLAY_DIGITS = 9;
    wire [NUMBER_DISPLAY_DIGITS - 1:0] disp_in_box_interior;
    assign disp_in_box_interior[0] = (x >= disp0_x_left_border && x <= disp0_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[1] = (x >= disp1_x_left_border && x <= disp1_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[2] = (x >= disp2_x_left_border && x <= disp2_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[3] = (x >= disp3_x_left_border && x <= disp3_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[4] = (x >= disp4_x_left_border && x <= disp4_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[5] = (x >= disp5_x_left_border && x <= disp5_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[6] = (x >= disp6_x_left_border && x <= disp6_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[7] = (x >= disp7_x_left_border && x <= disp7_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    assign disp_in_box_interior[8] = (x >= disp8_x_left_border && x <= disp8_x_right_border) && (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border);
    
    // Display when button pressed
    reg [4:0] display_digit = 5'd17;
    reg [5:0] disp0 = 6'd52;
    reg [4:0] disp1 = 5'd17;
    reg [4:0] disp2 = 5'd17;
    reg [4:0] disp3 = 5'd17;
    reg [4:0] disp4 = 5'd17;
    reg [4:0] disp5 = 5'd17;
    reg [4:0] disp6 = 5'd17;
    reg [4:0] disp7 = 5'd17;
    reg [4:0] disp8 = 5'd17;
    reg insert_digit = 0;
    
    // Direct to which digit in BCD_ROM
    always @(*) begin
        insert_digit = 1;
        case (current_box)
            0:  display_digit = 5'd7;
            1:  display_digit = 5'd8;
            2:  display_digit = 5'd9;
            4:  display_digit = 5'd4;
            5:  display_digit = 5'd5;
            6:  display_digit = 5'd6;
            9:  display_digit = 5'd1;
            10: display_digit = 5'd2;
            11: display_digit = 5'd3;
            13: display_digit = 5'd0;
            default: begin
                display_digit = 5'd17;
                insert_digit = 0;
            end
        endcase
    end
    
    // convert chars to int
    reg signed [31:0] entered_value; 
    reg signed [31:0] signed_value;
    reg input_negative = 0;
    always @(*) begin
        entered_value = 
         (( (disp3 == 5'd17) ? 0 : disp3) * 1_0000_0)    +
         (( (disp4 == 5'd17) ? 0 : disp4) * 1_0000)      +
         (( (disp5 == 5'd17) ? 0 : disp5) * 1_000)       +
         (( (disp6 == 5'd17) ? 0 : disp6) * 1_00)        +
         (( (disp7 == 5'd17) ? 0 : disp7) * 1_0)         +
         (( (disp8 == 5'd17) ? 0 : disp8));
        
         if (input_negative) begin
            signed_value = -entered_value;
         end else begin
            signed_value = entered_value;
         end
    end
    
    always @(posedge clk) begin
        if (rst) begin
            Done <= 0;
        end else begin
            if (btnC_pulse && current_box == 3) begin
                Done <= 1;
            end else begin
                Done <= 0;
            end
        end
    end
    
    reg [1:0] coefficient_state = 0;
    reg [2:0] cursor_position = 6;
    // mostleft disp0 disp1 disp2 disp3 disp4 disp5 disp6 disp7 disp8 mostright //
    // show display & save values to coefficient a,b,c
    always @(posedge clk) begin        
        if (rst) begin
            cursor_position <= 6;
            coefficient_state <= 0;
            input_negative <= 0;
            graph_enable <= 0;
            disp2 <= 5'd17;
            disp3 <= 5'd17;
            disp4 <= 5'd17;
            disp5 <= 5'd17;
            disp6 <= 5'd17;
            disp7 <= 5'd17;
            disp8 <= 5'd17;
        end else begin
            disp1 <= 5'd11; // display =
        
            case (coefficient_state)
                0: begin
                    disp0 <= 6'd26;
                end
                
                1: begin
                    disp0 <= 6'd27;
                end
                
                2: begin
                    disp0 <= 6'd28;
                end
            endcase
            
            if (btnC_pulse) begin
                if (insert_digit) begin
                    if (disp3 == 5'd17) begin
                        case (cursor_position)
                            1: begin
                                disp3 <= display_digit;
                            end
                            
                            2: begin
                                disp3 <= disp4;
                                disp4 <= display_digit;
                            end
                            
                            3: begin
                                disp3 <= disp4;
                                disp4 <= disp5;
                                disp5 <= display_digit;
                            end
                            
                            4: begin
                                disp3 <= disp4;
                                disp4 <= disp5;
                                disp5 <= disp6;
                                disp6 <= display_digit;
                            end
                            
                            5: begin
                                disp3 <= disp4;
                                disp4 <= disp5;
                                disp5 <= disp6;
                                disp6 <= disp7;
                                disp7 <= display_digit;
                            end
                            
                            6: begin
                                disp3 <= disp4;
                                disp4 <= disp5;
                                disp5 <= disp6;
                                disp6 <= disp7;
                                disp7 <= disp8;
                                disp8 <= display_digit;
                            end
                        endcase
                    end
                end else if (current_box == 7) begin
                    if (cursor_position > 1) begin
                        case (cursor_position)
                            2: begin
                                if (disp4 == 5'd17) begin
                                    cursor_position <= cursor_position;
                                end else begin
                                    cursor_position <= cursor_position - 1;
                                end
                            end
                            
                            3: begin
                                if (disp5 == 5'd17) begin
                                    cursor_position <= cursor_position;
                                end else begin
                                    cursor_position <= cursor_position - 1;
                                end
                            end
                            
                            4: begin
                                if (disp6 == 5'd17) begin
                                    cursor_position <= cursor_position;
                                end else begin
                                    cursor_position <= cursor_position - 1;
                                end
                            end
                            
                            5: begin
                                if (disp7 == 5'd17) begin
                                    cursor_position <= cursor_position;
                                end else begin
                                    cursor_position <= cursor_position - 1;
                                end
                            end
                            
                            6: begin
                                if (disp8 == 5'd17) begin
                                    cursor_position <= cursor_position;
                                end else begin
                                    cursor_position <= cursor_position - 1;
                                end
                            end
                        endcase
                    end
                end else if (current_box == 8) begin
                    if (cursor_position < 6) begin
                        cursor_position <= cursor_position + 1;
                    end  
                end else if (current_box == 12) begin
                    case (cursor_position) 
                        1: begin
                            disp3 <= 5'd17;
                        end
                        
                        2: begin
                            disp4 <= disp3;
                            disp3 <= 5'd17;
                        end
                        
                        3: begin
                            disp5 <= disp4;
                            disp4 <= disp3;
                            disp3 <= 5'd17;
                        end
                        
                        4: begin
                            disp6 <= disp5;
                            disp5 <= disp4;
                            disp4 <= disp3;
                            disp3 <= 5'd17;
                        end
                        
                        5: begin
                            disp7 <= disp6;
                            disp6 <= disp5;
                            disp5 <= disp4;
                            disp4 <= disp3;
                            disp3 <= 5'd17;
                        end
                        
                        6: begin
                            disp8 <= disp7;
                            disp7 <= disp6;
                            disp6 <= disp5;
                            disp5 <= disp4;
                            disp4 <= disp3;
                            disp3 <= 5'd17;
                        end
                    endcase
                end else if (current_box == 14) begin
                    if (input_negative) begin
                        input_negative <= 0;
                        disp2 <= 5'd17;
                    end else begin
                        input_negative <= 1;
                        disp2 <= 5'd10;
                    end
                    
                end else if (current_box == 16) begin
                    if (func_selected == 2'b00) begin
                        case (coefficient_state) 
                           0: begin 
                               if (disp8 != 5'd17) begin
                                    if (signed_value <= 31'sd10 && signed_value >= 31'sd1) begin
                                        coefficient_a <= signed_value;
                                        cursor_position <= 6;
                                        disp2 <= 5'd17;
                                        disp3 <= 5'd17;
                                        disp4 <= 5'd17;
                                        disp5 <= 5'd17;
                                        disp6 <= 5'd17;
                                        disp7 <= 5'd17;
                                        disp8 <= 5'd17;
                                        graph_enable <= 1; 
                                    end else begin
                                        graph_enable <= 0;
                                    end
                                end else begin
                                    graph_enable <= 0;
                                end
                                coefficient_state <= 2'd0;
                            end
                        endcase
                    end else if (func_selected == 2'b01) begin
                        case (coefficient_state)
                            0: begin
                                if (disp8 != 5'd17) begin
                                    if (signed_value <= 31'sd50 && signed_value >= -31'sd50) begin
                                        coefficient_a <= signed_value;
                                        coefficient_state <= 2'd1;
                                        cursor_position <= 6;
                                        disp2 <= 5'd17;
                                        disp3 <= 5'd17;
                                        disp4 <= 5'd17;
                                        disp5 <= 5'd17;
                                        disp6 <= 5'd17;
                                        disp7 <= 5'd17;
                                        disp8 <= 5'd17;
                                    end else begin
                                        coefficient_state <= 2'd0;
                                    end
                                end else begin
                                    coefficient_state <= 2'd0;
                                end
                                graph_enable <= 0;
                            end
                            
                            1: begin
                                if (disp8 != 5'd17) begin
                                    if (signed_value <= 31'sd100 && signed_value >= -31'sd100) begin
                                        coefficient_b <= signed_value;
                                        coefficient_state <= 2'd2;
                                        cursor_position <= 6;
                                        disp2 <= 5'd17;
                                        disp3 <= 5'd17;
                                        disp4 <= 5'd17;
                                        disp5 <= 5'd17;
                                        disp6 <= 5'd17;
                                        disp7 <= 5'd17;
                                        disp8 <= 5'd17;
                                    end else begin
                                        coefficient_state <= 2'd1;
                                    end
                                end else begin
                                    coefficient_state <= 2'd1;
                                end
                                graph_enable <= 0;
                            end
                            
                            2: begin
                                if (disp8 != 5'd17) begin
                                    if (signed_value <= 31'sd127 && signed_value >= -31'sd127) begin
                                        coefficient_c <= signed_value;
                                        coefficient_state <= 2'd0;
                                        graph_enable <= 1;
                                        cursor_position <= 6;
                                        disp2 <= 5'd17;
                                        disp3 <= 5'd17;
                                        disp4 <= 5'd17;
                                        disp5 <= 5'd17;
                                        disp6 <= 5'd17;
                                        disp7 <= 5'd17;
                                        disp8 <= 5'd17;
                                    end else begin
                                        coefficient_state <= 2'd2;
                                        graph_enable <= 0;
                                    end
                                end else begin
                                    coefficient_state <= 2'd2;
                                    graph_enable <= 0;
                                end
                            end
                        endcase
                    end else begin
                        case (coefficient_state) 
                           0: begin 
                               if (disp8 != 5'd17) begin
                                    if (signed_value <= 31'sd5 && signed_value >= 31'sd1) begin
                                        coefficient_a <= signed_value;
                                        cursor_position <= 6;
                                        disp2 <= 5'd17;
                                        disp3 <= 5'd17;
                                        disp4 <= 5'd17;
                                        disp5 <= 5'd17;
                                        disp6 <= 5'd17;
                                        disp7 <= 5'd17;
                                        disp8 <= 5'd17;
                                        graph_enable <= 1; 
                                    end else begin
                                        graph_enable <= 0;
                                    end
                                end else begin
                                    graph_enable <= 0;
                                end
                                coefficient_state <= 2'd0;
                            end
                        endcase
                    end
                end
            end
        end
    end

    // Below is the code that Display the Keypad
    reg [4:0] current_digit = 0;
    reg [5:0] char_index = 0;
    reg [2:0] rom_row = 0;
    reg [2:0] rom_col = 0;
    wire [7:0] row_data; 
    wire [7:0] row_data_font; 
    
    localparam BG_COLOUR     = 16'hDEDB;  // light grey
    localparam BOX_COLOUR    = 16'hBDF7;  // grey 
    localparam TEXT_COLOUR   = 16'h0000;  // black
    localparam BORDER_COLOUR = 16'h632C;
    localparam CURSOR_COLOUR = 16'h0000;
    
    wire blink_on;
    
    always @(*) begin
        oled_colour = BG_COLOUR;
        
        if (display_digit_area_in_box_interior) begin
            oled_colour = BG_COLOUR;
            current_digit = display_digit;
            
            if (disp_in_box_interior[0]) begin
                char_index = disp0;
                rom_row = y - display_digit_y_top_border; 
                rom_col = x - disp0_x_left_border;
                if (row_data_font[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[1]) begin
                current_digit = disp1;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp1_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[2]) begin
                current_digit = disp2;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp2_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[3] && disp3 != 5'd17) begin
                current_digit = disp3;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp3_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[4] && disp4 != 5'd17) begin
                current_digit = disp4;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp4_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[5] && disp5 != 5'd17) begin
                current_digit = disp5;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp5_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[6] && disp6 != 5'd17) begin
                current_digit = disp6;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp6_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[7] && disp7 != 5'd17) begin
                current_digit = disp7;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp7_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end else if (disp_in_box_interior[8] && disp8 != 5'd17) begin
                current_digit = disp8;
                rom_row = y - display_digit_y_top_border;
                rom_col = x - disp8_x_left_border;
                if (row_data[7-rom_col]) oled_colour = TEXT_COLOUR;
            end
            
            // display cursor
            if (y >= display_digit_y_top_border && y <= display_digit_y_bottom_border) begin
                if (cursor_position == 1) begin
                    if ( (x >= disp3_x_right_border && x <= disp3_x_right_border + 1) ) begin
                        if (blink_on) begin
                            oled_colour = CURSOR_COLOUR;
                        end else begin
                            oled_colour = BG_COLOUR;
                        end
                    end
                end else if (cursor_position == 2) begin
                    if ( (x >= disp4_x_right_border && x <= disp4_x_right_border + 1) ) begin
                        if (blink_on) begin
                            oled_colour = CURSOR_COLOUR;
                        end else begin
                            oled_colour = BG_COLOUR;
                        end
                    end
                end else if (cursor_position == 3) begin
                    if ( (x >= disp5_x_right_border && x <= disp5_x_right_border + 1) ) begin
                        if (blink_on) begin
                            oled_colour = CURSOR_COLOUR;
                        end else begin
                            oled_colour = BG_COLOUR;
                        end
                    end
                end else if (cursor_position == 4) begin
                    if ( (x >= disp6_x_right_border && x <= disp6_x_right_border + 1) ) begin
                        if (blink_on) begin
                            oled_colour = CURSOR_COLOUR;
                        end else begin
                            oled_colour = BG_COLOUR;
                        end
                    end
                end else if (cursor_position == 5) begin
                    if ( (x >= disp7_x_right_border && x <= disp7_x_right_border + 1) ) begin
                        if (blink_on) begin
                            oled_colour = CURSOR_COLOUR;
                        end else begin
                            oled_colour = BG_COLOUR;
                        end
                    end
                end else if (cursor_position == 6) begin
                    if ( (x >= disp8_x_right_border && x <= disp8_x_right_border + 1) ) begin
                        if (blink_on) begin
                            oled_colour = CURSOR_COLOUR;
                        end else begin
                            oled_colour = BG_COLOUR;
                        end
                    end
                end
            end
        end 
        
        // Box 0 display 7
        else if (on_box_border[0]) begin
            if (current_box == 0) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[0]) begin
            current_digit = 5'd7;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col1_x_left_border + 3 && x <= col1_x_left_border + 10) && (y >= row1_y_top_border + 1 && y <= row1_y_top_border + 8) ) begin
                rom_row = y - (row1_y_top_border + 1);
                rom_col = x - (col1_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 1 display 8
        else if (on_box_border[1]) begin
            if (current_box == 1) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[1]) begin
            current_digit = 5'd8;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col2_x_left_border + 3 && x <= col2_x_left_border + 10) && (y >= row1_y_top_border + 1 && y <= row1_y_top_border + 8) ) begin
                rom_row = y - (row1_y_top_border + 1);
                rom_col = x - (col2_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
    
        // Box 2 display 9
        else if (on_box_border[2]) begin
            if (current_box == 2) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[2]) begin
            current_digit = 5'd9;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col3_x_left_border + 3 && x <= col3_x_left_border + 10) && (y >= row1_y_top_border + 1 && y <= row1_y_top_border + 8) ) begin
                rom_row = y - (row1_y_top_border + 1);
                rom_col = x - (col3_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 3 display Graph, G
        else if (on_box_border[3]) begin
            if (current_box == 3) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[3]) begin
            char_index = 6'd6;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col4_x_left_border + 11 && x <= col4_x_left_border + 18) && (y >= row1_y_top_border + 1 && y <= row1_y_top_border + 8) ) begin
                rom_row = y - (row1_y_top_border + 1);
                rom_col = x - (col4_x_left_border + 3);
                
                if (row_data_font[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 4 display 4
        else if (on_box_border[4]) begin
            if (current_box == 4) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[4]) begin
            current_digit = 5'd4;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col1_x_left_border + 3 && x <= col1_x_left_border + 10) && (y >= row2_y_top_border + 1 && y <= row2_y_top_border + 8) ) begin
                rom_row = y - (row2_y_top_border + 1);
                rom_col = x - (col1_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 5 display 5
        else if (on_box_border[5]) begin
            if (current_box == 5) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[5]) begin
            current_digit = 5'd5;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col2_x_left_border + 3 && x <= col2_x_left_border + 10) && (y >= row2_y_top_border + 1 && y <= row2_y_top_border + 8) ) begin
                rom_row = y - (row2_y_top_border + 1);
                rom_col = x - (col2_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
    
        // Box 6 display 6
        else if (on_box_border[6]) begin
            if (current_box == 6) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[6]) begin
            current_digit = 5'd6;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col3_x_left_border + 3 && x <= col3_x_left_border + 10) && (y >= row2_y_top_border + 1 && y <= row2_y_top_border + 8) ) begin
                rom_row = y - (row2_y_top_border + 1);
                rom_col = x - (col3_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 7 display <-
        else if (on_box_border[7]) begin
            if (current_box == 7) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end 
        else if (in_box_interior[7]) begin
            current_digit = 5'd14;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col4_x_left_border + 3 && x <= col4_x_left_border + 10) && (y >= row2_y_top_border + 1 && y <= row2_y_top_border + 8) ) begin
                rom_row = y - (row2_y_top_border + 1);
                rom_col = x - (col4_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 8 display ->
        else if (on_box_border[8]) begin
            if (current_box == 8) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[8]) begin
            current_digit = 5'd13;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col4p5_x_left_border + 3 && x <= col4p5_x_left_border + 10) && (y >= row2_y_top_border + 1 && y <= row2_y_top_border + 8) ) begin
                rom_row = y - (row2_y_top_border + 1);
                rom_col = x - (col4p5_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 9 display 1
        else if (on_box_border[9]) begin
            if (current_box == 9) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[9]) begin
            current_digit = 5'd1;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col1_x_left_border + 3 && x <= col1_x_left_border + 10) && (y >= row3_y_top_border + 1 && y <= row3_y_top_border + 8) ) begin
                rom_row = y - (row3_y_top_border + 1);
                rom_col = x - (col1_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 10 display 2
        else if (on_box_border[10]) begin
            if (current_box == 10) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[10]) begin
            current_digit = 5'd2;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col2_x_left_border + 3 && x <= col2_x_left_border + 10) && (y >= row3_y_top_border + 1 && y <= row3_y_top_border + 8) ) begin
                rom_row = y - (row3_y_top_border + 1);
                rom_col = x - (col2_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
    
        // Box 11 display 3
        else if (on_box_border[11]) begin
            if (current_box == 11) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[11]) begin
            current_digit = 5'd3;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col3_x_left_border + 3 && x <= col3_x_left_border + 10) && (y >= row3_y_top_border + 1 && y <= row3_y_top_border + 8) ) begin
                rom_row = y - (row3_y_top_border + 1);
                rom_col = x - (col3_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 12 display Delete, D
        else if (on_box_border[12]) begin
            if (current_box == 12) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[12]) begin
            char_index = 6'd3;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col4_x_left_border + 11 && x <= col4_x_left_border + 18) && (y >= row3_y_top_border + 1 && y <= row3_y_top_border + 8) ) begin
                rom_row = y - (row3_y_top_border + 1);
                rom_col = x - (col4_x_left_border + 3);
                
                if (row_data_font[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 13 display 0
        else if (on_box_border[13]) begin
            if (current_box == 13) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[13]) begin
            current_digit = 5'd0;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col1_x_left_border + 3 && x <= col1_x_left_border + 10) && (y >= row4_y_top_border + 1 && y <= row4_y_top_border + 8) ) begin
                rom_row = y - (row4_y_top_border + 1);
                rom_col = x - (col1_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
        // Box 14 display +/-
        else if (on_box_border[14]) begin
            if (current_box == 14) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[14]) begin
            current_digit = 5'd12;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col2_x_left_border + 3 && x <= col2_x_left_border + 10) && (y >= row4_y_top_border + 1 && y <= row4_y_top_border + 8) ) begin
                rom_row = y - (row4_y_top_border + 1);
                rom_col = x - (col2_x_left_border + 3);
                
                if (row_data[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
        
//        // Box 15 display =
//        else if (on_box_border[15]) begin
//            if (current_box == 15) begin
//                oled_colour = BORDER_COLOUR;
//            end else begin
//                oled_colour = BOX_COLOUR;
//            end
//        end else if (in_box_interior[15]) begin
//            current_digit = 4'd11;
//            oled_colour = BOX_COLOUR;
            
//            if ( (x >= col3_x_left_border + 3 && x <= col3_x_left_border + 10) && (y >= row4_y_top_border + 1 && y <= row4_y_top_border + 8) ) begin
//                rom_row = y - (row4_y_top_border + 1);
//                rom_col = x - (col3_x_left_border + 3);
                
//                if (row_data[7 - rom_col]) begin
//                    oled_colour = TEXT_COLOUR;
//                end
//            end
//        end
        
        // Box 16 display Enter, E
        else if (on_box_border[16]) begin
            if (current_box == 16) begin
                oled_colour = BORDER_COLOUR;
            end else begin
                oled_colour = BOX_COLOUR;
            end
        end else if (in_box_interior[16]) begin
            char_index = 6'd4;
            oled_colour = BOX_COLOUR;
            
            if ( (x >= col4_x_left_border + 11 && x <= col4_x_left_border + 18) && (y >= row4_y_top_border + 1 && y <= row4_y_top_border + 8) ) begin
                rom_row = y - (row4_y_top_border + 1);
                rom_col = x - (col4_x_left_border + 3);
                
                if (row_data_font[7 - rom_col]) begin
                    oled_colour = TEXT_COLOUR;
                end
            end
        end
    end
    
    BCD_ROM_module bcd_rom (
        .bcd_digit(current_digit),
        .row(rom_row),
        .row_data(row_data)
    );
    
    font_ROM_module font_rom (
        .char_index(char_index),
        .row(rom_row),
        .row_data(row_data_font)
    );
    
    variable_clock F1 (clk, 49999999, blink_on); // clock = 1 Hz

endmodule
