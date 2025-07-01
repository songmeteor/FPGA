`timescale 1ns / 1ps


// module gate_test(
//     input wire a,  //slide switch
//     input b,     // 생략하면 wire
//     output ld0, ld1, ld2, ld3, ld4, ld5
//     );

//   //assign out = a & b;
//     assign ld0 = a & b;
//     assign ld1 = a | b;
//     assign ld2 = ~(a & b);   //NAND
//     assign ld3 = ~(a | b);   //NOR
//     assign ld4 = a ^ b;      //XOR
//     assign ld5 = ~a;         //NOT
// endmodule


module gate_test(
    input wire a,  //slide switch
    input b,     // 생략하면 wire
    output [5:0] ld 
    );

  //assign out = a & b;
    assign ld[0] = a & b;
    assign ld[1] = a | b;
    assign ld[2] = ~(a & b);   //NAND
    assign ld[3] = ~(a | b);   //NOR
    assign ld[4] = a ^ b;      //XOR
    assign ld[5] = ~a;         //NOT
endmodule
