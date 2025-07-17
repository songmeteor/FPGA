`timescale 1ns / 1ps


module Top_Module (
    input        clk,
    input        rst,
    input        btnL_clear,
    input        btnR_runstop,
    input        btnU_Up,
    input        btnD_Down,
    input        sw_mode,       // hour-min/sec-msec, 온도/습도
    input        sw_mode_1,
    input        sw_mode_2,     // 15sw 시간조절기능
    input        sw_mode_3,     // 거리
    input        sw_mode_4,     // 온도
    input        rx,
    input        echo,
    output       trig,
    output       tx,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [7:0] led,
    output       dht11_valid,
    inout        dht11_io
);

    wire rx_done;
    wire [7:0] rx_data;
    wire w_up, w_down, w_right, w_left, w_run, w_stop, w_clear, w_time_mode, w_reset, w_func_mode;
    wire w_dht_mode, w_sr_mode, w_time_change;
    wire [7:0] dht_fnd_data, sr_fnd_data, wt_fnd_data;
    wire [3:0] dht_fnd_com, sr_fnd_com, wt_fnd_com;
    wire wt_btnR, dht_btnR, sr_btnR;
    wire sr_btnU, dht_btnU;
    wire [7:0] w_t_data, w_rh_data;
    wire [10:0] w_distance;
    wire sw_mode_3_cu, sw_mode_4_cu;

    assign sw_mode_3_cu = sw_mode_3 | w_sr_mode;
    assign sw_mode_4_cu = sw_mode_4 | w_dht_mode;

    assign fnd_com = ((!sw_mode_3_cu) & (!sw_mode_4_cu)) ? wt_fnd_com :  
            ((sw_mode_3_cu) ? sr_fnd_com : dht_fnd_com);

    assign fnd_data = ((!sw_mode_3_cu) & (!sw_mode_4_cu)) ? wt_fnd_data :  
            ((sw_mode_3_cu) ? sr_fnd_data : dht_fnd_data);

    assign wt_btnR = ((!sw_mode_3_cu) & (!sw_mode_4_cu)) ? w_o_right : 0;

    assign dht_btnR = ((sw_mode_4_cu) & (!sw_mode_3_cu)) ? w_o_right : 0;

    assign dht_btnU = ((sw_mode_4_cu) & (!sw_mode_3_cu)) ? w_o_up : 0;

    assign sr_btnR = ((sw_mode_3_cu) & (!sw_mode_4_cu)) ? w_o_right : 0;

    assign sr_btnU = ((sw_mode_3_cu) & (!sw_mode_4_cu)) ? w_o_up : 0;

    btn_debounce U_BTN_DB_UP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU_Up),
        .o_btn(w_o_up)
    );

    btn_debounce U_BTN_DB_DOWN (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD_Down),
        .o_btn(w_o_down)
    );

    btn_debounce U_BTN_DB_LEFT (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL_clear),
        .o_btn(w_o_left)
    );

    btn_debounce U_BTN_DB_RIGHT (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR_runstop),
        .o_btn(w_o_right)
    );

    Top_dht11 U_DHT11 (
        .clk(clk),
        .rst(rst),
        .btn_start(dht_btnR | (w_run & sw_mode_4_cu)),
        .btn_auto(dht_btnU | (w_up & sw_mode_4_cu)),
        .sw0(sw_mode),
        .sw(sw_mode_4_cu),
        //.state_led,
        .fnd_data(dht_fnd_data),
        .fnd_com(dht_fnd_com),
        .dht11_valid(dht11_valid),
        .t_data(w_t_data),
        .rh_data(w_rh_data),
        .data_done(w_dht_done),
        .dht11_io(dht11_io),
        .led(led[7])
    );

    Top_sr04 U_SR04 (
        .clk(clk),
        .rst(rst),
        .btn_start(sr_btnR | (w_run & sw_mode_3_cu)),
        .btn_auto(sr_btnU | (w_up & sw_mode_3_cu)),
        .sw(sw_mode_3_cu),
        .echo(echo),
        .trig(trig),
        .distance(w_distance),
        .dist_done(w_dist_done),
        .fnd_data(sr_fnd_data),
        .fnd_com(sr_fnd_com),
        .led(led[6])
    );

    Top_Watch U_W (
        .clk(clk),
        .rst(rst),
        .btnL_clear(w_o_left),
        .btnR_runstop(wt_btnR),
        .btnU_Up(w_o_up),
        .btnD_Down(w_o_down),
        .sw_mode(sw_mode),
        .sw_mode_1(sw_mode_1),
        .sw_mode_2(sw_mode_2 | w_time_change),
        .up(w_up),
        .down(w_down),
        .right(w_right),
        .left(w_left),
        .run(w_run & (!sw_mode_3_cu) & (!sw_mode_4_cu)),
        .stop(w_stop),
        .clear(w_clear),
        .time_mode(w_time_mode),
        .reset(w_reset),
        .func_mode(w_func_mode),
        .fnd_com(wt_fnd_com),
        .fnd_data(wt_fnd_data),
        .led(led[5:0])
    );

    uart_cu U_U_CU (
        .clk(clk),
        .rst(rst),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .up(w_up),
        .down(w_down),
        .right(w_right),
        .left(w_left),
        .run(w_run),
        .stop(w_stop),
        .clear(w_clear),
        .time_mode(w_time_mode),
        .reset(w_reset),
        .func_mode(w_func_mode),
        .dht_mode(w_dht_mode),
        .sr_mode(w_sr_mode),
        .time_change(w_time_change)
    );

    sender_uart U_SEND (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .i_send_data({w_distance, w_rh_data, w_t_data}),
        .dht_done(w_dht_done),
        .dht_valid(dht11_valid),
        .dist_done(w_dist_done),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .tx(tx)
        //.tx_done(tx_done)
    );

endmodule


module sender_uart (
    input clk,
    input rst,
    input rx,
    input [26:0] i_send_data,
    input dht_done,
    input dht_valid,
    input dist_done,
    output rx_done,
    output [7:0] rx_data,
    output tx,
    output tx_done
);
    wire w_start, w_tx_full;
    wire [31:0] w_t_send_data, w_rh_send_data, w_dist_send_data;
    reg c_state, n_state;
    reg [7:0] send_data_reg, send_data_next;
    reg send_reg, send_next;
    reg [4:0] send_cnt_reg, send_cnt_next;
    reg r_dist_done, r_dht_done, n_dist_done, n_dht_done;

    /*btn_debounce U_START_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );*/

    //    assign w_start = btn_start;

    uart_controller U_UART_CNTL (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_pop(),
        .tx_push_data(send_data_reg),
        .tx_push(send_reg),
        .rx_data(rx_data),
        .rx_empty(),
        .rx_done(rx_done),
        .tx_full(w_tx_full),
        .tx_done(tx_done),
        .tx_busy(),
        .tx(tx)
    );

    datatoascii U_DtoA_T (
        .i_data(i_send_data[7:0]),
        .o_data(w_t_send_data)
    );

    datatoascii U_DtoA_RH (
        .i_data(i_send_data[15:8]),
        .o_data(w_rh_send_data)
    );

    datatoascii U_DtoA_DIST (
        .i_data(i_send_data[26:16]),
        .o_data(w_dist_send_data)
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state       <= 0;
            send_data_reg <= 0;
            send_reg      <= 0;
            send_cnt_reg  <= 0;
            r_dist_done   <= 0;
            r_dht_done    <= 0;
        end else begin
            c_state       <= n_state;
            send_data_reg <= send_data_next;
            send_reg      <= send_next;
            send_cnt_reg  <= send_cnt_next;
            r_dist_done   <= n_dist_done;
            r_dht_done    <= n_dht_done;
        end
    end

    always @(*) begin
        n_state        = c_state;
        send_data_next = send_data_reg;
        send_next      = send_reg;
        send_cnt_next  = send_cnt_reg;
        n_dist_done    = r_dist_done;
        n_dht_done     = r_dht_done;
        case (c_state)
            00: begin
                send_cnt_next = 0;
                if (dht_done | dist_done) begin
                    n_state = 1;
                    n_dist_done = dist_done;
                    n_dht_done = dht_done;
                end
            end
            01: begin  // send
                if (~w_tx_full) begin
                    send_next = 1;  // send tick 생성.
                    if (r_dht_done) begin
                        if (send_cnt_reg < 22) begin
                            // 상위부터 보내기
                            case (send_cnt_reg)
                                5'h00: send_data_next = 8'h54;  // T
                                5'h01: send_data_next = 8'h45;  // E
                                5'h02: send_data_next = 8'h4D;  // M
                                5'h03: send_data_next = 8'h50;  // P
                                5'h04: send_data_next = 8'h3A;  // :
                                5'h05:
                                send_data_next = w_t_send_data[15:8];  // t_data
                                5'h06:
                                send_data_next = w_t_send_data[7:0];  // t_data
                                5'h07: send_data_next = 8'h0A;  // \n
                                5'h08: send_data_next = 8'h52;  // R
                                5'h09: send_data_next = 8'h48;  // H
                                5'h0a: send_data_next = 8'h3A;  // :
                                5'h0b:
                                send_data_next = w_rh_send_data[15:8]; // rh_data
                                5'h0c:
                                send_data_next = w_rh_send_data[7:0]; // rh_data
                                5'h0d: send_data_next = 8'h0A;  // \n
                                5'h0e: send_data_next = 8'h56;  // V
                                5'h0f: send_data_next = 8'h41;  // A
                                5'h10: send_data_next = 8'h4C;  // L
                                5'h11: send_data_next = 8'h49;  // I
                                5'h12: send_data_next = 8'h44;  // D
                                5'h13: send_data_next = 8'h3A;  // :
                                5'h14:
                                send_data_next = dht_valid + 8'h30; // valid_data
                                5'h15: send_data_next = 8'h0A;  // \n
                            endcase
                            send_cnt_next = send_cnt_reg + 1;
                        end else begin
                            n_state   = 0;
                            send_next = 0;
                        end
                    end else if (r_dist_done) begin
                        if (send_cnt_reg < 17) begin
                            // 상위부터 보내기
                            case (send_cnt_reg)
                                5'h00: send_data_next = 8'h44;  // D
                                5'h01: send_data_next = 8'h49;  // I
                                5'h02: send_data_next = 8'h53;  // S
                                5'h03: send_data_next = 8'h54;  // T
                                5'h04: send_data_next = 8'h41;  // A
                                5'h05: send_data_next = 8'h4E;  // N
                                5'h06: send_data_next = 8'h43;  // C
                                5'h07: send_data_next = 8'h45;  // E
                                5'h08: send_data_next = 8'h3A;  // :
                                5'h09:
                                send_data_next = w_dist_send_data[31:24]; // dist_data
                                5'h0a:
                                send_data_next = w_dist_send_data[23:16]; // dist_data
                                5'h0b:
                                send_data_next = w_dist_send_data[15:8]; // dist_data
                                5'h0c: send_data_next = 8'h2E;  // .
                                5'h0d:
                                send_data_next = w_dist_send_data[7:0]; // dist_data
                                5'h0e: send_data_next = 8'h63;  // c
                                5'h0f: send_data_next = 8'h6D;  // m
                                5'h10: send_data_next = 8'h0A;  // \n
                            endcase
                            send_cnt_next = send_cnt_reg + 1;
                        end else begin
                            n_state   = 0;
                            send_next = 0;
                        end
                    end
                end else n_state = c_state;
            end
        endcase
    end
endmodule

// decoder, LUT
module datatoascii (
    input  [13:0] i_data,
    output [31:0] o_data
);
    assign o_data[7:0]   = i_data % 10 + 8'h30;  // 나머지 + 8'h30
    assign o_data[15:8]  = (i_data / 10) % 10 + 8'h30;
    assign o_data[23:16] = (i_data / 100) % 10 + 8'h30;
    assign o_data[31:24] = (i_data / 1000) % 10 + 8'h30;
endmodule
