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

        // 1) ready ���¿��� done=1�� trans ����, ack=1 ����
        done = 1; #10;
        done = 0; #10;

        // 2) trans ���¿��� done=0���� write ����, ack=0 ����
        done = 0; #10;

        // 3) write ���¿��� done=1�� read ����, ack=1 ����
        done = 1; #10;
        done = 0; #10;

        // 4) read ���¿��� done=1�� ready ����, ack=0 ����
        done = 1; #10;
        done = 0; #10;

        $finish;
    end

endmodule
