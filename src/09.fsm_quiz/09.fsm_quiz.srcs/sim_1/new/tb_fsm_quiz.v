`timescale 1ns / 1ps

module tb_fsm;

    // 테스트 벤치용 레지스터 (Inputs)
    reg clk;
    reg reset;
    reg btnU;
    reg btnD;

    // 테스트 벤치용 와이어 (Outputs)
    wire ret;
    wire [6:0] led;

    // 테스트할 모듈(UUT: Unit Under Test) 인스턴스화
    fsm uut (
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .btnD(btnD),
        .ret(ret),
        .led(led)
    );

    // 1. 클럭 생성 (100MHz, 10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 5ns마다 클럭 토글
    end

    // 2. 테스트 시나리오
    initial begin

        // 초기화 및 리셋
        reset = 1;
        btnU = 0;
        btnD = 0;
        #20; // 2 클럭 사이클 동안 리셋 유지
        reset = 0;
        #10;

        // 시나리오 1: IDLE 상태에서 btnU 누르기 (XO 상태로 전환)
        btnU = 1;
        #10; // 1 클럭 사이클 동안 버튼 누름
        btnU = 0;
        #10;
        
        #20; // 2 클럭 사이클 동안 상태 유지 확인

        // 시나리오 2: XO 상태에서 btnD 누르기 (OZ 상태로 전환)
        btnD = 1;
        #10;
        btnD = 0;
        #10;
        
        #20;

        // 시나리오 3: OZ 상태에서 btnU 누르기 (OO 상태로 전환)
        btnU = 1;
        #10;
        btnU = 0;
        #10;

        #20;

        // 시나리오 4: OO 상태에서 btnD 누르기 (다시 OZ 상태로 전환)
        btnD = 1;
        #10;
        btnD = 0;
        #10;

        #50; // 잠시 대기

        // 시뮬레이션 종료
        $finish;
    end

    // (선택) 모니터링: 시뮬레이션 중 신호 변화를 계속 확인하고 싶을 때 사용
    /*
    initial begin
        $monitor("[%0t] clk=%b, reset=%b, btnU=%b, btnD=%b -> led=%b, ret=%b",
                 $time, clk, reset, btnU, btnD, led, ret);
    end
    */

endmodule