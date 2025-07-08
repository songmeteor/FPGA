`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input btnL,
    input btnC,
    input btnR,
    input btnD,
    output [7:0] seg,
    output [3:0] an
    );

    wire w_tick;
    wire w_btnL, w_btnC, w_btnR, w_btnD;
    wire [13:0] w_total;
    wire w_anim_mode;

    fsm u_fsm(
        .clk(clk),
        .reset(reset),
        .btnL(w_btnL),
        .btnC(w_btnC),
        .btnR(w_btnR),
        .btnD(w_btnD),
        .anim_mode(w_anim_mode),
        .total(w_total)
        );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .anim_mode(w_anim_mode),
        .input_data(w_total),
        .seg_data(seg),
        .an(an)     
    );

    my_btn_debounce u1_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btnL),
        .tick(w_tick), 
        .clean_btn(w_btnL)
    );

    my_btn_debounce u2_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btnC),
        .tick(w_tick), 
        .clean_btn(w_btnC)
    );

    my_btn_debounce u3_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btnR),
        .tick(w_tick), 
        .clean_btn(w_btnR)
    );

    my_btn_debounce u4_my_btn_debounce(
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
endmodule
