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

    // ��ٿ���� ���� wire ����
    wire w_btnU, w_btnC, w_btnR, w_btnD, w_btnL;

    // 5���� ���踦 ���� ī���Ϳ� ���ļ� ��������
    reg [21:0] r_clk_cnt[4:0];
    reg        r_buzzer_frequency[4:0];

    // �� ��ư�� ���� ��ٿ�� ��� �ν��Ͻ�ȭ(��ư ������ �� Ŭ���� 1)
    // button_debounce u_btnU_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    // button_debounce u_btnC_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    // button_debounce u_btnR_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));
    // button_debounce u_btnD_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));
    // button_debounce u_btnL_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));

    // ��ư ������ ������ ��� 1
    button_debounce_2 u_btnU_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    button_debounce_2 u_btnC_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    button_debounce_2 u_btnR_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));
    button_debounce_2 u_btnD_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));
    button_debounce_2 u_btnL_debounce (.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));

    // 1. �� (Do) Note - btnU
    // ���ְ�: 76,444  => ī���� ��ǥ��: 38,222
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_clk_cnt[0] <= 0;
            r_buzzer_frequency[0] <= 0;
        end else begin
            if(!w_btnU) begin // ��ư�� ������ ������ ����
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

    // 2. �� (Re) Note - btnC
    // ���ְ�: 68,104  => ī���� ��ǥ��: 34,052
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

    // 3. �� (Mi) Note - btnR
    // ���ְ�: 60,674  => ī���� ��ǥ��: 30,337
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

    // 4. �� (Sol) Note - btnD
    // ���ְ�: 51,020  => ī���� ��ǥ��: 25,510
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

    // 5. �� (La) Note - btnL
    // ���ְ�: 45,454  => ī���� ��ǥ��: 22,727
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

    // 5�� ���� ��ȣ�� �ϳ��� ���ļ� ������ ���
    assign buzzer = r_buzzer_frequency[0] |
                    r_buzzer_frequency[1] |
                    r_buzzer_frequency[2] |
                    r_buzzer_frequency[3] |
                    r_buzzer_frequency[4];
                    
    // ������� �ʴ� LED ��� ó�� (�ʿ信 ���� ���� ����)
    assign led = 2'b00;

endmodule