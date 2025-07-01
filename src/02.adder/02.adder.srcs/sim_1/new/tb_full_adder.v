`timescale 1ns / 1ps


module tb_full_adder();

    reg i_a, i_b, i_cin;
    wire o_sum, o_carry_out;

    full_adder u_full_adder(
        .a(i_a),
        .b(i_b),
        .cin(i_cin),
        .sum(o_sum),
        .carry_out(o_carry_out)
    );

    initial begin
        #00 i_a = 1'b0; i_b = 1'b0; i_cin = 1'b0;
        #10 i_a = 1'b0; i_b = 1'b0; i_cin = 1'b1;
        #10 i_a = 1'b0; i_b = 1'b1; i_cin = 1'b0;
        #10 i_a = 1'b0; i_b = 1'b1; i_cin = 1'b1;
        #10 i_a = 1'b1; i_b = 1'b0; i_cin = 1'b0;
        #10 i_a = 1'b1; i_b = 1'b0; i_cin = 1'b1;
        #10 i_a = 1'b1; i_b = 1'b1; i_cin = 1'b0;
        #10 i_a = 1'b1; i_b = 1'b1; i_cin = 1'b1;
        #20 $stop;    
    end

endmodule
