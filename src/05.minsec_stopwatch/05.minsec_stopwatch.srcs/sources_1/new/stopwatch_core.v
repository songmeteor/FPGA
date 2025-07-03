`timescale 1ns / 1ps

module stopwatch_core(
    input clear,
    input clk,
    input reset,
    input run_stop,
    output reg[4:0] hour_count,
    output reg[5:0] min_count,
    output reg[12:0] sec_count,
    output reg[13:0] stopwatch_count
    );

    reg [19:0] counter;
    reg [13:0] ms10_up_counter;

    //stop watch up counter 
    always @ (posedge clk, posedge reset) begin
        if(reset || clear) begin
            counter <= 0;
            ms10_up_counter <= 0;
        end else begin
            if(counter == 20'd1_000_000) begin  //10ms
                ms10_up_counter <= ms10_up_counter + 1;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end          
        end
        stopwatch_count <= ms10_up_counter;
    end

    always @ (posedge clk, posedge reset) begin
        if(reset || clear) begin
            counter <= 0;
            ms10_up_counter <= 0;
            sec_count <=0;
        end else if(ms10_up_counter % 100 == 0) begin
            sec_count <= sec_count + 1;
        end       
    end

    always @ (posedge clk, posedge reset) begin
        if(reset || clear) begin
            counter <= 0;
            ms10_up_counter <= 0;
            min_count <=0;
        end else if(sec_count % 60 == 0) begin
            min_count <= min_count + 1;
        end       
    end

    always @ (posedge clk, posedge reset) begin
        if(reset || clear) begin
            counter <= 0;
            ms10_up_counter <= 0;
            hour_count <=0;
        end else if(sec_count % 60 == 0) begin
            hour_count <= hour_count + 1;
        end       
    end

endmodule
