`timescale 1ns / 1ps

module top_buzzer(
    input           clk,
    input           reset,
    input           btnU,
    input           btnC,
    input           btnR,
    input           btnD,
    input           btnL,
    output [1:0]    led,
    output          buzzer
    );

    // 디바운싱을 위한 wire 선언
    wire w_btnU, w_btnC, w_btnR, w_btnD, w_btnL;

    // 5개의 음계를 위한 카운터와 주파수 레지스터
    reg [21:0] r_clk_cnt[4:0];
    reg        r_buzzer_frequency[4:0];

    // 각 버튼에 대한 디바운싱 모듈 인스턴스화(버튼 누르면 한 클럭만 1)
    // button_debounce u_btnU_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    // button_debounce u_btnC_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    // button_debounce u_btnR_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));
    // button_debounce u_btnD_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));
    // button_debounce u_btnL_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));

    // 버튼 누르고 있으면 계속 1
    button_debounce_2 u_btnU_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    button_debounce_2 u_btnC_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    button_debounce_2 u_btnR_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));
    button_debounce_2 u_btnD_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));
    button_debounce_2 u_btnL_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));

    // 1. 도 (Do) Note - btnU
    // 분주값: 76,444  => 카운터 목표값: 38,222
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_clk_cnt[0] <= 0;
            r_buzzer_frequency[0] <= 0;
        end else begin
            if(!w_btnU) begin // 버튼이 눌리지 않으면 리셋
                r_clk_cnt[0] <= 0;
                r_buzzer_frequency[0] <= 0;
            end else begin
                if(r_clk_cnt[0] == 22'd38222 - 1) begin
                    r_clk_cnt[0] <= 0;
                    r_buzzer_frequency[0] <= ~r_buzzer_frequency[0];
                end else begin
                    r_clk_cnt[0] <= r_clk_cnt[0] + 1;
                end
            end
        end
    end

    // 2. 레 (Re) Note - btnC
    // 분주값: 68,104  => 카운터 목표값: 34,052
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_clk_cnt[1] <= 0;
            r_buzzer_frequency[1] <= 0;
        end else begin
            if(!w_btnL) begin
                r_clk_cnt[1] <= 0;
                r_buzzer_frequency[1] <= 0;
            end else begin
                if(r_clk_cnt[1] == 22'd34052 - 1) begin
                    r_clk_cnt[1] <= 0;
                    r_buzzer_frequency[1] <= ~r_buzzer_frequency[1];
                end else begin
                    r_clk_cnt[1] <= r_clk_cnt[1] + 1;
                end
            end
        end
    end

    // 3. 미 (Mi) Note - btnR
    // 분주값: 60,674  => 카운터 목표값: 30,337
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_clk_cnt[2] <= 0;
            r_buzzer_frequency[2] <= 0;
        end else begin
            if(!w_btnC) begin
                r_clk_cnt[2] <= 0;
                r_buzzer_frequency[2] <= 0;
            end else begin
                if(r_clk_cnt[2] == 22'd30337 - 1) begin
                    r_clk_cnt[2] <= 0;
                    r_buzzer_frequency[2] <= ~r_buzzer_frequency[2];
                end else begin
                    r_clk_cnt[2] <= r_clk_cnt[2] + 1;
                end
            end
        end
    end

    // 4. 솔 (Sol) Note - btnD
    // 분주값: 51,020  => 카운터 목표값: 25,510
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_clk_cnt[3] <= 0;
            r_buzzer_frequency[3] <= 0;
        end else begin
            if(!w_btnR) begin
                r_clk_cnt[3] <= 0;
                r_buzzer_frequency[3] <= 0;
            end else begin
                if(r_clk_cnt[3] == 22'd25510 - 1) begin
                    r_clk_cnt[3] <= 0;
                    r_buzzer_frequency[3] <= ~r_buzzer_frequency[3];
                end else begin
                    r_clk_cnt[3] <= r_clk_cnt[3] + 1;
                end
            end
        end
    end

    // 5. 라 (La) Note - btnL
    // 분주값: 45,454  => 카운터 목표값: 22,727
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_clk_cnt[4] <= 0;
            r_buzzer_frequency[4] <= 0;
        end else begin
            if(!w_btnD) begin
                r_clk_cnt[4] <= 0;
                r_buzzer_frequency[4] <= 0;
            end else begin
                if(r_clk_cnt[4] == 22'd22727 - 1) begin
                    r_clk_cnt[4] <= 0;
                    r_buzzer_frequency[4] <= ~r_buzzer_frequency[4];
                end else begin
                    r_clk_cnt[4] <= r_clk_cnt[4] + 1;
                end
            end
        end
    end

    // 5개 음계 신호를 하나로 합쳐서 버저로 출력
    assign buzzer = r_buzzer_frequency[0] |
                    r_buzzer_frequency[1] |
                    r_buzzer_frequency[2] |
                    r_buzzer_frequency[3] |
                    r_buzzer_frequency[4];
                    
    // 사용하지 않는 LED 출력 처리 (필요에 따라 수정 가능)
    assign led = 2'b00;

endmodule