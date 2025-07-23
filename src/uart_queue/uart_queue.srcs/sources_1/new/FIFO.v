`timescale 1ns / 1ps

module FIFO #(parameter width=8, parameter depth=16) (
    input             clk,
    input             reset,
    input             we,
    input             re,
    input [width-1:0] din,

    output reg [width-1:0] dout,    
    output                 empty,
    output                 full
    );

    reg [width-1 : 0] mem [depth-1:0];
    reg [$clog2(depth):0] r_count;
    reg[$clog2(depth)-1:0] pop,push;

    assign empty = (r_count == 0);
    assign full  = (r_count == depth);

//push
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            push <= 0;
        end else begin
            if(!full && we) begin
                mem[push] <= din;
                push <= push + 1;
            end
        end
    end
    
//pop
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            pop <= 0;
            dout <= 0;
        end else begin
            if(!empty && re) begin
                dout <= mem[pop];
                pop <= pop + 1;
            end 
        end
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_count <= 0;
        end else begin
            case ({we && !full, re && !empty}) // write, read
                2'b01: r_count <= r_count - 1; // Read only
                2'b10: r_count <= r_count + 1; // Write only
                2'b11: r_count <= r_count;     // Read and Write (no change)
                default: r_count <= r_count;   // No operation
            endcase
        end
    end    
 endmodule
