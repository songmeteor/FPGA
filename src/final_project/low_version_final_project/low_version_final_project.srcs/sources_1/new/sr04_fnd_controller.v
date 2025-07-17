`timescale 1ns / 1ps

module fnd_controllr_sr04 (
    input        clk,
    input        reset,
    input  [10:0] distance,
    input        dist_done,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [3:0] w_bcd;
    wire [3:0] w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] w_min_hour;
    wire [3:0] w_dot_1, w_dot_10, w_dot_100, w_dot_1000;
    wire w_oclk;
    wire [2:0] fnd_sel;
    reg [13:0] distance_reg, distance_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            distance_reg <= 0;
        end else begin
            distance_reg <= distance_next;
        end
    end

    always @(*) begin
        distance_next = distance_reg;
        if (dist_done) begin
            distance_next = distance;
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
    digit_splitter_sr04 #(
        .BIT_WIDTH(11)
    ) U_DS_MIN (
        .time_data(distance_reg),
        .digit_1(w_min_1),
        .digit_10(w_min_10),
        .digit_100(w_hour_1),
        .digit_1000(w_hour_10)
    );

    mux_8x1_sr04 U_MUX_8x1_MIN_HOUR (
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

    dot_make U_DOT (
        .msec(msec),
        .dot_1(w_dot_1),
        .dot_10(w_dot_10),
        .dot_100(w_dot_100),
        .dot_1000(w_dot_1000)
    );

    bcd U_BCD (
        .bcd(w_min_hour),
        .fnd_data(fnd_data)
    );

endmodule


module digit_splitter_sr04 #(
    parameter BIT_WIDTH = 14
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


module mux_8x1_sr04 (
    input  [2:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    input  [3:0] dot_1,
    input  [3:0] dot_10,
    input  [3:0] dot_100,
    input  [3:0] dot_1000,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 4:1 mux , always 
    always @(*) begin
        case (sel)
            3'b000:  r_bcd = digit_1;
            3'b001:  r_bcd = digit_10;
            3'b010:  r_bcd = digit_100;
            3'b011:  r_bcd = digit_1000;
            3'b100:  r_bcd = 4'b1111;
            3'b101:  r_bcd = 4'b1110;
            3'b110:  r_bcd = 4'b1111;
            3'b111:  r_bcd = 4'b1111;
            default: r_bcd = 4'b1010;
        endcase
    end
endmodule