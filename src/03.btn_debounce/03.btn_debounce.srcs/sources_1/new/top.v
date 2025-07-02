`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input btnC,
    output [1:0] led
    );

    wire w_btn_debounce;
    wire w_tick;
    reg [$clog2(500)-1:0] r_ms_count = 0;
    reg [$clog2(100)-1:0] r_100ms_count = 0;
    reg r_led_500ms_toggle = 0;
    reg r_led_100ms_toggle = 0;
    reg r_led_toggle = 0;

    button_debounce u_button_debounce(
        .i_clk(clk),
        .i_reset(reset),
        .i_btn(btnC),
        .o_led(w_btn_debounce)
    );

    tick_generator u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    always @ (posedge w_btn_debounce) begin
       r_led_toggle <= ~r_led_toggle;
    end

    always @ (posedge w_tick, posedge reset) begin
        if(reset) begin
            r_ms_count <= 0;
            r_100ms_count <= 0;
            r_led_500ms_toggle <= 0;
            r_led_100ms_toggle <= 0;
        end else begin
            if(r_ms_count == 500-1) begin
                r_ms_count <= 0;
                r_led_500ms_toggle <= ~r_led_500ms_toggle;
            end else begin
                r_ms_count <= r_ms_count + 1;
            end
            if(r_100ms_count == 100-1) begin
                r_100ms_count <= 0;
                r_led_100ms_toggle <= ~r_led_100ms_toggle;
            end else begin
                r_100ms_count <= r_100ms_count + 1;
            end
        end
        r_led_toggle <= ~r_led_toggle;
    end

    assign led[1] = r_led_100ms_toggle;
    assign led[0] = r_led_500ms_toggle;
    assign led[0] = r_led_toggle ? 1'b1 : 1'b0;
endmodule

