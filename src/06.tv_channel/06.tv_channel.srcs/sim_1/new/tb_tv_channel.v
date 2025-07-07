`timescale 1ns / 1ps

module tb_tv_channel();

    reg clk;
    reg rstn;
    reg up;
    reg dn;
    wire [3:0] ch;


    tv_channel u_tv_channel(
        .clk(clk),
        .rstn(rstn),
        .up(up),
        .dn(dn),
        .ch(ch)
        );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rstn = 0;
        up = 0;
        dn = 0;

        #12;           
        rstn = 1;      
        #20;  

        repeat(11) begin
        #15 up = 1;
    end
       #20 $finish;
    end
endmodule
