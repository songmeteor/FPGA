`timescale 1ns / 1ps

module tb_my_btn_debounce();
    reg clk;
    reg reset;
    reg noise_btn;
    wire tick;
    wire clean_btn;

    my_btn_debounce u_my_btn_debounce(
        .clk(clk),
        .reset(reset),
        .noise_btn(noise_btn),
        .tick(tick),
        .clean_btn(clean_btn)
    );

    tick_generator u_tick_generator(    
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        #0 reset = 0; noise_btn = 0;
        #10 reset = 1; 
        #20 reset = 0; noise_btn = 1;
        #20 noise_btn = 0;
        #20 noise_btn = 1;
        #20 noise_btn = 0;
        #20 noise_btn = 1;
        #20 noise_btn = 0;
        #20 noise_btn = 1;
        #30_000_000 noise_btn = 0;
        #20 noise_btn = 1;
        #20 noise_btn = 0;
        #20 noise_btn = 1;
        #20 noise_btn = 0;
        #20 noise_btn = 1;
        #10 noise_btn = 0;
        #30_000_000;
        $stop;
    end
    
endmodule