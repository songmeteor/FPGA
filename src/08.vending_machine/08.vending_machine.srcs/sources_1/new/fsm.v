`timescale 1ns / 1ps

module fsm(
    input  clk,
    input  reset,
    input  btnL,
    input  btnC,
    input  btnR,
    input  btnD,
    output reg anim_mode,
    output [13:0] total
    );

    parameter IDLE = 2'b00, 
              READY = 2'b01, 
              RUN = 2'b10;

    reg    btnL_prev;
    reg    btnC_prev;
    reg    btnR_prev;
    reg    btnD_prev;

    reg [1:0] current_state = IDLE;
    reg [1:0] next_state = IDLE;
    reg [13:0] r_total = 0;
    reg [13:0] next_total;
    reg [26:0] tick_counter = 0;
    reg [5:0] run_sec = 0;

    wire btnL_posedge =  btnL & ~btnL_prev;
    wire btnC_posedge =  btnC & ~btnC_prev;
    wire btnR_posedge =  btnR & ~btnR_prev;
    wire btnD_posedge =  btnD & ~btnD_prev;    

    wire tick_1s = (tick_counter == 100_000_000-1);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick_counter <= 0;
        end else if (tick_counter == 100_000_000-1)
            tick_counter <= 0;
        else
            tick_counter <= tick_counter + 1;
    end    

    always @(posedge clk or posedge reset) begin
        if (reset || current_state != RUN)
            run_sec <= 0;
        else if (tick_1s)
            run_sec <= run_sec + 1;
    end

    always @ (*) 
    begin
        case (current_state)
            IDLE : begin
                 next_state = READY;
            end
            READY : begin
                if     (btnR_posedge)                        next_state = IDLE;
                else if(btnC_posedge && (r_total >=14'd300)) next_state = RUN;
                else if(btnC_posedge && (r_total < 14'd300)) next_state = READY;
                else                                         next_state = READY;
            end    
            RUN : begin
                if(run_sec >=30) next_state = READY; 
                else             next_state = RUN; 
            end
            default : next_state = IDLE;
        endcase
    end   

    always @ (posedge clk, posedge reset) 
    begin
        if(reset) begin
            current_state <= IDLE;
            r_total   <=0;
            btnL_prev <=0;
            btnC_prev <=0;
            btnR_prev <=0;
            btnD_prev <=0;            
        end
        else begin
            current_state <= next_state;
            r_total       <= next_total;
            btnL_prev <= btnL;
            btnC_prev <= btnC;
            btnR_prev <= btnR;
            btnD_prev <= btnD;                     
        end  
    end 

    always @ (*) 
    begin
        next_total = r_total;
        case (current_state)
            IDLE : begin
                next_total = 14'd0;
                anim_mode = 0;
            end
            READY : begin
                anim_mode = 0;
                if(btnL_posedge)                             next_total = r_total + 14'd100;
                else if(btnC_posedge && (r_total >=14'd300)) next_total = r_total - 14'd300;
                else if(btnC_posedge && (r_total < 14'd300)) next_total = r_total; 
                else if(btnD_posedge)                        next_total = r_total + 14'd500; 
                else if(btnR_posedge)                        next_total = 0 ; 
                else                                         next_total = r_total; 
            end    
            RUN : begin
                next_total = r_total;
                anim_mode = 1;
            end
            default : next_total = r_total;
        endcase
    end    
    
    assign total = r_total;
endmodule
