`timescale 1ns / 1ps

module D_FF(
    input i_clk,
    input i_reset,
    input D,
    output reg Q
    );

    always @(posedge i_clk, posedge i_reset) begin // 8Hz
        if(i_reset) begin
            Q <= 0;
        end else begin
            Q <= D;
        end
    end 
endmodule
