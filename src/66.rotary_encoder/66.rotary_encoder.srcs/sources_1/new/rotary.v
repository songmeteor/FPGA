`timescale 1ns / 1ps

module rotary(
    input clk,
    input reset,
    input clean_s1,
    input clean_s2,
    input clean_key,

    output [15:0] led
    );

    reg [1:0] r_prev_state     = 2'b00;
    reg [1:0] r_curr_state     = 2'b00;
    reg [1:0] r_direction      = 2'b00; // 시계 : 01 반시계 : 10
    reg [7:0] r_count          = 8'h00;
    reg       r_prev_clean_key = 1'b0;
    reg       r_key_toggle     = 1'b0;
 
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_prev_state <= 2'b00;
            r_curr_state <= 2'b00;
            r_direction  <= 2'b00;
            r_count      <= 8'h00;
            r_key_toggle <= 1'b0;
            r_prev_clean_key <= 1'b0;
        end else begin
            r_prev_state <= r_curr_state;
            r_curr_state <= {clean_s1, clean_s2};
            r_prev_clean_key <= clean_key;

            if(!clean_key && r_prev_clean_key) r_key_toggle <= !r_key_toggle;

            case ({r_prev_state, r_curr_state})
                4'b0010, 4'b1011, 4'b1101, 4'b0100 : begin
                    if(r_count < 8'hFF)
                        r_count <= r_count + 1;
                    r_direction <= 2'b01;    
                end
                4'b0001, 4'b0111, 4'b1110, 4'b1000 : begin
                    if(r_count > 8'h00)
                        r_count <= r_count - 1;
                    r_direction <= 2'b10;    
                end                
            endcase
        end
    end

    assign led[15:14] = r_direction;
    assign led[12:8]  = 5'b000000;
    assign led[7:0]   = r_count;
    assign led[13]    = r_key_toggle;
endmodule
