`timescale 1ns / 1ps
module Shifter_mul(
    input [5:0] one_mul,
    input [8:0] mul_Exponent,
    
    output [8:0] mul_Exponent_shifter
    );
reg [8:0] ShOut;
always @(*) begin
    if(one_mul >= 6'd9) begin
        ShOut = 9'd0;
    end else begin
        case(one_mul)
 
            5'd1:ShOut = {mul_Exponent[7:0],{1{1'b0}}};
            5'd2:ShOut = {mul_Exponent[6:0],{2{1'b0}}};
            5'd3:ShOut = {mul_Exponent[5:0],{3{1'b0}}};
            5'd4:ShOut = {mul_Exponent[4:0],{4{1'b0}}};
            5'd5:ShOut = {mul_Exponent[3:0],{5{1'b0}}};
            5'd6:ShOut = {mul_Exponent[2:0],{6{1'b0}}};
            5'd7:ShOut = {mul_Exponent[1:0],{7{1'b0}}};
            5'd8:ShOut = {mul_Exponent[0],{8{1'b0}}};
            default:ShOut = 9'd0;
        endcase       
    end
end   
assign mul_Exponent_shifter = ShOut; 
endmodule
