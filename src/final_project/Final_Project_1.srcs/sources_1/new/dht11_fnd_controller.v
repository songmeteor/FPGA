`timescale 1ns / 1ps

module fnd_controllr_dht11 (
    input        clk,
    input        reset,
    input  [7:0] rh_data,
    input  [7:0] t_data,
    input        dht11_done,
    input        sw0,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [3:0] w_bcd;
    wire [3:0] w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] w_t_1, w_t_10, w_t_100, w_t_1000;
    wire [3:0] w_min_hour, w_sec_msec;
    wire [3:0] w_dot_1, w_dot_10, w_dot_100, w_dot_1000;
    wire w_oclk;
    wire [2:0] fnd_sel;
    reg [7:0] rh_data_reg, rh_data_next, t_data_reg, t_data_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            rh_data_reg <= 0;
            t_data_reg  <= 0;
        end else begin
            rh_data_reg <= rh_data_next;
            t_data_reg  <= t_data_next;
        end
    end

    always @(*) begin
        rh_data_next = rh_data_reg;
        t_data_next  = t_data_reg;
        if (dht11_done) begin
            rh_data_next = rh_data;
            t_data_next  = t_data;
        end
    end

    // fnd_sel 연결하기.
    clk_div U_CLK_Div (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_oclk)
    );
    counter_8 U_Counter_8 (
        .clk(w_oclk),
        .reset(reset),
        .fnd_sel(fnd_sel)
    );
    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    // ds min
    digit_splitter_dht11 #(
        .BIT_WIDTH(8)
    ) U_DS_RH (
        .time_data(rh_data_reg),
        .digit_1(w_min_1),
        .digit_10(w_min_10),
        .digit_100(w_hour_1),
        .digit_1000(w_hour_10)
    );
    digit_splitter_dht11 #(
        .BIT_WIDTH(8)
    ) U_DS_T (
        .time_data(t_data_reg),
        .digit_1(w_t_1),
        .digit_10(w_t_10),
        .digit_100(w_t_100),
        .digit_1000(w_t_1000)
    );

    mux_8x1 U_MUX_8x1_MIN_HOUR (
        .sel(fnd_sel),
        .digit_1(w_min_1),
        .digit_10(w_min_10),
        .digit_100(w_hour_1),
        .digit_1000(w_hour_10),
        .dot_1(w_dot_1),
        .dot_10(w_dot_10),
        .dot_100(w_dot_100),
        .dot_1000(w_dot_1000),
        .bcd(w_min_hour)
    );

    mux_8x1 U_MUX_8x1_T (
        .sel(fnd_sel),
        .digit_1(w_t_1),
        .digit_10(w_t_10),
        .digit_100(w_t_100),
        .digit_1000(w_t_1000),
        .dot_1(w_dot_1),
        .dot_10(w_dot_10),
        .dot_100(w_dot_100),
        .dot_1000(w_dot_1000),
        .bcd(w_sec_msec)
    );


    dot_make U_DOT (
        .msec(msec),
        .dot_1(w_dot_1),
        .dot_10(w_dot_10),
        .dot_100(w_dot_100),
        .dot_1000(w_dot_1000)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    mux_2x1 U_MUX_2x1 (
        .msec_sec(w_sec_msec),
        .min_hour(w_min_hour),
        .sel(sw0),
        .bcd(w_bcd)
    );

endmodule


module digit_splitter_dht11 #(
    parameter BIT_WIDTH = 8
) (
    input  [BIT_WIDTH-1:0] time_data,
    output [          3:0] digit_1,
    output [          3:0] digit_10,
    output [          3:0] digit_100,
    output [          3:0] digit_1000
);

    assign digit_1 = time_data % 10;
    assign digit_10 = (time_data / 10) % 10;
    assign digit_100 = (time_data / 100) % 10;
    assign digit_1000 = (time_data / 1000) % 10;

endmodule
