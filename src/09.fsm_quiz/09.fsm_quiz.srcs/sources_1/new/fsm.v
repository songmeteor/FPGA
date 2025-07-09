`timescale 1ns / 1ps

module fsm(
    input clk,
    input reset,
    input btnU,
    input btnD,
    output reg ret,
    output reg [6:0] led
    );

    reg       btnU_prev;
    reg       btnD_prev;
    reg [2:0] current_state, next_state;
    reg [6:0] r_led ;
    reg       r_ret ;

    wire btnU_posedge =  btnU & ~btnU_prev;
    wire btnD_posedge =  btnD & ~btnD_prev;
     
    parameter IDLE = 3'b000, 
              XZ   = 3'b001, 
              XO   = 3'b010, 
              ZZ   = 3'b011,
              ZO   = 3'b100,
              OZ   = 3'b101,
              OO   = 3'b110;

    always @ (posedge clk, posedge reset) 
    begin
        if(reset) begin
            current_state <= IDLE;
            ret <= 0; 
            led <= 0;
            btnU_prev <= 0;
            btnD_prev <= 0;
        end
        else begin
            btnU_prev <= btnU;
            btnD_prev <= btnD;
            current_state <= next_state;
            led <= r_led;
            ret <= r_ret;
        end
    end

    always @ (*) 
    begin
        case (current_state)
            IDLE : begin
                if(btnU_posedge) begin
                next_state = XO;
                r_ret = 0; r_led = {led[5:0], 1'b1};
                end
                else if(btnD_posedge) begin
                next_state = XZ;    
                r_ret = 0; r_led = {led[5:0], 1'b0};        
                end  
                else begin
                next_state = IDLE;     
                r_ret = ret; r_led = led;
                end
            end

            XZ : begin
                if(btnU_posedge) begin
                next_state = ZO;    
                r_ret = 0; r_led = {led[5:0], 1'b1};
                end
                else if(btnD_posedge) begin
                next_state = ZZ;    
                r_ret = 1; r_led = {led[5:0], 1'b0};
                end
                else begin
                next_state = XZ;     
                r_ret = ret; r_led = led;
                end                 
            end

            XO : begin
                if(btnU_posedge) begin
                next_state = OO;    
                r_ret = 1; r_led = {led[5:0], 1'b1};
                end
                else if(btnD_posedge) begin
                next_state = OZ;      
                r_ret = 0; r_led = {led[5:0], 1'b0};
                end
                else begin
                next_state = XO;     
                r_ret = ret; r_led = led;
                end                
            end

            ZZ : begin
                if(btnU_posedge) begin
                next_state = ZO;    
                r_ret = 0; r_led = {led[5:0], 1'b1};     
                end
                else if(btnD_posedge) begin
                next_state = ZZ;    
                r_ret = 0; r_led = {led[5:0], 1'b0};    
                end
                else begin
                next_state = ZZ;     
                r_ret = ret; r_led = led;
                end                
            end

            ZO : begin
                if(btnU_posedge) begin
                next_state = OO;    
                r_ret = 1; r_led = {led[5:0], 1'b1};    
                end
                else if(btnD_posedge) begin
                next_state = OZ;    
                r_ret = 0; r_led = {led[5:0], 1'b0};    
                end
                else begin
                next_state = ZO;     
                r_ret = ret; r_led = led;
                end                
            end            

            OZ : begin
                if(btnU_posedge) begin
                next_state = OO;    
                r_ret = 1; r_led = {led[5:0], 1'b1};    
                end
                else if(btnD_posedge) begin
                next_state = ZZ;    
                r_ret = 1; r_led = {led[5:0], 1'b0};    
                end
                else begin
                next_state = OZ;     
                r_ret = ret; r_led = led;
                end                
            end

            OO : begin
                if(btnU_posedge) begin
                next_state = OO;    
                r_ret = 1; r_led = {led[5:0], 1'b1};    
                end
                else if(btnD_posedge) begin
                next_state = OZ;    
                r_ret = 0; r_led = {led[5:0], 1'b0};    
                end
                else begin
                next_state = OO;     
                r_ret = ret; r_led = led;
                end                
            end
        endcase
    end                  
endmodule
