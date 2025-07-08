`timescale 1ns/1ps

module tb_vending_machine();
    // 1) 신호 선언
    reg         clk;
    reg         reset;
    reg         btnL, btnC, btnR, btnD;
    wire [13:0] total;
    wire        anim_mode;

    // 2) DUT 인스턴스화
    fsm uut (
        .clk       (clk),
        .reset     (reset),
        .btnL      (btnL),
        .btnC      (btnC),
        .btnR      (btnR),
        .btnD      (btnD),
        .anim_mode (anim_mode),
        .total     (total)
    );

    // 3) 클럭 생성: 100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 주기 10ns
    end

    // 4) 시뮬레이션 자극
    initial begin
        // 초기화
        reset = 1;
        btnL = 0; btnC = 0; btnR = 0; btnD = 0;

        // 리셋 해제
        #100;
        reset = 0;

        // 1) +100 테스트 (btnL)
        #20;
        btnL = 1; #10; btnL = 0;
        #20;

        // 2) -300 테스트 (btnC) — 현재 total<300 이므로 변화 없어야 함
        btnC = 1; #10; btnC = 0;
        #20;

        // 3) +500 테스트 (btnD)
        btnD = 1; #10; btnD = 0;
        #20;

        // 4) -300 테스트 (btnC) — 이제 total>=300 이므로 300만큼 감소
        btnC = 1; #10; btnC = 0;
        #1_000_000_000;

        // 5) 리셋 테스트 (btnR)
        btnR = 1; #10; btnR = 0;
        #20;

        $finish;
    end

endmodule
