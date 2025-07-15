`timescale 1ns / 1ps

module data_sender(
    input        clk,
    input        reset,
    input [7:0]  send_data,
    input        start_trigger,
    input        tx_done,
    input        tx_busy,

    output reg       tx_start,
    output reg [7:0] tx_data
    );

    reg [6:0] r_data_cnt;
    reg [7:0] r_temp_data;  // '0' ~ '9'

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            tx_start   <= 0;
            r_data_cnt <= 0;
        end else begin
            if(start_trigger && !tx_busy) begin
                tx_start <= 1'b1;
                tx_data  <= send_data;        
            end else if(tx_done) begin
                if(r_data_cnt == 7'd10) begin
                    r_data_cnt <= 0;
                    r_temp_data <= send_data;
                end else begin
                    r_data_cnt <= r_data_cnt + 1;
                    r_temp_data <= r_temp_data + 1;
                    tx_start <= 1'b1; 
                end
            end else begin
                tx_start <= 1'b0;
            end
        end    
    end
endmodule
