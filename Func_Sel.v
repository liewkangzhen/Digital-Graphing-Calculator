`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2026 20:29:42
// Design Name: 
// Module Name: Func_Sel
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


module Func_Sel(
    input clk, clk_1k, clk_6p25m, 
    input rst, 
    input btnC_pulse, btnR_pulse, btnL_pulse,
    input [12:0] pixel_index,
    output reg [2:0] led,
    output reg [1:0] func_selected,
    output reg [15:0] oled_colour = 16'b0000000000000000,
    output reg Done = 0
    );
    
    //Setting coordinates for pixel_index                       
    wire [6:0] x; wire [5:0] y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;    
    
    //Coordinates for frame (with default values)
    reg [6:0] frame_x_min = 33;
    reg [6:0] frame_x_max = 62;
    reg [5:0] frame_y_min = 19;
    reg [5:0] frame_y_max = 45;
    
    //Debouncer
//    reg [7:0] debounce_counter = 0;
//    reg btnL_sync = 0; reg btnR_sync = 0; reg btnC_sync = 0;
//    reg btnL_prev = 0; reg btnR_prev = 0; reg btnC_prev = 0;
//    reg btnL_valid = 0; reg btnR_valid = 0; reg btnC_valid = 0;
//    wire btnL_pressed; wire btnR_pressed; wire btnC_pressed;
    
//    //Debouncer with reset 
//    always @(posedge clk_1k) begin
//        if (rst) begin
//            btnL_sync <= 0; btnL_prev <= 0; btnL_valid <= 0;
//            btnR_sync <= 0; btnR_prev <= 0; btnR_valid <= 0;
//            btnC_sync <= 0; btnC_prev <= 0; btnC_valid <= 0;
//            debounce_counter <= 0;
//        end 
//        else begin
//            btnL_sync <= btnL;
//            btnL_prev <= btnL_sync;
//            btnR_sync <= btnR;
//            btnR_prev <= btnR_sync;
//            btnC_sync <= btnC;
//            btnC_prev <= btnC_sync;

//            if (debounce_counter != 0) begin
//                debounce_counter <= debounce_counter - 1;
//                btnL_valid <= 0;
//                btnR_valid <= 0;
//                btnC_valid <= 0;
//            end
//            else begin
//                if (btnL_sync & ~btnL_prev) begin
//                    btnL_valid <= 1;
//                    debounce_counter <= 200;
//                end
//                else
//                    btnL_valid <= 0;

//                if (btnR_sync & ~btnR_prev) begin
//                    btnR_valid <= 1;
//                    debounce_counter <= 200;
//                end
//                else
//                    btnR_valid <= 0;

//                if (btnC_sync & ~btnC_prev) begin
//                    btnC_valid <= 1;
//                    debounce_counter <= 200;
//                end
//                else
//                    btnC_valid <= 0;
//            end
//        end
//    end
    
//    assign btnL_pressed = btnL_valid ;
//    assign btnR_pressed = btnR_valid ;
//    assign btnC_pressed = btnC_valid ;
    
//    reg btnL_fast_prev = 0;
//    reg btnR_fast_prev = 0;
//    reg btnC_fast_prev = 0;
    
//    wire btnL_pulse, btnR_pulse, btnC_pulse;
    
//    always @(posedge clk) begin
//        btnL_fast_prev <= btnL_valid;
//        btnR_fast_prev <= btnR_valid;
//        btnC_fast_prev <= btnC_valid;
//    end
    
//    assign btnL_pulse = btnL_valid & ~btnL_fast_prev;
//    assign btnR_pulse = btnR_valid & ~btnR_fast_prev;
//    assign btnC_pulse = btnC_valid & ~btnC_fast_prev;
     
    reg [1:0] current_state = 2'b01;
    reg [1:0] next_state = 2'b01;
    
    parameter TRIGO = 2'b00, POLY = 2'b01, EXP = 2'b10;
    
    always @(*) begin
        case (current_state) 
            TRIGO: next_state = btnR_pulse ? POLY  : TRIGO;
            POLY:  next_state = btnL_pulse ? TRIGO : (btnR_pulse ? EXP : POLY);
            EXP:   next_state = btnL_pulse ? POLY  : EXP;
            default: next_state = POLY;                       
        endcase
    end
    
    //State register + frame update with reset
    always @(posedge clk) begin
        if (rst) begin
            current_state  <= POLY;                     
            func_selected  <= POLY;
            frame_x_min    <= 33;
            frame_x_max    <= 62;
            frame_y_min    <= 19;
            frame_y_max    <= 45;
            Done <= 0;
        end
        else begin
            current_state <= next_state;
            Done <= 0;

            case (next_state)
                TRIGO: begin frame_x_min <= 1;  frame_x_max <= 30; end
                POLY:  begin frame_x_min <= 33; frame_x_max <= 62; end
                EXP:   begin frame_x_min <= 65; frame_x_max <= 94; end
            endcase

            frame_y_min <= 19;
            frame_y_max <= 45;

            if (btnC_pulse) begin
                func_selected <= next_state;
                Done <= 1;
            end
        end
    end
    
    //Oled Update
    always @(posedge clk_6p25m) begin
        oled_colour <= 16'b0000000000000000;
        if ((x >= 2 && x <= 3) | (x >= 27 && x <= 28) | (x >= 34 && x <= 35) | (x >= 59 && x <= 60) | (x >= 66 && x <= 67) | (x >= 91 && x <= 92)) begin
            if (y >= 20 && y <= 44) begin
                oled_colour <= 16'b0000000000011111;
            end
        end
        if ((x >= 4 && x <= 27) | (x >= 36 && x <= 59) | (x >= 68 && x <= 91)) begin
            if ((y >= 20 && y <= 21) | (y >= 43 && y <= 44)) begin
                oled_colour <= 16'b0000000000011111;
            end
        end
        
        if ((x == frame_x_min) | (x == frame_x_max)) begin
            if ((y >= frame_y_min && y <= frame_y_max)) begin
                oled_colour <= 16'b1111100000000000;
            end
        end
        if ((x >= frame_x_min) && (x <= frame_x_max)) begin
            if ((y == frame_y_min) | (y == frame_y_max)) begin
                oled_colour <= 16'b1111100000000000;
            end
        end
        
        //TRIGO
        if (x >= 7 && x <= 24) begin
            if (y == 32) begin
                oled_colour <= 16'b0000011111100000;
            end
        end
        if (x == 15) begin
            if (y >= 25 && y <= 38) begin
                oled_colour <= 16'b0000011111100000;
            end
        end
        
        if (
            (x==8  && (y==30 || y==31 || y==32)) ||
            (x==9  && (y==27 || y==28 || y==29)) ||
            (x==10 && (y==26 || y==27))          ||  // clamped
            (x==11 && (y==27 || y==28 || y==29)) ||
            (x==12 && (y==30 || y==31 || y==32)) ||
            (x==13 && (y==33 || y==34 || y==35)) ||
            (x==14 && (y==36 || y==37))          ||  // clamped
            (x==15 && (y==33 || y==34 || y==35)) ||
            (x==16 && (y==30 || y==31 || y==32)) ||
            (x==17 && (y==27 || y==28 || y==29)) ||
            (x==18 && (y==26 || y==27))          ||  // clamped
            (x==19 && (y==27 || y==28 || y==29)) ||
            (x==20 && (y==30 || y==31 || y==32)) ||
            (x==21 && (y==33 || y==34 || y==35)) ||
            (x==22 && (y==36 || y==37))          ||  // clamped
            (x==23 && (y==33 || y==34 || y==35))
        ) begin
            oled_colour <= 16'b1111111111111111; // white
        end
        
        //POLY
        if (x >= 40 && x <= 55) begin
            if (y == 36) begin
                oled_colour <= 16'b0000011111100000;
            end
        end
        if (x == 47) begin
            if (y >= 25 && y <= 38) begin
                oled_colour <= 16'b0000011111100000;
            end
        end   
        
        if (
            (x==41 && (y==26 || y==27))          ||  // clamped
            (x==42 && (y==28 || y==29 || y==30)) ||
            (x==43 && (y==31 || y==32 || y==33)) ||
            (x==44 && (y==33 || y==34 || y==35)) ||
            (x==45 && (y==34 || y==35 || y==36)) ||
            (x==46 && (y==35 || y==36 || y==37)) ||
            (x==47 && (y==35 || y==36 || y==37)) ||  // vertex
            (x==48 && (y==35 || y==36 || y==37)) ||
            (x==49 && (y==34 || y==35 || y==36)) ||
            (x==50 && (y==33 || y==34 || y==35)) ||
            (x==51 && (y==31 || y==32 || y==33)) ||
            (x==52 && (y==28 || y==29 || y==30)) ||
            (x==53 && (y==26 || y==27))              // clamped
        ) begin
            oled_colour <= 16'b1111111111111111; // white
        end
        
        //EXP
        if (x >= 72 && x <= 87) begin
            if (y == 36) begin
                oled_colour <= 16'b0000011111100000;
            end
        end
        if (x == 72) begin
            if (y >= 25 && y <= 38) begin
                oled_colour <= 16'b0000011111100000;
            end
        end
        
        if (
            (x==72 && y==36) ||
            (x==73 && y==34) ||
            (x==74 && y==32) ||
            (x==75 && y==31) ||
            (x==76 && y==30) ||
            (x==77 && y==30) ||
            (x==78 && y==29) ||
            (x==79 && y==29) ||
            (x==80 && y==28) ||
            (x==81 && y==28) ||
            (x==82 && y==27) ||
            (x==83 && y==27) ||
            (x==84 && y==27) ||
            (x==85 && y==27) ||
            (x==86 && y==27) 
        ) begin
            oled_colour <= 16'b1111111111111111; // white
        end
        
    end
  
    
    
    always @(*) begin
        case (func_selected) 
            TRIGO: led[2:0] <= 3'b100;
            POLY: led[2:0] <= 3'b010;
            EXP: led[2:0] <= 3'b001;
        endcase
    end

    
endmodule
