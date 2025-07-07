`timescale 1ns / 1ps

module mealy_fsm(
    input clk, rstn, done,
    output reg ack
    );

    reg [1:0] current_state, next_state;

    parameter ready = 2'b00, trans = 2'b01, write = 2'b10, read = 2'b11;

    always @ (*) 
    begin
        case (current_state)
            ready : begin
                if(done)
                next_state = trans;
                else
                next_state = ready;
            end
            trans : begin
                if(done)
                next_state = trans;
                else
                next_state = write;    
            end    
            write : begin
                if(done)
                next_state = read;
                else
                next_state = write;
            end
            read : begin
                if(done)
                next_state = ready;
                else
                next_state = read;
            end
        endcase
    end

    always @ (posedge clk, negedge rstn) 
    begin
        if(!rstn) current_state <= ready;
        else current_state <= next_state;
    end

    always @(*)
    begin
        case (current_state)
            ready : begin
                if(done)
                ack = 1;
                else
                ack = 0;
            end
            trans : begin
                if(done)
                ack = 0;
                else
                ack = 0;    
            end    
            write : begin
                if(done)
                ack = 1;
                else
                ack = 0;
            end
            read : begin
                if(done)
                ack = 0;
                else
                ack = 0;
            end            
        endcase
    end

endmodule

