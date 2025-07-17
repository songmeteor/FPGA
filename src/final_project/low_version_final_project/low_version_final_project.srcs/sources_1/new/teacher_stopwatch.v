`timescale 1ns / 1ps

module stopwatch (
    input        clk,
    input        rst,
    input        btnL_clear,
    input        btnR_runstop,
    input        btnD_Down,
    input        sw_mode,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;
    wire w_clear, w_runstop;
    wire o_clear, o_runstop, o_down, o_count_down;


    /*btn_debounce U_BTN_DB_CLEAR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL_clear),
        .o_btn(o_clear)
    );
    btn_debounce U_BTN_DB_RUNSTOP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR_runstop),
        .o_btn(o_runstop)
    );

    btn_debounce U_BTN_DB_DOWN (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD_Down),
        .o_btn(o_down)
    );*/

    stopwatch_cu U_StopWatch_CU (
        .clk(clk),
        .rst(rst),
        .i_clear(btnL_clear),
        .i_runstop(btnR_runstop),
        .i_count_down(btnD_Down),
        .o_clear(w_clear),
        .o_runstop(w_runstop),
        .o_count_down(o_count_down)
    );


    stopwatch_dp U_StopWatch_DP (
        .clk(clk),
        .rst(rst),
        .run_stop(w_runstop),
        .count_down(o_count_down),
        .clear(w_clear),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );

    fnd_controllr U_FND_CNTL (
        .clk(clk),
        .reset(rst),
        .sw_mode(sw_mode),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
