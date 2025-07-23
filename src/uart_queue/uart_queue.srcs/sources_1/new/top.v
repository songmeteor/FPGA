`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input RsRx,
    
    output [15:0] led
    );

    wire w_rx_done;
    wire [7:0] w_data_out;

    FIFO u_FIFO (
        .clk(clk),
        .reset(reset),
        .we(w_rx_done),
        .re(),
        .din(w_data_out),

        output reg [width-1:0] dout,
        .empty,
        .full
    );

    uart_rx u_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(RsRx),

        data_out(w_data_out),
        .rx_done(w_rx_done)
    );    

endmodule
