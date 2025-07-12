`timescale 1ns / 1ps

module tb_microwave;

    // -- Parameters --
    localparam CLK_PERIOD = 10; // 100MHz Clock
    localparam ONE_SECOND = 1_000_000_000;
    localparam MS_300 = 300_000_000;
    localparam MS_500 = 500_000_000;
    localparam SHORT_DELAY = 20000; // 2만 클럭 (의미 없는 짧은 시간)

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
    top_microwave uut ( .clk(clk), .reset(reset), .btnU(btnU), .btnL(btnL), .btnC(btnC), .btnD(btnD), .door(door), .seg(seg), .an(an), .buzzer(buzzer), .in1_in2(in1_in2), .servo(servo), .dc_motor(dc_motor) );

    // -- Clock Generator --
    always #((CLK_PERIOD) / 2) clk = ~clk;

    // -- Main Test Scenario --
    initial begin
        
        // -- 0. Initialization & Reset --
        $display("--------------------------------------------------");
        $display("--- Testbench Started ---");
        $display("--------------------------------------------------");
        clk = 0; reset = 1; btnU = 0; btnL = 0; btnC = 0; btnD = 0; door = 0;
        #(CLK_PERIOD * 10);
        reset = 0;
        $display("[%0t ns] System Reset Released. Initial state: IDLE", $time);
        #(CLK_PERIOD * 10);

        // -- 1. Set Time to 30 seconds --
        $display("[%0t ns] Moving to SET mode...", $time);
        press_button(btnC);
        #(SHORT_DELAY);
        $display("[%0t ns] Setting time to 30s...", $time);
        press_button(btnU);
        #(SHORT_DELAY);

        // -- 2. Try to start with door open --
        $display("[%0t ns] Opening door and trying to start (should fail)...", $time);
        door = 1;
        #(SHORT_DELAY);
        press_button(btnC);
        #(SHORT_DELAY);

        // -- 3. Close door and Start --
        $display("[%0t ns] Closing door and starting...", $time);
        door = 0;
        #(SHORT_DELAY);
        press_button(btnC);
        $display("[%0t ns] Microwave started. Mode should be RUN.", $time);

        // -- 4. Observe RUN mode and FND toggle --
        // 가짜 1초가 10000클럭이므로, 7번의 1초 틱을 보려면 70000 클럭 이상만 기다리면 됨
        #(SHORT_DELAY * 4); // 8만 클럭 대기 (충분함)

        // -- 5. Pause operation --
        $display("[%0t ns] Pausing microwave (RUN -> STOP)...", $time);
        press_button(btnC);
        #(SHORT_DELAY);
        
        // --- 이런 식으로 모든 긴 지연 시간을 SHORT_DELAY로 대체 ---

        // -- 8. Let it finish --
        $display("[%0t ns] Waiting for cooking to finish...", $time);
        #(SHORT_DELAY * 15); // 남은 가짜 시간(30-7=23초)이 모두 지나갈 만큼 충분히 대기
        $display("[%0t ns] Cooking should be finished. Mode should be FINISH.", $time);

        // -- 9. Observe FINISH mode beeping --
        #(SHORT_DELAY * 4); // 가짜 1초 간격의 비프음을 몇 번 볼 수 있을 만큼 대기

        $display("[%0t ns] FINISH mode complete. FSM should move to SET/IDLE.", $time);
        #(ONE_SECOND);

        // -- 10. End Simulation --
        $display("--------------------------------------------------");
        $display("--- Testbench Finished ---");
        $display("--------------------------------------------------");
        $finish;
    end

    // -- Task for simulating a button press --
    task press_button;
        input button_to_press;
        begin
            @(posedge clk);
            button_to_press = 1;
            #(100_000_000);
            button_to_press = 0;
            @(posedge clk);
        end
    endtask

endmodule