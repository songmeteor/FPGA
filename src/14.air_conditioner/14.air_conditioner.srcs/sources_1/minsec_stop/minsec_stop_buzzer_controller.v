`timescale 1ns / 1ps

//==================================================================
// minsec_stop_buzzer_controller
// 기능: 4개의 버튼 중 하나라도 눌리면 100ms 동안 클릭음을 발생시킵니다.
//       버튼 입력이 Tick이 아닌 Level 방식이므로 엣지 감지 로직을 포함합니다.
//==================================================================
module minsec_stop_buzzer_controller(
    input           clk,
    input           reset,
    input           btnU,
    input           btnC,
    input           btnD,

    output          buzzer
    );

    // FSM 상태 정의
    localparam S_IDLE       = 1'b0; // 대기 상태
    localparam S_PLAY_SOUND = 1'b1; // 소리 재생 상태

    // 소리 길이 파라미터 (100MHz 클럭 기준)
    localparam DUR_100MS = 24'd10_000_000; // 100ms

    // 주파수 분주 값 파라미터 (100MHz 클럭 기준 약 1.3kHz)
    localparam DIV_CLICK = 16'd38222;

    // FSM 레지스터
    reg current_state, next_state;

    // 타이머 및 주파수 생성기 레지스터
    reg [23:0] duration_timer;
    reg [15:0] frequency_counter;
    reg        buzzer_internal;

    // 신호 감지 로직 (엣지 감지용)
    wire any_button_pressed;
    reg  any_button_pressed_prev;
    wire button_tick;


    //================================================
    // 1. 버튼 엣지 감지 로직
    // 어떤 버튼이든 눌리면 1로 만들고, 이전 클럭과 비교하여
    // 눌리는 순간(rising edge)에만 1클럭 길이의 'button_tick' 신호를 생성합니다.
    //================================================
    assign any_button_pressed = btnU | btnC | btnD;
    assign button_tick = any_button_pressed && !any_button_pressed_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            any_button_pressed_prev <= 1'b0;
        end else begin
            any_button_pressed_prev <= any_button_pressed;
        end
    end


    //================================================
    // 2. FSM (Finite State Machine)
    //================================================

    // 2-1. Next-State Logic (조합 회로)
    // 현재 상태와 입력(button_tick)에 따라 다음 상태를 결정합니다.
    always @(*) begin
        next_state = current_state; // 기본적으로 현재 상태 유지
        case (current_state)
            S_IDLE: begin
                if (button_tick) begin
                    next_state = S_PLAY_SOUND; // 버튼이 눌리면 소리 재생 상태로 전환
                end
            end
            S_PLAY_SOUND: begin
                if (duration_timer == 1) begin // 타이머가 끝나면
                    next_state = S_IDLE;       // 대기 상태로 복귀
                end
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // 2-2. State Register (순차 회로)
    // clk에 맞춰 현재 상태를 다음 상태로 업데이트합니다.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end


    //================================================
    // 3. 소리 길이 제어 타이머
    // S_PLAY_SOUND 상태가 되면 DUR_100MS에서 1씩 감소합니다.
    //================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            duration_timer <= 0;
        end else begin
            // S_PLAY_SOUND 상태로 처음 진입할 때 타이머를 설정합니다.
            if (current_state == S_IDLE && next_state == S_PLAY_SOUND) begin
                duration_timer <= DUR_100MS;
            end
            // 타이머가 0보다 크면 계속 카운트 다운합니다.
            else if (duration_timer > 0) begin
                duration_timer <= duration_timer - 1;
            end
        end
    end


    //================================================
    // 4. 주파수(톤) 생성 및 최종 출력
    //================================================

    // 주파수 카운터 및 내부 버저 신호 생성
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            frequency_counter <= 0;
            buzzer_internal   <= 1'b0;
        end else begin
            // 소리 재생 상태일 때만 주파수 카운터가 동작합니다.
            if (current_state == S_PLAY_SOUND) begin
                if (frequency_counter >= DIV_CLICK - 1) begin
                    frequency_counter <= 0;
                    buzzer_internal   <= ~buzzer_internal; // 주파수에 맞춰 토글
                end else begin
                    frequency_counter <= frequency_counter + 1;
                end
            end else begin
                frequency_counter <= 0; // 다른 상태에서는 카운터와 버저 신호를 초기화
                buzzer_internal   <= 1'b0;
            end
        end
    end

    // 최종 버저 출력: 소리 재생 상태(S_PLAY_SOUND)일 때만 내부 버저 신호를 출력합니다.
    assign buzzer = (current_state == S_PLAY_SOUND) ? buzzer_internal : 1'b0;

endmodule