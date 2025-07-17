`timescale 1ns / 1ps


module Top_sr04 (
    input clk,
    input rst,
    input btn_start,
    input btn_auto,
    input echo,
    input sw,
    output [10:0] distance,
    output dist_done,
    output led,
    output trig,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire w_clk, cnt_valid;
    reg c_auto, n_auto;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_auto <= 0;
        end else begin
            c_auto <= n_auto;
        end
    end

    always @(*) begin
        n_auto = c_auto;
        if (btn_auto) begin
            n_auto = ~c_auto;
        end
    end

    assign led = (sw) ? 1 : 0;

    clk_div_1sec U_DIV_1SEC (
        .clk  (clk & c_auto),
        .reset(rst),
        .o_clk(w_clk)
    );

    counter_4sec U_CNT_4SEC (
        .i_clk(w_clk),
        .clk(clk),
        .rst(rst),
        .cnt_valid(cnt_valid)
    );

    sr04_controller U_SR04_CTRL (
        .clk(clk),
        .rst(rst),
        .start(btn_start | cnt_valid),
        .echo(echo),
        .trig(trig),
        .dist(distance),
        .dist_done(dist_done)
    );

    fnd_controllr_sr04 U_FND_CTRL (
        .clk(clk),
        .reset(rst),
        .distance(distance),
        .dist_done(dist_done),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
