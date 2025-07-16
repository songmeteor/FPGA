`timescale 1ns / 1ps

module uart_rx(
    input clk,
    input reset,
    input rx,

    output reg [7:0] data_out,
    output reg       rx_done
    );

    parameter 
        IDLE      = 2'b00,
        START_BIT = 2'b01,
        DATA_BITS = 2'b10,
        STOP_BIT  = 2'b11;

    parameter integer DIVIDER_COUNT = 100_000_000 / (9600 * 16);    

    reg [1:0]  r_state;
    reg [3:0]  r_bit_cnt;        //r_data_reg에 들어갈 index값
    reg [7:0]  r_data_reg;       //rx 포트로부터 들어온 bit를 담을 그릇
    reg [15:0] r_baud_cnt;       //651 : 9600 오버샘플링 count 변수
    reg        r_baud_tick;      //651ns 마다 tick 발생
    reg [3:0]  r_baud_tick_cnt;  //16개 오버샘플링값 count

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_baud_cnt  <= 0;
            r_baud_tick <= 0;    
        end else begin
            if(r_baud_cnt == DIVIDER_COUNT - 1) begin
                r_baud_cnt  <= 0;
                r_baud_tick <= 1;            
            end else begin
                r_baud_cnt  <= r_baud_cnt + 1;
                r_baud_tick <= 0;
            end       
        end
    end

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_state         <= IDLE;
            data_out        <= 0;
            rx_done         <= 0;
            r_data_reg      <= 0;
            r_baud_tick_cnt <= 0;
        end else begin
            case(r_state)
                IDLE : begin
                    rx_done <= 0;
                    if(!rx) begin
                        r_state         <= START_BIT;
                        r_baud_tick_cnt <= 4'd0;
                    end 
                end
                START_BIT : begin
                    if(r_baud_tick) begin
                        if(r_baud_tick_cnt == 7) begin
                            r_state         <= DATA_BITS;
                            r_bit_cnt       <= 0;
                            r_baud_tick_cnt <= 0;
                        end else begin
                            r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                        end
                    end
                end
                DATA_BITS : begin
                    if(r_baud_tick) begin
                        if(r_baud_tick_cnt == 15) begin
                            r_data_reg[r_bit_cnt] <= rx;
                            r_baud_tick_cnt       <= 0;
                            if(r_bit_cnt == 7) begin
                                r_state <= STOP_BIT;
                            end else begin
                                r_bit_cnt <= r_bit_cnt + 1;
                            end
                        end else begin
                            r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                        end
                    end
                end
                STOP_BIT : begin
                    if(r_baud_tick) begin
                        if(r_baud_tick_cnt == 15) begin
                            r_state <= IDLE;
                            data_out <= r_data_reg;
                            rx_done <= 1;
                        end else begin
                            r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                        end
                    end
                end                                                
            endcase
        end
    end    
endmodule 
