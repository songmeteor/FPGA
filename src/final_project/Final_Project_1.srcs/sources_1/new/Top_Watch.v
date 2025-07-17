`timescale 1ns / 1ps


module Top_Watch (
    input        clk,
    input        rst,
    input        btnL_clear,
    input        btnR_runstop,
    input        btnU_Up,
    input        btnD_Down,
    input        sw_mode,
    input        sw_mode_1,
    input        sw_mode_2,
    input        up,
    input        down,
    input        right,
    input        left,
    input        run,
    input        stop,
    input        clear,
    input        time_mode,
    input        reset,
    input        func_mode,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [5:0] led
);

    wire [7:0] sw_fnd_data, w_fnd_data;
    wire [3:0] sw_fnd_com, w_fnd_com;
    wire sw_btnL, w_btnL, sw_btnR, w_btnR;
    wire sw_btnD, w_btnD;
    wire w_sw_mode, w_sw_mode_1;

    assign w_sw_mode = (sw_mode) | time_mode;
    assign w_sw_mode_1 = (sw_mode_1) | func_mode;

    assign sw_btnD  = (((!w_sw_mode_1) & (btnD_Down)) | down) ? 1 : 0;
    assign w_btnD   = (((w_sw_mode_1) & (sw_mode_2) & (btnD_Down)) | down) ? 1 : 0;
    assign sw_btnL  = (((!w_sw_mode_1) & (btnL_clear)) | clear) ? 1 : 0;
    assign w_btnL   = (((w_sw_mode_1) & (sw_mode_2) & (btnL_clear)) | left) ? 1 : 0;
    assign sw_btnR  = (((!w_sw_mode_1) & (btnR_runstop)) | run | stop) ? 1 : 0;
    assign w_btnR   = (((w_sw_mode_1) & (sw_mode_2) & (btnR_runstop)) | right) ? 1 : 0;

    assign fnd_com  = (w_sw_mode_1) ? w_fnd_com : sw_fnd_com;
    assign fnd_data = (w_sw_mode_1) ? w_fnd_data : sw_fnd_data;

    assign led[0]   = ((!w_sw_mode) & (!w_sw_mode_1)) ? 1 : 0;
    assign led[1]   = ((w_sw_mode) & (!w_sw_mode_1)) ? 1 : 0;
    assign led[2]   = ((!w_sw_mode) & (w_sw_mode_1) & (!sw_mode_2)) ? 1 : 0;
    assign led[3]   = ((w_sw_mode) & (w_sw_mode_1) & (!sw_mode_2)) ? 1 : 0;
    assign led[4]   = ((!w_sw_mode) & (w_sw_mode_1) & (sw_mode_2)) ? 1 : 0;
    assign led[5]   = ((w_sw_mode) & (w_sw_mode_1) & (sw_mode_2)) ? 1 : 0;

    stopwatch U_SW (
        .clk(clk),
        .rst(rst | reset),
        .btnL_clear(sw_btnL),
        .btnR_runstop(sw_btnR),
        .btnD_Down(sw_btnD),
        .sw_mode(w_sw_mode),
        .fnd_com(sw_fnd_com),
        .fnd_data(sw_fnd_data)
    );

    Watch U_WT (
        .clk(clk),
        .rst(rst | reset),
        .btnU_Up(btnU_Up | up),
        .btnD_Down(w_btnD),
        .btnL_Left(w_btnL),
        .btnR_Right(w_btnR),
        .sw_mode(w_sw_mode),
        .sw_mode_2(sw_mode_2),
        .fnd_com(w_fnd_com),
        .fnd_data(w_fnd_data)
    );

endmodule
