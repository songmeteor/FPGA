`timescale 1ns / 1ps

module tb_fsm2;
    // 1) 신호 선언
    reg  clk;
    reg  rstn;
    reg  go;
    reg  ws;
    wire rd;
    wire ds;

    // 2) DUT 인스턴스화
    fsm2 uut (
        .clk  (clk),
        .rstn (rstn),
        .go   (go),
        .ws   (ws),
        .rd   (rd),
        .ds   (ds)
    );

    // 3) 클럭 발생기: 주기 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    // 4) 자극(stimulus) 시퀀스
    initial begin
        // 초기화
        rstn = 0; 
        go   = 0; 
        ws   = 0;
        #20;        // 0~20ns: reset 유지

        rstn = 1;   // 20ns에서 reset 해제
        #10;        // 20~30ns: IDLE 상태 관찰

        //── 1) IDLE -> READ (go = 1 펄스)
        go = 1;
        #10;        // 30~40ns: CLK rising 에서 READ 진입
        go = 0;
        #20;        // 40~60ns: READ -> DLY -> DONE 또는 READ 반복 관찰

        //── 2) DLY 상태에서 ws=1일 때 READ로 복귀
        ws = 1;
        #10;        // 60~70ns: DLY->READ
        ws = 0;
        #20;        // 70~90ns: READ->DLY

        //── 3) DLY 상태에서 ws=0일 때 DONE으로 진행
        // ws가 이미 0이므로 그대로 유지
        #20;        // 90~110ns: DLY->DONE->IDLE

        #20;        // 110~130ns: IDLE에서 최종 출력 확인
        $finish;
    end
endmodule
