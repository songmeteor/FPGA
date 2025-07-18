`timescale 1ns / 1ps

module dht11_controller (
    input               clk,
    input               reset,

    output reg [7:0]    humidity,               // 상대 습도 상위 8bit
    output reg [7:0]    current_temperature,    // 온도 상위 8비트

    inout               dht11_data              // 단방향 통신핀 (드라이브/하이임피던스 제어)
);

    // 상태 정의
    localparam IDLE         = 3'd0,
               START        = 3'd1,
               WAIT         = 3'd2,
               SYNCL        = 3'd3,
               SYNCH        = 3'd4,
               DATA_SYNC    = 3'd5,
               DATA_DETECT  = 3'd6,
               STOP         = 3'd7;

    // 카운터 최대치
    localparam CNT19MS_MAX  = 1900;     // 19ms 카운터 (START 단계) (10us * 1900)
    localparam CNT1US_MAX   = 100;      // 1μs 카운터 최대치
    localparam SEC_CNT_MAX  = 100000;   // 1초 카운터 (10us 틱 × 100_000)

    // 레지스터 정의
    reg [2:0]  c_state, n_state;
    reg [16:0] sec_cnt_reg,  sec_cnt_next;   // 1초 카운터
    reg [10:0] t_cnt_reg,    t_cnt_next;     // 10μs 타이머
    reg [6:0]  t_cnt1us_reg, t_cnt1us_next;  // 1μs 타이머
    reg [5:0]  bit_cnt_reg,  bit_cnt_next;   // 수신 비트 카운터 (0-39)
    reg [39:0] data_reg,     data_next;
    reg        dht11_reg,    dht11_next;
    reg        io_en_reg,    io_en_next;

    reg dht11_data_s1, dht11_data_s2;

    // 양방향 핀 제어: io_en_reg가 1이면 출력, 0이면 입력(High-Z)
    assign dht11_data = io_en_reg ? dht11_reg : 1'bz;

    // 10μs 틱 생성기 인스턴스
    wire w_tick_10us;
    tick_gen_10us U_TICK_10US (
        .clk(clk), .rst(reset), .o_tick(w_tick_10us)
    );

    // 1μs 틱 생성기 인스턴스
    wire w_tick_1us;
    tick_gen_1us U_TICK_1US (
        .clk(clk), .rst(reset), .o_tick(w_tick_1us)
    );

    // [추가됨] 2-플립플롭 동기화기
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            dht11_data_s1 <= 1'b1;
            dht11_data_s2 <= 1'b1;
        end else begin
            dht11_data_s1 <= dht11_data;
            dht11_data_s2 <= dht11_data_s1;
        end
    end    

    // 동기 블록: 클럭에 맞춰 레지스터 값 업데이트
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            c_state             <= IDLE;
            sec_cnt_reg         <= 0;
            t_cnt_reg           <= 0;
            t_cnt1us_reg        <= 0;
            bit_cnt_reg         <= 0;
            data_reg            <= 0;
            humidity            <= 0;
            current_temperature <= 0;
            dht11_reg           <= 1;
            io_en_reg           <= 1;
        end else begin
            c_state      <= n_state;
            sec_cnt_reg  <= sec_cnt_next;
            t_cnt_reg    <= t_cnt_next;
            t_cnt1us_reg <= t_cnt1us_next;
            bit_cnt_reg  <= bit_cnt_next;
            data_reg     <= data_next;
            dht11_reg    <= dht11_next;
            io_en_reg    <= io_en_next;
            
            // 데이터 수신이 완료되어 STOP 상태로 진입할 때, 최종 데이터로 출력 레지스터 업데이트
            if (n_state == STOP && c_state != STOP) begin
                // 체크섬 검증 로직 (선택 사항)
                // wire [7:0] checksum = data_next[39:32] + data_next[31:24] + data_next[23:16] + data_next[15:8];
                // if (checksum == data_next[7:0]) begin
                    humidity            <= data_next[39:32];
                    current_temperature <= data_next[23:16];
                // end
            end
        end
    end

    // 조합 블록: 현재 상태(c_state)에 따라 다음 상태(n_state) 및 신호 결정
    always @(*) begin
        // 기본적으로 현재 값 유지
        n_state       = c_state;
        sec_cnt_next  = sec_cnt_reg;
        t_cnt_next    = t_cnt_reg;
        t_cnt1us_next = t_cnt1us_reg;
        bit_cnt_next  = bit_cnt_reg;
        data_next     = data_reg;
        dht11_next    = dht11_reg;
        io_en_next    = io_en_reg;

        

        case (c_state)
            // IDLE: 1초마다 통신 시작
            IDLE: begin
                io_en_next   = 1; // 버스 제어권 가짐
                dht11_next   = 1; // 버스 High 유지
                bit_cnt_next = 0; // 비트 카운터 초기화
                data_next    = 0; // 데이터 레지스터 초기화
                
                if (w_tick_10us) begin
                    if (sec_cnt_reg == SEC_CNT_MAX - 1) begin
                        sec_cnt_next = 0;
                        n_state      = START;
                    end else begin
                        sec_cnt_next = sec_cnt_reg + 1;
                    end
                end
            end

            // START: MCU가 데이터 핀을 19ms 동안 LOW로 유지하여 시작 신호 전송
            START: begin
                dht11_next = 0; // 데이터 핀 LOW
                if (w_tick_10us) begin
                    t_cnt_next = t_cnt_reg + 1;
                    if (t_cnt_reg == CNT19MS_MAX - 1) begin
                        n_state    = WAIT;
                        t_cnt_next = 0; // 다음 상태를 위해 카운터 초기화
                    end
                end
            end

            // WAIT: MCU가 핀을 30µs 동안 HIGH로 유지 후, 센서 응답을 위해 입력으로 전환
            WAIT: begin
                dht11_next = 1; // 데이터 핀 HIGH
                if (w_tick_10us) begin
                    t_cnt_next = t_cnt_reg + 1;
                    if (t_cnt_reg == 2) begin // 3 * 10µs = 30µs
                        n_state    = SYNCL;
                        t_cnt_next = 0;
                        io_en_next = 0; // 센서가 버스를 제어하도록 입력(High-Z)으로 전환
                    end
                end
            end

            // SYNCL: 센서의 응답 신호(80µs Low) 시작 대기
            SYNCL: begin
                if (dht11_data_s2  == 1'b0) begin
                    n_state = SYNCH;
                end
                // 타임아웃 로직 추가 가능
            end

            // SYNCH: 센서의 응답 신호(80µs High) 시작 대기
            SYNCH: begin
                if (dht11_data_s2  == 1'b1) begin
                    n_state = DATA_SYNC;
                end
                // 타임아웃 로직 추가 가능
            end

            // DATA_SYNC: 각 데이터 비트 전의 50µs Low 신호가 끝나고, High 신호가 시작되기를 대기
            DATA_SYNC: begin
                if (w_tick_10us) begin
                    // 타임아웃: 100us 이상 응답 없으면 통신 중단
                    if (t_cnt_reg > 10) begin
                        n_state = STOP;
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                        if (dht11_data_s2  == 1'b1) begin
                            n_state       = DATA_DETECT;
                            t_cnt1us_next = 0; // 1us 카운터 초기화
                            t_cnt_next    = 0;
                        end
                    end
                end
            end

            // DATA_DETECT: 데이터 비트의 High 펄스 길이를 측정하여 0과 1을 판별
            DATA_DETECT: begin
                if (w_tick_1us) begin
                    if (dht11_data_s2 == 1'b1) begin // High 펄스 길이 측정
                        t_cnt1us_next = t_cnt1us_reg + 1;
                    end else begin // Low로 바뀌면 비트 판별
                        // High 펄스가 약 40us (26-28us vs 70us의 중간값) 이상이면 '1', 아니면 '0'
                        data_next = (t_cnt1us_reg >= 35) ? {data_reg[38:0], 1'b1} : {data_reg[38:0], 1'b0};
                        bit_cnt_next = bit_cnt_reg + 1;

                        if (bit_cnt_reg == 39) begin // 40비트 수신 완료
                            n_state = STOP;
                        end else begin
                            n_state = DATA_SYNC;
                        end
                    end
                end
            end

            // STOP: 통신 완료 후 IDLE 상태로 복귀 준비
            STOP: begin
                n_state = IDLE;
            end
            
            default: n_state = IDLE;

        endcase
    end

endmodule

// 10μs 분주 모듈 (변경 없음)
module tick_gen_10us (
    input  clk,
    input  rst,
    output reg o_tick
);
    localparam F_CNT = 1000; // 100MHz 시스템 클럭 기준 -> 10us
    reg [$clog2(F_CNT)-1:0] counter_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            o_tick      <= 0;
        end else if (counter_reg < F_CNT-1) begin
            counter_reg <= counter_reg + 1;
            o_tick      <= 0;
        end else begin
            counter_reg <= 0;
            o_tick      <= 1;
        end
    end
endmodule

// 1μs 분주 모듈 (변경 없음)
module tick_gen_1us (
    input  clk,
    input  rst,
    output reg o_tick
);
    localparam F_CNT = 100;  // 100MHz 시스템 클럭 기준 -> 1us
    reg [$clog2(F_CNT)-1:0] counter_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            o_tick      <= 0;
        end else if (counter_reg < F_CNT-1) begin
            counter_reg <= counter_reg + 1;
            o_tick      <= 0;
        end else begin
            counter_reg <= 0;
            o_tick      <= 1;
        end
    end
endmodule




// module dht11_controller(
//     input clk,
//     input reset,

//     output reg [7:0] humidity,
//     output reg [7:0] current_temperature,
//     inout dht11_data
//     );

//     localparam COUNT_1US = 100;
//     localparam COUNT_1MS = 100_000;
//     localparam COUNT_1S  = 100_000_000;

//     localparam IDLE               = 4'b0000,
//                START_LOW          = 4'b0001,
//                START_HIGH         = 4'b0010,
//                RESP_LOW           = 4'b0011,
//                RESP_HIGH          = 4'b0100,
//                WAIT_BIT_LOW_START = 4'b0101,
//                DATA_WAIT_LOW_END  = 4'b0110, 
//                DATA_MEASURE_HIGH  = 4'b0111, 
//                DATA_PROCESS       = 4'b1000, 
//                DATA_END           = 4'b1001,
//                ERROR              = 4'b1111; 

//     reg [3:0]  state;
//     reg [23:0] timer_count;
//     reg [26:0] second_counter;
//     reg [39:0] data_buffer;
//     reg [5:0]  bit_count;
//     reg        dht_data_out;
//     reg        dht_data_en;  

//     assign dht11_data = dht_data_en ? dht_data_out : 1'bz;

//     initial begin
//         state          <= IDLE;
//         second_counter <= 0;
//     end  

//     always @(posedge clk, posedge reset) begin
//         if(reset) begin
//             state             <= IDLE;
//             timer_count       <= 0;
//             second_counter    <= 0;
//             data_buffer       <= 0;
//             bit_count         <= 0;
//             dht_data_out      <= 1;            
//         end else begin
//             case(state)
//                 IDLE : begin
//                     dht_data_en <= 0; // 입력 모드
//                     if (second_counter == COUNT_1S - 1) begin
//                         state <= START_LOW;
//                         timer_count <= 0;
//                         second_counter <= 0; 
//                     end else begin
//                         second_counter <= second_counter + 1;
//                     end
//                 end
//                 START_LOW : begin   //18ms 동안 LOW 출력
//                     dht_data_out <= 0;
//                     dht_data_en  <= 1; // 출력 모드
//                     if (timer_count < 20 * COUNT_1MS) begin
//                         timer_count <= timer_count + 1;
//                     end else begin
//                         state <= START_HIGH;
//                         timer_count <= 0;
//                     end            
//                 end
//                 START_HIGH : begin   //30us 동안 HIGH 출력
//                     dht_data_out <= 1;  
//                     if (timer_count < 30 * COUNT_1US) begin
//                         timer_count <= timer_count + 1;
//                     end else begin
//                         state <= RESP_LOW;
//                         dht_data_en <= 0;  // 입력 모드
//                         timer_count <= 0;
//                     end            
//                 end
//                 RESP_LOW : begin
//                     if (dht11_data == 1'b0) begin
//                         state <= RESP_HIGH;
//                         timer_count <= 0;
//                     end else if (timer_count > (200 * COUNT_1US)) begin // 200us 타임아웃
//                         state <= ERROR;
//                         timer_count <= 0;
//                     end else begin
//                         timer_count <= timer_count + 1;
//                     end           
//                 end
//                 RESP_HIGH : begin
//                     if (dht11_data == 1'b1) begin
//                         state <= WAIT_BIT_LOW_START;
//                         bit_count <= 0;
//                         timer_count <= 0;
//                     end else if (timer_count > (300 * COUNT_1US)) begin // 300us 타임아웃
//                         state <= ERROR;
//                         timer_count <= 0;
//                     end else begin
//                         timer_count <= timer_count + 1;
//                     end        
//                 end
//                 WAIT_BIT_LOW_START : begin
//                     if (dht11_data == 1'b0) begin
//                         state       <= DATA_WAIT_LOW_END;
//                         timer_count <= 0;
//                     end else if (timer_count > (200 * COUNT_1US)) begin // 200us 타임아웃
//                         state <= ERROR;
//                         timer_count <= 0;
//                     end else begin
//                         timer_count <= timer_count + 1;
//                     end               
//                 end
//                 DATA_WAIT_LOW_END : begin
//                     if (dht11_data == 1'b1) begin
//                         state <= DATA_MEASURE_HIGH;
//                         timer_count <= 0; 
//                     end else if (timer_count > (200 * COUNT_1US)) begin // 200us 타임아웃
//                         state <= ERROR;
//                     end else begin
//                         timer_count <= timer_count + 1;
//                     end
//                 end

//                 DATA_MEASURE_HIGH : begin
//                     if (dht11_data == 1'b0) begin
//                         state <= DATA_PROCESS;
//                     end else begin
//                         timer_count <= timer_count + 1;
//                     end
//                 end

//                 DATA_PROCESS : begin
//                     data_buffer <= data_buffer << 1;
//                     if (timer_count > (40 * COUNT_1US)) begin 
//                         data_buffer[0] <= 1'b1;
//                     end else begin 
//                         data_buffer[0] <= 1'b0;
//                     end

//                     bit_count <= bit_count + 1;

//                     if (bit_count == 39) begin
//                         state <= DATA_END;
//                     end else begin
//                         state <= WAIT_BIT_LOW_START;
//                     end
//                 end
//                 //(data_buffer[39:32] + data_buffer[31:24] + data_buffer[23:16] + data_buffer[15:8]) == data_buffer[7:0]
//                 DATA_END : begin
//                     if (1) begin
//                         humidity            <= data_buffer[39:32];
//                         current_temperature <= data_buffer[23:16];
//                     end
//                     timer_count   <= 0; 
//                     state <= IDLE;   
//                     data_buffer <= 0;
//                     bit_count   <= 0;         
//                 end
//                 ERROR : begin
//                     state       <= IDLE; // 에러 발생 시 IDLE로 돌아가 다시 시도
//                     timer_count   <= 0; 
//                     data_buffer <= 0;
//                     bit_count   <= 0;                    
//                 end
//                 default : state <= IDLE;                                                                                     
//             endcase
//         end
//     end                      
// endmodule


