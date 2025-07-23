`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input RsRx,
    
    output [15:0] led
    );

    wire w_rx_done;
    wire [7:0] w_data_out;
    wire [7:0] w_dout;
    wire w_empty;
    wire w_full;
    wire w_re;

    FIFO u_FIFO (
        .clk(clk),
        .reset(reset),
        .we(w_rx_done),
        .re(w_re),
        .din(w_data_out),

        .dout(w_dout),
        .empty(w_empty),
        .full(w_full)
    );

    uart_rx u_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(RsRx),

        .data_out(w_data_out),
        .rx_done(w_rx_done)
    );    

    led_controller u_led_controller(
        .clk(clk),
        .reset(reset),
        .dout(w_dout),
        .empty(w_empty),

        .led(led),
        .re(w_re)
    );
endmodule
