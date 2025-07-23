`timescale 1ns / 1ps

module led_controller(
    input       clk,
    input       reset,
    input [7:0] dout,
    input       empty,

    output reg [15:0] led,
    output reg        re
    );

    parameter IDLE  = 3'b000,
              POP   = 3'b001,
              WAIT1  = 3'b010, // 새로운 상태
              WAIT2  = 3'b011,
              READ  = 3'b100,
              CHECK = 3'b101;

    integer  i;

    reg [2:0] state;
    reg [7:0] cmd_buff [15:0];
    reg [$clog2(16):0] buff_index;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            for(i=0;i<16;i=i+1) begin
                cmd_buff[i] <= 0;
            end
            state <= IDLE;
            led   <= 0;
            re    <= 0;
            buff_index <= 0;
        end else begin
            re <= 0;
            case (state)
                IDLE : begin
                buff_index <= 0;    
                if(!empty) begin
                    state <= POP;
                end
            end
            POP :begin
                re <= 1'b1; // FIFO에 데이터 읽기 요청
                state <= WAIT1; // 다음 사이클에 데이터를 읽기 위해 상태 전환
            end 
            WAIT1 : begin
                re <= 1'b0;
                state <= WAIT2;
            end
            WAIT2 : begin
                state <= READ;  
            end
            READ: begin
                // 이제 dout은 유효한 값을 가짐
                cmd_buff[buff_index] <= dout;

                // 명령어의 끝(.)이거나 버퍼가 꽉 찼는지 확인
                if (dout == 8'h2E || buff_index == 15) begin
                    state <= CHECK; // 명령어 검사 상태로 이동
                end else begin
                    // 아직 명령어가 끝나지 않았으면 다음 데이터를 요청
                    buff_index <= buff_index + 1;
                    state <= POP;
                end
            end            
            CHECK : begin
                if(cmd_buff[0]==8'h6C && cmd_buff[1]==8'h65 && cmd_buff[2]==8'h64 && cmd_buff[3]==8'h61 && cmd_buff[4]==8'h6C && cmd_buff[5]==8'h6C && cmd_buff[6]==8'h6F && cmd_buff[7]==8'h6E && cmd_buff[8]==8'h2E) begin
                    led <= 16'b1111111111111111;
                end else if(cmd_buff[0]==8'h6C && cmd_buff[1]==8'h65 && cmd_buff[2]==8'h64 && cmd_buff[3]==8'h61 && cmd_buff[4]==8'h6C && cmd_buff[5]==8'h6C && cmd_buff[6]==8'h6F && cmd_buff[7]==8'h66 && cmd_buff[8]==8'h66 && cmd_buff[9]==8'h2E) begin
                    led <= 16'b0;
                end else if(cmd_buff[0]==8'h6C && cmd_buff[1]==8'h65 && cmd_buff[2]==8'h64 && cmd_buff[5]==8'h6F && cmd_buff[6]==8'h6E && cmd_buff[7]==8'h2E) begin
                    led <= led | (1 << ((cmd_buff[3] - 8'h30) * 10 + cmd_buff[4] - 8'h30));
                end else if(cmd_buff[0]==8'h6C && cmd_buff[1]==8'h65 && cmd_buff[2]==8'h64 && cmd_buff[5]==8'h6F && cmd_buff[6]==8'h66 && cmd_buff[7]==8'h66 && cmd_buff[8]==8'h2E) begin
                    led <= led & ~(1 << ((cmd_buff[3] - 8'h30) * 10 + cmd_buff[4] - 8'h30));
                end else begin
                    led <= led;
                end
                state <= IDLE;
            end  
                default: state <= IDLE;
            endcase
        end
    end
endmodule
