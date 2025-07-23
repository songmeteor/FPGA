`timescale 1ns / 1ps

module FIFO #(parameter width=8, parameter depth=16) (
    input             clk,
    input             reset,
    input             we,
    input             re,
    input [width-1:0] din,

    output reg [width-1:0] dout,
    output                 empty,
    output                 full
    );

    reg [width-1 : 0] mem [depth-1:0];

    reg[$clog2(depth)-1:0] pop,push;

    assign empty = (pop == push);
    assign full  = (depth == push + 1);

//push
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            push <= 0;
        end else begin
            if(!full && we) begin
                mem[push] <= din;
                push <= push + 1;
            end
        end
    end
    
//pop
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            pop <= 0;
        end else begin
            if(!empty && re) begin
                pop <= pop + 1;
                dout <= mem[pop];
            end 
        end
    end
 endmodule
