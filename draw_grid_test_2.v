`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 19:47:43
// Design Name: 
// Module Name: draw_grid
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


module draw_grid_test_2(
    input basys_clock,
    input quad_zoom_fit_sw,
    input trigo_toggle_sw,
    input graph_mode_sw,
    input [12:0] pixel_index_in,
    input frame_begin_in,                  
    input [1:0] curve_type,                    //rename this for graph mode selection from Keypad module
    input signed [7:0] coefficient_a,
    input signed [7:0] coefficient_b,
    input signed [7:0] coefficient_c,
    input graph_enable,
    output [15:0] oled_colour,
    output [3:0] led_scroll,
    // --- Outputs for External Display Integration -------------------------------------------------------------------------------
    output reg [1:0] out_mode,           // Current function: 00=Trigo, 01=Quad, 10=Exp
    output reg signed [31:0] out_true_x, // Mathematical X-coordinate
    output reg signed [47:0] out_true_y, // Mathematical Y-coordinate (Raw from BRAM)
    output reg out_val_valid,            // High when the output x and y are valid (i.e cursor is tracing and the module is in TRACING MODE)
    //-----------------------------------------------------------------------------------------------------------------------------------
    inout PS2Clk,
    inout PS2Data
);  
    wire clk_6p25M;
    wire clk_25M;
    wire clk_1k;
    
    //OLED registers and wires
    reg [15:0] pixel_colour = 16'h0000;
    wire frame_begin;
    wire [12:0] pixel_index;
//    wire sending_pixels;
//    wire sample_pixels;
    //Setting coordinates for pixel_index
    reg [6:0] origin_x = 48;                    //point of reference for the grid
    reg [5:0] origin_y = 32;
    reg signed [8:0] initial_oled_left_x = -48;  // 9-bit to cover -192 to +191
    reg signed [7:0] inital_oled_top_y = 32;   // 8-bit to cover -96 to +95
    wire [6:0] oled_x;
    wire [5:0] oled_y;
    wire signed [8:0] world_x;
    wire signed [7:0] world_y;
    assign pixel_index = pixel_index_in;
    assign oled_x = pixel_index % 96;
    assign oled_y = pixel_index / 96;
    assign oled_colour = pixel_colour;
    assign frame_begin = frame_begin_in;
    
    //Mouse
    wire [11:0] mouse_x_pos;
    wire [11:0] mouse_y_pos;
    wire [3:0] mouse_scroll_acc;        //user scrolls up --> +1,  0 -> 7 -> -8 -> -1 -> 0
                                        //user scrolls down --> -1,  0 -> -1 -> -8 -> 7 -> 0
    assign led_scroll = mouse_scroll_acc;
        
    //Declarations for writing to and reading from BRAM that stores the result of each of the current chosen function
    wire we_a_1;
    wire [8:0] addr_a_1;
    wire signed [47:0] din_a_1;       //BRAM stores 48 bits signed integers. Q32.16 for quadratic output, Q8.8 for trigo output
    wire [8:0] addr_b_1;               
    wire signed [47:0] y_stored_1;    //Output from BRAM
    wire we_a_2;
    wire [8:0] addr_a_2;
    wire signed [47:0] din_a_2;       //BRAM stores 48 bits signed integers. Q32.16 for quadratic output, Q8.8 for trigo output
    wire [8:0] addr_b_2;               
    wire signed [47:0] y_stored_2;    //Output from BRAM
    
    //wires and regs declaration for quadratic function module
    localparam quad_x = 1;
    localparam quad_a = 1;
    localparam quad_b = 1;
    localparam quad_c = 1;
    wire signed [47:0] quad_y;
    wire [32:0] quad_y_int;
    wire [15:0] quad_y_frac;
    
    //wires and regs for exponential function module
    wire signed [47:0] exp_y_48bit;
    
    //ZOOM FIT registers
    reg signed [47:0] running_min, running_max;
    reg signed [47:0] latched_min, latched_max;

    
    //Formula for plotting a curve on the grid:
    //Cordic function output is Q8.8, right shift by 8 and multiply by scaling factor,
    //equivalent to dividing by 256 and multiplying by scaling factor, ---> 15/256*cordic_output ---> sine/cosine function with 15 as amplitude

    //BLOCK to choose curve drawing mode TRIGO/QUADRATIC/EXPONENTIAL
    localparam TRIGO = 2'b00;
    localparam QUAD = 2'b01;
    localparam EXP = 2'b10;
    reg [1:0] current_curve_mode = 2'b00;
    always @(posedge basys_clock) begin
        if (curve_type == 2'b00 || curve_type == 2'b11) begin
            current_curve_mode <= TRIGO;
        end
        else begin
            current_curve_mode <= curve_type;
        end
    end

    //Create FSM for changing between DRAG and TRACING state 
    //DRAG state: where the user uses the mouse to drag the grid and curve around by left clicking the mouse and dragging it around
    //TRACING state: User is not able to drag the curve and grid around. The last frame in the DRAG state is fixed in this state.
    //               The cursor in this state is used to trace the curve corresponding to the cursors current x position. 
    //               The cursor movement is constraint to the curve.
    
    localparam DRAG = 1'b0;
    localparam TRACING = 1'b1;
    reg grid_drawing_current_state = DRAG;
    reg grid_drawing_next_state;
    wire grid_drawing_fsm_input;
    wire grid_drawing_fsm_output;
    assign grid_drawing_fsm_input = graph_mode_sw;
    
    always @(*) begin
        case(grid_drawing_current_state)
            DRAG: grid_drawing_next_state <= (grid_drawing_fsm_input) ? TRACING : DRAG;
            TRACING: grid_drawing_next_state <= (grid_drawing_fsm_input) ? TRACING : DRAG;
        endcase  
    end
    
    always @(posedge basys_clock) begin
        grid_drawing_current_state <= grid_drawing_next_state;
    end
    
    assign grid_drawing_fsm_output = grid_drawing_current_state;
    
    
    //when the user presses the mouse left button, save the instantaneous position of the coordinates only at this edge, 
    //subsequent mouse movements will be relative to this position
    wire mouse_click_left;
    reg mouse_click_left_prev;
    reg mouse_click_left_curr;
    reg [11:0] mouse_pan_x_pos;
    reg [11:0] mouse_pan_y_pos;
    reg signed [13:0] mid_shift_x = 0;
    reg signed [13:0] mid_shift_y = 0;
    reg signed [13:0] final_shift_x = 0;
    reg signed [13:0] final_shift_y = 0;
    wire signed [12:0] mouse_relative_x_pos;
    wire signed [12:0] mouse_relative_y_pos;
    assign mouse_relative_x_pos = $signed({1'b0, mouse_x_pos}) - $signed({1'b0, mouse_pan_x_pos});
    assign mouse_relative_y_pos = $signed({1'b0, mouse_y_pos}) - $signed({1'b0, mouse_pan_y_pos});
    
    wire signed [13:0] new_final_x;
    wire signed [13:0] new_final_y;
    assign new_final_x = final_shift_x + mid_shift_x;
    assign new_final_y = final_shift_y + mid_shift_y;
    // 2. Map this to where the screen "starts" in the BRAM
    // Based on your world_x math, let's find the window start index
    wire signed [13:0] proposed_start_x = $signed({5'b0, initial_oled_left_x}) 
                                           - $signed(final_shift_x) 
                                           - $signed(mouse_relative_x_pos) 
                                           + 14'sd195;
                                           
    wire signed [13:0] proposed_start_y =  $signed(final_shift_y) 
                                          + $signed(mouse_relative_y_pos);
             
    always @(posedge basys_clock) begin
        if (grid_drawing_fsm_output == DRAG) begin
            mouse_click_left_curr <= mouse_click_left;
            mouse_click_left_prev <= mouse_click_left_curr;
        end
        else begin
            mouse_click_left_curr <= 0;
            mouse_click_left_prev <= 0;
        end
        
        if (grid_drawing_fsm_output == DRAG) begin
            if (mouse_click_left_curr == 1 && mouse_click_left_prev == 0) begin
                mouse_pan_x_pos <= mouse_x_pos - mid_shift_x[11:0];
                mouse_pan_y_pos <= mouse_y_pos - mid_shift_x[11:0];
                mid_shift_x <= 0;
                mid_shift_y <= 0;
            end
            else if (mouse_click_left_curr == 1 && mouse_click_left_prev == 1) begin
                // 1. Calculate where the window would START if we allowed this move
                // current_window_start = cam_x_latched - (final_shift_x + mouse_relative_x_pos) + 195
            
                // 2. Clamp mid_shift_x so that proposed_start stays between 0 and 288
                if (proposed_start_x < 0) begin
                    // Force mid_shift_x to the value that results in exactly Index 0
                    mid_shift_x <= $signed({4'b0, initial_oled_left_x}) + 13'sd195 - final_shift_x;
                end 
                else if (proposed_start_x > 288) begin
                    // Force mid_shift_x to the value that results in exactly Index 288
                    mid_shift_x <= $signed({4'b0, initial_oled_left_x}) + 13'sd195 - 13'sd288 - final_shift_x;
                end 
                else begin
                    // Inside boundaries: movement is free
                    mid_shift_x <= mouse_relative_x_pos;
                end
                
                // Clamp mid_shift_y so that proposed_start stays between 0 and 288
                if (proposed_start_y < -13'sd64) begin
                    // Stick at top boundary: solve for mid_shift_y where proposed is exactly -64
                    mid_shift_y <= -13'sd64 - final_shift_y;
                end
                else if (proposed_start_y > 13'sd64) begin
                    // Stick at bottom boundary: solve for mid_shift_y where proposed is exactly 64
                    mid_shift_y <= 13'sd64 - final_shift_y;
                end
                else begin
                    mid_shift_y <= mouse_relative_y_pos;
                end
            end
            
            else if (mouse_click_left_curr == 0 && mouse_click_left_prev == 1) begin
                // Clamp on commit
                final_shift_x <= new_final_x;
                final_shift_y <= new_final_y;
                mid_shift_x <= 0;
                mid_shift_y <= 0;
            end
        end
    end
    
    reg signed [13:0] final_shift_x_25M, mid_shift_x_25M;
    reg signed [13:0] final_shift_y_25M, mid_shift_y_25M;
    
    always @(posedge clk_25M) begin
        final_shift_x_25M <= final_shift_x;
        mid_shift_x_25M   <= mid_shift_x;
        final_shift_y_25M <= final_shift_y;
        mid_shift_y_25M   <= mid_shift_y;
    end
    
    //global world x and y coordinates, these are the actual world coordinates that each of the oled pixels are 
    //mapped to within the range defined by us
    assign world_x = (pixel_index % 96) + initial_oled_left_x - final_shift_x_25M - mid_shift_x_25M;
    assign world_y = -(pixel_index / 96) + inital_oled_top_y + final_shift_y_25M + mid_shift_y_25M;

    //Next state generation circuit for zooming logic
//    reg zoom_y_btn_curr, zoom_y_btn_next;
//    reg [2:0] zoom_y_mode = 3;
//    always @ (posedge basys_clock) begin
//        zoom_y_btn_next <= btnL;
//        zoom_y_btn_curr <= zoom_y_btn_next;
        
//        if (zoom_y_btn_next == 1'b1 && zoom_y_btn_curr == 1'b0) begin
//            if (zoom_y_mode == 5) begin
//                    zoom_y_mode <= 0;
//                end
//                else begin
//                    zoom_y_mode <= zoom_y_mode + 1;
//                end
//        end
//    end 

    // Registers for edge detection
    wire mouse_click_right;
    reg mouse_click_right_curr, mouse_click_right_prev;
    reg [2:0] zoom_y_mode = 3;
//    assign led_mouse[1] = mouse_click_left;
//    assign led_mouse[0] = mouse_click_right;
    
    always @ (posedge basys_clock) begin
        // Synchronize and detect edge
        mouse_click_right_curr <= mouse_click_right;
        mouse_click_right_prev <= mouse_click_right_curr;
        
        // Rising edge detection: Current is 1, Previous was 0
        if (mouse_click_right_curr == 1'b1 && mouse_click_right_prev == 1'b0) begin
            if (zoom_y_mode == 5) begin
                zoom_y_mode <= 0; // Loop back to 0.125x
            end
            else begin
                zoom_y_mode <= zoom_y_mode + 1;
            end
        end
    end
    
    //Zooming logic for grid Y-axis (zooming states)
    localparam zoom_y_0p125 = 0;
    localparam zoom_y_0p25 = 1;
    localparam zoom_y_0p5 = 2;
    localparam zoom_y_1 = 3;
    localparam zoom_y_2 = 4;
    localparam zoom_y_4 = 5;
    
    reg signed [6:0] grid_y_sf;                 //6 bits to accomodate up to maximum 40

    //counter for zooming feature (Output)
    always @ (posedge basys_clock) begin
        case(zoom_y_mode) 
            zoom_y_0p125: grid_y_sf <= 8'd1;      //0.125 * 8   
            zoom_y_0p25: grid_y_sf <= 8'd2;      // 0.25 * 8            
            zoom_y_0p5: grid_y_sf <= 8'd4;      // 0.5 * 8
            zoom_y_1: grid_y_sf <= 8'd8;        // 1.0 * 8
            zoom_y_2: grid_y_sf <= 8'd16;       // 2.0 * 8
            zoom_y_4: grid_y_sf <= 8'd32;       // 4.0 * 8
            default: grid_y_sf <= 8'd8;         // 1.0 * 8
        endcase
    end
    
    
    // Registers to track scroll movement (X zooming logic using mouse scroll)
    reg [2:0] zoom_x_mode = 3;
    reg [3:0] scroll_prev;
    
    always @ (posedge basys_clock) begin
        // 1. Capture the previous state of the scroll accumulator
        scroll_prev <= mouse_scroll_acc;
        
        // 2. Detect Scroll UP (Increment zoom mode)
        // Note: The accumulator wraps, but usually by 1 unit per "tick"
        if (mouse_scroll_acc > scroll_prev || (scroll_prev == 4'hF && mouse_scroll_acc == 4'h0)) begin
            if (zoom_x_mode < 5) 
                zoom_x_mode <= zoom_x_mode + 1;
            else
                zoom_x_mode <= 5; // Clamp at max zoom
        end
        
        // 3. Detect Scroll DOWN (Decrement zoom mode)
        else if (mouse_scroll_acc < scroll_prev || (scroll_prev == 4'h0 && mouse_scroll_acc == 4'hF)) begin
            if (zoom_x_mode > 0)
                zoom_x_mode <= zoom_x_mode - 1;
            else
                zoom_x_mode <= 0; // Clamp at min zoom
        end
    end
    
    //Zooming logic for grid X-axis (zooming states)
    localparam zoom_x_0p125 = 0;
    localparam zoom_x_0p25 = 1;
    localparam zoom_x_0p5 = 2;
    localparam zoom_x_1 = 3;
    localparam zoom_x_2 = 4;
    localparam zoom_x_4 = 5;
    reg signed [6:0] grid_x_sf;                 //6 bits to accomodate up to maximum 40

    //counter for zooming feature (Output)
    always @ (posedge basys_clock) begin
        case(zoom_x_mode) 
            zoom_x_0p125: grid_x_sf <= 8'd1;     // 0.125 * 8
            zoom_x_0p25: grid_x_sf <= 8'd2;     // 0.25 * 8
            zoom_x_0p5: grid_x_sf <= 8'd4;      // 0.5 * 8
            zoom_x_1: grid_x_sf <= 8'd8;        // 1.0 * 8
            zoom_x_2: grid_x_sf <= 8'd16;       // 2.0 * 8
            zoom_x_4: grid_x_sf <= 8'd32;       // 4.0 * 8
            default: grid_x_sf <= 8'd8;         // 1.0 * 8
        endcase
    end
    
//    wire signed [13:0] x_scaled;        //12 bits for -4096 to 4096 + 1 sign bit to accomodate x max range from -64*40 to 63*40 before left shifting
//    assign x_scaled = (grid_x_sf * x) >>> 3;
   
    wire signed [47:0] y_ram_curr, y_ram_next;
    reg signed [47:0] y_curr_scaled, y_next_scaled;
        // Check if current pixel y falls in the vertical span between y_cur and y_nxt
    wire signed [47:0] y_low, y_high;
    reg on_curve;
    wire signed [47:0] span;
    wire signed [13:0] addr_b_calc;
    reg [3:0] auto_shift_quad;
    wire signed [47:0] current_range = latched_max - latched_min;
    
    localparam y_scaling_factor = 15;

    assign y_ram_curr = y_stored_1;
    assign y_ram_next = y_stored_2;

    //ZOOM-FIT: Calculating the auto shift value for QUADRATIC FUNCTION
    always @(*) begin
        if      (current_range > 48'sd4000000)  auto_shift_quad = 16;
        else if (current_range > 48'sd1000000)  auto_shift_quad = 14;
        else if (current_range > 48'sd250000)   auto_shift_quad = 11;
        else if (current_range > 48'sd60000)    auto_shift_quad = 9;
        else if (current_range > 48'sd15000)    auto_shift_quad = 7;
        else if (current_range > 48'sd4000)     auto_shift_quad = 5;
        else                                    auto_shift_quad = 2;
    end
    
    always @(*) begin
        if (current_curve_mode == EXP) begin
            // y_ram_curr is Q16.16. 
            // Multiplying by grid_y_sf (which is 8 at 1x zoom) 
            // then shifting right by 16 converts the fixed point to pixel units.
            y_curr_scaled = ($signed(y_ram_curr) * grid_y_sf) >>> 16; 
            y_next_scaled = ($signed(y_ram_next) * grid_y_sf) >>> 16;
            
            // The "on_curve" check
            on_curve = (span <= 16'sd2) && // Tighten span for better line quality
                       ($signed(world_y) >= y_low) && 
                       ($signed(world_y) <= y_high);
        end
        else if (current_curve_mode == QUAD) begin
//            y_curr_scaled = $signed(y_ram_curr) * 1 >>> 7;
//            y_next_scaled = $signed(y_ram_next) * 1 >>> 7;
//            on_curve =  (span <= 16'sd20) && 
//                        (($signed(world_y) * grid_y_sf) >>> 3 >= y_low) && 
//                        (($signed(world_y) * grid_y_sf) >>> 3 <= y_high);
            
            if (quad_zoom_fit_sw == 1) begin
                y_curr_scaled = y_ram_curr >>> auto_shift_quad;
                y_next_scaled = y_ram_next >>> auto_shift_quad;
            end
            else begin
                y_curr_scaled = y_ram_curr >>> auto_shift_quad;
                y_next_scaled = y_ram_next >>> auto_shift_quad;
            end
            on_curve =  ($signed(world_y) >= y_low) && 
                        ($signed(world_y) <= y_high);
        end
        else if (current_curve_mode == TRIGO) begin
            y_curr_scaled = $signed(y_ram_curr) * y_scaling_factor >>> 8;
            y_next_scaled = $signed(y_ram_next) * y_scaling_factor >>> 8;
            on_curve =  (span <= 16'sd20) && 
                        (($signed(world_y) * grid_y_sf) >>> 3 >= y_low) && 
                        (($signed(world_y) * grid_y_sf) >>> 3 <= y_high);
        end
    end

    assign span = y_high - y_low;
    assign y_low = (y_curr_scaled < y_next_scaled) ? y_curr_scaled : y_next_scaled;
    assign y_high = (y_curr_scaled > y_next_scaled) ? y_curr_scaled : y_next_scaled;
    assign addr_b_calc = $signed({3'b000, oled_x})
                       + $signed({initial_oled_left_x[8], initial_oled_left_x})
                       - $signed(final_shift_x_25M)
                       - $signed(mid_shift_x_25M)
                       + 14'sd195;
    assign addr_b_1 = addr_b_calc[8:0] - 1;
    assign addr_b_2 = addr_b_calc[8:0];
    
          
                       
    // TRACING MODE: Get the output from the BRAM at the current cursor x position
    wire signed [8:0] world_mouse_x;
//    wire signed [7:0] oled_mouse_y;
    reg signed [47:0] mouse_tracing_world_y; // This is the corresponding Y output as a function of the current cursor x position
    reg signed [47:0] cursor_current_raw_y_value;

//    always @(posedge clk_25M) begin
//        if (world_mouse_x == world_x) begin
//            mouse_tracing_world_y <= y_curr_scaled;
//            cursor_current_raw_y_value <= y_ram_curr;   //current y value to be directly used by the display modules to display the digits
//        end
//    end

    //-----------------------------------------------------------------------
    reg [1:0] current_curve_mode_prev_25M;
    always @(posedge clk_25M) begin
        current_curve_mode_prev_25M <= current_curve_mode;
    end

    always @(posedge clk_25M) begin
        // Reset the latch when mode changes to flush the stale value
        if (current_curve_mode != current_curve_mode_prev_25M) begin
            mouse_tracing_world_y <= 48'sd0;
        end
        else if (world_mouse_x == world_x) begin
            mouse_tracing_world_y <= y_curr_scaled;
            cursor_current_raw_y_value <= y_ram_curr;
        end
    end
    
    assign world_mouse_x = $signed({1'b0, mouse_x_pos}) + initial_oled_left_x - final_shift_x - mid_shift_x;
//    assign oled_mouse_y = -($signed(mouse_tracing_world_y[7:0]) <<< 3) / $signed({1'b0, grid_y_sf})
//                            + inital_oled_top_y + final_shift_y 
//                            + mid_shift_y;
                            
    //------------------------------------------------------------------------------
    // Use full 48-bit value, not truncated [7:0]
    wire signed [55:0] oled_mouse_y_unclamp;
    wire signed [7:0] oled_mouse_y;
    
    assign oled_mouse_y_unclamp = 
        -($signed(mouse_tracing_world_y) <<< 3) / $signed({1'b0, grid_y_sf})
        + $signed({1'b0, inital_oled_top_y})
        + $signed(final_shift_y)
        + $signed(mid_shift_y);
    
    // Clamp to [0, 63]
    assign oled_mouse_y = (oled_mouse_y_unclamp < 0)  ? 8'd0  :
                          (oled_mouse_y_unclamp > 63) ? 8'd63 :
                          oled_mouse_y_unclamp[7:0];


    //GRID DRAWING BLOCK
    always @(posedge clk_25M) begin
        if (on_curve) begin
            pixel_colour <= 16'hf800; //red colour for curve
        end
        else if (world_x == 0 || world_y == 0) begin
            pixel_colour <= 16'h0000;
        end
        else if (world_x % 4 == 0 || world_y % 4 == 0) begin
            pixel_colour <= 16'h530d;
        end
        else begin
            pixel_colour <= 16'hffff;
        end
        
        if (grid_drawing_fsm_output == DRAG) begin
            //Draw the freely moving cursor in DRAG mode
            if ((oled_x - mouse_x_pos)**2 + (oled_y - mouse_y_pos) **2 <= 9 ) begin
                pixel_colour <= 16'hFE26;
            end
        end
        else if (grid_drawing_fsm_output == TRACING) begin
            //cursor is constraint to the curve
            if ((oled_x - mouse_x_pos)**2 + (oled_y - oled_mouse_y) **2 <= 9 ) begin
                pixel_colour <= 16'hFE26;
            end
        end
    end
    
    reg [8:0] function_step_count = 9'd497;
    reg we_pipeline [0:15];
    reg [8:0] addr_pipeline [0:15];
    integer k;
    wire signed [15:0] sine_output;
    wire signed [15:0] cosine_output;
    
    integer j;
    initial begin
        for (j = 0; j < 16; j = j + 1) begin
            we_pipeline[j] = 1'b0;
            addr_pipeline[j] = 9'd0;
        end
    end
    
    // Pipeline shift register for cordic inputs to wait 15 cycles before the first data is ready
    always @(posedge basys_clock) begin
        we_pipeline[0]   <= 1'b1;
        addr_pipeline[0] <= function_step_count;
        for (k = 1; k < 16; k = k + 1) begin
            we_pipeline[k]   <= we_pipeline[k-1];
            addr_pipeline[k] <= addr_pipeline[k-1];
        end
    end
    
    reg bram_filling = 0;
    reg frame_begin_s1, frame_begin_s2;
    
    always @(posedge basys_clock) begin
        frame_begin_s1 <= frame_begin;
        frame_begin_s2 <= frame_begin_s1;
    end
    
    // Use frame_begin_s2 instead of frame_begin
    always @(posedge basys_clock) begin
        if (frame_begin_s2) begin
            bram_filling <= 1;
        end
        else if (function_step_count == 398) begin
            bram_filling <= 0;
        end
    end
    
    assign we_a_1 = (current_curve_mode == EXP) ? (bram_filling && function_step_count <= 383):
                  (current_curve_mode == QUAD) ? (bram_filling && function_step_count <= 383):
                  (we_pipeline[15] & bram_filling);
    assign we_a_2 = we_a_1;
    assign addr_a_1 = (current_curve_mode == EXP)? function_step_count : 
                    (current_curve_mode == QUAD)? function_step_count : 
                    addr_pipeline[15];
    assign addr_a_2 = addr_a_1;
    assign din_a_1 = (current_curve_mode == EXP)? exp_y_48bit: 
                    (current_curve_mode == QUAD)? quad_y: 
                    (trigo_toggle_sw)? {{32{cosine_output[15]}},cosine_output} : 
                    {{32{sine_output[15]}},sine_output};
    assign din_a_2 = din_a_1;

    always @ (posedge basys_clock) begin
        if (frame_begin_s2)
            function_step_count <= 0;
        else if (bram_filling)
            function_step_count <= function_step_count + 1;
    end
    
    //ZOOM FIT
    //Block to find out the maximum and minimum values within the the BRAM index range to determine an appropriaate scaling factor for ZOOM FIT.
    always @(posedge basys_clock) begin
        if (frame_begin_s2) begin
            // Reset to extreme values so the first data point always overrides them
            running_min <= 48'sh7FFFFFFFFFFF; 
            running_max <= 48'sh800000000000;
        end else if (bram_filling) begin
            // Track the range as we write to BRAM
            if (din_a_1 < running_min) running_min <= din_a_1;
            if (din_a_1 > running_max) running_max <= din_a_1;
        end
        
        // Latch the values once the BRAM write cycle is complete
        if (function_step_count == 384) begin
            latched_min <= running_min;
            latched_max <= running_max;
        end
    end    
    
    wire signed [15:0] angle_input;
    wire signed [15:0] quad_input;
    wire signed [15:0] exp_input;
    
    // 1. Capture the multiplier from switches (e.g., using sw_high[15:12])
    // We add 1 to the switch value so 0000 = 1, and we can cap it at 10.
    reg [3:0] trig_a_from_keypad = 0;
    always @(posedge basys_clock) begin
        if (graph_enable) begin
            trig_a_from_keypad <= coefficient_a[3:0];
        end
    end
    wire [3:0] trig_a = (trig_a_from_keypad > 4'd9) ? 4'd10 : (trig_a_from_keypad);  
    //when cordic_input_cnt == 0, x input == -48 * 0.1, 
    // 2*pi in Q8.8 = 1608
    // For N cycles across 96 pixels, each pixel step = N * 2pi / 96
    // e.g. 2 cycles: step = 2 * 1608 / 96 = 33 (in Q8.8)
    reg signed [15:0] angle_accumulator = -16'sd804; // start at -pi
    wire signed [15:0] trigo_base_step = (16'sd67 * grid_x_sf) >>> 3;
    wire signed [15:0] angle_step = trigo_base_step * trig_a;         // 2 cycles across screen
    
    always @(posedge basys_clock) begin
        if (function_step_count == 0)
           angle_accumulator <= -$signed(16'sd192) * angle_step;
        else begin
            angle_accumulator <= angle_accumulator + angle_step;
            // Wrap if it exceeds pi
            if (angle_accumulator + angle_step > 16'sd804)
                angle_accumulator <= angle_accumulator + angle_step - 16'sd1608;
        end
    end

    wire signed [7:0] a_in; //using switches to input quadratic coefficients for testing
    assign angle_input = angle_accumulator;
//    assign a_in = sw_high[15:11];
    assign quad_input = $signed({1'b0,function_step_count}) - 192; //only integer inputs, no fixed point inputs
    

    //---------------------------------------------------------------------------------------------------------------------------------------------
    // 1. Define the math wire (Place this above the always block)
    wire signed [31:0] trigo_x_val = $signed(world_mouse_x) * $signed(trigo_base_step);
    
    // --- New Registers for the Pipeline ---
        reg signed [31:0] pipe_raw_angle;
        reg signed [31:0] pipe_out_x; 
        reg signed [15:0] pipe_mod_result;
        reg signed [15:0] pipe_positive_wrapped;
        reg signed [15:0] tracing_final_angle_reg;
        wire signed [15:0] sine_trace, cosine_trace;
        
        always @(posedge basys_clock) begin
            // Stage 1: Multiplication (Sync X and Angle)
            pipe_raw_angle <= $signed(world_mouse_x) * $signed(trigo_base_step) * $signed({12'b0, trig_a});
            pipe_out_x     <= $signed(world_mouse_x) * $signed(trigo_base_step) * $signed({1'b0, trig_a});
        
            // This is the standard hardware trick for a "True Modulo"
            pipe_mod_result <= (pipe_raw_angle % 16'sd1608);
        
            if ((pipe_raw_angle % 16'sd1608) < 0)
                pipe_positive_wrapped <= (pipe_raw_angle % 16'sd1608) + 16'sd1608;
            else
                pipe_positive_wrapped <= (pipe_raw_angle % 16'sd1608);
                
            // Stage 4: Feed the 0...1607 value to the normalizer
            tracing_final_angle_reg <= pipe_positive_wrapped;
    
        end
        
        top_cordic_2 trigo_func_trace (
            .clk(basys_clock),
            .angle(tracing_final_angle_reg), // The wrap-corrected angle
            .sine(sine_trace),
            .cosine(cosine_trace)
        );
    //---------------------------------------------------------------------------------------------------------------
    
 
    reg signed [7:0] quad_a_from_keypad = 0;
    reg signed [7:0] quad_b_from_keypad = 0;
    reg signed [7:0] quad_c_from_keypad = 0;
    
    always @(posedge basys_clock) begin
        if (graph_enable) begin
           quad_a_from_keypad <= coefficient_a;
           quad_b_from_keypad <= coefficient_b;
           quad_c_from_keypad <= coefficient_c;
        end
    end
    
    wire signed [15:0] quad_x_trace;
    wire signed [47:0] quad_y_trace;
    wire signed [31:0] quad_y_int_trace;
    wire signed [15:0] quad_y_frac_trace;
    assign quad_x_trace = $signed(world_mouse_x);
    
    //Instantiate the quadratic function block for TRACING
    quadratic_func quad_func_trace (.x(quad_x_trace),
    .a(quad_a_from_keypad),
    .b(quad_b_from_keypad),
    .c(quad_c_from_keypad),
    .y(quad_y_trace),
    .y_int(quad_y_int_trace),
    .y_frac(quad_y_frac_trace));
    
    //-------------------------------------------------------------------------------------------------------
    // 2. The Integration Interface (IMPORTANT FOR DISPLAY LOGIC)
    //------------------------------------------------------------------------------------------------------
    always @(posedge clk_25M) begin
        out_mode <= current_curve_mode;
        
        // Check if we are in Tracing mode and the scanline matches the cursor
        if (grid_drawing_fsm_output == TRACING && (world_mouse_x == world_x)) begin
            out_val_valid <= 1'b1;
            
            case(current_curve_mode)
                TRIGO: begin
                    // X: [31:0] | Fractional Bits: 8 bits (Q24.8)
                    // In decimal, X ranges from -50.25 rad to 53.90 rad
                    out_true_x <= trigo_x_val; 
                    // Y: [47:0] | FB: 8 bits (Q40.8)
                    //In decimal, X ranges from -1.00 to 1.00
                    if (trigo_toggle_sw == 1) begin
                        out_true_y <= { {32{cosine_trace[15]}}, cosine_trace }; // Sign-extended Cosine
                    end
                    else begin
                        out_true_y <= { {32{sine_trace[15]}}, sine_trace };   // Sign-extended Sine
                    end
                end
                
                QUAD: begin
                    // X: [31:0] | Fractional Bits: 0 bits (Integer)
                    // In decimal, X ranges from (-191 to -192) (integer only)
                    out_true_x <= {{23{world_mouse_x[8]}}, world_mouse_x}; 
                    // Y: [47:0] | Fractional Bits: 16 bits (Q32.16)
                    // In decimal, X ranges from -50(192)**2 -100(192) - 200 = -1862600 to +1862600 
                    out_true_y <= quad_y_trace; 
                end
                
                EXP: begin
                    // X: [31:0] | Fractional Bits: 8 bits (Q24.8) - Applies 0.01 scaling logic
                    // In decimal, X ranges from -1.91 to 1.91
                    out_true_x <= ($signed(world_mouse_x) <<< 8) / 100; 
                    // Y: [47:0] | Fractional Bits: 16 bits (Q32.16)
                    //In decimal, Y ranges from 0.148 to 6.753
                    out_true_y <= cursor_current_raw_y_value; 
                end
                
                default: begin
                    out_true_x <= 32'sd0;
                    out_true_y <= 48'sd0;
                end
            endcase
        end 
        else begin
            // Reset signals when not actively tracing the cursor
            out_val_valid <= 1'b0;
            out_true_x    <= 32'sd0;
            out_true_y    <= 48'sd0;
        end
    end
//----------------------------------------------------------------------------------------------------------------

    //Instantiate the vairable clock module
    variable_clock vc_6p25M (basys_clock, 7, clk_6p25M);
    variable_clock vc_25M (basys_clock, 3, clk_25M);
    variable_clock vc_1k(basys_clock, 49999, clk_1k);

    //Instantiate the trigonometric function block
    top_cordic trigo_func (.clk(basys_clock),.angle(angle_input),.sine(sine_output),.cosine(cosine_output));

    //Instantiate the quadratic function block for CURVE DRAWING
    quadratic_func quad_func (.x(quad_input),.a(quad_a_from_keypad),.b(quad_b_from_keypad),.c(quad_c_from_keypad),.y(quad_y),.y_int(quad_y_int),.y_frac(quad_y_frac));
        
    reg signed [7:0] exp_a_from_keypad = 0;
    always @(posedge basys_clock) begin
        if (graph_enable) begin
            exp_a_from_keypad <= coefficient_a;
        end
    end
    //Instantiate the exponential function block
    Exponential_Graph exp_func (
        .step_index(function_step_count),
        .a_val(exp_a_from_keypad), // Example: using 3 switches to set 'a'
        .result(exp_y_48bit)
    );

    //Instantiate the Mouse Cursor Module
    Mouse_Cursor mouse_cursor (.basys_clock(basys_clock),.RST(0),
                                .mouse_x_pos(mouse_x_pos),.mouse_y_pos(mouse_y_pos),.mouse_scroll_acc(mouse_scroll_acc),
                                .mouse_click_left_output(mouse_click_left),.mouse_click_right_output(mouse_click_right),
                                .PS2Clk(PS2Clk),.PS2Data(PS2Data));
    
    //Instantiate the BRAM for storing y-values for each x-value
    dual_port_bram BRAM_1 (.clk_a(basys_clock),.we_a(we_a_1),.addr_a(addr_a_1),.din_a(din_a_1),.clk_b(clk_25M),.addr_b(addr_b_1),.dout_b(y_stored_1));
    dual_port_bram BRAM_2 (.clk_a(basys_clock),.we_a(we_a_2),.addr_a(addr_a_2),.din_a(din_a_2),.clk_b(clk_25M),.addr_b(addr_b_2),.dout_b(y_stored_2));
    
endmodule
