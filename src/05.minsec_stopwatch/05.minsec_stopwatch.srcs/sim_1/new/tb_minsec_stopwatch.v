`timescale 1ns / 1ps

module tb_my_top();

    // 테스트용 입력은 reg, 출력은 wire로 선언
    reg clk;
    reg reset;           
    reg [2:0] btn; 
    reg [7:0] sw;
    wire [7:0] seg;
    wire [3:0] an;
    wire [15:0] led;   

    // DUT 인스턴스
    my_top uut (
        .clk(clk),
        .reset(reset),       
        .btn(btn), 
        .sw(sw),
        .seg(seg),
        .an(an),
        .led(led)
    );

    // 클럭 생성 (10ns 주기 → 100MHz)
    always #5 clk = ~clk;

    initial begin
        // 초기화
        clk = 0;
        reset = 1;
        btn = 3'b000;
        sw  = 8'd0;

        // 1. reset -> 20ms 대기
        #20_000_000;    // 20ms
        reset = 0;

        // 2. btn[0] = 1 -> 3초 대기 -> btn[0] = 0
        btn[0] = 1;
        #1_000_000_000;
        #1_000_000_000;
        #1_000_000_000;
        btn[0] = 0;

        // 3. 20ms 대기
        #20_000_000;

        // 4. btn[0] = 1 -> 20ms 대기
        btn[0] = 1;
        #20_000_000;
        btn[0] = 0;

        // 5. btn[1] = 1 -> 3초 대기 -> btn[1] = 0
        btn[1] = 1;
        #1_000_000_000;
        #1_000_000_000;
        #1_000_000_000;
        btn[1] = 0;

        // 6. 20ms 대기
        #20_000_000;

        // 7. btn[2] = 1 -> 20ms 대기 -> btn[2] = 0
        btn[2] = 1;
        #20_000_000;
        btn[2] = 0;

        // 8. 20ms 대기 -> 시뮬레이션 종료
        #20_000_000;
        $finish;
    end
endmodule