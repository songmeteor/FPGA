`timescale 1ns / 1ps


module Watch (
    input        clk,
    input        rst,
    input        btnU_Up,
    input        btnD_Down,
    input        btnL_Left,
    input        btnR_Right,
    input        sw_mode,
    input        sw_mode_2,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire w_o_up, w_o_down, w_o_left, w_o_right;
    wire [1:0] w_o_num;
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;
    wire [5:0] w_tick_cnt;


    /*btn_debounce U_BTN_DB_UP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU_Up & sw_mode_2),
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
        .i_btn(btnL_Left),
        .o_btn(w_o_left)
    );

    btn_debounce U_BTN_DB_RIGHT (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR_Right),
        .o_btn(w_o_right)
    );*/

    watch_cu U_WATCH_CU (
        .clk(clk),
        .rst(rst),
        .i_left(btnL_Left),
        .i_right(btnR_Right),
        .o_num(w_o_num)
    );

    watch_dp U_Watch_DP (
        .clk(clk),
        .rst(rst),
        .i_num(w_o_num),
        .i_down(btnD_Down),
        .sw_mode(sw_mode),
        .sw_mode_2(sw_mode_2),
        .i_up(btnU_Up & sw_mode_2),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .tick_cnt(w_tick_cnt)
    );

    fnd_controller_watch U_FND_CNTL (
        .clk(clk),
        .reset(rst),
        .i_num(w_o_num),
        .sw_mode(sw_mode),
        .sw_mode_2(sw_mode_2),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .tick_cnt(w_tick_cnt),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule

module watch_cu (
    input clk,
    input rst,
    input i_left,
    input i_right,
    output [1:0] o_num
);


    reg [1:0] c_state, n_state;

    assign o_num = c_state;


    // SL state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            0: begin
                if (i_right) begin
                    n_state = 3;
                end else if (i_left) begin
                    n_state = 1;
                end else n_state = c_state;
            end
            1: begin
                if (i_right) begin
                    n_state = 0;
                end else if (i_left) begin
                    n_state = 2;
                end else n_state = c_state;
            end
            2: begin
                if (i_right) begin
                    n_state = 1;
                end else if (i_left) begin
                    n_state = 3;
                end else n_state = c_state;
            end
            3: begin
                if (i_right) begin
                    n_state = 2;
                end else if (i_left) begin
                    n_state = 0;
                end else n_state = c_state;
            end
        endcase
    end

endmodule


module watch_dp (
    input        clk,
    input        rst,
    input  [1:0] i_num,
    input        i_down,
    input        i_up,
    input        sw_mode,
    input        sw_mode_2,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour,
    output [5:0] tick_cnt
);
    wire w_tick_100hz, w_sec_tick, w_min_tick;
    wire sec_up, sec_down, min_up, min_down;

    assign sec_up   = (!sw_mode) ? i_up : 0;
    assign sec_down = (!sw_mode) ? i_down : 0;
    assign min_up   = (sw_mode) ? i_up : 0;
    assign min_down = (sw_mode) ? i_down : 0;

    // msec
    time_counter_msec #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100),
        .FIRST_TIME(0)
    ) U_MSEC (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .sw_mode_2(sw_mode_2),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );
    //sec
    time_counter_sec #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .FIRST_TIME(0)
    ) U_SEC (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),
        .i_num(i_num),
        .i_up(sec_up),
        .i_down(sec_down),
        .sw_mode_2(sw_mode_2),
        .o_time(sec),
        .o_tick(w_min_tick)
    );
    // min
    time_counter_min #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .FIRST_TIME(0)
    ) U_MIN (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),
        .i_num(i_num),
        .i_up(min_up),
        .i_down(min_down),
        .sw_mode_2(sw_mode_2),
        .o_time(min),
        .o_tick(w_hour_tick)
    );
    time_counter_hour #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24),
        .FIRST_TIME(12)
    ) U_HOUR (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),
        .i_num(i_num),
        .i_up(min_up),
        .i_down(min_down),
        .sw_mode_2(sw_mode_2),
        .o_time(hour),
        .o_tick()
    );

    tick_gen_100hz U_Tick_100hz_Watch (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );

    tick_gen_counter U_TICK_CNT (
        .clk(clk),
        .rst(rst),
        .sw_mode_2(sw_mode_2),
        .i_tick_gen(w_tick_100hz),
        .tick_cnt(tick_cnt)
    );


endmodule


module time_counter_msec #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    FIRST_TIME = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input                  sw_mode_2,
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
        if ((!sw_mode_2) & (i_tick == 1'b1)) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next  = 0;
                o_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end

endmodule


module time_counter_sec #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    FIRST_TIME = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input  [          1:0] i_num,
    input                  i_up,
    input                  i_down,
    input                  sw_mode_2,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg = FIRST_TIME, count_next;
    reg o_tick_reg, o_tick_next;
    reg valid_up, valid_down;
    //reg [9:0] r_counter_add;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= FIRST_TIME;
            o_tick_reg <= 0;
            valid_up   <= 0;
            valid_down <= 0;
            //r_counter_add <= 0;
        end else begin
            //count_reg <= count_next;
            count_reg <= (count_reg == 60) ? 0 : (((count_reg <= 63) & (count_reg >= 61)) ? 59 : count_next);
            o_tick_reg <= o_tick_next;
            if (sw_mode_2) begin
                if (i_up & !valid_up) begin
                    if ((i_num == 0) || (i_num == 2)) begin
                        count_reg <= count_reg + 1;
                        valid_up  <= 1;
                    end else if ((i_num == 1) || (i_num == 3)) begin
                        count_reg <= count_reg + 10;
                        valid_up  <= 1;
                    end
                end else if (!i_up & valid_up) begin
                    valid_up <= 0;
                end
                if (i_down & !valid_down) begin
                    if ((i_num == 0) || (i_num == 2)) begin
                        count_reg  <= count_reg - 1;
                        valid_down <= 1;
                    end else if ((i_num == 1) || (i_num == 3)) begin
                        count_reg  <= count_reg - 10;
                        valid_down <= 1;
                    end
                end else if (!i_down & valid_down) begin
                    valid_down <= 0;
                end
            end
        end
    end

    // CL next state
    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next  = 0;
                o_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end


endmodule


module time_counter_min #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    FIRST_TIME = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input  [          1:0] i_num,
    input                  i_up,
    input                  i_down,
    input                  sw_mode_2,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg = FIRST_TIME, count_next;
    reg o_tick_reg, o_tick_next;
    reg valid_up, valid_down;
    //reg [9:0] r_counter_add;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= FIRST_TIME;
            o_tick_reg <= 0;
            valid_up   <= 0;
            valid_down <= 0;
            //r_counter_add <= 0;
        end else begin
            //count_reg <= count_next;
            count_reg <= (count_reg == 60) ? 0 : (((count_reg <= 63) & (count_reg >= 61)) ? 59 : count_next);
            //o_tick_reg <= o_tick_next;
            o_tick_reg <= (count_reg == 60) ? 1 : o_tick_next;
            if (sw_mode_2) begin
                if (i_up & !valid_up) begin
                    if (i_num == 0) begin
                        count_reg <= count_reg + 1;
                        valid_up  <= 1;
                    end else if (i_num == 1) begin
                        count_reg <= count_reg + 10;
                        valid_up  <= 1;
                    end
                end else if (!i_up & valid_up) begin
                    valid_up <= 0;
                end
                if (i_down & !valid_down) begin
                    if (i_num == 0) begin
                        count_reg  <= count_reg - 1;
                        valid_down <= 1;
                    end else if (i_num == 1) begin
                        count_reg  <= count_reg - 10;
                        valid_down <= 1;
                    end
                end else if (!i_down & valid_down) begin
                    valid_down <= 0;
                end
            end
        end
    end

    // CL next state
    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next  = 0;
                o_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end


endmodule

module time_counter_hour #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100,
    FIRST_TIME = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input  [          1:0] i_num,
    input                  i_up,
    input                  i_down,
    input                  sw_mode_2,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg = FIRST_TIME, count_next;
    reg o_tick_reg, o_tick_next;
    reg valid_up, valid_down;
    reg [9:0] r_counter_add;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= FIRST_TIME;
            o_tick_reg <= 0;
            valid_up   <= 0;
            valid_down <= 0;
            // r_counter_add <= 0;
        end else begin
            count_reg  <= count_next;
            o_tick_reg <= o_tick_next;
            if (sw_mode_2) begin
                if (i_up & !valid_up) begin
                    if (i_num == 2) begin
                        count_reg <= count_reg + 1;
                        valid_up  <= 1;
                    end else if (i_num == 3) begin
                        count_reg <= count_reg + 10;
                        valid_up  <= 1;
                    end
                end else if (!i_up & valid_up) begin
                    valid_up <= 0;
                end
                if (i_down & !valid_down) begin
                    if (i_num == 2) begin
                        count_reg  <= count_reg - 1;
                        valid_down <= 1;
                    end else if (i_num == 3) begin
                        count_reg  <= count_reg - 10;
                        valid_down <= 1;
                    end
                end else if (!i_down & valid_down) begin
                    valid_down <= 0;
                end
            end
        end
    end

    // CL next state
    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next  = 0;
                o_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end

endmodule


module tick_gen_counter (
    input clk,
    input rst,
    input sw_mode_2,
    input i_tick_gen,
    output [5:0] tick_cnt
);

    reg [5:0] counter;

    assign tick_cnt = counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            if (sw_mode_2) begin
                if (i_tick_gen) begin
                    if (counter >= 40) counter <= 0;
                    else counter <= counter + 1;
                end
            end else begin
                counter <= 0;
            end
        end
    end

endmodule
