`timescale 1ns / 1ps


module top_make_buzzer(
    input  clk,
    input  reset,
    input  btnL,
    input  btnR,              // --- �߰� ---
    output buzzer
    );
    wire w_btnL;
    wire w_btnR;              // --- �߰� ---
    wire w_tick;

    reg r_run_buzzer_L;       // --- ���� ---
    reg r_run_buzzer_R;       // --- �߰� ---
    reg [9:0]  r_ms_cnt;
    reg [23:0] r_clk_cnt[7:0];  // --- ����: ī���� �迭 8���� Ȯ�� ---
    reg        r_buzzer_frequency;
    reg [3:0]  r_mode;          // --- ����: ��带 4��Ʈ�� Ȯ�� ---

    button_debounce u_btnL_debounce (
        .i_clk(clk),
        .i_reset(reset),
        .i_btn(btnL),
        .o_btn_clean(w_btnL)
    );
    
    // --- �߰�: btnR ��ٿ ---
    button_debounce u_btnR_debounce (
        .i_clk(clk),
        .i_reset(reset),
        .i_btn(btnR),
        .o_btn_clean(w_btnR)
    );

    tick_generator u_tick_generator(     
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );


    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            r_ms_cnt <= 0;
        end else begin
            // --- ����: L �Ǵ� R ������ ���� ���� �� ī��Ʈ ---
            if(r_run_buzzer_L || r_run_buzzer_R) begin
                if(w_tick) begin
                    if(r_ms_cnt >= 280) begin
                        r_ms_cnt <= 0;
                    end else begin
                        r_ms_cnt <= r_ms_cnt + 1;
                    end   
                end
            end else begin
                r_ms_cnt <= 0;
            end
        end
    end

    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            r_run_buzzer_L <= 0;
            r_run_buzzer_R <= 0; // --- �߰� ---
        end else begin
            // --- ����: ��ư �Է� ó�� ���� ---
            if(w_btnL) begin
                r_run_buzzer_L <= 1;
                r_run_buzzer_R <= 0; // �ٸ� �� ������ ��
            end
            if(w_btnR) begin
                r_run_buzzer_R <= 1;
                r_run_buzzer_L <= 0; // �ٸ� �� ������ ��
            end

            // --- ����: ��� ���� ���� ---
            if(r_run_buzzer_L) begin
                if(r_ms_cnt <= 70)        r_mode = 4'd0;
                else if (r_ms_cnt <= 140) r_mode = 4'd1;
                else if (r_ms_cnt <= 210) r_mode = 4'd2;
                else if (r_ms_cnt < 280)  r_mode = 4'd3;
                else                      r_run_buzzer_L <= 0;
            end else if(r_run_buzzer_R) begin
                if(r_ms_cnt <= 70)        r_mode = 4'd4;
                else if (r_ms_cnt <= 140) r_mode = 4'd5;
                else if (r_ms_cnt <= 210) r_mode = 4'd6;
                else if (r_ms_cnt < 280)  r_mode = 4'd7;
                else                      r_run_buzzer_R <= 0;
            end else begin
                r_mode <= 4'd0; // �� �� ���� ���� �ƴϸ� �⺻ ���
            end
        end
    end

    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            r_clk_cnt[0] <= 0; r_clk_cnt[1] <= 0; r_clk_cnt[2] <= 0; r_clk_cnt[3] <= 0;
            r_clk_cnt[4] <= 0; r_clk_cnt[5] <= 0; r_clk_cnt[6] <= 0; r_clk_cnt[7] <= 0; // --- �߰� ---
            r_buzzer_frequency <= 0;
        end else begin
            case (r_mode)
                4'd0 : begin // 1KHz
                    r_clk_cnt[1]<=0; r_clk_cnt[2]<=0; r_clk_cnt[3]<=0; r_clk_cnt[4]<=0; r_clk_cnt[5]<=0; r_clk_cnt[6]<=0; r_clk_cnt[7]<=0;
                    if(r_clk_cnt[0] == 24'd50000 - 1) begin r_clk_cnt[0] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[0] <= r_clk_cnt[0] + 1; end
                end
                4'd1 : begin // 2KHz
                    r_clk_cnt[0]<=0; r_clk_cnt[2]<=0; r_clk_cnt[3]<=0; r_clk_cnt[4]<=0; r_clk_cnt[5]<=0; r_clk_cnt[6]<=0; r_clk_cnt[7]<=0;
                    if(r_clk_cnt[1] == 24'd25000 - 1) begin r_clk_cnt[1] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[1] <= r_clk_cnt[1] + 1; end
                end
                4'd2 : begin // 3KHz
                    r_clk_cnt[0]<=0; r_clk_cnt[1]<=0; r_clk_cnt[3]<=0; r_clk_cnt[4]<=0; r_clk_cnt[5]<=0; r_clk_cnt[6]<=0; r_clk_cnt[7]<=0;
                    if(r_clk_cnt[2] == 24'd16667 - 1) begin r_clk_cnt[2] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[2] <= r_clk_cnt[2] + 1; end
                end
                4'd3 : begin // 4KHz
                    r_clk_cnt[0]<=0; r_clk_cnt[1]<=0; r_clk_cnt[2]<=0; r_clk_cnt[4]<=0; r_clk_cnt[5]<=0; r_clk_cnt[6]<=0; r_clk_cnt[7]<=0;
                    if(r_clk_cnt[3] == 24'd12500 - 1) begin r_clk_cnt[3] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[3] <= r_clk_cnt[3] + 1; end
                end
                // --- �߰�: btnR ���ļ� ���� ���� ---
                4'd4 : begin // 261Hz
                    r_clk_cnt[0]<=0; r_clk_cnt[1]<=0; r_clk_cnt[2]<=0; r_clk_cnt[3]<=0; r_clk_cnt[5]<=0; r_clk_cnt[6]<=0; r_clk_cnt[7]<=0;
                    if(r_clk_cnt[4] == 24'd191571 - 1) begin r_clk_cnt[4] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[4] <= r_clk_cnt[4] + 1; end
                end
                4'd5 : begin // 329Hz
                    r_clk_cnt[0]<=0; r_clk_cnt[1]<=0; r_clk_cnt[2]<=0; r_clk_cnt[3]<=0; r_clk_cnt[4]<=0; r_clk_cnt[6]<=0; r_clk_cnt[7]<=0;
                    if(r_clk_cnt[5] == 24'd151976 - 1) begin r_clk_cnt[5] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[5] <= r_clk_cnt[5] + 1; end
                end
                4'd6 : begin // 392Hz
                    r_clk_cnt[0]<=0; r_clk_cnt[1]<=0; r_clk_cnt[2]<=0; r_clk_cnt[3]<=0; r_clk_cnt[4]<=0; r_clk_cnt[5]<=0; r_clk_cnt[7]<=0;
                    if(r_clk_cnt[6] == 24'd127551 - 1) begin r_clk_cnt[6] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[6] <= r_clk_cnt[6] + 1; end
                end
                4'd7 : begin // 554Hz
                    r_clk_cnt[0]<=0; r_clk_cnt[1]<=0; r_clk_cnt[2]<=0; r_clk_cnt[3]<=0; r_clk_cnt[4]<=0; r_clk_cnt[5]<=0; r_clk_cnt[6]<=0;
                    if(r_clk_cnt[7] == 24'd90253 - 1) begin r_clk_cnt[7] <= 0; r_buzzer_frequency <= ~r_buzzer_frequency; end
                    else begin r_clk_cnt[7] <= r_clk_cnt[7] + 1; end
                end
                default : ;
            endcase
        end
    end

    // --- ����: L �Ǵ� R ������ ���� ���� �� ��� ---
    assign buzzer = (r_run_buzzer_L || r_run_buzzer_R) ? r_buzzer_frequency : 0;

endmodule    
