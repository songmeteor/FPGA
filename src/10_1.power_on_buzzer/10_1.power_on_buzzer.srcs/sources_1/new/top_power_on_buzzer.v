`timescale 1ns / 1ps

module top_power_on_buzzer(
    input  clk,
    input  reset,
    input  btnL,
    output buzzer
    );

    wire w_btnL;
    wire w_tick;

    reg        r_run_buzzer;
    reg [9:0]  r_ms_cnt;
    reg [23:0] r_clk_cnt[3:0];
    reg        r_buzzer_frequency;
    reg [2:0]  r_mode;

    button_debounce u_btnL_debounce (
        .i_clk(clk),
        .i_reset(reset),
        .i_btn(btnL),
        .o_btn_clean(w_btnL)
        );

    tick_generator u_tick_generator(    
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );


    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            r_ms_cnt <= 0;
        end else begin
            if(r_run_buzzer) begin
                if(w_tick) begin
                    if(r_ms_cnt >= 280) begin
                        r_ms_cnt <= 0;
                    end else begin
                        r_ms_cnt <= r_ms_cnt + 1;
                    end   
                end else begin
                    r_ms_cnt <= r_ms_cnt;
                end
            end else begin
                r_ms_cnt <= 0;
            end
        end
    end

    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            r_run_buzzer <= 0;
        end else begin
            if(w_btnL) begin
                r_run_buzzer <= 1;
            end else begin
                r_run_buzzer <= r_run_buzzer;
            end

            if(r_run_buzzer) begin
                if(r_ms_cnt <= 70)        r_mode = 2'b00;
                else if (r_ms_cnt <= 140) r_mode = 2'b01;
                else if (r_ms_cnt <= 210) r_mode = 2'b10;
                else if (r_ms_cnt < 280)  r_mode = 2'b11;
                else  begin               r_mode = 2'b00;  r_run_buzzer <= 0; end
            end        
        end
    end

    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            r_clk_cnt[0] <= 0; r_clk_cnt[1] <= 0; r_clk_cnt[2] <= 0; r_clk_cnt[3] <= 0;
            r_buzzer_frequency <= 0;
        end else begin
            case (r_mode)
                2'b00 : begin
                    r_clk_cnt[1] <= 0; r_clk_cnt[2] <= 0; r_clk_cnt[3] <= 0;
                    if(r_clk_cnt[0] == 24'd50000 - 1) begin
                        r_clk_cnt[0] <= 0;
                        r_buzzer_frequency <= ~r_buzzer_frequency;
                    end else begin
                        r_clk_cnt[0] <= r_clk_cnt[0] + 1;
                    end                    
                end
                2'b01 : begin
                    r_clk_cnt[0] <= 0; r_clk_cnt[2] <= 0; r_clk_cnt[3] <= 0;
                    if(r_clk_cnt[1] == 24'd25000 - 1) begin
                        r_clk_cnt[1] <= 0;
                        r_buzzer_frequency <= ~r_buzzer_frequency;
                    end else begin
                        r_clk_cnt[1] <= r_clk_cnt[1] + 1;
                    end                     
                end
                2'b10 : begin
                    r_clk_cnt[0] <= 0; r_clk_cnt[1] <= 0; r_clk_cnt[3] <= 0;
                    if(r_clk_cnt[2] == 24'd16667 - 1) begin
                        r_clk_cnt[2] <= 0;
                        r_buzzer_frequency <= ~r_buzzer_frequency;
                    end else begin
                        r_clk_cnt[2] <= r_clk_cnt[2] + 1;
                    end                 
                end
                2'b11 : begin
                    r_clk_cnt[0] <= 0; r_clk_cnt[1] <= 0; r_clk_cnt[2] <= 0;
                    if(r_clk_cnt[3] == 24'd12500 - 1) begin
                        r_clk_cnt[3] <= 0;
                        r_buzzer_frequency <= ~r_buzzer_frequency;
                    end else begin
                        r_clk_cnt[3] <= r_clk_cnt[3] + 1;
                    end                 
                end
                default : ;                                                 
            endcase 
        end
    end

    assign buzzer = (r_run_buzzer) ? r_buzzer_frequency : 0;
endmodule
