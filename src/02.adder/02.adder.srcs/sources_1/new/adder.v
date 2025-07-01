`timescale 1ns / 1ps


module full_adder(
    input a, b, cin,
    output sum, carry_out
);

    wire w_sum1, w_sum2, w_carry_out1, w_carry_out2;

    adder u_half_adder1(
        .a(a), .b(b), .sum(w_sum1), .carry_out(w_carry_out1)
    );
    adder u_half_adder2(
        .a(w_sum1), .b(cin), .sum(w_sum2), .carry_out(w_carry_out2)
    );

    assign sum = w_sum2;
    assign carry_out = w_carry_out1 | w_carry_out2;

endmodule


module adder(
    input a, b,
    output sum, carry_out
    );

    assign sum = a ^ b;
    assign carry_out = a & b;
endmodule
