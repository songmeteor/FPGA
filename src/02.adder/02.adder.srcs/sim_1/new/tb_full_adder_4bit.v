`timescale 1ns / 1ps

module tb_full_adder_4bit();

    reg [3:0] a;
    reg [3:0] b;
    reg cin;
    wire [3:0] sum;
    wire carry_out;

    full_adder_4bit u_full_adder_4bit(
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .carry_out(carry_out)
    );

    initial begin
        cin = 0;  // �ʱ� cin ����

        #00 a = 0; b = 0;
        #10 a = 0; b = 2;
        #10 a = 7; b = 9;
        #10 a = 9; b = 9;
        #10 a = 7; b = 7;

        // �ݺ� �׽�Ʈ
        for (integer i = 0; i < 20; i = i + 1) begin
            #10 a = i; b = i + 1;
        end

        #10 $finish;
    end

endmodule
