`timescale 1ns / 1ps


module uart_cu (
    input clk,
    input rst,
    input rx_done,
    input [7:0] rx_data,
    output up,
    output down,
    output right,
    output left,
    output run,
    output stop,
    output clear,
    output time_mode,
    output reset,
    output func_mode,
    output dht_mode,
    output sr_mode,
    output time_change
);
    reg up_reg, up_next;
    reg down_reg, down_next;
    reg right_reg, right_next;
    reg left_reg, left_next;
    reg run_reg, run_next;
    reg stop_reg, stop_next;
    reg clear_reg, clear_next;
    reg time_mode_reg, time_mode_next;
    reg reset_reg, reset_next;
    reg func_mode_reg, func_mode_next;
    reg dht_mode_reg, dht_mode_next;
    reg sr_mode_reg, sr_mode_next;
    reg time_change_reg, time_change_next;

    assign up = up_reg;
    assign down = down_reg;
    assign right = right_reg;
    assign left = left_reg;
    assign run = run_reg;
    assign stop = stop_reg;
    assign clear = clear_reg;
    assign time_mode = time_mode_reg;
    assign reset = reset_reg;
    assign func_mode = func_mode_reg;
    assign dht_mode = dht_mode_reg;
    assign sr_mode = sr_mode_reg;
    assign time_change = time_change_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            up_reg <= 0;
            down_reg <= 0;
            right_reg <= 0;
            left_reg <= 0;
            run_reg <= 0;
            stop_reg <= 0;
            clear_reg <= 0;
            time_mode_reg <= 0;
            reset_reg <= 0;
            func_mode_reg <= 0;
            dht_mode_reg <= 0;
            sr_mode_reg <= 0;
            time_change_reg <= 0;
        end else begin
            up_reg <= up_next;
            down_reg <= down_next;
            right_reg <= right_next;
            left_reg <= left_next;
            run_reg <= run_next;
            stop_reg <= stop_next;
            clear_reg <= clear_next;
            time_mode_reg <= time_mode_next;
            reset_reg <= reset_next;
            func_mode_reg <= func_mode_next;
            dht_mode_reg <= dht_mode_next;
            sr_mode_reg <= sr_mode_next;
            time_change_reg <= time_change_next;
        end
    end

    always @(*) begin
        up_next = up_reg;
        down_next = down_reg;
        right_next = right_reg;
        left_next = left_reg;
        run_next = run_reg;
        stop_next = stop_reg;
        clear_next = clear_reg;
        time_mode_next = time_mode_reg;
        reset_next = reset_reg;
        func_mode_next = func_mode_reg;
        dht_mode_next = dht_mode_reg;
        sr_mode_next = sr_mode_reg;
        time_change_next = time_change_reg;
        if (rx_done) begin
            case (rx_data)
                8'h55: begin
                    up_next = 1;
                end
                8'h44: begin
                    down_next = 1;
                end
                8'h52: begin
                    right_next = 1;
                end
                8'h4C: begin
                    left_next = 1;
                end
                8'h72: begin
                    run_next = 1;
                end
                8'h53: begin
                    stop_next = 1;
                end
                8'h43: begin
                    clear_next = 1;
                end
                8'h4D: begin
                    if (time_mode_reg) begin
                        time_mode_next = 0;
                    end
                    else begin
                        time_mode_next = 1;
                    end
                end
                8'h1B: begin
                    reset_next = 1;
                end
                8'h4E: begin
                    if(func_mode_reg)begin
                        func_mode_next = 0;
                    end
                    else begin
                        func_mode_next = 1;
                    end
                end
                8'h54: begin
                    if(dht_mode_reg)begin
                        dht_mode_next = 0;
                    end
                    else begin
                        dht_mode_next = 1;
                    end
                end
                8'h49: begin
                    if(sr_mode_reg)begin
                        sr_mode_next = 0;
                    end
                    else begin
                        sr_mode_next = 1;
                    end
                end
                8'h48: begin
                    if(time_change_reg)begin
                        time_change_next = 0;
                    end
                    else begin
                        time_change_next = 1;
                    end
                end
            endcase
        end else begin
            up_next = 0;
            down_next = 0;
            right_next = 0;
            left_next = 0;
            run_next = 0;
            stop_next = 0;
            clear_next = 0;
            reset_next = 0;
        end
    end

endmodule
