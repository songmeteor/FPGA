`timescale 1ns / 1ps

module fnd_controllr (
    input        clk,
    input        reset,
    input        sw_mode,
    input  [6:0] msec,
    input  [5:0] sec,
    input  [5:0] min,
    input  [4:0] hour,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [3:0] w_bcd, w_msec_1, w_msec_10, w_sec_1, w_sec_10;
    wire [3:0] w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] w_min_hour, w_msec_sec;
    wire [3:0] w_dot_1, w_dot_10, w_dot_100, w_dot_1000;
    wire w_oclk;
    wire [2:0] fnd_sel;


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

    // ds msec
    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_DS_MSEC (
        .time_data(msec),
        .digit_1  (w_msec_1),
        .digit_10 (w_msec_10)
    );
    // ds sec
    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_SEC (
        .time_data(sec),
        .digit_1  (w_sec_1),
        .digit_10 (w_sec_10)
    );

    // ds min
    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_MIN (
        .time_data(min),
        .digit_1  (w_min_1),
        .digit_10 (w_min_10)
    );
    // ds hour
    digit_splitter #(
        .BIT_WIDTH(5)
    ) U_DS_HOUR (
        .time_data(hour),
        .digit_1  (w_hour_1),
        .digit_10 (w_hour_10)
    );
    mux_2x1 U_MUX_2x1 (
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .sel(sw_mode),
        .bcd(w_bcd)

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

    mux_8x1 U_MUX_8x1 (
        .sel(fnd_sel),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10),
        .digit_100(w_sec_1),
        .digit_1000(w_sec_10),
        .dot_1(w_dot_1),
        .dot_10(w_dot_10),
        .dot_100(w_dot_100),
        .dot_1000(w_dot_1000),
        .bcd(w_msec_sec)
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

endmodule

// mux_2x1 msec_sec, min_hour
module mux_2x1 (
    input  [3:0] msec_sec,
    input  [3:0] min_hour,
    input        sel,
    output [3:0] bcd

);
    assign bcd = (sel) ? min_hour : msec_sec;
endmodule

// clk divider
// 1khz
module clk_div (
    input  clk,
    input  reset,
    output o_clk
);
    // clk 100_000_000, r_count = 100_000
    //reg [16:0] r_counter;
    reg [$clog2(100_000)-1:0] r_counter;
    reg r_clk;

    assign o_clk = r_clk;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk     <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin  // 1khz period
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end

endmodule

// 4진 카운터
module counter_8 (
    input        clk,
    input        reset,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;
    assign fnd_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module decoder_2x4 (
    input      [2:0] fnd_sel,
    output reg [3:0] fnd_com
);
    always @(fnd_sel) begin
        case (fnd_sel)
            3'b000:  fnd_com = 4'b1110;  // fnd 1의 자리 On,
            3'b001:  fnd_com = 4'b1101;
            3'b010:  fnd_com = 4'b1011;
            3'b011:  fnd_com = 4'b0111;
            3'b100:  fnd_com = 4'b1110;
            3'b101:  fnd_com = 4'b1101;
            3'b110:  fnd_com = 4'b1011;
            3'b111:  fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end
endmodule


module dot_make (
    input [6:0] msec,
    output reg [3:0] dot_1,
    output reg [3:0] dot_10,
    output reg [3:0] dot_100,
    output reg [3:0] dot_1000
);


    always @(*) begin
        if (msec <= 50) begin
            dot_1 = 4'b1111;
            dot_10 = 4'b1111;
            dot_100 = 4'b1111;
            dot_1000 = 4'b1111;
        end else begin
            dot_1 = 4'b1111;
            dot_10 = 4'b1111;
            dot_100 = 4'b1110;
            dot_1000 = 4'b1111;
        end
    end

endmodule


module mux_8x1 (
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
            3'b100:  r_bcd = dot_1;
            3'b101:  r_bcd = dot_10;
            3'b110:  r_bcd = dot_100;
            3'b111:  r_bcd = dot_1000;
            default: r_bcd = 4'b1010;
        endcase
    end
endmodule


module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH-1:0] time_data,
    output [          3:0] digit_1,
    output [          3:0] digit_10
);

    assign digit_1  = time_data % 10;
    assign digit_10 = (time_data / 10) % 10;

endmodule

module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    reg [7:0] r_fnd_data;

    assign fnd_data = r_fnd_data;

    // 조합논리 combinational , 행위수준 모델링.

    always @(bcd) begin
        case (bcd)
            4'h00:   r_fnd_data = 8'hc0;
            4'h01:   r_fnd_data = 8'hf9;
            4'h02:   r_fnd_data = 8'ha4;
            4'h03:   r_fnd_data = 8'hb0;
            4'h04:   r_fnd_data = 8'h99;
            4'h05:   r_fnd_data = 8'h92;
            4'h06:   r_fnd_data = 8'h82;
            4'h07:   r_fnd_data = 8'hf8;
            4'h08:   r_fnd_data = 8'h80;
            4'h09:   r_fnd_data = 8'h90;
            4'b1010: r_fnd_data = 8'hff;
            4'b1011: r_fnd_data = 8'hff;
            4'b1100: r_fnd_data = 8'hff;
            4'b1101: r_fnd_data = 8'hff;
            4'b1110: r_fnd_data = 8'h7f;
            4'b1111: r_fnd_data = 8'hff;
            default: r_fnd_data = 8'hff;
        endcase
    end

endmodule
