`timescale 1ns / 1ps

module buzzer_controller(
    input       clk,
    input       reset,
    input [9:0] distance,
    input       btnU,
    input       btnL,
    input       btnC,
    input       btnD,

    output reg  buzzer
    );
endmodule
