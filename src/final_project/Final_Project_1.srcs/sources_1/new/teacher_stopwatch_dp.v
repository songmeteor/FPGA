`timescale 1ns / 1ps

module stopwatch_dp (
    input        clk,
    input        rst,
    input        run_stop,
    input        clear,
    input        count_down,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_tick_down;
    wire run_clk, cd_clk, w_count_down_stop;

    assign run_clk = clk & run_stop;
    assign cd_clk  = clk & count_down;

    // msec
    time_counter #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100),
        .FIRST_TIME(0)
    ) U_MSEC (
        .clk(clk),
        .rst(rst | clear),
        .count_down(count_down),
        .i_count_down_stop(w_count_down_stop),
        .i_tick(w_tick_100hz | w_tick_down),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );
    //sec
    time_counter_down_sec #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .FIRST_TIME(0)
    ) U_SEC (
        .clk(clk),
        .rst(rst | clear),
        .count_down(count_down),
        .i_tick(w_sec_tick),
        .o_time(sec),
        .o_tick(w_min_tick),
        .o_count_down_stop(w_count_down_stop)
    );
    // min
    time_counter #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .FIRST_TIME(0)
    ) U_MIN (
        .clk(clk),
        .rst(rst | clear),
        .count_down(count_down),
        .i_count_down_stop(w_count_down_stop),
        .i_tick(w_min_tick),
        .o_time(min),
        .o_tick(w_hour_tick)
    );
    time_counter #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24),
        .FIRST_TIME(0)
    ) U_HOUR (
        .clk(clk),
        .rst(rst | clear),
        .count_down(count_down),
        .i_count_down_stop(w_count_down_stop),
        .i_tick(w_hour_tick),
        .o_time(hour),
        .o_tick()
    );

    tick_gen_100hz U_Tick_100hz (
        .clk(run_clk),
        .cd_clk(cd_clk),
        .rst(rst | clear),
        .o_tick_100(w_tick_100hz),
        .o_tick_down(w_tick_down)
    );
endmodule


module time_counter #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    FIRST_TIME = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input                  count_down,
    input                  i_count_down_stop,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg = FIRST_TIME, count_next;
    reg o_tick_reg, o_tick_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= FIRST_TIME;
            o_tick_reg <= 0;
        end else begin
            count_reg  <= count_next;
            o_tick_reg <= o_tick_next;
        end
    end

    // CL next state
    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 1'b0;
        if (!count_down) begin
            if (i_tick == 1'b1) begin
                if (count_reg == (TICK_COUNT - 1)) begin
                    count_next  = 0;
                    o_tick_next = 1'b1;
                end else begin
                    count_next  = count_reg + 1;
                    o_tick_next = 1'b0;
                end
            end
        end else begin
            if (i_tick == 1'b1) begin
                if (count_reg == 0) begin
                    if (i_count_down_stop) begin
                        count_next  = 0;
                        o_tick_next = 1'b0;
                    end else begin
                        count_next  = 99;
                        o_tick_next = 1'b1;
                    end
                end else begin
                    count_next = count_reg - 1;
                    o_tick_next = 1'b0;
                end
            end
        end
    end

endmodule


module time_counter_down_sec #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    FIRST_TIME = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input                  count_down,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick,
    output                 o_count_down_stop
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg = FIRST_TIME, count_next;
    reg o_tick_reg, o_tick_next, o_count_down_stop_reg, o_count_down_stop_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;
    assign o_count_down_stop = (count_down & !count_reg) ? 1 : 0;
    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= FIRST_TIME;
            o_tick_reg <= 0;
            //o_count_down_stop_reg <= 0;
        end else begin
            count_reg <= count_next;
            o_tick_reg <= o_tick_next;
            //o_count_down_stop_reg <= o_count_down_stop_next;
        end
    end

    // CL next state
    always @(*) begin
        count_next = count_reg;
        //o_count_down_stop_next = 0;
        o_tick_next = 1'b0;
        if (!count_down) begin
            if (i_tick == 1'b1) begin
                if (count_reg == (TICK_COUNT - 1)) begin
                    count_next  = 0;
                    o_tick_next = 1'b1;
                end else begin
                    count_next  = count_reg + 1;
                    o_tick_next = 1'b0;
                end
            end
        end else begin
            if (i_tick == 1'b1) begin
                if (!count_reg) begin
                    count_next = 0;
                    o_tick_next = 1'b1;
                    //o_count_down_stop_next = 1;
                end else begin
                    count_next  = count_reg - 1;
                    o_tick_next = 1'b0;
                end
            end
        end
    end

endmodule


module tick_gen_100hz (
    input      clk,
    input      cd_clk,
    input      rst,
    output reg o_tick_100,
    output reg o_tick_down
);
    parameter FCOUNT = 1_000_000;  //1_000_000;

    reg [$clog2(FCOUNT)-1:0] r_counter, r_d_counter;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                o_tick_100 <= 1'b1;// 카운트 값이 일치했을때,o-tick을 상승
                r_counter <= 0;
            end else begin
                o_tick_100 <= 1'b0;
                r_counter  <= r_counter + 1;
            end
        end
    end

    always @(posedge cd_clk, posedge rst) begin
        if (rst) begin
            r_d_counter <= 0;
            o_tick_down <= 0;
        end else begin
            if (r_d_counter == FCOUNT - 1) begin
                o_tick_down <= 1'b1;// 카운트 값이 일치했을때,o-tick을 상승
                r_d_counter <= 0;
            end else begin
                o_tick_down <= 1'b0;
                r_d_counter <= r_d_counter + 1;
            end
        end
    end

endmodule


