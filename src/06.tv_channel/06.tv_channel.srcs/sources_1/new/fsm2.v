`timescale 1ns / 1ps

module fsm2(
    input clk, rstn, go, ws,
    output reg rd, ds
    );

    reg [1:0] current_state, next_state;

    parameter IDLE = 2'b00, DONE = 2'b01, DLY = 2'b10, READ = 2'b11;

    always @ (*) 
    begin
        case (current_state)
            IDLE : begin
                if(go)
                next_state = READ;
                else
                next_state = IDLE;
            end
            DONE : begin
                next_state = IDLE;
            end    
            DLY : begin
                if(ws)
                next_state = READ;
                else
                next_state = DONE;
            end
            READ : begin
                next_state = DLY;
            end
            default : next_state = IDLE;
        endcase
    end  

    always @ (posedge clk, negedge rstn) 
    begin
        if(!rstn) current_state <= IDLE;
        else current_state <= next_state;
    end 

    always @(*) begin
        rd = 0;
        ds = 0;
        case (current_state)
            IDLE: begin
                rd = 0;
                ds = 0;
            end
            READ: begin
                rd = 1;
                ds = 0;
            end
            DLY: begin
                rd = 1;
                ds = 0;
            end
            DONE: begin
                rd = 0;
                ds = 1;
            end
            default: begin
                rd = 0;
                ds = 0;
            end
        endcase
    end        
endmodule
