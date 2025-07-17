`timescale 1ns / 1ps


module Top_dht11 (
    input clk,
    input rst,
    input btn_start,
    input btn_auto,
    input sw0,
    input sw,
    output [2:0] state_led,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output dht11_valid,
    output led,
    output [7:0] t_data,
    output [7:0] rh_data,
    output data_done,
    inout dht11_io
);
    wire [7:0] w_rh_data, w_t_data;
    wire w_dht11_done;
    wire w_clk, cnt_valid;
    reg c_auto, n_auto;

    assign t_data = w_t_data;
    assign rh_data = w_rh_data;
    assign data_done = w_dht11_done;

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

    dht11_controller U_DHT_CTRL (
        .clk(clk),
        .rst(rst),
        .start(btn_start | cnt_valid),
        .rh_data(w_rh_data),
        .t_data(w_t_data),
        .dht11_done(w_dht11_done),
        .dht11_valid(dht11_valid),  // checksum
        .state_led(state_led),
        .dht11_io(dht11_io)
    );

    fnd_controllr_dht11 U_FND_CTRL (
        .clk(clk),
        .reset(rst),
        .rh_data(w_rh_data),
        .t_data(w_t_data),
        .dht11_done(w_dht11_done),
        .sw0(sw0),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule


module clk_div_1sec (
    input  clk,
    input  reset,
    output o_clk
);

    localparam F_CNT = 100_000_000;

    reg [$clog2(F_CNT)-1:0] r_counter;
    reg r_clk;

    assign o_clk = r_clk;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk     <= 1'b0;
        end else begin
            if (r_counter == F_CNT - 1) begin  // 1khz period
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end

endmodule


module counter_4sec (
    input i_clk,
    input clk,
    input rst,
    output reg cnt_valid
);

    reg [1:0] counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            if (i_clk) begin
                if (counter == 2) begin
                    counter   <= 0;
                    cnt_valid <= 1;
                end else begin
                    counter   <= counter + 1;
                    cnt_valid <= 0;
                end
            end else begin
                cnt_valid <= 0;
            end
        end
    end

endmodule
