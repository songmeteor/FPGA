`timescale 1ns / 1ps

// 이 테스트벤치는 디자인 파일에 `ifdef` 수정이 없는 원본 코드용입니다.

module tb_microwave;

    // -- Parameters --
    localparam CLK_PERIOD    = 10; // 100MHz Clock

    // -- Testbench Signals --
    reg         clk;
    reg         reset;
    reg         btnU, btnL, btnC, btnD;
    reg         door;

    wire [7:0]  seg;
    wire [3:0]  an;
    wire        buzzer;
    wire [1:0]  in1_in2;
    wire        servo;
    wire        dc_motor;

    // -- Instantiate the DUT --
    top_microwave uut (
        .clk(clk), .reset(reset), .btnU(btnU), .btnL(btnL), .btnC(btnC), .btnD(btnD),
        .door(door), .seg(seg), .an(an), .buzzer(buzzer), .in1_in2(in1_in2),
        .servo(servo), .dc_motor(dc_motor)
    );

    // -- Clock Generator --
    always #((CLK_PERIOD) / 2) clk = ~clk;

    // -- Main Test Scenario --
    initial begin
        // -- 0. Initialization & Reset --
        $display("--------------------------------------------------");
        $display("--- Custom Test Scenario Started (for Original Design) ---");
        $display("--------------------------------------------------");
        clk = 0; reset = 1; btnU = 0; btnL = 0; btnC = 0; btnD = 0; door = 0;
        #(CLK_PERIOD * 10);
        reset = 0;
        $display("[%0t ns] System Reset Released. Initial state: IDLE", $time);
        #(150_000_000); // 150ms 대기

        // -- 1. 초기상태에서 btnC 눌러서 SET 모드 --
        $display("[%0t ns] STEP 1: Pressing btnC to enter SET mode.", $time);
        press_button(btnC);
        #(150_000_000);

        // -- 2. btnU 두번, btnD 한번 눌러서 run_time 변하는거 체크 --
        $display("[%0t ns] STEP 2: Setting time (U -> U -> D). Should be 30s.", $time);
        press_button(btnU); // +30s
        #(150_000_000);
        press_button(btnU); // +30s -> 60s
        #(150_000_000);
        press_button(btnD); // -30s -> 30s
        #(150_000_000);

        // -- 3. btnC 눌러서 RUN 상태에서 100ms 대기 --
        $display("[%0t ns] STEP 3: Pressing btnC to enter RUN mode.", $time);
        press_button(btnC);
        $display("[%0t ns] Now in RUN mode. Waiting for 100ms...", $time);
        #(100_000_000); // 정확히 100ms 대기

        // -- 4. 이상태에서 door open 해서 STOP 상태로 변하는지 체크 --
        $display("[%0t ns] STEP 4: Opening door during RUN. Should go to STOP mode.", $time);
        door = 1;
        #(150_000_000);

        // -- 5. 다시 close 하고 btnC 눌러서 RUN --
        $display("[%0t ns] STEP 5: Closing door and pressing btnC to resume RUN mode.", $time);
        door = 0;
        #(150_000_000);
        press_button(btnC);
        #(150_000_000);

        // -- 6. btnL 눌러서 SET 모드로 바뀌는지 체크 --
        $display("[%0t ns] STEP 6: Pressing btnL during RUN. Should go back to SET mode.", $time);
        press_button(btnL);
        #(150_000_000);

        // -- 7. End Simulation --
        $display("--------------------------------------------------");
        $display("--- Custom Test Scenario Finished ---");
        $display("--------------------------------------------------");
        $finish;
    end

    // -- Task for simulating a button press --
    task press_button;
        input button_to_press;
        begin
            @(posedge clk);
            button_to_press = 1;
            // [수정] 실제 디바운서 시간(100ms)에 맞춤
            #(100_000_000);
            button_to_press = 0;
            @(posedge clk);
        end
    endtask

endmodule