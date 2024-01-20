`timescale 1ns / 1ps
module FPU3#(width = 24)(
    input FPUcontrol, // 替换sec;//sec==1;加法减法   sec==0;乘法
    input [31:0] FloatingPointa,
    input [31:0] FloatingPointb,
    output [31:0] FloatingPointResult
    );
//加法减法，乘法除法
// wire sec;//sec==1;加法减法   sec==0;乘法除法
// assign sec = (instr[31:30]==2'b11) ? 1'b1:1'b0;
//获得输入a的符号，指数，尾数  
reg a_sign;
reg [7:0] a_Exponent;
reg [23:0] a_Mantissa;
always @(*) begin
    a_sign = FloatingPointa[31];
    a_Exponent = FloatingPointa[30:23];
    a_Mantissa[22:0] = FloatingPointa[22:0];
    a_Mantissa[23] = 1'b1;
end
//获得输入b的符号，指数，尾数     
reg b_sign;
reg [7:0] b_Exponent;
reg [23:0] b_Mantissa;
always @(*) begin
    b_sign = FloatingPointb[31];
    b_Exponent = FloatingPointb[30:23];
    b_Mantissa[22:0]= FloatingPointb[22:0];
    b_Mantissa[23] = 1'b1;
end   
//判断是否有特殊值。
reg a0;
reg b0;
reg apos;
reg bpos;
reg aneg;
reg bneg;
reg NaN;
reg special_add;
reg special_zero_mul,special_zero_mul_2;
always @(*) begin
    if(a_Exponent==8'b0000_0000 && a_Mantissa==24'b1000_0000_0000_0000_0000_0000) begin
        a0 = 1;
    end else begin
        a0 = 0;
    end
    if(b_Exponent==8'b0000_0000 && b_Mantissa==24'b1000_0000_0000_0000_0000_0000) begin
        b0 = 1;
    end else begin
        b0 = 0;
    end
    if(a_sign==1'b0 && a_Exponent==8'b1111_1111 && a_Mantissa==24'b1000_0000_0000_0000_0000_0000) begin
        apos = 1;
    end else begin
        apos = 0;
    end
    if(b_sign==1'b0 && b_Exponent==8'b1111_1111 && b_Mantissa==24'b1000_0000_0000_0000_0000_0000) begin
        bpos = 1;
    end else begin
        bpos = 0;
    end
    if(a_sign==1'b1 && a_Exponent==8'b1111_1111 && a_Mantissa==24'b1000_0000_0000_0000_0000_0000) begin
        aneg = 1;
    end else begin
        aneg = 0;
    end
    if(b_sign==1'b1 && b_Exponent==8'b1111_1111 && b_Mantissa==24'b1000_0000_0000_0000_0000_0000) begin
        bneg = 1;
    end else begin
        bneg = 0;
    end
    if(a_Exponent==8'b1111_1111 && a_Mantissa!=24'b1000_0000_0000_0000_0000_0000 || b_Exponent==8'b1111_1111 && b_Mantissa!=24'b1000_0000_0000_0000_0000_0000) begin
        NaN = 1;
    end else begin
        NaN = 0;
    end
    special_add = apos|bpos|aneg|bneg|NaN;
    special_zero_mul = (a0&bpos)|(apos&b0)|(a0&bneg)|(aneg&b0);
    special_zero_mul_2 = (a0 | b0) & (~special_zero_mul);
end
//计算浮点数加法
reg [7:0] c_Exponent;
reg [23:0] aa_Mantissa;
reg [23:0] bb_Mantissa;
//按照指数移位，aa_Mantissa和bb_Mantissa对应的指数应当相同，c_Exponent对应大的指数。
reg [7:0] Shamt8;
reg [23:0] ShIn_Mantissa;
wire [23:0] ShOut_Mantissa;
always @(*) begin
    if(a_Exponent <= b_Exponent && special_add == 1'b0) begin
        Shamt8 = b_Exponent - a_Exponent;
        ShIn_Mantissa = a_Mantissa;
    end else if(special_add == 1'b0) begin
        Shamt8 = a_Exponent - b_Exponent;
        ShIn_Mantissa = b_Mantissa;
    end
end
Shifter_add u_Shifter_add (
.Shamt8(Shamt8),
.ShIn_Mantissa(ShIn_Mantissa),
.ShOut_Mantissa(ShOut_Mantissa)
);
always @(*) begin
    if(a_Exponent <= b_Exponent && special_add == 1'b0) begin
        //aa_Mantissa = a_Mantissa >> (b_Exponent - a_Exponent);
        aa_Mantissa = ShOut_Mantissa;
        bb_Mantissa = b_Mantissa;
        c_Exponent = b_Exponent;
    end else if(special_add == 1'b0) begin
        //bb_Mantissa = b_Mantissa >> (a_Exponent - b_Exponent);
        bb_Mantissa = ShOut_Mantissa;
        aa_Mantissa = a_Mantissa;
        c_Exponent = a_Exponent;
    end
end
//根据符号位是否相同来进行加法或取反加一的减法.获得 c_Mantissa，最高位判断是否进位。
reg c_sign; 
reg [24:0] c_Mantissa;
always @(*) begin
    if(a_sign != b_sign && special_add == 1'b0) begin
        if(aa_Mantissa <= bb_Mantissa && special_add == 1'b0) begin
            c_sign = b_sign;
            c_Mantissa = (~aa_Mantissa + 24'd1) + bb_Mantissa;
        end else if(special_add == 1'b0) begin
            c_sign = a_sign;
            c_Mantissa = (~bb_Mantissa + 24'd1) + aa_Mantissa;
        end
    end else if(special_add == 1'b0) begin 
        c_sign = a_sign;
        c_Mantissa = bb_Mantissa + aa_Mantissa;
    end
end    
//异号相加时，获得除24位的首个1
wire [4:0] pos_range[0:24];
wire [4:0] one;    
assign    pos_range[0]=24'd0;//default
generate
    genvar i;
    for(i=0;i<24;i=i+1)begin
        assign    pos_range[i+1]=(c_Mantissa[i]==1'b1)? (24-1-i):pos_range[i];
    end
endgenerate

assign    one=pos_range[24];
//根据c_Mantissa的前两位和符号位来判断c_Mantissa的变化以及c_Exponent的变化，获得最终结果。
reg [7:0] result_Exponent;
reg [22:0] result_Mantissa;
//调用shifter
reg [1:0] start_shifter;
reg [1:0] Sh;
reg [4:0] Shamt5;
reg [31:0] ShIn;
wire [31:0] ShOut;
always @(*) begin
    if(start_shifter == 2'b00) begin
        Sh = 2'b00;
        Shamt5 = one;
        ShIn[31:7] = c_Mantissa;
        ShIn[6:0] = 7'd0;
    end else if(start_shifter == 2'b01) begin
        Sh = 2'b01;
        Shamt5 = 5'd1;
        ShIn[31:7] = c_Mantissa;
        ShIn[6:0] = 7'd0;
    end
end
Shifter2 u_Shifter2 (
.Sh(Sh),
.Shamt5(Shamt5),
.ShIn(ShIn),
.ShOut(ShOut)
);


always @(*) begin
    if(a_sign != b_sign && special_add == 1'b0) begin
        if(c_Mantissa[23:0]==24'b0000_0000_0000_0000_0000_0000 && special_add == 1'b0) begin
            result_Exponent = 8'd0;
            result_Mantissa = c_Mantissa;
        end else
        if(special_add == 1'b0) begin
            start_shifter = 2'b00;
            result_Exponent = c_Exponent - one;
            //result_Mantissa = c_Mantissa << one;
            result_Mantissa = ShOut[29:7];
        end
    end else if(special_add == 1'b0) begin
        if(c_Mantissa[24] == 1'b1 && special_add == 1'b0) begin
            start_shifter = 2'b01;
            result_Exponent = c_Exponent + 8'd1;
            //result_Mantissa = c_Mantissa >> 1'd1;
            result_Mantissa = ShOut[29:7];
        end else if(special_add == 1'b0) begin
            result_Exponent = c_Exponent;
            result_Mantissa = c_Mantissa;
        end
    end
end
//计算浮点数乘法
//获得乘法结果符号
wire mul_result_sign;
assign mul_result_sign = a_sign^b_sign;
//获得乘法结果指数
wire [8:0] mul_Exponent;
assign mul_Exponent =a_Exponent + b_Exponent -9'd127;
//计算乘法结果尾数
wire [47:0] mul_Mantissa;
wire [47:0] Result_MCycle;
//assign mul_Mantissa = a_Mantissa * b_Mantissa;
MUL u_MUL (
.Operand1(a_Mantissa),
.Operand2(b_Mantissa),
.Result_MCycle(Result_MCycle)
);
assign mul_Mantissa = Result_MCycle;


//reg [2*width-1:0] shifted_op2_divider_mul;
//reg [2*width-1:0] temp_sum_divider_mul;
//reg [2*width-1:0] temp_sum2;
//reg [2*width-1:0] sum;
//generate
//    genvar m;
//    for(m=0;m<25;m=m+1)begin
//        always @(*) begin
//            if(m == 1'b0) begin
//                shifted_op2_divider_mul = {a_Mantissa,{width{1'b0}}};
//                temp_sum_divider_mul = {{width{1'b0}}, b_Mantissa};
//            end else begin
//                if(temp_sum_divider_mul[0]) begin
//                    temp_sum2 = shifted_op2_divider_mul + temp_sum_divider_mul;
//                    temp_sum_divider_mul = temp_sum2 >> 1;
//                end else begin
//                    temp_sum_divider_mul = temp_sum_divider_mul >>1;
//                end
//            end
//            if(m==24) begin
//                sum = temp_sum_divider_mul;
//            end
//        end
//    end
//endgenerate
//assign    mul_Mantissa = sum; 
//符号数相乘时，获得46位的首个1
wire [5:0] pos_range_mul [0:46];
wire [5:0] one_mul;    
assign    pos_range_mul[0]=46'd0;//default
generate
    genvar q;
    for(q=0;q<46;q=q+1)begin
        assign    pos_range_mul[q+1]=(mul_Mantissa[q]==1'b1)? (46-1-q):pos_range_mul[q];
    end
endgenerate
assign    one_mul=pos_range_mul[46];
//得到真正的乘法结果指数尾数   1、超出指数范围，输出NaN
reg [22:0] mul_result_Mantissa;
reg [7:0] mul_result_Exponent;
reg [47:0] mul_Mantissa_round;
//用Shifter_mul取代<<
wire [8:0] mul_Exponent_shifter;
Shifter_mul u_Shifter_mul (
.one_mul(one_mul),
.mul_Exponent(mul_Exponent),
.mul_Exponent_shifter(mul_Exponent_shifter)
);
always @(*) begin
    if(mul_Exponent >= 9'd256) begin
        mul_result_Exponent = 8'b1111_1111;
        mul_result_Mantissa = 23'b1111_1111_1111_1111_1111_111;
    end else begin
        if(mul_Mantissa[47]==1'b1 && mul_Exponent != 8'b1111_1111) begin
            mul_result_Exponent = mul_Exponent + 8'd1;
            mul_result_Mantissa = mul_Mantissa[46:24];
        end else if(mul_Mantissa[47]==1'b1 && mul_Exponent == 8'b1111_1111) begin
            mul_result_Exponent = 8'b1111_1111;
            mul_result_Mantissa = 23'b1111_1111_1111_1111_1111_111;
        end else begin
           // mul_result_Exponent = mul_Exponent - one_mul;
            //mul_Mantissa_round = mul_Exponent << one_mul;
              mul_result_Exponent = mul_Exponent;
            //mul_Mantissa_round = mul_Exponent_shifter;
            mul_result_Mantissa = mul_Mantissa[45:23];
        end
    end
end
//得到特殊值结果
reg [31:0] special_add_result;
always @(*) begin
    if(NaN==1'b1) begin
        special_add_result = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
    end else if (FPUcontrol == 1'b1) begin
       if(a_sign == b_sign) begin
            if(apos==1'b1 && bneg==1'b1 || aneg==1'b1 && bpos==1'b1) begin
                special_add_result = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
            end else if(apos==1'b1 || bpos==1'b1) begin
                special_add_result = 32'b0111_1111_1000_0000_0000_0000_0000_0000;
            end else if(aneg==1'b1 || bneg==1'b1) begin
                special_add_result = 32'b1111_1111_1000_0000_0000_0000_0000_0000;
            end    
       end else begin
            if(apos==1'b1 && bpos==1'b1 || aneg==1'b1 && bneg==1'b1) begin
                special_add_result = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
            end else if(apos==1'b1 || bneg==1'b1) begin
                special_add_result = 32'b0111_1111_1000_0000_0000_0000_0000_0000;
            end else if(aneg==1'b1 || bpos==1'b1) begin
                special_add_result = 32'b1111_1111_1000_0000_0000_0000_0000_0000;
            end
        end       
    end else begin    
        if(special_zero_mul == 1'b1) begin
            special_add_result = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
        end else if(special_zero_mul_2 == 1'b1) begin
            special_add_result = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        end
    end
end
//获得Result
reg [31:0] Result;
always @(*) begin
    if(special_add == 1'b1) begin
        Result = special_add_result;
    end else begin
        if(FPUcontrol == 1'b1) begin
            Result[31] = c_sign;
            Result[30:23] = result_Exponent;
            Result[22:0] = result_Mantissa;
        end else begin
            if(special_zero_mul==1'b1) begin
                Result = special_add_result;
            end else if(special_zero_mul_2==1'b1) begin
                Result = special_add_result;
            end else begin
            Result[31] = mul_result_sign;
            Result[30:23] = mul_result_Exponent;
            Result[22:0] = mul_result_Mantissa;
            end
        end
    end
end    
//得到最终结果
assign FloatingPointResult = Result; 

endmodule


