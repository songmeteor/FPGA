`timescale 1ns / 1ps

module buzzer_controller(
    input clk,
    input reset,
    input btnU,
    input btnL,
    input btnC,
    input btnD,
    input mode,
    output reg buzzer
    );

    parameter IDLE   = 3'b000,
              SET    = 3'b001,
              RUN    = 3'b010,
              STOP   = 3'b011,
              FINISH = 3'b100;

    wire w_click_buzzer;   
    wire w_power_buzzer;
    wire w_power_sound_active;       

    btn_click_sound u_btn_click_sound(
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .btnL(btnL),
        .btnC(btnC),
        .btnD(btnD),
        .buzzer(w_click_buzzer)   
    );

    btn_power_sound u_btn_power_sound(
        .clk(clk),
        .reset(reset),
        .btnC(btnC),
        .mode(mode),
        .buzzer(w_power_buzzer),   
        .power_sound_active(w_power_sound_active)
    );    

    always @(*) begin
        if (w_power_sound_active) begin
            buzzer = w_power_buzzer; 
        end
        else begin
            buzzer = w_click_buzzer; 
        end
    end

endmodule

module btn_click_sound(
    input clk,
    input reset,
    input btnU,
    input btnL,
    input btnC,
    input btnD,
    output buzzer   
    );

    parameter TIME_20MS = 2_000_000;

    parameter N = 1'b0;
    parameter P = 1'b1;

    reg [27:0] step_timer;
    reg        current_state;
    reg        next_state;
    reg        count_20ms;
    reg        r_buzzer_frequency;
    reg [21:0] clk_div;    

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            step_timer <= 0;
        end else if ((step_timer == TIME_20MS-1)) begin
            step_timer <= 0;
            count_20ms <= 1;
        end else if(current_state == N) begin
            step_timer <= 0;
            count_20ms <= 0;
        end
        else
            step_timer <= step_timer + 1;
    end    

    always @(*) begin
        case(current_state)
            N : begin
                if(btnU || btnL || btnC || btnD) next_state = P;
                else                             next_state = N;
            end
            P : begin
                if(count_20ms) next_state = N;
                else           next_state = P;
            end
        endcase
    end

    always @ (posedge clk, posedge reset) 
    begin
        if(reset) current_state <= N;
        else      current_state <= next_state;
    end

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            clk_div <= 0;
            r_buzzer_frequency <= 0;
        end else begin
            if(current_state == N) begin 
                clk_div <= 0;
                r_buzzer_frequency <= 0;
            end else begin
                if(clk_div == 22'd38222 - 1) begin
                    clk_div <= 0;
                    r_buzzer_frequency <= ~r_buzzer_frequency;
                end else begin
                    clk_div <= clk_div + 1;
                end
            end
        end
    end

    assign buzzer = r_buzzer_frequency;    

endmodule


module btn_power_sound(
    input clk,
    input reset,
    input btnC,
    input mode,
    output buzzer,
    output power_sound_active   
    );

    parameter TIME_70MS = 7_000_000;

    parameter N = 3'b000;
    parameter DIV_1KHZ = 3'b001;
    parameter DIV_2KHZ = 3'b010;
    parameter DIV_3KHZ = 3'b011;
    parameter DIV_4KHZ = 3'b100;

    parameter IDLE   = 3'b000,
              SET    = 3'b001,
              RUN    = 3'b010,
              STOP   = 3'b011,
              FINISH = 3'b100;    

    reg [27:0] step_timer;
    reg [2:0]  current_state;
    reg [2:0]  next_state;
    reg        count_70ms;
    reg        r_buzzer_frequency;
    reg [21:0] clk_div[3:0];    

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            step_timer <= 0;
            count_70ms <= 0;
        // IDLE 상태에서는 타이머와 신호를 모두 초기화
        end else if(current_state == N) begin
            step_timer <= 0;
            count_70ms <= 0;
        // 그 외의 활성 상태(소리 재생 중)일 때
        end else begin
            // 타이머가 70ms에 도달했다면
            if (step_timer == TIME_70MS - 1) begin
                step_timer <= 0;  // 다음 상태를 위해 타이머를 다시 0부터 시작
                count_70ms <= 1;  // FSM에 상태를 바꾸라는 신호를 보냄 (단 한 클럭 동안만!)
            // 타이머가 아직 70ms에 도달하지 못했다면
            end else begin
                step_timer <= step_timer + 1; // 타이머를 계속 증가
                count_70ms <= 0;              // ★★★ 핵심: 신호는 0으로 유지 ★★★
            end
        end
    end   

    always @(*) begin
        case(current_state)
            N : begin
                if(btnC && (mode == IDLE))       next_state = DIV_1KHZ;
                else                             next_state = N;
            end
            DIV_1KHZ : begin
                if(count_70ms) next_state = DIV_2KHZ;
                else           next_state = DIV_1KHZ;
            end
            DIV_2KHZ : begin
                if(count_70ms) next_state = DIV_3KHZ;
                else           next_state = DIV_2KHZ;
            end
            DIV_3KHZ : begin
                if(count_70ms) next_state = DIV_4KHZ;
                else           next_state = DIV_3KHZ;
            end
            DIV_4KHZ : begin
                if(count_70ms) next_state = N;
                else           next_state = DIV_4KHZ;
            end
            default :         next_state = N;                            
        endcase
    end

    always @ (posedge clk, posedge reset) 
    begin
        if(reset) current_state <= N;
        else      current_state <= next_state;
    end

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            clk_div[0] <= 0; clk_div[1] <= 0; clk_div[2] <= 0; clk_div[3] <= 0;
            r_buzzer_frequency <= 0;
        end else begin
            if(current_state == N) begin 
                clk_div[0] <= 0; clk_div[1] <= 0; clk_div[2] <= 0; clk_div[3] <= 0;
                r_buzzer_frequency <= 0;
            end else begin
                case (current_state)
                    DIV_1KHZ : begin
                        clk_div[1] <= 0; clk_div[2] <= 0; clk_div[3] <= 0;
                        if(clk_div[0] == 22'd50000 - 1) begin
                            clk_div[0] <= 0;
                            r_buzzer_frequency <= ~r_buzzer_frequency;
                        end else begin
                            clk_div[0] <= clk_div[0] + 1;
                        end
                    end
                    DIV_2KHZ : begin
                        clk_div[0] <= 0; clk_div[2] <= 0; clk_div[3] <= 0;
                        if(clk_div[1] == 22'd25000 - 1) begin
                            clk_div[1] <= 0;
                            r_buzzer_frequency <= ~r_buzzer_frequency;
                        end else begin
                            clk_div[1] <= clk_div[1] + 1;
                        end
                    end
                    DIV_3KHZ : begin
                        clk_div[0] <= 0; clk_div[1] <= 0; clk_div[3] <= 0;
                        if(clk_div[2] == 22'd16667 - 1) begin
                            clk_div[2] <= 0;
                            r_buzzer_frequency <= ~r_buzzer_frequency;
                        end else begin
                            clk_div[2] <= clk_div[2] + 1;
                        end
                    end
                    DIV_4KHZ : begin
                        clk_div[0] <= 0; clk_div[1] <= 0; clk_div[2] <= 0;
                        if(clk_div[3] == 22'd12500 - 1) begin
                            clk_div[3] <= 0;
                            r_buzzer_frequency <= ~r_buzzer_frequency;
                        end else begin
                            clk_div[3] <= clk_div[3] + 1;
                        end
                    end
                    default : begin
                        clk_div[0] <= 0; clk_div[1] <= 0; clk_div[2] <= 0; clk_div[3] <= 0;
                        r_buzzer_frequency <= 0;
                    end                                                                               
                endcase
            end
        end
    end
    assign power_sound_active = (current_state != N);
    assign buzzer = r_buzzer_frequency;    

endmodule