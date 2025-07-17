`timescale 1ns / 1ps
module stopwatch_cu (
    input  clk,
    input  rst,
    input  i_clear,
    input  i_runstop,
    input  i_count_down,
    output o_clear,
    output o_runstop,
    output o_count_down
);

    parameter STOP = 0, RUN = 1, CLEAR = 2, COUNT_DOWN_RUN = 3, COUNT_DOWN_STOP = 4;


    reg [2:0] c_state, n_state;

    assign o_count_down = (c_state == COUNT_DOWN_RUN) ? 1 : 0;
    assign o_clear = (c_state == CLEAR) ? 1 : 0;
    assign o_runstop = (c_state == RUN) ? 1 : 0;

    // SL state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            //            o_clear <= 0;
            //            o_runstop <= 0;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            STOP: begin
                if (i_runstop) begin
                    n_state = RUN;
                end else if (i_clear) begin
                    n_state = CLEAR;
                end else if (i_count_down) begin
                    n_state = COUNT_DOWN_RUN;
                end else n_state = c_state;
            end
            RUN: begin
                if (i_runstop) begin
                    n_state = STOP;
                end
            end
            CLEAR: begin
                if (i_clear) begin
                    n_state = STOP;
                end
            end
            COUNT_DOWN_RUN: begin
                if (i_runstop) begin
                    n_state = COUNT_DOWN_STOP;
                end else n_state = c_state;
            end
            COUNT_DOWN_STOP: begin
                if (i_runstop) begin
                    n_state = COUNT_DOWN_RUN;
                end else if (i_clear) begin
                    n_state = CLEAR;
                end else n_state = c_state;
            end
        endcase
    end

endmodule
