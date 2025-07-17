`timescale 1ns / 1ps


module Top_Fifo_Uart (
    input clk,
    input rst,
    input rx,
    output tx
);

    wire w_bd_tick, w_tx_full, w_tx_empty;
    wire [7:0] w_rx_pop_data, w_tx_push_data, w_rx_data;

    /*uart_controller U_UART (
        .clk(clk),
        .rst(rst),
        //.btn_start(),
        .rx(rx),
        .tx_din(tx_din),
        .tx(tx),
        .rx_done(rx),  //
        .tx_done(),
        .rx_data()  //
    );*/

    baudrate U_BR (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick)
    );

    uart_tx U_TX (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick),
        .start(~w_tx_empty),
        .din(w_tx_push_data),
        .o_tx(tx),
        .o_tx_busy(w_tx_busy),
        .o_tx_done(w_tx_done)
    );

    uart_rx U_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_bd_tick),
        .rx(rx),
        .o_dout(w_rx_data),
        .o_rx_done(w_rx_done)
    );

    fifo U_RX_FIFO (
        .clk(clk),
        .rst(rst),
        .push(w_rx_done),
        .pop(~w_tx_full),
        .push_Data(w_rx_data),
        //.full(),
        .empty(w_rx_empty),
        .pop_data(w_rx_pop_data)
    );

    fifo U_TX_FIFO (
        .clk(clk),
        .rst(rst),
        .push(~w_rx_empty),
        .pop(~w_tx_busy),
        .push_Data(w_rx_pop_data),
        .full(w_tx_full),
        .empty(w_tx_empty),
        .pop_data(w_tx_push_data)
    );

endmodule
