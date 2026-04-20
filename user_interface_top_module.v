`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2026 16:32:21
// Design Name: 
// Module Name: user_interface_top_module
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


module user_interface_top_module(
    input clk,
    input btnU, btnL, btnR, btnD, btnC,
    input sw0,
    input sw1,
    input sw2,
    input sw3,
    output [7:0] JA,
    output [7:0] JC,
    output [2:0] led,
    output led3,
    inout PS2Clk,
    inout PS2Data
);
    // Connections to OLED Module
    wire clk_6p25MHz, clk_25MHz, clk_1kHz;
    wire frame_begin_1, frame_begin_2, sending_pixels_1, sending_pixels_2, sample_pixel_1, sample_pixel_2;
    wire [12:0] pixel_index_1, pixel_index_2;
    wire [6:0] x;
    wire [5:0] y;
    wire [15:0] oled_colour_1;
    wire [15:0] oled_colour_2;
    
    // Connections to other Modules
    wire btnU_keypad;
    wire btnL_keypad;
    wire btnR_keypad;
    wire btnD_keypad;
    wire btnC_keypad;
    wire btnC_func_sel;
    wire btnR_func_sel;
    wire btnL_func_sel;
    wire Done_func_sel;
    wire Done_keypad;
    wire [15:0] oled_colour_keypad;
    wire [15:0] oled_colour_func_sel;
    wire [15:0] oled_colour_draw_grid;
    wire [15:0] oled_colour_show_abc;
    wire [1:0] func_selected;                 // Trigo, Poly, Expo
    wire signed [7:0] coefficient_a;
    wire signed [7:0] coefficient_b;
    wire signed [7:0] coefficient_c;
    wire graph_enable;
    wire [2:0] led_func_sel;
    reg Rst_func_sel;
    reg Rst_keypad;
    
    //connections for draw_grid module
    wire signed [31:0] draw_grid_tracing_x;
    wire signed [47:0] draw_grid_tracing_y;
    wire draw_grid_tracing_val_valid;
    wire [1:0] draw_gird_out_mode;
    wire [3:0] wire_scroll;
    
    // switch mode
    reg switch = 1;
    
    // declaration for debouncer
    wire btnU_pulse;
    wire btnL_pulse;
    wire btnR_pulse;
    wire btnD_pulse;
    wire btnC_pulse;
    
    assign led3 = sw3;
    
    assign led = led_func_sel;
    
    always @(posedge clk) begin
        Rst_keypad   <= 0;
        Rst_func_sel <= 0;
    
        if (Done_func_sel) begin
            switch <= 0;         // go to keypad
            Rst_keypad <= 1;     // reset keypad for 1 cycle
        end else if (Done_keypad) begin
            switch <= 1;         // go to func_sel
            Rst_func_sel <= 1;   // reset func_sel for 1 cycle
        end
    end
    
    
    assign oled_colour_1 = (switch) ? oled_colour_func_sel : 
                            (sw0) ? oled_colour_draw_grid :
                            oled_colour_keypad;
                            
    assign oled_colour_2 = oled_colour_show_abc;
                            
    assign btnU_keypad = (~switch) ? btnU_pulse : 0;
    assign btnL_keypad = (~switch) ? btnL_pulse : 0;
    assign btnR_keypad = (~switch) ? btnR_pulse : 0;
    assign btnD_keypad = (~switch) ? btnD_pulse : 0;
    assign btnC_keypad = (~switch) ? btnC_pulse : 0;
    
    assign btnC_func_sel = (switch) ? btnC_pulse : 0;
    assign btnR_func_sel = (switch) ? btnR_pulse : 0;
    assign btnL_func_sel = (switch) ? btnL_pulse : 0;
    
    debouncer D1 (clk, clk_1kHz, btnU, btnU_pulse);
    debouncer D2 (clk, clk_1kHz, btnL, btnL_pulse);
    debouncer D3 (clk, clk_1kHz, btnR, btnR_pulse);
    debouncer D4 (clk, clk_1kHz, btnD, btnD_pulse);
    debouncer D5 (clk, clk_1kHz, btnC, btnC_pulse);
    
    Func_Sel menu (
        .clk(clk),
        .clk_1k(clk_1kHz),
        .clk_6p25m(clk_6p25MHz),
        .rst(Rst_func_sel),
        .btnC_pulse(btnC_func_sel),
        .btnR_pulse(btnR_func_sel),
        .btnL_pulse(btnL_func_sel),
        .pixel_index(pixel_index_1),
        .led(led_func_sel),
        .func_selected(func_selected),
        .oled_colour(oled_colour_func_sel),
        .Done(Done_func_sel)
    );
    
    keypad keypad0 (
        .clk(clk),
        .clk_1kHz(clk_1kHz),
        .btnU_pulse(btnU_keypad),
        .btnL_pulse(btnL_keypad),
        .btnR_pulse(btnR_keypad),
        .btnD_pulse(btnD_keypad),
        .btnC_pulse(btnC_keypad),
        .pixel_index(pixel_index_1),
        .func_selected(func_selected),
        .rst(Rst_keypad),
        .oled_colour(oled_colour_keypad),
        .coefficient_a(coefficient_a),
        .coefficient_b(coefficient_b),
        .coefficient_c(coefficient_c),
        .graph_enable(graph_enable),
        .Done(Done_keypad)
    );
    
    draw_grid_test_2 draw_grid (
        .basys_clock(clk),
        .quad_zoom_fit_sw(sw1),
        .trigo_toggle_sw(sw2),                          //To toggle between sin and cos function
        .graph_mode_sw(sw3),
        .pixel_index_in(pixel_index_1),
        .frame_begin_in(frame_begin_1),                  
        .curve_type(func_selected),                    //rename this for graph mode selection from Keypad module
        .coefficient_a(coefficient_a),
        .coefficient_b(coefficient_b),
        .coefficient_c(coefficient_c),
        .graph_enable(graph_enable),
        .oled_colour(oled_colour_draw_grid),
        // --- Outputs for External Display Integration -------------------------------------------------------------------------------
        .out_mode(draw_gird_out_mode),           // Current function: 00=Trigo, 01=Quad, 10=Exp
        .out_true_x(draw_grid_tracing_x), // Mathematical X-coordinate
        .out_true_y(draw_grid_tracing_y), // Mathematical Y-coordinate (Raw from BRAM)
        .out_val_valid(draw_grid_tracing_val_valid),            // High when the output x and y are valid (i.e cursor is tracing and the module is in TRACING MODE)
        //-----------------------------------------------------------------------------------------------------------------------------------
        .PS2Clk(PS2Clk),
        .PS2Data(PS2Data)
    );  
    
    show_abc show_abc1(
        .clk(clk),
        .pixel_index(pixel_index_2),
        .curve_mode(func_selected),
        .sw_low(sw2),                               //To toggle between sin and cos function
        .true_x(draw_grid_tracing_x),
        .true_y(draw_grid_tracing_y),
        .val_valid(draw_grid_tracing_val_valid),
    
        .quad_a(coefficient_a),
        .quad_b(coefficient_b),
        .quad_c(coefficient_c),
        .trigo_a(coefficient_a),
        .exp_a(coefficient_a),
    
        .oled_colour(oled_colour_show_abc)
    );
    
    variable_clock F1 (clk, 7, clk_6p25MHz);
    variable_clock F2 (clk, 1, clk_25MHz);
    variable_clock F3 (clk, 49999, clk_1kHz);

    Oled_Display OLED1 (
    .clk(clk_6p25MHz), 
    .reset(0), 
    .frame_begin(frame_begin_1), 
    .sending_pixels(sending_pixels_1),
    .sample_pixel(sample_pixel_1), 
    .pixel_index(pixel_index_1), 
    .pixel_data(oled_colour_1), 
    .cs(JC[0]), 
    .sdin(JC[1]), 
    .sclk(JC[3]), 
    .d_cn(JC[4]), 
    .resn(JC[5]), 
    .vccen(JC[6]),
    .pmoden(JC[7]));
    
    Oled_Display OLED2 (
    .clk(clk_6p25MHz), 
    .reset(0), 
    .frame_begin(frame_begin_2), 
    .sending_pixels(sending_pixels_2),
    .sample_pixel(sample_pixel_2), 
    .pixel_index(pixel_index_2), 
    .pixel_data(oled_colour_2), 
    .cs(JA[0]), 
    .sdin(JA[1]), 
    .sclk(JA[3]), 
    .d_cn(JA[4]), 
    .resn(JA[5]), 
    .vccen(JA[6]),
    .pmoden(JA[7]));
endmodule
