`timescale 1ns / 1ps
module Shifter2(
    input [1:0] Sh,
    input [4:0] Shamt5,
    input [31:0] ShIn,
    
    output [31:0] ShOut
    );
//reg [31:0] ShOut1;
//always @(*) begin
//    case(Sh)
//    2'b00:ShOut1 = ShIn << Shamt5;
//    2'b01:ShOut1 = ShIn >> Shamt5;
//    2'b10:ShOut1 = ($signed(ShIn)) >>> Shamt5;
//    2'b11:ShOut1 = (ShIn >> Shamt5) | ShIn << (5'd32 - Shamt5); 
//    default:ShOut1 <= ShOut;
//    endcase
//end   
//assign ShOut = ShOut1;
wire [3:0] zero = 4'b0000;
wire [31:0] ShOutLSLA;
wire [31:0] ShOutLSLB;
wire [31:0] ShOutLSLC;
wire [31:0] ShOutLSLD;
wire [31:0] ShOutLSL;
//LSL
assign ShOutLSLA = (Shamt5[4]==1)?{ShIn[15:0],{16{1'b0}}}:ShIn;
assign ShOutLSLB = (Shamt5[3]==1)?{ShOutLSLA[23:0],{8{1'b0}}}:ShOutLSLA;
assign ShOutLSLC = (Shamt5[2]==1)?{ShOutLSLB[27:0],{4{1'b0}}}:ShOutLSLB;
assign ShOutLSLD = (Shamt5[1]==1)?{ShOutLSLC[29:0],{2{1'b0}}}:ShOutLSLC;
assign ShOutLSL = (Shamt5[0]==1)?{ShOutLSLD[30:0],{1{1'b0}}}:ShOutLSLD;
//LSR
wire [31:0] ShOutLSRA;
wire [31:0] ShOutLSRB;
wire [31:0] ShOutLSRC;
wire [31:0] ShOutLSRD;
wire [31:0] ShOutLSR;
assign ShOutLSRA = (Shamt5[4]==1)?{{16{1'b0}},ShIn[31:16]}:ShIn;
assign ShOutLSRB = (Shamt5[3]==1)?{{8{1'b0}},ShOutLSRA[31:8]}:ShOutLSRA;
assign ShOutLSRC = (Shamt5[2]==1)?{{4{1'b0}},ShOutLSRB[31:4]}:ShOutLSRB;
assign ShOutLSRD = (Shamt5[1]==1)?{{2{1'b0}},ShOutLSRC[31:2]}:ShOutLSRC;
assign ShOutLSR  = (Shamt5[0]==1)?{{1{1'b0}},ShOutLSRD[31:1]}:ShOutLSRD;
//ASR
wire [31:0] ShOutASRA;
wire [31:0] ShOutASRB;
wire [31:0] ShOutASRC;
wire [31:0] ShOutASRD;
wire [31:0] ShOutASR;
assign ShOutASRA = (Shamt5[4]==1)?{{16{ShIn[31]}},ShIn[31:16]}:ShIn;
assign ShOutASRB = (Shamt5[3]==1)?{{8{ShIn[31]}},ShOutASRA[31:8]}:ShOutASRA;
assign ShOutASRC = (Shamt5[2]==1)?{{4{ShIn[31]}},ShOutASRB[31:4]}:ShOutASRB;
assign ShOutASRD = (Shamt5[1]==1)?{{2{ShIn[31]}},ShOutASRC[31:2]}:ShOutASRC;
assign ShOutASR  = (Shamt5[0]==1)?{{1{ShIn[31]}},ShOutASRD[31:1]}:ShOutASRD;
//ROR
wire [31:0] ShOutRORA;
wire [31:0] ShOutRORB;
wire [31:0] ShOutRORC;
wire [31:0] ShOutRORD;
wire [31:0] ShOutROR;
assign ShOutRORA = (Shamt5[4]==1)?{ShIn[15:0],ShIn[31:16]}:ShIn;
assign ShOutRORB = (Shamt5[3]==1)?{ShOutRORA[7:0],ShOutRORA[31:8]}:ShOutRORA;
assign ShOutRORC = (Shamt5[2]==1)?{ShOutRORB[3:0],ShOutRORB[31:4]}:ShOutRORB;
assign ShOutRORD = (Shamt5[1]==1)?{ShOutRORC[1:0],ShOutRORC[31:2]}:ShOutRORC;
assign ShOutROR  = (Shamt5[0]==1)?{ShOutRORD[0],ShOutRORD[31:1]}:ShOutRORD;
//get ShOut
reg [31:0] ShOut1;
always @(*) begin
    case(Sh)
    2'b00:ShOut1 = ShOutLSL;
    2'b01:ShOut1 = ShOutLSR;
    2'b10:ShOut1 = ShOutASR;
    2'b11:ShOut1 = ShOutROR; 
    default:ShOut1 <= ShOut;
    endcase
end   
assign ShOut = ShOut1;
endmodule 