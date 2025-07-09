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
    wire        w_ret;
    wire [6:0]  w_led_out;

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

    fsm u_fsm(
        .clk(clk),
        .reset(reset),
        .btnU(w_btnU),
        .btnD(w_btnD),
        .ret(w_ret),
        .led(w_led_out)
        );

    tick_generator u_tick_generator(    
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );           

    assign led[15] = (w_ret) ? 1 : 0;
    assign led[0] = (w_led_out[0] == 1) ? 1 : 0;
    assign led[1] = (w_led_out[1] == 1) ? 1 : 0;
    assign led[2] = (w_led_out[2] == 1) ? 1 : 0;
    assign led[3] = (w_led_out[3] == 1) ? 1 : 0;
    assign led[4] = (w_led_out[4] == 1) ? 1 : 0;
    assign led[5] = (w_led_out[5] == 1) ? 1 : 0;
    assign led[6] = (w_led_out[6] == 1) ? 1 : 0;     
endmodule
