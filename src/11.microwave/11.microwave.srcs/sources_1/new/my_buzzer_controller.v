`timescale 1ns / 1ps

module my_buzzer_controller(
    input       clk,
    input       reset,
    input       btnU,
    input       btnL,
    input       btnC,
    input       btnD,
    input       door, 
    input [2:0] mode,
    output reg  buzzer
    );

    // IDLE  BTN_CLICK_SOUND  POWER_ON_SOUND  FINISH_SOUND  OPEN_SOUND  CLOSE_SOUND 

    localparam IDLE_SOUND       = 3'b000,
               BTN_CLICK_SOUND  = 3'b001,
               POWER_ON_SOUND   = 3'b010,
               FINISH_SOUND     = 3'b011,
               OPEN_SOUND       = 3'b100,
               CLOSE_SOUND      = 3'b101;

    localparam IDLE   = 3'b000,
               SET    = 3'b001,
               RUN    = 3'b010,
               STOP   = 3'b011,
               FINISH = 3'b100; 

    localparam DUR_1S   = 28'd100_000_000,
               DUR_70MS = 28'd7_000_000,
               DUR_100MS = 28'd10_000_000,
               DUR_200MS = 28'd20_000_000;                

    reg [2:0]  current_state, next_state;   
    reg        prev_door;
    reg [27:0] duration_timer;
    reg [27:0] term_timer;
    reg [3:0]  sound_state;
    reg        term_timer_start; 

    wire term_timer_done = (term_timer == 1);
    wire check_1s = (duration_timer == DUR_1S-1) ? 1 : 0;

    always @(*) begin
        if(current_state == IDLE_SOUND) begin
            if     (mode == FINISH)                 next_state = FINISH_SOUND;
            else if((mode == IDLE_SOUND) && btnC)   next_state = POWER_ON_SOUND;
            else if(!prev_door && door)             next_state = OPEN_SOUND;
            else if(prev_door && !door)             next_state = CLOSE_SOUND;
            else if(btnU || btnL || btnC || btnD)   next_state = BTN_CLICK_SOUND;
            else                                    next_state = IDLE_SOUND;
        end else if(mode == FINISH) begin  
        
        end else if(check_1s) begin
            next_state = IDLE_SOUND;
        end else next_state = next_state;
    end 

    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            current_state <= IDLE_SOUND;
            prev_door <= 0;
        end else begin
            current_state <= next_state;
            prev_door <= door;
        end
    end

    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            duration_timer <= 0;
        end else begin
            if(check_1s || (current_state == IDLE_SOUND)) duration_timer <= 0;
            else duration_timer <= duration_timer + 1;
        end
    end           

    always @ (*) begin
        case (current_state) 
            IDLE_SOUND : begin
            end
            BTN_CLICK_SOUND : begin

            end
            POWER_ON_SOUND : begin
            end
            FINISH_SOUND : begin
            end
            OPEN_SOUND : begin
            end
            CLOSE_SOUND : begin
            end 
        endcase
    end

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            term_timer <= 0;
        end else begin
            if(term_timer_start) begin
                case(next_state)
                    BTN_CLICK_SOUND : term_timer <= DUR_100MS;
                    POWER_ON_SOUND  : term_timer <= DUR_70MS;
                    OPEN_SOUND      : term_timer <= DUR_200MS;
                    CLOSE_SOUND     : term_timer <= DUR_200MS;
                    FINISH_SOUND    : term_timer <= DUR_1S;
                endcase 
            end
        end
    end
                
endmodule
