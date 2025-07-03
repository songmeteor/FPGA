`timescale 1ns / 1ps

module btn_command_controller(
    input clk,
    input reset,  //          
    input [2:0] btn, // L C R 
    input [7:0] sw,
    output [13:0] seg_data,
    output reg [15:0] led    
    );

    //mode
    parameter UP_COUNTER = 3'b000;
    parameter DOWN_COUNTER = 3'b001;
    parameter SLIDE_SW_READ = 3'b010;

    reg prev_btnL = 0;
    reg [2:0] r_mode;
    reg [19:0] counter;
    reg [13:0] ms10_up_counter;
    reg [13:0] ms10_down_counter;

    //mode check
    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            r_mode <= 0;
            prev_btnL <= 0;
        end else begin
            if(btn[0] && !prev_btnL) begin // 처음 눌려진 상태
                r_mode <= (r_mode == SLIDE_SW_READ) ? UP_COUNTER : r_mode + 1;
            end 
            prev_btnL <= btn[0];  
        end
    end

    // up / down counter 
    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            counter <= 0;
            ms10_up_counter <= 0;
            ms10_down_counter <= 9999;
        end else if(r_mode == UP_COUNTER) begin
            if(counter == 20'd1_000_000) begin  //10ms
                ms10_up_counter <= ms10_up_counter + 1;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end  
        end else if(r_mode == DOWN_COUNTER) begin
            if(counter == 20'd1_000_000) begin  //10ms
                ms10_down_counter <= ms10_down_counter - 1;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end 
        end else begin
            ms10_up_counter <= 0;
            ms10_down_counter <= 0;
            counter <= 0;       
        end
    end

    //led
    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            led[15:13] <= 3'b100;
        end    
        case(r_mode)
            UP_COUNTER: led[15:13] <= 3'b100;
            DOWN_COUNTER: led[15:13] <= 3'b010;
            SLIDE_SW_READ: led[15:13] <= 3'b001;
            default : led[15:13] <= 3'b000;
        endcase      
    end
 
    assign seg_data = (r_mode == UP_COUNTER) ? ms10_up_counter : 
                      (r_mode == DOWN_COUNTER) ? ms10_down_counter : sw;
endmodule
