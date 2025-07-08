`timescale 1ns / 1ps

module tb_fsm2;
    // 1) ��ȣ ����
    reg  clk;
    reg  rstn;
    reg  go;
    reg  ws;
    wire rd;
    wire ds;

    // 2) DUT �ν��Ͻ�ȭ
    fsm2 uut (
        .clk  (clk),
        .rstn (rstn),
        .go   (go),
        .ws   (ws),
        .rd   (rd),
        .ds   (ds)
    );

    // 3) Ŭ�� �߻���: �ֱ� 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    // 4) �ڱ�(stimulus) ������
    initial begin
        // �ʱ�ȭ
        rstn = 0; 
        go   = 0; 
        ws   = 0;
        #20;        // 0~20ns: reset ����

        rstn = 1;   // 20ns���� reset ����
        #10;        // 20~30ns: IDLE ���� ����

        //���� 1) IDLE -> READ (go = 1 �޽�)
        go = 1;
        #10;        // 30~40ns: CLK rising ���� READ ����
        go = 0;
        #20;        // 40~60ns: READ -> DLY -> DONE �Ǵ� READ �ݺ� ����

        //���� 2) DLY ���¿��� ws=1�� �� READ�� ����
        ws = 1;
        #10;        // 60~70ns: DLY->READ
        ws = 0;
        #20;        // 70~90ns: READ->DLY

        //���� 3) DLY ���¿��� ws=0�� �� DONE���� ����
        // ws�� �̹� 0�̹Ƿ� �״�� ����
        #20;        // 90~110ns: DLY->DONE->IDLE

        #20;        // 110~130ns: IDLE���� ���� ��� Ȯ��
        $finish;
    end
endmodule
