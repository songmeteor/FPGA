
module sr04_controller (
    input clk,
    input rst,
    input start, //btn_U
    input echo,
    output trig,
    output [10:0] dist,
    output dist_done
);

    wire w_tick,w_start;

    tick_gen_1Mhz U_tick_gen_1mhz(
        .clk(clk),
        .rst(rst),
        .o_tick_1mhz(w_tick)
    );

    tick_gen_10Mhz U_tick_gen_10Mhz(
        .clk(clk),
        .rst(rst),
        .o_tick_100khz(w_tick_1)
    );

    start_trigger U_START_TIRRIG(
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick),
        .start(start),
        .o_sr04_trigger(trig)
    );

    high_level_detector  U_high_level_detector(
        .echo(echo),
        .i_tick(w_tick),
        .i_tick_1(w_tick_1),
        .clk(clk),
        .rst(rst),
        .dist(dist),
        .dist_done(dist_done)
    );
    
endmodule


module high_level_detector(
    input echo,
    input i_tick,
    input i_tick_1,
    input clk,
    input rst,
    output [10:0] dist,
    output dist_done
);

    parameter idle = 0, start = 1, stop = 2;

    reg [1:0] c_state, n_state;
    reg [20:0] count_reg, count_next; 
    reg dist_reg, dist_next;
    reg r_done, n_done;

    assign dist_done = dist_reg;
    assign dist = count_reg / 58;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state <= idle;
            count_reg <= 0;
            dist_reg <= 0;
        end else begin
            c_state <= n_state;
            count_reg <= count_next;
            dist_reg <= dist_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        count_next = count_reg;
        n_done = r_done;
        dist_next = dist_reg;
        case(c_state)
            idle: begin
                dist_next = 0;
                if (echo & i_tick) begin
                    count_next = 1;
                    n_state = start;
                end else begin
                    count_next = count_reg;
                end
            end
            start: begin
                if (echo & i_tick_1) begin
                    count_next = count_reg + 1;
                end else if (!echo) begin
                    n_state = stop;
                end
            end
            stop: begin
                n_state = idle;
                dist_next = 1;
            end
        endcase
    end
endmodule


module start_trigger(
    input clk,
    input rst,
    input i_tick,
    input start,
    output o_sr04_trigger
);

    reg [3:0] count_reg, count_next; 
    reg start_reg, start_next;
    reg sr04_trigg_reg, sr04_trigg_next;

    assign o_sr04_trigger = sr04_trigg_reg;

    always@(posedge clk, posedge rst)begin
        if(rst)begin
            start_reg <=0;
            sr04_trigg_reg <=0;
            count_reg <=0;
        end else begin
            start_reg <= start_next;
            sr04_trigg_reg <= sr04_trigg_next;
            count_reg <= count_next;
        end    
    end

    always@(*) begin
        start_next = start_reg;
        sr04_trigg_next= sr04_trigg_reg;
        count_next = count_reg;
        case(start_reg)
            0:begin
                count_next =0;
                sr04_trigg_next =1'b0;
                if(start)begin
                    start_next =1;
                end
            end
            1:begin
                if(i_tick)begin
                    sr04_trigg_next =1'b1;
                    count_next = count_reg + 1;
                    if(count_reg >= 10)begin
                    start_next =0;
                    end
                end
            end
        endcase
    end
endmodule


module tick_gen_1Mhz (
    input  clk,
    input  rst,
    output o_tick_1mhz
);
    // 100_000_000 ->1_000_000
    parameter FCOUNT = 100 - 1;  //1_00

    reg [7:0] count;
    reg tick;
    // state register
    assign o_tick_1mhz = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == FCOUNT) begin
                count <= 0;
                tick  <= 1'b1;
            end else begin
                count <= count + 1;
                tick  <= 1'b0;
            end
        end
    end
endmodule


module tick_gen_10Mhz (
    input  clk,
    input  rst,
    output o_tick_100khz
);
    // 100_000_000 ->1_000_000
    parameter FCOUNT = 10 - 1;  //1_000

    reg [3:0] count;
    reg tick;
    // state register
    assign o_tick_100khz = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == FCOUNT) begin
                count <= 0;
                tick  <= 1'b1;
            end else begin
                count <= count + 1;
                tick  <= 1'b0;
            end
        end
    end
endmodule


