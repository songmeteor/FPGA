`timescale 1ns / 1ps

module my_btn_debounce(
    input clk,
    input reset,
    input noise_btn,
    output reg clean_btn
);

    parameter COUNTER_10MS = 1000000;
    reg [$clog2(COUNTER_10MS)-1:0] counter;
    reg previous_btn_state;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            counter <= 0;
            clean_btn <= 0;
        end else begin
            if(!noise_btn == previous_btn_state) begin
                counter <= COUNTER_10MS;
            end else begin
                if(counter == 0) begin
                    clean_btn <= noise_btn;
                end else begin
                    counter <= counter-1;
                end
            end
        end
    end
endmodule
