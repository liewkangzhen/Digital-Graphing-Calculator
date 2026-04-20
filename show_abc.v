module show_abc(
    input clk,
    input [12:0] pixel_index,

    input [1:0] curve_mode,
    input sw_low,
    input signed [31:0] true_x,
    input signed [47:0] true_y,
    input val_valid,

    input signed [7:0] quad_a,
    input signed [7:0] quad_b,
    input signed [7:0] quad_c,
    input signed [7:0] trigo_a,
    input signed [7:0] exp_a,

    output reg [15:0] oled_colour
);

    wire [6:0] x = pixel_index % 96;
    wire [5:0] y = pixel_index / 96;
    
    //VALUE STORE
    reg signed [31:0] stored_x;
    reg [15:0] stored_x_frac;
    reg signed [31:0] stored_y;
    reg [15:0] stored_y_frac;
    reg stored_x_neg;
    reg stored_y_neg;
    
    reg signed [31:0] abs_x;
    reg signed [47:0] abs_y;
    
//    reg [15:0] frac_tmp;
    
    always @(posedge clk) begin
        if (val_valid) begin
            abs_x <= (true_x < 0) ? -true_x : true_x;
            abs_y <= (true_y < 0) ? -true_y : true_y;
            stored_x_neg <= (true_x < 0);
            stored_y_neg <= (true_y < 0);
    
            case(curve_mode) 
            2'b00: begin 
