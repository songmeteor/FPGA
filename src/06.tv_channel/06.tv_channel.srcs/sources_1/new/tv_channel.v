`timescale 1ns / 1ps

module tv_channel(

    input clk,
    input rstn,
    input up,
    input dn,
    output [3:0] ch
    );

    wire [3:0] w_current_state;
    wire [3:0] w_next_state;

    fsm u_fsm(
        .up(up),
        .dn(dn),
        .current_state(w_current_state),
        .next_state(w_next_state)
    );

    state_register u_state_register(
        .clk(clk),
        .rstn(rstn),
        .next_state(w_next_state),
        .current_state(w_current_state)
    ); 

    assign ch = w_current_state;
endmodule


module fsm(
    input up,
    input dn,
    input [3:0] current_state,
    output reg [3:0] next_state
);
    always@(up,dn,current_state) begin
        if(up&~dn) begin
            if(current_state == 9) next_state = 0;
            else next_state = current_state + 1;
        end
        else if (~up&dn) begin
            if(current_state == 0) next_state = 9;
            else next_state = current_state - 1;
        end
        else next_state = current_state;
    end
    
endmodule


module state_register(
    input clk,
    input rstn,
    input [3:0] next_state,
    output reg [3:0] current_state
); 
    always @ (posedge clk, negedge rstn) begin
        if(!rstn) current_state <= 4'b0;
        else current_state <= next_state;
    end
endmodule
