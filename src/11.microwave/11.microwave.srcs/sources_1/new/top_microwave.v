`timescale 1ns / 1ps

module top_microwave(
    input        clk,
    input        reset,
    input        btnU,
    input        btnL,
    input        btnC,
    input        btnD,
    input        door,
    output [7:0] seg,
    output [3:0] an,
    output       buzzer,
    output [1:0] in1_in2,
    output       servo, 
    output       dc_motor 
    );

    wire w_btnU, w_btnL, w_btnC, w_btnD;
    wire [13:0] w_run_time;
    wire [2:0]  w_mode;

    // button_debounce u_btnU(.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    // button_debounce u_btnL(.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));
    // button_debounce u_btnC(.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    // button_debounce u_btnD(.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));   

    debounce_pushbutton u_btnU(.clk(clk), .noise_btn(btnU), .clean_btn(w_btnU));
    debounce_pushbutton u_btnL(.clk(clk), .noise_btn(btnL), .clean_btn(w_btnL));   
    debounce_pushbutton u_btnC(.clk(clk), .noise_btn(btnC), .clean_btn(w_btnC));   
    debounce_pushbutton u_btnD(.clk(clk), .noise_btn(btnD), .clean_btn(w_btnD));      

    fsm u_fsm(
        .clk     (clk),
        .reset   (reset),
        .btnU    (w_btnU),
        .btnL    (w_btnL),
        .btnC    (w_btnC),
        .btnD    (w_btnD),
        .door    (door),   
        .run_time(w_run_time),
        .mode    (w_mode)
        );

    btn_controller u_btn_controller(
        .clk        (clk),
        .reset      (reset),
        .btnU       (w_btnU),
        .btnL       (w_btnL),
        .btnC       (w_btnC),
        .btnD       (w_btnD),
        .mode       (w_mode),
        .run_time   (w_run_time)
        );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .mode(w_mode),
        .input_data(w_run_time), 
        .seg_data(seg),
        .an(an)       
        );

    dc_motor_controller u_dc_motor_controller(
        .clk(clk),
        .mode(w_mode),
        .dc_motor(dc_motor),
        .in1_in2(in1_in2) 
        );

    servo_controller u_servo_controller(
        .clk(clk),    
        .reset(reset),  
        .door(door),   
        .servo(servo)   
    ); 

    buzzer_controller u_buzzer_controller(
        .clk(clk),
        .reset(reset),
        .btnU(w_btnU),
        .btnL(w_btnL),
        .btnC(w_btnC),
        .btnD(w_btnD),
        .mode(w_mode),
        .buzzer(buzzer)
        );                              
endmodule
