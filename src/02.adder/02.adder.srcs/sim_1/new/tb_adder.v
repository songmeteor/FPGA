`timescale 1ns / 1ps


module tb_adder();

    reg i_a, i_b;
    wire o_sum, o_carry_out;

    adder u_adder(
        .a(i_a),
        .b(i_b),
        .sum(o_sum),
        .carry_out(o_carry_out)
    );

    initial begin
        i_a = 1'b0; i_b = 1'b0;
        #20 i_a = 1'b0; i_b = 1'b1;
        #20 i_a = 1'b1; i_b = 1'b0;
        #20 i_a = 1'b1; i_b = 1'b1;
        #20 $stop;    
    end

endmodule
