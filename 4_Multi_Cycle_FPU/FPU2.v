`timescale 1ns / 1ps
module FPU2#(width = 24)(
    input CLK,
    input Reset,
    input [31:0] Src_A,
    input [31:0] Src_B,
    input FPUControl,  // 0 - FADD, 1 - FMUL
    input FPUStart_cond,
    input [3:0] WA3_FPU_in,
    
    input FPU_halt,
    
    output FPUBusy,
    output FPUReady,
    output [3:0] WA3_FPU_out,
    output reg [31:0] FPUResult // reg?
    );
    
    reg [3:0] WA3_FPU_store;
    reg [31:0] Src_A_FPU_store;
    reg [31:0] Src_B_FPU_store;
    
    always @(*) begin // ����ֵ������ // FPUControl���ô��棿�˷�/�ӷ�/�����������һ���ھ�����
        if(FPUStart_cond) begin
            WA3_FPU_store = WA3_FPU_in;
            Src_A_FPU_store = Src_A;
            Src_B_FPU_store = Src_B;
        end
    end   
    
    assign WA3_FPU_out = WA3_FPU_store; // д��ʱ��Ҫ����ready=1����busy��Ҫ�����ж��Ƿ���ͣ�ͳ�ˢ
    
    reg a_sign;
    reg [7:0] a_Exponent;
    reg [23:0] a_Mantissa;
    always @(*) begin
        a_sign = Src_A_FPU_store[31];
        a_Exponent = Src_A_FPU_store[30:23];
        a_Mantissa[22:0] = Src_A_FPU_store[22:0];
        a_Mantissa[23] = 1'b1;
    end
    //�������b�ķ��ţ�ָ����β��     
    reg b_sign;
    reg [7:0] b_Exponent;
    reg [23:0] b_Mantissa;
    always @(*) begin 
        b_sign = Src_B_FPU_store[31];
        b_Exponent = Src_B_FPU_store[30:23];
        b_Mantissa[22:0]= Src_B_FPU_store[22:0];
        b_Mantissa[23] = 1'b1;
    end   
    //�ж��Ƿ�������ֵ��
    reg a0;
    reg b0;
    reg apos;
    reg bpos;
    reg aneg;
    reg bneg;
    reg NaN;
    reg special_add;
    reg special_zero_mul;
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
        special_add = apos|bpos|aneg|bneg|(FPUControl == 1'b0 & NaN);
        special_zero_mul = (a0&bpos) | (apos&b0) | (a0&bneg) | (aneg&b0)
        |(apos & bpos) | (aneg & bpos)| (apos & bneg) | (aneg & bneg);
    end
    
    
    //���㸡�����ӷ�
    reg [7:0] c_Exponent;
    reg [23:0] aa_Mantissa;
    reg [23:0] bb_Mantissa;
    //����ָ����λ��aa_Mantissa��bb_Mantissa��Ӧ��ָ��Ӧ����ͬ��c_Exponent��Ӧ���ָ����
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
            aa_Mantissa = ShOut_Mantissa;
            bb_Mantissa = b_Mantissa;
            c_Exponent = b_Exponent;
        end else if(special_add == 1'b0) begin
            bb_Mantissa = ShOut_Mantissa;
            aa_Mantissa = a_Mantissa;
            c_Exponent = a_Exponent;
        end
    end
    //���ݷ���λ�Ƿ���ͬ�����мӷ���ȡ����һ�ļ���.��� c_Mantissa�����λ�ж��Ƿ��λ��
    reg c_sign; 
    reg [24:0] c_Mantissa;
    always @(*) begin
        if(a_sign != b_sign && special_add == 1'b0) begin // special_add������FPUcontrolΪ1�����
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
    //������ʱ����ó�24λ���׸�1
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
    //����c_Mantissa��ǰ��λ�ͷ���λ���ж�c_Mantissa�ı仯�Լ�c_Exponent�ı仯��������ս����
    reg [7:0] result_Exponent;
    reg [22:0] result_Mantissa;
    //����shifter
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
        if(FPUControl == 0) begin
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
    end
    
    //���㸡�����˷�
    //��ó˷��������
    wire mul_result_sign;
    assign mul_result_sign = a_sign^b_sign;
    //��ó˷����ָ��
    wire [8:0] mul_Exponent;
    wire overflow;
    assign mul_Exponent = a_Exponent + b_Exponent -9'd127;
    assign overflow = (mul_Exponent >= 9'd256);
    
     wire [22:0] mul_result_Mantissa;
     wire special_mul;
     assign special_mul = special_zero_mul | overflow | (FPUControl == 1'b1 & NaN);
     
     // reg FPUBusy_add;
      reg FPUBusy_mul = 0; // ����case default��Ҳ�У�
      reg FPUReady_add = 0;
      reg FPUReady_mul = 0;
      reg FPUReady_special = 0;// ������ֵ��
     // reg FPUBusy_special;
    
      localparam IDLE = 1'b0;
      localparam COMPUTING = 1'b1;
      reg state, n_state;
      reg done;
    
     always @(posedge CLK) begin
        if(Reset) //  || FPU_halt
          state <= IDLE;
        else  // �ӷ�ʱҲ���е��ǲ���ֵFPUresult���Ƿ��ռ�ÿռ䣿һֱmulbusy��
        if(FPUControl == 1'b1) begin
              state <= n_state;
        end
     end
     
     always @(*) begin // ����߼�
         case(state)
             IDLE: begin
                   if(FPUControl == 1'b1 & special_mul == 1'b0 & FPUStart_cond & ~FPUReady) begin //add�� special��ʱ�򶼲�Ӧ�����У�û��busy�Ͳ���stall��flush
                     n_state = COMPUTING;
                     FPUBusy_mul = 1'b1; // ���� addbusy/mulbusy
                   end
                   else begin
                     n_state = IDLE;
                     FPUBusy_mul = 1'b0;
                   end
             end
             COMPUTING: begin
                   if(~done) begin
                     n_state = COMPUTING ;
                     FPUBusy_mul = 1'b1 ;
                   end
                   else begin
                     n_state = IDLE; // ���һ����������done����1��n_stateΪ����
                     FPUBusy_mul = 1'b0;
                   end
             end
             default:FPUBusy_mul = 1'b0; // �������X
         endcase
     end
  
      reg FPUBusy1_mul; // use to judge the negedge of FPUBusy_mul ?
      
      always @(posedge CLK) begin  // @ (CLK or *) ?
        if(Reset ) begin // || FPU_halt
            if(FPUBusy_mul == 1) begin 
                FPUBusy1_mul = 1; // ��ǰʱ��busyΪ1
                FPUReady_mul = 0;
            end
            else if(FPUBusy_mul == 0 & FPUBusy1_mul == 1)begin // ��ǰʱ��busyΪ0����һ��busyΪ1�����½���
                FPUReady_mul = 1; 
                FPUBusy1_mul = 0; // ���µ�ǰʱ��busyΪ0����ֹ��һʱ���ظ���ֵ
            end
            else if(FPUBusy_mul == 0 & FPUBusy1_mul == 0)begin // ��busy��Ϊ0��always��û�б����ı䣬���޷�����always����ready���ܼ�ʱ���0
                FPUReady_mul = 0;
                 FPUBusy1_mul = 0;
            end
            else begin
                FPUReady_mul = 0; // ����busy��ֵʱreadyΪXӰ���ж�
                 FPUBusy1_mul = 0;
            end
        end
      end    
      
      /*   always @(CLK or negedge FPUBusy_mul) begin  // @ (CLK or *) ?
             FPUReady_mul = 1;
       end   */
     
      reg [5:0] count = 0 ; 
      reg [47:0] Num_result_mul_tem = 0 ;
      reg [47:0] shifted_op1 = 0 ;
      reg [23:0] shifted_op2 = 0 ;
      // localparam width = 5'b11000; // 24 bit num
    
      always @(posedge CLK)
      begin: COMPUTING_PROCESS 
        if(Reset) begin  //  || FPU_halt
          count <= 0 ;
          Num_result_mul_tem <= 0 ;
          shifted_op1 <= {{width{1'b0}}, a_Mantissa} ;
          shifted_op2 <= b_Mantissa;
          done <= 0;
        end
        // state: IDLE
        else if(state == IDLE) begin
              if(n_state == COMPUTING) begin  // �ӷ�����specialʱ������n_stateΪcomputing����
                count <= 0 ;
                Num_result_mul_tem <= 0 ;
                shifted_op1 <= {{width{1'b0}}, a_Mantissa} ;
                shifted_op2 <= b_Mantissa;
                done <= 0; // ��һֱ����(����������״̬��doneһֱΪ1)
              end
              else begin // else IDLE->IDLE: registers unchanged // ʹdoneֻһ�����ڸߵ�ƽ���Ӷ���done��ֵready?
                done <= 0;
              end
        end
        // state: COMPUTING
        else if(n_state == COMPUTING) begin
            if(count == width-1) begin // last cycle
              done <= 1'b1 ;
              count <= 0;
            end
            else begin
              done <= 1'b0;
              count <= count + 1;
            end
            
            if(shifted_op2[0]) begin
              Num_result_mul_tem <= shifted_op1 + Num_result_mul_tem; // = or <=
            end
            // else temp_sum unchanged
            shifted_op1 <= {shifted_op1[2*width-2 : 0], 1'b0} ;
            shifted_op2 <= {1'b0, shifted_op2[width-1 : 1]} ;
        end
        // else COMPUTING->IDLE: registers unchanged
      end
      
      wire mul_in;       
      assign mul_in = (Num_result_mul_tem[47] == 1'b1);
      assign mul_result_Mantissa = mul_in ? Num_result_mul_tem[46:24] : Num_result_mul_tem[45:23]; //[46:24] Ӧȡ��24λ���(��ȥ��һ��1) ? 1xxx��1xxx�׸�1��2*4-1λ��2*4λ
                          //  [2*width-2:width]   1000��1000����1000_000,������Ȼ�п��ܽ�һλ,��λexpҲҪ��1��Ҳ�п������
     // assign MulResult = {Sign_result_mul,Exp_result_mul[7:0],Num_result_mul[22:0]}; // �ų�special�ſ�
     
    
    //�õ�����ֵ���
    reg [31:0] special_result;  // start��MULһ����������о�Ϊ�ߵ�ƽ���ɣ�ready��Ϊbusy�½���
    always @(*) begin  // CLK�� // �������Ҳ�ͼӷ�һ�������õ����������busy/ready  //����Ҫ�ڳ˷���ֵbusy��ready���޶�����
                                                    // �ⲿģ���ж��Ƿ��������Ҫ����Ϊbusy��ready��Ҫ���ڶ����ڼ��������д��
                  // ����ready��lab3һ��ʵʱд��Ҳ�ɣ�ֻҪ�ڸı�Ĵ������޶�~busy���ɣ�                                               
       if (FPUControl == 1'b0) begin // special_add
               if(NaN == 1'b1) begin
                    special_result = 32'b1111_1111_1111_1111_1111_1111_1111_1111; 
               end else if(apos==1'b1 && bneg==1'b1 || aneg==1'b1 && bpos==1'b1) begin
                    special_result = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
               end else if(apos==1'b1 || bpos==1'b1) begin
                    special_result = 32'b0111_1111_1000_0000_0000_0000_0000_0000;
                end else if(aneg==1'b1 || bneg==1'b1) begin
                    special_result = 32'b1111_1111_1000_0000_0000_0000_0000_0000;
                end           
        end 
        else begin
            if(special_mul == 1'b1) begin
               special_result = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
            end
        end
    end
    
    //���Result
    always @(*) begin
        if(FPUStart_cond == 1'b1) begin // �ӷ�����������Լ�����ͣ�ĳ˷�ֻ��һ�����ڣ��������ս�FPU�˷���������һֱΪ1(ָ��һֱͣ��FPU)
            if(FPUControl == 1'b0) begin // ADD
                if(special_add == 1'b1) begin
                    FPUResult = special_result;
                    FPUReady_special = 1'b1;
                    FPUReady_add = 1'b0;
                end 
                else begin
                    FPUResult[31] = c_sign;
                    FPUResult[30:23] = result_Exponent;
                    FPUResult[22:0] = result_Mantissa;
                    FPUReady_add = 1'b1;
                    FPUReady_special = 1'b0; // ��س�ֵ��������ֹ�special��һֱΪ1
                end 
            end
            else begin // MUL
                if(special_mul == 1'b1) begin
                    FPUResult = special_result;
                    FPUReady_special = 1'b1;
                    FPUReady_add = 1'b0;
                end
                else begin  // ÿһʱ�̾���ֵ��ֻ��readyʱ�Ŵ������һ�����д��
                    if(mul_in == 1'b1) begin // �˷��н�λʱ
                        if(mul_Exponent == 8'b1111_1111) begin // ���Ͻ�λ����������NaN
                            FPUResult[31] = 1'b1; 
                            FPUResult[30:23] = 8'b1111_1111;
                            FPUResult[22:0] = 23'b111_1111_1111_1111_1111_1111;
                        end
                        else begin
                            FPUResult[31] = mul_result_sign; 
                            FPUResult[30:23] = mul_Exponent[7:0] + 1'b1;
                            FPUResult[22:0] = mul_result_Mantissa;
                        end
                    end
                    else begin
                        FPUResult[31] = mul_result_sign; 
                        FPUResult[30:23] = mul_Exponent[7:0];
                        FPUResult[22:0] = mul_result_Mantissa;
                    end
                    FPUReady_special = 1'b0;
                    FPUReady_add = 1'b0;    
                end
            end
        end
        else begin
            // δstartʱȫ���0������߼�ʵʱ�ı䣬���ܻ�Ӱ���������Բ���
            FPUReady_special = 1'b0;
            FPUReady_add = 1'b0;
        end
    end    
     
    assign FPUBusy = (FPUBusy_mul || FPUBusy1_mul) && (FPUReady != 1); // ���˷�����û���������ʱ����busy��reset�����������ALU����߼�������õ���
    assign FPUReady = FPUReady_mul | FPUReady_add | FPUReady_special; // ���Ǽӷ����������Ҳ��Ҫready��д��Ĵ���ʱѡ��readyǰһ��FPUstart
    // FPUReady_mulδ���ģ���Ȼ�ӳ٣��������ܷ���done��ֵ
endmodule
