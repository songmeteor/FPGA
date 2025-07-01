`timescale 1ns / 1ps

module tb_gate_test();

    reg i_a;  //slide switch
    reg i_b;     // �����ϸ� wire
    wire [5:0] o_ld;

   //named port ���
    gate_test u_gate_test(   //u_gate_test ��� �̸����� �ν��Ͻ� ����
    .a(i_a),  
    .b(i_b),     
    .ld(o_ld) 
    );

    //a  b
    //0  0
    //0  1
    //1  0
    //1  1
    initial begin
        i_a = 1'b0; i_b = 1'b0;
        #20 i_a = 1'b0; i_b = 1'b1;
        #20 i_a = 1'b1; i_b = 1'b0;
        #20 i_a = 1'b1; i_b = 1'b1;
        #20 $stop;
    end

endmodule
