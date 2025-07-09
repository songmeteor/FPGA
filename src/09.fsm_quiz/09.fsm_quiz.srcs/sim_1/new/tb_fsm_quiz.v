`timescale 1ns / 1ps

module tb_fsm;

    // �׽�Ʈ ��ġ�� �������� (Inputs)
    reg clk;
    reg reset;
    reg btnU;
    reg btnD;

    // �׽�Ʈ ��ġ�� ���̾� (Outputs)
    wire ret;
    wire [6:0] led;

    // �׽�Ʈ�� ���(UUT: Unit Under Test) �ν��Ͻ�ȭ
    fsm uut (
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .btnD(btnD),
        .ret(ret),
        .led(led)
    );

    // 1. Ŭ�� ���� (100MHz, 10ns �ֱ�)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 5ns���� Ŭ�� ���
    end

    // 2. �׽�Ʈ �ó�����
    initial begin

        // �ʱ�ȭ �� ����
        reset = 1;
        btnU = 0;
        btnD = 0;
        #20; // 2 Ŭ�� ����Ŭ ���� ���� ����
        reset = 0;
        #10;

        // �ó����� 1: IDLE ���¿��� btnU ������ (XO ���·� ��ȯ)
        btnU = 1;
        #10; // 1 Ŭ�� ����Ŭ ���� ��ư ����
        btnU = 0;
        #10;
        
        #20; // 2 Ŭ�� ����Ŭ ���� ���� ���� Ȯ��

        // �ó����� 2: XO ���¿��� btnD ������ (OZ ���·� ��ȯ)
        btnD = 1;
        #10;
        btnD = 0;
        #10;
        
        #20;

        // �ó����� 3: OZ ���¿��� btnU ������ (OO ���·� ��ȯ)
        btnU = 1;
        #10;
        btnU = 0;
        #10;

        #20;

        // �ó����� 4: OO ���¿��� btnD ������ (�ٽ� OZ ���·� ��ȯ)
        btnD = 1;
        #10;
        btnD = 0;
        #10;

        #50; // ��� ���

        // �ùķ��̼� ����
        $finish;
    end

    // (����) ����͸�: �ùķ��̼� �� ��ȣ ��ȭ�� ��� Ȯ���ϰ� ���� �� ���
    /*
    initial begin
        $monitor("[%0t] clk=%b, reset=%b, btnU=%b, btnD=%b -> led=%b, ret=%b",
                 $time, clk, reset, btnU, btnD, led, ret);
    end
    */

endmodule