//                stored_x <= true_x >>> 8; 
//                stored_x_frac <= ((abs_x & 8'hFF) * 1000 + 128) >>> 8;
//                if (true_y >= 0) begin 
//                    stored_y <= true_y >>> 8; 
//                    stored_y_frac <= ((abs_y & 8'hFF) * 1000 + 128) >>> 8; 
//                end else begin 
//                    stored_y <= -(abs_y >>> 8);
//                    stored_y_frac <= ((abs_y & 8'hFF) * 1000 + 128) >>> 8;
//                end 
                
                // Use the absolute value to get the integer part, then re-apply sign
                stored_x <= (true_x < 0) ? -(abs_x >>> 8) : (abs_x >>> 8); 
                stored_x_frac <= ((abs_x & 8'hFF) * 1000 + 128) >>> 8;
                
                if (true_y >= 0) begin 
                    stored_y <= abs_y >>> 8; 
                end else begin 
                    stored_y <= -(abs_y >>> 8);
                end
                stored_y_frac <= ((abs_y & 8'hFF) * 1000 + 128) >>> 8;
            end
            2'b01: begin
                stored_x <= true_x;
                stored_x_frac <= 0;
//                stored_y <= (true_y < 0) ? -(abs_y >>> 16) : (abs_y >>> 16);
//                stored_y <= true_y[31:0];
                stored_y <= (true_y[47]) ? -$signed(abs_y[31:0]) : $signed(abs_y[31:0]);
                stored_y_frac <= 0;
//                stored_y_frac <= ((abs_y & 16'hFFFF) * 1000 + 32768) >>> 16;
            end
            2'b10: begin
                stored_x      <= true_x >>> 8;
                stored_x_frac <= ((abs_x & 8'hFF) * 1000 + 128) >>> 8;
                stored_y      <= true_y >>> 16;
                stored_y_frac <= ((abs_y & 16'hFFFF) * 1000 + 32768) >>> 16;
            end
            endcase
        end
    end

    // ROM
    reg [4:0] current_digit;
    reg [2:0] rom_row, rom_col;
    wire [7:0] row_data;

    bcd_ROM_module_2 bcd(
        .bcd_digit(current_digit),
        .row(rom_row),
        .row_data(row_data)
    );

    reg [5:0] char_index;
    wire [7:0] font_row;
    wire [2:0] font_r = y % 8;

    font_ROM_module_2 font(
        .char_index(char_index),
        .row(font_r),
        .row_data(font_row)
    );
    
    localparam BG = 16'h0000;
    localparam TXT = 16'h9FE0;

    // FUNCS
    function [3:0] get_digit;
        input signed [31:0] num;
        input integer place;
        reg [31:0] abs_val;
        begin
            abs_val = (num < 0) ? -num : num;
    
            case(place)
                0: get_digit = abs_val % 10;
                1: get_digit = (abs_val / 10) % 10;
                2: get_digit = (abs_val / 100) % 10;
                3: get_digit = (abs_val / 1000) % 10;
                4: get_digit = (abs_val / 10000) % 10;
                5: get_digit = (abs_val / 100000) % 10;
                6: get_digit = (abs_val / 1000000) % 10;
                default: get_digit = 0;
            endcase
        end
    endfunction

    function [3:0] get_frac_digit;
        input [15:0] frac;
        input integer place;
        begin
            case(place)
                0: get_frac_digit = frac % 10;
                1: get_frac_digit = (frac / 10) % 10;
                2: get_frac_digit = (frac / 100) % 10;
                default: get_frac_digit = 0;
            endcase
        end
    endfunction

    function show_digit;
        input signed [31:0] num;
        input integer place;
        reg [31:0] abs_val;
        begin
            abs_val = (num < 0) ? -num : num;
    
            case(place)
                6: show_digit = (abs_val >= 1000000);
                5: show_digit = (abs_val >= 100000);
                4: show_digit = (abs_val >= 10000);
                3: show_digit = (abs_val >= 1000);
                2: show_digit = (abs_val >= 100);
                1: show_digit = (abs_val >= 10);
                0: show_digit = 1;
                default: show_digit = 0;
            endcase
        end
    endfunction
    
    // COEFF
    reg signed [7:0] A,B,C;
    reg showB,showC;

    always @(*) begin
        case(curve_mode)
            2'b00: begin A=trigo_a; B=0; C=0; showB=0; showC=0; end
            2'b01: begin A=quad_a;  B=quad_b; C=quad_c; showB=1; showC=1; end
            2'b10: begin A=exp_a;   B=0; C=0; showB=0; showC=0; end
        endcase
    end
    
    // MAIN
    always @(*) begin
        oled_colour = BG;
        current_digit = 5'd31;
        rom_row = 0;
        rom_col = 0;
        char_index = 0;
        
    // FORMULA EXPRESSION
    if (y < 8) begin
        if (x >=2 && x < 10) begin
            char_index = 50; // y
            if (font_row[7-(x-2)]) oled_colour = TXT;
        end
        else if (x >= 10 && x < 18) begin
            current_digit = 5'd11; // '='
            rom_row = y;
            rom_col = x - 10;
        end
        // sin(ax)
        if (curve_mode == 2'b00) begin
            if(sw_low)begin
                if (x>=20 && x<28) begin char_index=28; if(font_row[7-(x-20)]) oled_colour=TXT; end // c
                if (x>=28 && x<36) begin char_index=40; if(font_row[7-(x-28)]) oled_colour=TXT; end // o
                if (x>=36 && x<44) begin char_index=44; if(font_row[7-(x-36)]) oled_colour=TXT; end // s
                if (x>=44 && x<52) begin char_index=26; if(font_row[7-(x-44)]) oled_colour=TXT; end // a
                if (x>=52 && x<60) begin char_index=49; if(font_row[7-(x-52)]) oled_colour=TXT; end // x
            end
            else begin
                if (x>=20 && x<28) begin char_index=44; if(font_row[7-(x-20)]) oled_colour=TXT; end // s
                if (x>=28 && x<36) begin char_index=34; if(font_row[7-(x-28)]) oled_colour=TXT; end // i
                if (x>=36 && x<44) begin char_index=39; if(font_row[7-(x-36)]) oled_colour=TXT; end // n
                if (x>=44 && x<52) begin char_index=26; if(font_row[7-(x-44)]) oled_colour=TXT; end // a
                if (x>=52 && x<60) begin char_index=49; if(font_row[7-(x-52)]) oled_colour=TXT; end // x
            end
            
end
        // quad
        else if (curve_mode == 2'b01) begin
            if (x>=20 && x<28) begin char_index=26; if(font_row[7-(x-20)]) oled_colour=TXT; end // a
            if (x>=28 && x<36) begin char_index=49; if(font_row[7-(x-28)]) oled_colour=TXT; end // x
            if (x>=36 && x<44) begin current_digit=5'd15; rom_row=y; rom_col=x-36; end // ^
            if (x>=44 && x<52) begin current_digit=5'd2; rom_row=y; rom_col=x-44; end // 2
            if (x>=52 && x<60) begin current_digit=5'd16; rom_row=y; rom_col=x-52; end // +
            if (x>=60 && x<68) begin char_index=27; if(font_row[7-(x-60)]) oled_colour=TXT; end // b
            if (x>=68 && x<76) begin char_index=49; if(font_row[7-(x-68)]) oled_colour=TXT; end // x
            if (x>=76 && x<84) begin current_digit=5'd16; rom_row=y; rom_col=x-76; end // +
            if (x>=84 && x<92) begin char_index=28; if(font_row[7-(x-84)]) oled_colour=TXT; end // c
        end
        // exp
        else if (curve_mode == 2'b10) begin
            if (x>=20 && x<28) begin char_index=30; if(font_row[7-(x-20)]) oled_colour=TXT; end // e
            if (x>=28 && x<36) begin current_digit=5'd15; rom_row=y; rom_col=x-28; end // ^
            if (x>=36 && x<44) begin char_index=26; if(font_row[7-(x-36)]) oled_colour=TXT; end // a
            if (x>=44 && x<52) begin char_index=49; if(font_row[7-(x-44)]) oled_colour=TXT; end // x
        end
    end

    // =====================================
    // PARAM ROWS a=, b=, c=, x=, y=
    // =====================================
        if (y>=8 && y<16) begin // a=
            if (x<8) begin char_index=26; if(font_row[7-(x)]) oled_colour=TXT; end
            if (x>=10 && x<18) begin current_digit=5'd11; rom_row=y-8; rom_col=x-10; end
            draw_param(x, y, A, 8);
        end
        if (y>=16 && y<24 && showB) begin // b=
            if (x<8) begin char_index=27; if(font_row[7-(x)]) oled_colour=TXT; end
            if (x>=10 && x<18) begin current_digit=5'd11; rom_row=y-16; rom_col=x-10; end
            draw_param(x, y, B, 16);
        end
        if (y>=24 && y<32 && showC) begin // c=
            if (x<8) begin char_index=28; if(font_row[7-(x)]) oled_colour=TXT; end
            if (x>=10 && x<18) begin current_digit=5'd11; rom_row=y-24; rom_col=x-10; end
            draw_param(x, y, C, 24);
        end
        if (y>=39 && y<47) begin // x=
            if (x<8) begin char_index=49; if(font_row[7-(x)]) oled_colour=TXT; end
            if (x>=10 && x<18) begin current_digit=5'd11; rom_row=y-39; rom_col=x-10; end
            draw_value(x, y, stored_x, stored_x_frac, 39, 1,stored_x_neg);
        end
        if (y>=48 && y<56) begin // y=
            if (x<8) begin char_index=50; if(font_row[7-(x)]) oled_colour=TXT; end
            if (x>=10 && x<18) begin current_digit=5'd11; rom_row=y-48; rom_col=x-10; end
            if (curve_mode == 2'b01)
                draw_value_7digit(x, y, stored_y, 48);
            else
                draw_value(x, y, stored_y, stored_y_frac, 48, 1, stored_y_neg);
        end
    
        if (current_digit != 5'd31)
            if (row_data[7-rom_col]) oled_colour = TXT;
    end

    // ================= DRAW PARAM =================
    task draw_param;
        input [6:0] px;
        input [5:0] py;
        input signed [7:0] val;
        input [5:0] y_base;
        begin
            if (px>=20 && px<28) begin
                current_digit = (val<0)?5'd10:5'd31;
                rom_row = py - y_base;
                rom_col = px - 20;
            end
            else if (px>=30 && px<38 && show_digit(val,2)) begin
                current_digit = get_digit(val,2);
                rom_row = py - y_base;
                rom_col = px - 30;
            end
            else if (px>=40 && px<48 && show_digit(val,1)) begin
                current_digit = get_digit(val,1);
                rom_row = py - y_base;
                rom_col = px - 40;
            end
            else if (px>=50 && px<58) begin
                current_digit = get_digit(val,0);
                rom_row = py - y_base;
                rom_col = px - 50;
            end
        end
    endtask

    // ================= DRAW VALUE =================
    task draw_value;
        input [6:0] px;
        input [5:0] py;
        input signed [31:0] int_val;
        input [15:0] frac_val;
        input [5:0] y_base;
        input show_frac;
        input is_neg;
//        reg is_neg;
        reg signed [31:0] abs_int;
    
    begin
        abs_int = (is_neg) ? -int_val : int_val;

        if (px >= 20 && px < 28) begin
            current_digit = (is_neg) ? 5'd10 : 5'd31;
            rom_row = py - y_base;
            rom_col = px - 20;
        end
        else if (px >= 30 && px < 38 && show_digit(abs_int,2)) begin
            current_digit = get_digit(abs_int,2);
            rom_row = py - y_base;
            rom_col = px - 30;
        end
        else if (px >= 40 && px < 48 && show_digit(abs_int,1)) begin
            current_digit = get_digit(abs_int,1);
            rom_row = py - y_base;
            rom_col = px - 40;
        end
        else if (px >= 50 && px < 58) begin
            current_digit = get_digit(abs_int,0);
            rom_row = py - y_base;
            rom_col = px - 50;
        end
        if (show_frac) begin
            if (px >= 59 && px < 67) begin
                current_digit = 5'd17;
                rom_row = py - y_base;
                rom_col = px - 59;
            end
            else if (px >= 68 && px < 76) begin
                current_digit = get_frac_digit(frac_val,2);
                rom_row = py - y_base;
                rom_col = px - 68;
            end
            else if (px >= 77 && px < 85) begin
                current_digit = get_frac_digit(frac_val,1);
                rom_row = py - y_base;
                rom_col = px - 77;
            end
            else if (px >= 86 && px < 94) begin
                current_digit = get_frac_digit(frac_val,0);
                rom_row = py - y_base;
                rom_col = px - 86;
            end
        end
    end
    endtask
    
    task draw_value_7digit;
        input [6:0] px;
        input [5:0] py;
        input signed [31:0] int_val;
        input [5:0] y_base;
    
        reg signed [31:0] abs_int;
    
    begin
        abs_int = (int_val < 0) ? -int_val : int_val;
    
        // SIGN
        if (px >= 20 && px < 28) begin
            current_digit = (int_val < 0) ? 5'd10 : 5'd31;
            rom_row = py - y_base;
            rom_col = px - 20;
        end
    
        // d6 (1,000,000)
        else if (px >= 30 && px < 38 && show_digit(abs_int,6)) begin
            current_digit = get_digit(abs_int,6);
            rom_row = py - y_base;
            rom_col = px - 30;
        end
    
        // d5
        else if (px >= 40 && px < 48 && show_digit(abs_int,5)) begin
            current_digit = get_digit(abs_int,5);
            rom_row = py - y_base;
            rom_col = px - 40;
        end
    
        // d4
        else if (px >= 50 && px < 58 && show_digit(abs_int,4)) begin
            current_digit = get_digit(abs_int,4);
            rom_row = py - y_base;
            rom_col = px - 50;
        end
    
        // d3
        else if (px >= 59 && px < 67 && show_digit(abs_int,3)) begin
            current_digit = get_digit(abs_int,3);
            rom_row = py - y_base;
            rom_col = px - 59;
        end
    
        // d2
        else if (px >= 68 && px < 76 && show_digit(abs_int,2)) begin
            current_digit = get_digit(abs_int,2);
            rom_row = py - y_base;
            rom_col = px - 68;
        end
    
        // d1
        else if (px >= 77 && px < 85 && show_digit(abs_int,1)) begin
            current_digit = get_digit(abs_int,1);
            rom_row = py - y_base;
            rom_col = px - 77;
        end
    
        // d0
        else if (px >= 86 && px < 94) begin
            current_digit = get_digit(abs_int,0);
            rom_row = py - y_base;
            rom_col = px - 86;
        end
    end
    endtask

endmodule