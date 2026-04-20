`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: font_ROM_module
// Description: 8x8 font ROM, A-Z (0-25), a-z (26-51)
//              Strokes thickened by 1px rightward: row | (row >> 1)
//////////////////////////////////////////////////////////////////////////////////

module font_ROM_module_2 (
    input  [5:0] char_index,  // 0-25: A-Z,  26-51: a-z
    input  [2:0] row,         // Row index 0-7
    output reg [7:0] row_data // 8 pixel bits for that row
);

    always @(*) begin
        row_data = 8'b00000000;

        case (char_index)

            // ----------------
            // Uppercase A-Z
            // ----------------

            6'd0: case(row) // A
                0: row_data = 8'b00111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01111111;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd1: case(row) // B
                0: row_data = 8'b01111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01111110;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd2: case(row) // C
                0: row_data = 8'b00111111;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01100000;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b00111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd3: case(row) // D
                0: row_data = 8'b01111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd4: case(row) // E
                0: row_data = 8'b01111111;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01111110;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd5: case(row) // F
                0: row_data = 8'b01111111;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01111110;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01100000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd6: case(row) // G
                0: row_data = 8'b00111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01101111;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd7: case(row) // H
                0: row_data = 8'b01100011;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01111111;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd8: case(row) // I
                0: row_data = 8'b00111110;
                1: row_data = 8'b00011100;
                2: row_data = 8'b00011100;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00011100;
                5: row_data = 8'b00011100;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd9: case(row) // J
                0: row_data = 8'b00011111;
                1: row_data = 8'b00000110;
                2: row_data = 8'b00000110;
                3: row_data = 8'b00000110;
                4: row_data = 8'b01100110;
                5: row_data = 8'b01100110;
                6: row_data = 8'b00111100;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd10: case(row) // K
                0: row_data = 8'b01100011;
                1: row_data = 8'b01100110;
                2: row_data = 8'b01101100;
                3: row_data = 8'b01111000;
                4: row_data = 8'b01101100;
                5: row_data = 8'b01100110;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd11: case(row) // L
                0: row_data = 8'b01100000;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01100000;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd12: case(row) // M
                0: row_data = 8'b01100011;
                1: row_data = 8'b01110111;
                2: row_data = 8'b01111111;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd13: case(row) // N
                0: row_data = 8'b01100011;
                1: row_data = 8'b01110011;
                2: row_data = 8'b01111011;
                3: row_data = 8'b01101111;
                4: row_data = 8'b01100111;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd14: case(row) // O
                0: row_data = 8'b00111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd15: case(row) // P
                0: row_data = 8'b01111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01111110;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01100000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd16: case(row) // Q
                0: row_data = 8'b00111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01101111;
                5: row_data = 8'b01100110;
                6: row_data = 8'b00111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd17: case(row) // R
                0: row_data = 8'b01111110;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01111110;
                4: row_data = 8'b01101100;
                5: row_data = 8'b01100110;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd18: case(row) // S
                0: row_data = 8'b00111111;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01100000;
                3: row_data = 8'b00111110;
                4: row_data = 8'b00000011;
                5: row_data = 8'b00000011;
                6: row_data = 8'b01111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd19: case(row) // T
                0: row_data = 8'b01111111;
                1: row_data = 8'b00011100;
                2: row_data = 8'b00011100;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00011100;
                5: row_data = 8'b00011100;
                6: row_data = 8'b00011100;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd20: case(row) // U
                0: row_data = 8'b01100011;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd21: case(row) // V
                0: row_data = 8'b01100011;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b00110110;
                6: row_data = 8'b00011100;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd22: case(row) // W
                0: row_data = 8'b01100011;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01111111;
                5: row_data = 8'b01110111;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd23: case(row) // X
                0: row_data = 8'b01100011;
                1: row_data = 8'b00110110;
                2: row_data = 8'b00011100;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00011100;
                5: row_data = 8'b00110110;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd24: case(row) // Y
                0: row_data = 8'b01100011;
                1: row_data = 8'b00110110;
                2: row_data = 8'b00011100;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00011100;
                5: row_data = 8'b00011100;
                6: row_data = 8'b00011100;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd25: case(row) // Z
                0: row_data = 8'b01111111;
                1: row_data = 8'b00000110;
                2: row_data = 8'b00001100;
                3: row_data = 8'b00011000;
                4: row_data = 8'b00110000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            // ----------------
            // Lowercase a-z
            // ----------------

            6'd26: case(row) // a
                0: row_data = 8'b00000000;
                1: row_data = 8'b00111100;
                2: row_data = 8'b00000110;
                3: row_data = 8'b00111110;
                4: row_data = 8'b01100110;
                5: row_data = 8'b01100110;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd27: case(row) // b
                0: row_data = 8'b01100000;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01111110;
                3: row_data = 8'b01110011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd28: case(row) // c
                0: row_data = 8'b00000000;
                1: row_data = 8'b00111110;
                2: row_data = 8'b01100000;
                3: row_data = 8'b01100000;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd29: case(row) // d
                0: row_data = 8'b00000011;
                1: row_data = 8'b00000011;
                2: row_data = 8'b00111111;
                3: row_data = 8'b01100111;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b00111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd30: case(row) // e
                0: row_data = 8'b00000000;
                1: row_data = 8'b00111110;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01111111;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd31: case(row) // f
                0: row_data = 8'b00011110;
                1: row_data = 8'b00110000;
                2: row_data = 8'b00110000;
                3: row_data = 8'b01111110;
                4: row_data = 8'b00110000;
                5: row_data = 8'b00110000;
                6: row_data = 8'b00110000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd32: case(row) // g
                0: row_data = 8'b00000000;
                1: row_data = 8'b00111110;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b00111111;
                5: row_data = 8'b00000011;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd33: case(row) // h
                0: row_data = 8'b01100000;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01111110;
                3: row_data = 8'b01110011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd34: case(row) // i
                0: row_data = 8'b00011100;
                1: row_data = 8'b00000000;
                2: row_data = 8'b00111100;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00011100;
                5: row_data = 8'b00011100;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd35: case(row) // j
                0: row_data = 8'b00000110;
                1: row_data = 8'b00000000;
                2: row_data = 8'b00001110;
                3: row_data = 8'b00000110;
                4: row_data = 8'b00000110;
                5: row_data = 8'b01100110;
                6: row_data = 8'b00111100;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd36: case(row) // k
                0: row_data = 8'b01100000;
                1: row_data = 8'b01100000;
                2: row_data = 8'b01100110;
                3: row_data = 8'b01101100;
                4: row_data = 8'b01111000;
                5: row_data = 8'b01101100;
                6: row_data = 8'b01100110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd37: case(row) // l
                0: row_data = 8'b00111000;
                1: row_data = 8'b00011000;
                2: row_data = 8'b00011000;
                3: row_data = 8'b00011000;
                4: row_data = 8'b00011000;
                5: row_data = 8'b00011000;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd38: case(row) // m
                0: row_data = 8'b00000000;
                1: row_data = 8'b01111110;
                2: row_data = 8'b01111011;
                3: row_data = 8'b01111011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd39: case(row) // n
                0: row_data = 8'b00000000;
                1: row_data = 8'b01111110;
                2: row_data = 8'b01110011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd40: case(row) // o
                0: row_data = 8'b00000000;
                1: row_data = 8'b00111110;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd41: case(row) // p
                0: row_data = 8'b00000000;
                1: row_data = 8'b01111110;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01111110;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01100000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd42: case(row) // q
                0: row_data = 8'b00000000;
                1: row_data = 8'b00111111;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b00111111;
                5: row_data = 8'b00000011;
                6: row_data = 8'b00000011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd43: case(row) // r
                0: row_data = 8'b00000000;
                1: row_data = 8'b01111110;
                2: row_data = 8'b01110011;
                3: row_data = 8'b01100000;
                4: row_data = 8'b01100000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01100000;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd44: case(row) // s
                0: row_data = 8'b00000000;
                1: row_data = 8'b00111111;
                2: row_data = 8'b01100000;
                3: row_data = 8'b00111110;
                4: row_data = 8'b00000011;
                5: row_data = 8'b00000011;
                6: row_data = 8'b01111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd45: case(row) // t
                0: row_data = 8'b00110000;
                1: row_data = 8'b00110000;
                2: row_data = 8'b01111110;
                3: row_data = 8'b00110000;
                4: row_data = 8'b00110000;
                5: row_data = 8'b00110011;
                6: row_data = 8'b00011110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd46: case(row) // u
                0: row_data = 8'b00000000;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01100011;
                5: row_data = 8'b01100111;
                6: row_data = 8'b00111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd47: case(row) // v
                0: row_data = 8'b00000000;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b00110110;
                5: row_data = 8'b00110110;
                6: row_data = 8'b00011100;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd48: case(row) // w
                0: row_data = 8'b00000000;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b01100011;
                4: row_data = 8'b01111111;
                5: row_data = 8'b01110111;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd49: case(row) // x
                0: row_data = 8'b00000000;
                1: row_data = 8'b01100011;
                2: row_data = 8'b00110110;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00011100;
                5: row_data = 8'b00110110;
                6: row_data = 8'b01100011;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd50: case(row) // y
                0: row_data = 8'b00000000;
                1: row_data = 8'b01100011;
                2: row_data = 8'b01100011;
                3: row_data = 8'b00111111;
                4: row_data = 8'b00000011;
                5: row_data = 8'b01100011;
                6: row_data = 8'b00111110;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            6'd51: case(row) // z
                0: row_data = 8'b00000000;
                1: row_data = 8'b01111111;
                2: row_data = 8'b00000110;
                3: row_data = 8'b00011100;
                4: row_data = 8'b00110000;
                5: row_data = 8'b01100000;
                6: row_data = 8'b01111111;
                7: row_data = 8'b00000000;
                default: row_data = 8'b00000000;
            endcase

            default: row_data = 8'b00000000;
        endcase
    end
endmodule