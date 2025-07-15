`timescale 1ns / 1ps

module uart_tx # (parameter
        BAUD_RATE = 9600
) (
    input       clk,
    input       reset,
    input [7:0] tx_data,
    input       tx_start,
    
    output reg  tx,
    output reg  tx_busy,
    output reg  tx_done
    );

    parameter IDLE      = 2'b00,
              START_BIT = 2'b01,
              DATA_BITS = 2'b10,
              STOP_BIT  = 2'b11;

    parameter DIVIDER_COUNT = 100_000_000 / BAUD_RATE;

    reg [15:0] r_baud_cnt;   // 10416번 count
    reg        r_baud_tick;
    reg [1:0]  r_state;      // 상태천이
    reg [3:0]  r_bit_cnt;    // 전송 비트수 : 8
    reg [7:0]  r_data_reg;   // 전송할 1 byte

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
            r_state    <= IDLE;
            r_bit_cnt  <= 0;
            r_data_reg <= 0;
            tx_busy    <= 0;
            tx_done    <= 0;
            tx         <= 1;                           
        end else begin
            case(r_state)
                IDLE : begin
                    tx_done <= 0;
                    if(tx_start) begin
                        r_state    <= START_BIT;
                        r_data_reg <= tx_data;
                        tx_busy    <= 1;
                        r_bit_cnt  <= 0;
                    end
                end
                START_BIT : begin
                    if(r_baud_tick) begin
                        tx      <= 0; // start bit
                        r_state <= DATA_BITS;
                    end
                end
                DATA_BITS : begin
                    if(r_baud_tick) begin
                        tx <= r_data_reg[r_bit_cnt]; // 
                        if(r_bit_cnt == 4'd7) begin
                            r_state <= STOP_BIT;    
                        end else begin
                            r_bit_cnt <= r_bit_cnt + 1;
                        end
                    end
                end
                STOP_BIT : begin
                    if(r_baud_tick) begin
                        tx      <= 1;
                        tx_done <= 1'b1; // 1byte 전송완료
                        tx_busy <= 1'b0; // 전송중이 아님
                        r_state <= IDLE;
                    end
                end
                default : begin
                    r_state <= IDLE;
                end                                                                
            endcase
        end
    end 
endmodule
