`timescale 1ns / 1ps

module dht11_controller(
    input clk,
    input reset,

    output reg [7:0] humidity,
    output reg [7:0] current_temperature,

    inout dht11_data
    );

    localparam COUNT_1US = 100;
    localparam COUNT_1MS = 100_000;
    localparam COUNT_1S  = 100_000_000;

    localparam IDLE               = 4'b0000,
               START_LOW          = 4'b0001,
               START_HIGH         = 4'b0010,
               RESP_LOW           = 4'b0011,
               RESP_HIGH          = 4'b0100,
               WAIT_BIT_LOW_START = 4'b0101,
               DATA_WAIT_LOW_END  = 4'b0110, 
               DATA_MEASURE_HIGH  = 4'b0111, 
               DATA_PROCESS       = 4'b1000, 
               DATA_END           = 4'b1001,
               ERROR              = 4'b1111; 

    reg [3:0]  state;
    reg [23:0] timer_count;
    reg [26:0] second_counter;
    reg [39:0] data_buffer;
    reg [5:0]  bit_count;
    reg        dht_data_out;
    reg        dht_data_en;  

    assign dht11_data = dht_data_en ? dht_data_out : 1'bz;

    initial begin
        state          <= IDLE;
        second_counter <= 0;
    end  

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state             <= IDLE;
            timer_count       <= 0;
            second_counter    <= 0;
            data_buffer       <= 0;
            bit_count         <= 0;
            dht_data_out      <= 1;            
        end else begin
            case(state)
                IDLE : begin
                    dht_data_en <= 0; // 입력 모드
                    if (second_counter == COUNT_1S - 1) begin
                        state <= START_LOW;
                        timer_count <= 0;
                        second_counter <= 0; 
                    end else begin
                        second_counter <= second_counter + 1;
                    end
                end
                START_LOW : begin   //18ms 동안 LOW 출력
                    dht_data_out <= 0;
                    dht_data_en  <= 1; // 출력 모드
                    if (timer_count < 20 * COUNT_1MS) begin
                        timer_count <= timer_count + 1;
                    end else begin
                        state <= START_HIGH;
                        timer_count <= 0;
                    end            
                end
                START_HIGH : begin   //30us 동안 HIGH 출력
                    dht_data_out <= 1;  
                    if (timer_count < 30 * COUNT_1US) begin
                        timer_count <= timer_count + 1;
                    end else begin
                        state <= RESP_LOW;
                        dht_data_en <= 0;  // 입력 모드
                        timer_count <= 0;
                    end            
                end
                RESP_LOW : begin
                    if (dht11_data == 1'b0) begin
                        state <= RESP_HIGH;
                        timer_count <= 0;
                    end else if (timer_count > (200 * COUNT_1US)) begin // 200us 타임아웃
                        state <= ERROR;
                        timer_count <= 0;
                    end else begin
                        timer_count <= timer_count + 1;
                    end           
                end
                RESP_HIGH : begin
                    if (dht11_data == 1'b1) begin
                        state <= WAIT_BIT_LOW_START;
                        bit_count <= 0;
                        timer_count <= 0;
                    end else if (timer_count > (200 * COUNT_1US)) begin // 200us 타임아웃
                        state <= ERROR;
                        timer_count <= 0;
                    end else begin
                        timer_count <= timer_count + 1;
                    end        
                end
                WAIT_BIT_LOW_START : begin
                    if (dht11_data == 1'b0) begin
                        state       <= DATA_WAIT_LOW_END;
                        timer_count <= 0;
                    end else if (timer_count > (100 * COUNT_1US)) begin // 100us 타임아웃
                        state <= ERROR;
                        timer_count <= 0;
                    end else begin
                        timer_count <= timer_count + 1;
                    end               
                end
                DATA_WAIT_LOW_END : begin
                    if (dht11_data == 1'b1) begin
                        state <= DATA_MEASURE_HIGH;
                        timer_count <= 0; 
                    end else if (timer_count > (100 * COUNT_1US)) begin // 100us 타임아웃
                        state <= ERROR;
                    end else begin
                        timer_count <= timer_count + 1;
                    end
                end

                DATA_MEASURE_HIGH : begin
                    if (dht11_data == 1'b1) begin
                        timer_count <= timer_count + 1;
                    end else begin
                        state <= DATA_PROCESS;
                    end
                end

                DATA_PROCESS : begin
                    data_buffer <= data_buffer << 1;
                    if (timer_count > (40 * COUNT_1US)) begin 
                        data_buffer[0] <= 1'b1;
                    end else begin 
                        data_buffer[0] <= 1'b0;
                    end

                    bit_count <= bit_count + 1;

                    if (bit_count == 39) begin
                        state <= DATA_END;
                    end else begin
                        state <= WAIT_BIT_LOW_START;
                    end
                end
                DATA_END : begin
                    if ((data_buffer[39:32] + data_buffer[31:24] + data_buffer[23:16] + data_buffer[15:8]) == data_buffer[7:0]) begin
                        humidity            <= data_buffer[39:32];
                        current_temperature <= data_buffer[23:16];
                    end
                    timer_count   <= 0; 
                    state <= IDLE;   
                    data_buffer <= 0;
                    bit_count   <= 0;         
                end
                ERROR : begin
                    state       <= IDLE; // 에러 발생 시 IDLE로 돌아가 다시 시도
                    timer_count   <= 0; 
                    data_buffer <= 0;
                    bit_count   <= 0;                    
                end
                default : state <= IDLE;                                                                                     
            endcase
        end
    end                      
endmodule
