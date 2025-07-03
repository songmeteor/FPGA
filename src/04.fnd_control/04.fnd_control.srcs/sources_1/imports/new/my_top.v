`timescale 1ns / 1ps

module my_top(
    input clk,
    input reset,  //          
    input [2:0] btn, //
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0] w_btn_debounce;
    wire [13:0] w_seg_data;
    wire w_tick;

    my_btn_debounce u_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(btn),
        .tick(w_tick),
        .clean_btn(w_btn_debounce)
    );

    tick_generator u_tick_generator(    
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .input_data(w_seg_data),
        .seg_data(seg),
        .an(an)    
    );

    btn_command_controller u_btn_command_controller(
        .clk(clk),
        .reset(reset),           
        .btn(w_btn_debounce), 
        .sw(sw),
        .seg_data(w_seg_data),
        .led(led)    
        );    

endmodule
