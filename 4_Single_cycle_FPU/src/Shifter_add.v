`timescale 1ns / 1ps
module Shifter_add(
    input [7:0] Shamt8,
    input [23:0] ShIn_Mantissa,
    
    output [23:0] ShOut_Mantissa
    );

wire [23:0] ShOutLSRA;
wire [23:0] ShOutLSRB;
wire [23:0] ShOutLSRC;
wire [23:0] ShOutLSRD;
wire [23:0] ShOutLSR;
assign ShOutLSRA = (Shamt8[4]==1)?{{16{1'b0}},ShIn_Mantissa[23:16]}:ShIn_Mantissa;
assign ShOutLSRB = (Shamt8[3]==1)?{{8{1'b0}},ShOutLSRA[23:8]}:ShOutLSRA;
assign ShOutLSRC = (Shamt8[2]==1)?{{4{1'b0}},ShOutLSRB[23:4]}:ShOutLSRB;
assign ShOutLSRD = (Shamt8[1]==1)?{{2{1'b0}},ShOutLSRC[23:2]}:ShOutLSRC;
assign ShOutLSR  = (Shamt8[0]==1)?{{1{1'b0}},ShOutLSRD[23:1]}:ShOutLSRD;
assign ShOut_Mantissa = (Shamt8 >= 8'd24) ? 24'd0:ShOutLSR;
endmodule
