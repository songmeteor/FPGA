`timescale 1ns / 1ps

module my_top(
    input clk,
    input reset,
    input btnC,
    output reg led
    );

    wire w_btn_debounce;
    wire w_tick;

    my_btn_debounce u_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btnC),
        .tick(w_tick),
        .clean_btn(w_btn_debounce)
    );

    tick_generator u_tick_generator(    
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    always @ (posedge w_btn_debounce, posedge reset) begin
        if(reset)
            led <= 0;   
        else 
            led <= ~led;
    end
endmodule
