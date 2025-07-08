`timescale 1ns / 1ps

module shift_register(
    input         clk,
    input         reset,
    input         btnU,
    input         btnD,
    output [6:0]  dout
    );

    reg       btnU_prev;
    reg       btnD_prev;
    reg [6:0] sr7 = 7'b0;

    wire btnU_posedge =  btnU & ~btnU_prev;
    wire btnD_posedge =  btnD & ~btnD_prev;

    always @ (posedge clk or posedge reset)
    begin
        if(reset) begin
            sr7 <= 7'b0;
            btnU_prev <= 0;
            btnD_prev <= 0;
        end
        else begin
            btnU_prev <= btnU;
            btnD_prev <= btnD;
            if     (btnU_posedge) sr7 <= {sr7[5:0], 1'b1};
            else if(btnD_posedge) sr7 <= {sr7[5:0], 1'b0};
            else sr7 <= sr7;
        end
    end

    assign dout = sr7;
    
endmodule


