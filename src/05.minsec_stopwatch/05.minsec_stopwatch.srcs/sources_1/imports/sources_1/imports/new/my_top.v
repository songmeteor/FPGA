`timescale 1ns / 1ps

module my_top(
    input clk,
    input reset,  //          
    input [2:0] btn, //
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0] w_btn_debounce;
    wire [13:0] w_seg_data;
    wire w_tick;

    wire [4:0] w_hour_count;
    wire [5:0] w_min_count;
    wire [12:0] w_sec_count;
    wire [13:0] w_stopwatch_count;
    wire w_clear;
    wire w_run_stop;
    wire w_anim_mode;
    
    stopwatch_core u_stopwatch_core(
        .clear(w_clear),
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .hour_count(w_hour_count),
        .min_count(w_min_count),
        .sec_count(w_sec_count),
        .stopwatch_count(w_stopwatch_count)
    );

    my_btn_debounce u_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btn),
        .tick(w_tick),
        .clean_btn(w_btn_debounce)
    );

    tick_generator u_tick_generator(    
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .input_data(w_seg_data),
        .anim_mode(w_anim_mode), 
        .seg_data(seg),
        .an(an)    
    );

    btn_command_controller u_btn_command_controller(
        .clk(clk),
        .reset(reset),
        .btn(w_btn_debounce),
        .sw(sw),
        .hour_count(w_hour_count),
        .min_count(w_min_count),
        .sec_count(w_sec_count),
        .stopwatch_count(w_stopwatch_count),
        .seg_data(w_seg_data),
        .led(led),
        .clear(w_clear),
        .run_stop(w_run_stop),
        .anim_mode(w_anim_mode)
    );    

endmodule
