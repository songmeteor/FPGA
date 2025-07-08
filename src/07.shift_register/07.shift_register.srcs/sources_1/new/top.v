`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input btnU,
    input btnD,
    output [15:0] led
    );

    wire        w_tick; 
    wire        w_btnU;
    wire        w_btnD;
    wire [6:0]  w_dout;
    
    my_btn_debounce u1_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btnU),
        .tick(w_tick), 
        .clean_btn(w_btnU)
    );

    my_btn_debounce u2_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btnD),
        .tick(w_tick), 
        .clean_btn(w_btnD)
    );

    tick_generator u_tick_generator(    
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    shift_register u_shift_register(
        .clk(clk),
        .reset(reset),
        .btnU(w_btnU),
        .btnD(w_btnD),
        .dout(w_dout)
        );

    assign led[0] = (w_dout == 7'b1010111) ? 1 : 0;
    assign led[1] = (w_dout[0] == 1) ? 1 : 0;
    assign led[2] = (w_dout[1] == 1) ? 1 : 0;
    assign led[3] = (w_dout[2] == 1) ? 1 : 0;
    assign led[4] = (w_dout[3] == 1) ? 1 : 0;
    assign led[5] = (w_dout[4] == 1) ? 1 : 0;
    assign led[6] = (w_dout[5] == 1) ? 1 : 0;
    assign led[7] = (w_dout[6] == 1) ? 1 : 0;

endmodule
