`timescale 1ns / 1ps


module fnd_controller_watch (
    input        clk,
    input        reset,
    input        sw_mode,
    input        sw_mode_2,
    input  [1:0] i_num,
    input  [6:0] msec,
    input  [5:0] sec,
    input  [5:0] min,
    input  [4:0] hour,
    input  [5:0] tick_cnt,
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
    mux_8x1_watch U_MUX_8x1_MIN_HOUR (
        .sel(fnd_sel),
        .digit_1(w_min_1),
        .digit_10(w_min_10),
        .digit_100(w_hour_1),
        .digit_1000(w_hour_10),
        .dot_1(w_dot_1),
        .dot_10(w_dot_10),
        .dot_100(w_dot_100),
        .dot_1000(w_dot_1000),
        .tick_cnt(tick_cnt),
        .sw_mode_2(sw_mode_2),
        .i_num(i_num),
        .bcd(w_min_hour)
    );

    mux_8x1_watch_sec U_MUX_8x1 (
        .sel(fnd_sel),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10),
        .digit_100(w_sec_1),
        .digit_1000(w_sec_10),
        .dot_1(w_dot_1),
        .dot_10(w_dot_10),
        .dot_100(w_dot_100),
        .dot_1000(w_dot_1000),
        .tick_cnt(tick_cnt),
        .sw_mode_2(sw_mode_2),
        .i_num(i_num),
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


module mux_8x1_watch (
    input [2:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [3:0] dot_1,
    input [3:0] dot_10,
    input [3:0] dot_100,
    input [3:0] dot_1000,
    input [5:0] tick_cnt,
    input [1:0] i_num,
    input sw_mode_2,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 4:1 mux , always 
    always @(*) begin
        if (!sw_mode_2) begin
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
        end else begin
            case (i_num)
                0: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = dot_1;
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
                end
                1: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = digit_1;
                            3'b001:  r_bcd = dot_1;
                            3'b010:  r_bcd = digit_100;
                            3'b011:  r_bcd = digit_1000;
                            3'b100:  r_bcd = dot_1;
                            3'b101:  r_bcd = dot_10;
                            3'b110:  r_bcd = dot_100;
                            3'b111:  r_bcd = dot_1000;
                            default: r_bcd = 4'b1010;
                        endcase
                    end
                end
                2: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = digit_1;
                            3'b001:  r_bcd = digit_10;
                            3'b010:  r_bcd = dot_1;
                            3'b011:  r_bcd = digit_1000;
                            3'b100:  r_bcd = dot_1;
                            3'b101:  r_bcd = dot_10;
                            3'b110:  r_bcd = dot_100;
                            3'b111:  r_bcd = dot_1000;
                            default: r_bcd = 4'b1010;
                        endcase
                    end
                end
                3: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = digit_1;
                            3'b001:  r_bcd = digit_10;
                            3'b010:  r_bcd = digit_100;
                            3'b011:  r_bcd = dot_1;
                            3'b100:  r_bcd = dot_1;
                            3'b101:  r_bcd = dot_10;
                            3'b110:  r_bcd = dot_100;
                            3'b111:  r_bcd = dot_1000;
                            default: r_bcd = 4'b1010;
                        endcase
                    end
                end
                default: r_bcd = 4'b1010;
            endcase

        end
    end
endmodule


module mux_8x1_watch_sec (
    input [2:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [3:0] dot_1,
    input [3:0] dot_10,
    input [3:0] dot_100,
    input [3:0] dot_1000,
    input [5:0] tick_cnt,
    input [1:0] i_num,
    input sw_mode_2,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 4:1 mux , always 
    always @(*) begin
        if (!sw_mode_2) begin
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
        end else begin
            case (i_num)
                0: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = digit_1;
                            3'b001:  r_bcd = digit_10;
                            3'b010:  r_bcd = dot_1;
                            3'b011:  r_bcd = digit_1000;
                            3'b100:  r_bcd = dot_1;
                            3'b101:  r_bcd = dot_10;
                            3'b110:  r_bcd = dot_100;
                            3'b111:  r_bcd = dot_1000;
                            default: r_bcd = 4'b1010;
                        endcase
                    end
                end
                1: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = digit_1;
                            3'b001:  r_bcd = digit_10;
                            3'b010:  r_bcd = digit_100;
                            3'b011:  r_bcd = dot_1;
                            3'b100:  r_bcd = dot_1;
                            3'b101:  r_bcd = dot_10;
                            3'b110:  r_bcd = dot_100;
                            3'b111:  r_bcd = dot_1000;
                            default: r_bcd = 4'b1010;
                        endcase
                    end
                end
                2: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = digit_1;
                            3'b001:  r_bcd = digit_10;
                            3'b010:  r_bcd = dot_1;
                            3'b011:  r_bcd = digit_1000;
                            3'b100:  r_bcd = dot_1;
                            3'b101:  r_bcd = dot_10;
                            3'b110:  r_bcd = dot_100;
                            3'b111:  r_bcd = dot_1000;
                            default: r_bcd = 4'b1010;
                        endcase
                    end
                end
                3: begin
                    if (tick_cnt < 20) begin
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
                    end else begin
                        case (sel)
                            3'b000:  r_bcd = digit_1;
                            3'b001:  r_bcd = digit_10;
                            3'b010:  r_bcd = digit_100;
                            3'b011:  r_bcd = dot_1;
                            3'b100:  r_bcd = dot_1;
                            3'b101:  r_bcd = dot_10;
                            3'b110:  r_bcd = dot_100;
                            3'b111:  r_bcd = dot_1000;
                            default: r_bcd = 4'b1010;
                        endcase
                    end
                end
                default: r_bcd = 4'b1010;
            endcase

        end
    end
endmodule