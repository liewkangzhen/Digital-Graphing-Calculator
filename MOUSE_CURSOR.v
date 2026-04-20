`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 11:03:34
// Design Name: 
// Module Name: mouse_testing
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


module Mouse_Cursor(
    input basys_clock,
    input RST,
    output [7:0] JC,
    output [11:0] mouse_x_pos,
    output [11:0] mouse_y_pos,
    output mouse_click_left_output,
    output mouse_click_right_output,
    output reg [3:0] mouse_scroll_acc = 0, //user scrolls up --> +1,  0 -> 7 -> -8 -> -1 -> 0
                                    //user scrolls down --> -1,  0 -> -1 -> -8 -> 7 -> 0
    inout PS2Clk,
    inout PS2Data
    );
    
    //MouseCtl module registers and wires
    reg [11:0] settings_value;
    reg SETX;
    reg SETY;
    reg SETMAX_X;
    reg SETMAX_Y;
    wire [11:0] XPOS;
    wire [11:0] YPOS;
    wire [3:0] ZPOS;
    wire mouse_click_left;
    wire mouse_click_middle;
    wire mouse_click_right;
    wire new_event;
    
    //clock wires
//    wire clk_6p25M;
//    wire clk_25M;
    
    //OLED registers and wires
    reg [15:0] pixel_colour = 16'h0000;
    wire frame_begin;
    wire [12:0] pixel_index;
    wire sending_pixels;
    wire sample_pixels;
    wire [11:0] cursor_centre_x;
    wire [11:0] cursor_centre_y;
    //Setting coordinates for pixel_index                       
    wire [6:0] x; wire [5:0] y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96; 
    assign cursor_centre_x = XPOS;
    assign cursor_centre_y = YPOS;
    assign mouse_x_pos = cursor_centre_x;
    assign mouse_y_pos = cursor_centre_y;
    assign mouse_click_left_output = mouse_click_left;
    assign mouse_click_right_output = mouse_click_right;
    
    
    
    always @(posedge basys_clock) begin
        if (new_event)
            mouse_scroll_acc <= mouse_scroll_acc + ZPOS;
    end
    
    reg Mouse_Init_X = 1'b0;
    reg Mouse_Init_Y = 1'b0;
    //Mouse upper and lower bound initialization settings
    always @ (posedge basys_clock) begin
        if (Mouse_Init_X == 1'b0) begin
            settings_value <= 96;
            SETMAX_X <= 1'b1;
            Mouse_Init_X <= 1'b1;
        end
        else if (Mouse_Init_Y == 1'b0) begin
            settings_value <= 64;
            SETMAX_X <= 1'b0;
            SETMAX_Y <= 1'b1;
            Mouse_Init_Y <= 1'b1;
        end
        else begin
            SETMAX_Y <= 1'b0;
        end
    end
    
    
//    always @ (posedge clk_25M) begin
//        if ( (x-cursor_centre_x)**2 + (y-cursor_centre_y) **2 <= 9 ) begin
//            pixel_colour <= 16'hFFFF;
//        end
//        else begin
//            pixel_colour <= 16'h0000;
//        end
//    end
    
    
    //Instantiate the vairable clock module
//    variable_clock vc_6p25M (basys_clock, 7, clk_6p25M);
//    variable_clock vc_25M (basys_clock, 3, clk_25M);
    
    //Instantiate the OLED module
//    Oled_Display dut2 (.clk(clk_6p25M), .reset(1'b0), .frame_begin(frame_begin), .sending_pixels(sending_pixels), 
//                               .sample_pixel(sample_pixels), .pixel_index(pixel_index), .pixel_data(pixel_colour), 
//                               .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), 
//                               .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7]));
    
    //Instantiate the mouse module
    MouseCtl dut1 (.clk(basys_clock),.rst(RST),.value(settings_value),.setx(SETX),.sety(SETY),.setmax_x(SETMAX_X),.setmax_y(SETMAX_Y),
        .xpos(XPOS),.ypos(YPOS),.zpos(ZPOS),.new_event(new_event),
        .left(mouse_click_left),.middle(mouse_click_middle),.right(mouse_click_right),
        .ps2_clk(PS2Clk),.ps2_data(PS2Data));
   
        
endmodule
