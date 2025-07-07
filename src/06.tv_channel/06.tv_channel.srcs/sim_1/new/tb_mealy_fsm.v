`timescale 1ns / 1ps

module tb_mealy_fsm;
    reg clk;
    reg rstn;
    reg done;
    wire ack;

    mealy_fsm uut (
        .clk(clk),
        .rstn(rstn),
        .done(done),
        .ack(ack)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn = 0;
        done = 0;
        #12;
        rstn = 1;
        #10;

        // 1) ready 상태에서 done=1로 trans 진입, ack=1 검증
        done = 1; #10;
        done = 0; #10;

        // 2) trans 상태에서 done=0으로 write 진입, ack=0 검증
        done = 0; #10;

        // 3) write 상태에서 done=1로 read 진입, ack=1 검증
        done = 1; #10;
        done = 0; #10;

        // 4) read 상태에서 done=1로 ready 복귀, ack=0 검증
        done = 1; #10;
        done = 0; #10;

        $finish;
    end

endmodule
