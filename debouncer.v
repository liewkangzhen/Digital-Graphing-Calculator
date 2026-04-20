`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2026 23:52:26
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk, clk_1kHz,
    input btn,
    output btn_pulse
);

    reg [7:0] btn_debouncer_counter = 0;
    reg btn_sync = 0;
    reg btn_prev = 0;
    reg btn_valid = 0;
    wire btn_pressed;
    reg btn_prev_fast = 0;
    
    always @(posedge clk) begin
        btn_prev_fast <= btn_pressed;
    end
    
    assign btn_pulse = btn_pressed & ~btn_prev_fast;
    
    always @(posedge clk_1kHz) begin
        btn_sync <= btn;
        btn_prev <= btn_sync;
        
        if (btn_debouncer_counter != 0) begin
            btn_debouncer_counter <= btn_debouncer_counter - 1;
            btn_valid <= 0;
        end else begin
            if (btn_sync && ~btn_prev) begin
                btn_valid <= 1;
                btn_debouncer_counter <= 200;
            end else begin
                btn_valid <= 0;
            end
        end
    end
    
    assign btn_pressed = btn_valid;

endmodule
