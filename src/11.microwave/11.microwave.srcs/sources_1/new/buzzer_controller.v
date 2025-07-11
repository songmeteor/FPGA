`timescale 1ns / 1ps

//------------------------------------------------------------------
// buzzer_controller (Refactored v2)
//------------------------------------------------------------------
module buzzer_controller (
    input           clk,
    input           reset,
    input           btnU,
    input           btnL,
    input           btnC,
    input           btnD,
    input           door,    // [추가] 문 센서 입력
    input   [2:0]   mode,
    output  reg     buzzer
);

    // FSM 상태 정의
    localparam S_IDLE         = 4'b0000; // 대기 상태
    localparam S_CLICK        = 4'b0001; // 버튼 클릭/문 개폐음 재생
    localparam S_POWER_1      = 4'b0010; // 파워온 소리 1
    localparam S_POWER_2      = 4'b0011; // 파워온 소리 2
    localparam S_POWER_3      = 4'b0100; // 파워온 소리 3
    localparam S_POWER_4      = 4'b0101; // 파워온 소리 4
    localparam S_FINISH_BEEP  = 4'b0110; // [추가] 종료 알림음
    localparam S_FINISH_PAUSE = 4'b0111; // [추가] 종료 알림음 간격

    // 시스템 모드 파라미터
    localparam M_IDLE   = 3'b000;
    localparam M_FINISH = 3'b100; // [추가]

    // 소리 길이(Duration) 파라미터 (100MHz 클럭 기준)
    localparam DUR_20MS   = 28'd2_000_000;   // 20ms
    localparam DUR_70MS   = 28'd7_000_000;   // 70ms
    localparam DUR_100MS  = 28'd10_000_000;  // 100ms [추가]
    localparam DUR_1S     = 28'd100_000_000; // 1s [추가]

    // 주파수 분주(Divider) 값 파라미터
    localparam DIV_CLICK      = 22'd38222;  // 약 1.3kHz
    localparam DIV_FINISH     = 22'd25000;  // 2kHz [추가]
    localparam DIV_POWER_1KHZ = 22'd50000;
    localparam DIV_POWER_2KHZ = 22'd25000;
    localparam DIV_POWER_3KHZ = 22'd16667;
    localparam DIV_POWER_4KHZ = 22'd12500;

    // FSM 레지스터
    reg [3:0] current_state, next_state;

    // 타이머 및 주파수 생성기
    reg [27:0]  duration_timer;
    reg         duration_timer_start;
    wire        duration_timer_done;
    reg [21:0]  frequency_divider_val;
    reg [21:0]  frequency_counter;
    reg         buzzer_internal;

    // 신호 감지 로직
    wire any_button_pressed = btnU | btnL | btnC | btnD;
    reg  door_prev;
    wire door_opened = door && !door_prev;
    wire door_closed = !door && door_prev;

    //================================================
    // 1. Next-State Logic (조합 회로)
    //================================================
    always @(*) begin
        // 기본값 설정
        next_state = current_state;
        duration_timer_start = 1'b0;
        frequency_divider_val = 0;

        // [수정] FINISH 모드가 최우선 순위
        if (mode == M_FINISH) begin
            case(current_state)
                S_FINISH_BEEP: begin
                    frequency_divider_val = DIV_FINISH;
                    if (duration_timer_done) begin
                        next_state = S_FINISH_PAUSE;
                        duration_timer_start = 1'b1;
                    end
                end
                S_FINISH_PAUSE: begin
                    if (duration_timer_done) begin
                        next_state = S_FINISH_BEEP;
                        duration_timer_start = 1'b1;
                    end
                end
                default: begin // 다른 어떤 상태에 있더라도 FINISH 모드가 되면 알림 시작
                    next_state = S_FINISH_BEEP;
                    duration_timer_start = 1'b1;
                end
            endcase
        end else begin // FINISH 모드가 아닐 때의 기존 로직
            case (current_state)
                S_IDLE: begin
                    if (btnC && (mode == M_IDLE)) begin
                        next_state = S_POWER_1;
                        duration_timer_start = 1'b1;
                    end
                    // [추가] 문 열림/닫힘 또는 버튼 클릭 시
                    else if (any_button_pressed || door_opened || door_closed) begin
                        next_state = S_CLICK;
                        duration_timer_start = 1'b1;
                    end
                end
                S_CLICK: begin
                    frequency_divider_val = DIV_CLICK;
                    if (duration_timer_done) begin
                        next_state = S_IDLE;
                    end
                end
                S_POWER_1: begin
                    frequency_divider_val = DIV_POWER_1KHZ;
                    if (duration_timer_done) begin
                        next_state = S_POWER_2;
                        duration_timer_start = 1'b1;
                    end
                end
                S_POWER_2: begin
                    frequency_divider_val = DIV_POWER_2KHZ;
                    if (duration_timer_done) begin
                        next_state = S_POWER_3;
                        duration_timer_start = 1'b1;
                    end
                end
                S_POWER_3: begin
                    frequency_divider_val = DIV_POWER_3KHZ;
                    if (duration_timer_done) begin
                        next_state = S_POWER_4;
                        duration_timer_start = 1'b1;
                    end
                end
                S_POWER_4: begin
                    frequency_divider_val = DIV_POWER_4KHZ;
                    if (duration_timer_done) begin
                        next_state = S_IDLE;
                    end
                end
                default: begin
                    next_state = S_IDLE;
                end
            endcase
        end
    end

    //================================================
    // 2. State Register & Edge Detection (순차 회로)
    //================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S_IDLE;
            door_prev     <= 0;
        end else begin
            current_state <= next_state;
            door_prev     <= door; // [추가] 문 상태 업데이트
        end
    end

    //================================================
    // 3. 소리 길이 제어 타이머 (순차 회로)
    //================================================
    assign duration_timer_done = (duration_timer == 1);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            duration_timer <= 0;
        end else begin
            if (duration_timer_start) begin
                // [수정] 새로운 상태에 대한 타이머 값 설정 추가
                case(next_state)
                    S_CLICK:        duration_timer <= DUR_20MS;
                    S_POWER_1,
                    S_POWER_2,
                    S_POWER_3,
                    S_POWER_4:      duration_timer <= DUR_70MS;
                    S_FINISH_BEEP:  duration_timer <= DUR_100MS;
                    S_FINISH_PAUSE: duration_timer <= DUR_1S;
                    default:        duration_timer <= 0;
                endcase
            end else if (duration_timer > 0) begin
                duration_timer <= duration_timer - 1;
            end else begin
                duration_timer <= 0;
            end
        end
    end

    //================================================
    // 4. 주파수(톤) 생성기 및 출력 로직 (순차 회로)
    //================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            frequency_counter <= 0;
            buzzer_internal <= 0;
            buzzer <= 0;
        end else begin
            if (current_state == S_IDLE || current_state == S_FINISH_PAUSE) begin
                frequency_counter <= 0;
                buzzer_internal <= 0;
            end else begin
                if (frequency_counter >= frequency_divider_val - 1) begin
                    frequency_counter <= 0;
                    buzzer_internal <= ~buzzer_internal;
                end else begin
                    frequency_counter <= frequency_counter + 1;
                end
            end
            buzzer <= buzzer_internal;
        end
    end

endmodule