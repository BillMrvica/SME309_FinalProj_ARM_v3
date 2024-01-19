`timescale 1ns / 1ps
module MUL  #(width = 24)// 32-bits for ARMv3
   (
input [width-1:0] Operand1, // Multiplicand / Dividend
        input [width-1:0] Operand2, // Multiplier / Divisor
        output reg [2*width-1:0] Result_MCycle
       
    );
   
    reg [23:0] b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21,b22,b23;
    reg [47:0] y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18,y19,y20,y21,y22,y23;
 
 always@(*)  begin
        b0 = {width{Operand2[0]}};
        b1 = {width{Operand2[1]}};
        b2 = {width{Operand2[2]}};
        b3 = {width{Operand2[3]}};
        b4 = {width{Operand2[4]}};
        b5 = {width{Operand2[5]}};
        b6 = {width{Operand2[6]}};
        b7 = {width{Operand2[7]}};
        b8 = {width{Operand2[8]}};
        b9 = {width{Operand2[9]}};
        b10 = {width{Operand2[10]}};
        b11 = {width{Operand2[11]}};
        b12 = {width{Operand2[12]}};
        b13 = {width{Operand2[13]}};
        b14 = {width{Operand2[14]}};
        b15 = {width{Operand2[15]}};
        b16 = {width{Operand2[16]}};
        b17 = {width{Operand2[17]}};
        b18 = {width{Operand2[18]}};
        b19 = {width{Operand2[19]}};
        b20 = {width{Operand2[20]}};
        b21 = {width{Operand2[21]}};
        b22 = {width{Operand2[22]}};
        b23 = {width{Operand2[23]}};
        
        
        y0 = {24'b00000000,b0&Operand1};
        y1 = {23'b0000000,b1&Operand1,1'b0};
        y2 = {22'b000000,b2&Operand1,2'b00};
        y3 = {21'b00000,b3&Operand1,3'b000};
        y4 = {20'b0000,b4&Operand1,4'b0000};
        y5 = {19'b000,b5&Operand1,5'b00000};
        y6 = {18'b00,b6&Operand1,6'b000000};
        y7 = {17'b0,b7&Operand1,7'b0000000};
        y8 = {16'b0,b8&Operand1,8'b0000000};
        y9 = {15'b0,b9&Operand1,9'b0000000};
        y10 = {14'b0,b10&Operand1,10'b0000000};
        y11 = {13'b0,b11&Operand1,11'b0000000};
        y12 = {12'b0,b12&Operand1,12'b0000000};
        y13 = {11'b0,b13&Operand1,13'b0000000};
        y14 = {10'b0,b14&Operand1,14'b0000000};
        y15 = {9'b0,b15&Operand1,15'b0000000};
        y16 = {8'b0,b16&Operand1,16'b0000000};
        y17 = {7'b0,b17&Operand1,17'b0000000};
        y18 = {6'b0,b18&Operand1,18'b0000000};
        y19 = {5'b0,b19&Operand1,19'b0000000};
        y20 = {4'b0,b20&Operand1,20'b0000000};
        y21 = {3'b0,b21&Operand1,21'b0000000};
        y22 = {2'b0,b22&Operand1,22'b0000000};
        y23 = {1'b0,b23&Operand1,23'b0000000};
       
        
        Result_MCycle = ((y0 + y1) + (y2 + y3)) + ((y4 + y5) + (y6 + y7) + (y8 + y9) + (y10 + y11) + (y12 + y13) + (y14 + y15) + (y16 + y17) + (y18 + y19) + (y20 + y21) + (y22 + y23));
    end

//    reg[2*width-1:0] c;
    
//    integer i;
//    always@(Operand1 or Operand2)
//    begin
//        c=0;
//        for (i=1; 1<=width;i=i+1) begin
//            c = c + ((Operand2[i] == 1) ? (Operand1 << {i-1}):0);     //ÒÆÎ»Ïà¼Ó
//        end
//    end
//reg [2*width-1:0] shifted_op2_divider_mul;
//reg [2*width-1:0] temp_sum_divider_mul;
//reg [2*width-1:0] temp_sum2;
//reg [2*width-1:0] sum;
//generate
//    genvar i;
//    for(i=0;i<25;i=i+1)begin:mul
//        always @(*) begin
//            if(i == 1'b0) begin
//                shifted_op2_divider_mul = {Operand2,{width{1'b0}}};
//                temp_sum_divider_mul = {{width{1'b0}}, Operand1};
//            end else begin
//                if(temp_sum_divider_mul[0]) begin
//                    temp_sum2 = shifted_op2_divider_mul + temp_sum_divider_mul;
//                    temp_sum_divider_mul = temp_sum2 >> 1;
//                end else begin
//                    temp_sum_divider_mul = temp_sum_divider_mul >>1;
//                end
//            end
//            if(i==24) begin
//                sum = temp_sum_divider_mul;
                
//            end
//        end
//    end
//endgenerate 

//assign    Result_MCycle = c; 
 
        
endmodule
