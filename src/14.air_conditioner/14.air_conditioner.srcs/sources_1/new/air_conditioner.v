`timescale 1ns / 1ps

module air_conditioner(
    input clk,
    input reset,
    input btnU,
    input btnC,
    input btnD,
    input RsRx,

    output       RSTx,
    output [7:0] seg,
    output [3:0] an,

    inout dht11_data
    );
endmodule
