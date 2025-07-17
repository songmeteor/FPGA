`timescale 1ns / 1ps

module uart_tx (
    input clk,
    input rst,
    input baud_tick,
    input start,
    input [7:0] din,
    output o_tx_done,
    output o_tx_busy,
    output o_tx
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3, WAIT = 4;

    reg [2:0] c_state, n_state;  // state들은 fsm만들때 항상 필요
    reg tx_reg, tx_next;
    reg [2:0] data_cnt_reg, data_cnt_next;
    reg [3:0] b_cnt_reg, b_cnt_next;
    reg tx_done_reg, tx_done_next;
    reg tx_busy_reg, tx_busy_next;
    reg [7:0] tx_din_reg, tx_din_next;

    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;
    assign o_tx_busy = tx_busy_reg;

    //assign o_tx_done = ((c_state == STOP) & (b_cnt_reg == 7)) ? 1'b1 : 1'b0;

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= 0;
            tx_reg       <= 1'b1;  // 출력 초기를 high로 
            data_cnt_reg <= 0;  //data bit 전송 반복 구조를 위해서
            b_cnt_reg    <= 0;  // baud tick을 0부터 7까지 count
            tx_done_reg  <= 0;
            tx_busy_reg  <= 0;
            tx_din_reg <= 0;
        end else begin
            c_state      <= n_state;
            tx_reg       <= tx_next;
            data_cnt_reg <= data_cnt_next;
            b_cnt_reg    <= b_cnt_next;
            tx_done_reg  <= tx_done_next;
            tx_busy_reg  <= tx_busy_next;
            tx_din_reg <= tx_din_next;
        end
    end

    //next state CL
    always @(*) begin  //조합논리
        n_state       = c_state;
        tx_next       = tx_reg;
        data_cnt_next = data_cnt_reg;
        b_cnt_next    = b_cnt_reg;
        tx_done_next  = 0;
        tx_busy_next  = tx_busy_reg;
        tx_din_next = tx_din_reg;
        case (c_state)
            IDLE: begin
                b_cnt_next = 0;
                data_cnt_next = 0;
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tx_busy_next = 1'b0;
                if (start == 1) begin
                    n_state = START;  // state만 변경
                    tx_busy_next = 1'b1;
                    tx_din_next = din;
                end
            end
            START: begin
                if (baud_tick == 1'b1) begin
                    tx_next = 1'b0;
                    if (b_cnt_reg == 8) begin
                        // tick이 오면 출력이 나감
                        n_state = DATA;  // 다음 state로
                        data_cnt_next = 0;
                        b_cnt_next = 0;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = tx_din_reg[data_cnt_reg];
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin
                        if (data_cnt_reg == 3'b111) begin
                            n_state = STOP;
                        end
                        b_cnt_next = 0;
                        data_cnt_next = data_cnt_reg + 1;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin
                        n_state = IDLE;
                        tx_done_next = 1'b1;
                        tx_busy_next = 1'b0;
                    end
                    b_cnt_next = b_cnt_reg + 1;
                end
            end
        endcase
    end
endmodule
