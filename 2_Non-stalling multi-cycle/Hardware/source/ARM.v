module ARM(
    input CLK,
    input Reset,
    input [31:0] Instr,
    input [31:0] ReadData,

    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
); 
    //Decoder新添信号
    wire Start_MCycle_D,MCycleOp_MCycle_D;
    //与Decoder新添信号连线
    reg Start_MCycle_E,MCycleOp_MCycle_E;
    //mul的输出结果
    wire [31:0] Result_MCycle_E;
    //mul的Buzy
    wire Busy_MCycle_E;
    
    wire [3:0] ALUFlags;
    // wire PCSrc;
    wire PCS_D;  reg PCS_E; wire PCSrc_E;
    // wire [31:0] PC_Plus_4;
    wire [31:0] PC_Plus_4_F, PC_Plus_8_D;
    // wire [31:0] Result;
    wire [31:0] Result_W;

    // wire MemtoReg;
    wire MemtoReg_D; reg MemtoReg_E, MemtoReg_M, MemtoReg_W;
    // wire ALUSrc;
    wire ALUSrc_D; reg ALUSrc_E;
    // wire [1:0] ImmSrc;
    wire [1:0] ImmSrc_D;
    // wire RegWrite;
    wire RegW_D; reg RegW_E;
    wire RegWrite_E; reg RegWrite_M, RegWrite_W;
    // wire [1:0] RegSrc;
    wire [1:0] RegSrc_D;
    
    // wire [1:0] ALUControl;
    wire [3:0] ALUControl_D; reg [3:0] ALUControl_E;	

    // wire [3:0] A1;
    wire [3:0] RA1_D; reg [3:0] RA1_E;
    // wire [3:0] A2;
    wire [3:0] RA2_D; reg [3:0] RA2_E;
    // wire [3:0] A3;
    wire [3:0] WA3_D; reg [3:0] WA3_E, WA3_M, WA3_W;
    wire [31:0] R15;
    // wire [31:0] RD1;
    wire [31:0] RD1_D; reg [31:0] RD1_E;
    // wire [31:0] RD2;
    wire [31:0] RD2_D;
    // wire [31:0] RD2_shifted;
    wire [31:0] RD2_shifted_D; reg [31:0] RD2_shifted_E, RD2_shifted_M;

    wire [31:0] SrcA_E;
    // wire [31:0] Src_B;
    wire [31:0] SrcB_E;
    // wire [31:0] ExtImm;
    wire [31:0] ExtImm_D; reg [31:0] ExtImm_E;

    wire MemW_D; reg MemW_E;
    wire MemWrite_E; reg MemWrite_M;
    wire NoWrite_D;  reg NoWrite_E;
    wire [1:0] FlagW_D; reg [1:0] FlagW_E;
    wire carrier;
    wire [3:0] Cond_D; reg [3:0] Cond_E;
    wire [31:0] Instr_F;  reg [31:0] Instr_D;
    wire [31:0] ALUResult_E; reg [31:0] ALUResult_M, ALUResult_W;
    wire [31:0] WriteData_E; reg [31:0] WriteData_M;
    wire [31:0] ReadData_M;  reg [31:0] ReadData_W;

    wire [31:0] SrcB_RD2;

    wire Stall_F, Stall_D;
    wire Flush_D, Flush_E,Flush_M;
    wire [1:0] ForwardA_E;
    wire [1:0] ForwardB_E;
    wire Forward_M;

    // Add a enable signal to control the FETCH stage
    ProgramCounter u_ProgramCounter(
        .CLK    ( CLK    ),
        .Reset  ( Reset  ),
        .PCSrc  ( PCSrc_E  ),
        .Result ( ALUResult_E ),
        .en     ( ~Stall_F ), // For load stall hazard

        .PC     ( PC     ),
        .PC_Plus_4  ( PC_Plus_4_F  )
    );

    /* Original version is split into two blocks since the condition logic happens at Execute stage
    ControlUnit u_ControlUnit(
        .Instr      ( Instr      ),
        .ALUFlags   ( ALUFlags   ),
        .CLK        ( CLK        ),
        .MemtoReg   ( MemtoReg   ),
        .MemWrite   ( MemWrite   ),
        .ALUSrc     ( ALUSrc     ),
        .ImmSrc     ( ImmSrc     ),
        .RegWrite   ( RegWrite   ),
        .RegSrc     ( RegSrc     ),
        .ALUControl ( ALUControl ),
        .PCSrc      ( PCSrc      ),
        
        // add carrier to enable multi-word operation
        .C          ( Carrier )
    );
    */

    Decoder u_Decoder(
        .Instr      ( Instr_D ),
        
        .Start_MCycle(Start_MCycle_D),
        .MCycleOp_MCycle(MCycleOp_MCycle_D),
        
        .PCS        ( PCS_D ),
        .RegW       ( RegW_D ),
        .MemW       ( MemW_D ),
        .MemtoReg   ( MemtoReg_D ),
        .ALUSrc     ( ALUSrc_D ),
        .ImmSrc     ( ImmSrc_D ),
        .RegSrc     ( RegSrc_D ),
        .ALUControl ( ALUControl_D ),
        .NoWrite    ( NoWrite_D ),
        .FlagW      ( FlagW_D )
    );

    CondLogic u_CondLogic(
        .CLK      ( CLK ),
        .Reset    ( Reset ),

        .PCS      ( PCS_E ),
        .RegW     ( RegW_E ),
        .MemW     ( MemW_E ),
        .FlagW    ( FlagW_E ),
        .Cond     ( Cond_E ),
        .ALUFlags ( ALUFlags ),
        .NoWrite  ( NoWrite_E ),
        .PCSrc    ( PCSrc_E ),
        
        .RegWrite ( RegWrite_E ),
        .MemWrite ( MemWrite_E  ),
        .C        ( carrier )
    );

    RegisterFile u_RegisterFile(
        .CLK ( CLK ),
        .WE3 ( RegWrite_W ),
        .A1  ( RA1_D  ),
        .A2  ( RA2_D  ),
        .A3  ( WA3_W  ),
        .WD3 ( Result_W ),
        .R15 ( PC_Plus_8_D ),
        
        .RD1 ( RD1_D ),
        .RD2  ( RD2_D  )
    );

    // PROBLEMATIC, where to place
    Shifter u_Shifter(
        .Sh     ( Instr_D[6:5] ),
        .Shamt5 ( Instr_D[11:7] ),
        .ShIn   ( RD2_D ),
        .ShOut  ( RD2_shifted_D )
    );

    ALU u_ALU(
        .Src_A      ( SrcA_E ),
        .Src_B      ( SrcB_E ),
        // add carrier to enable multi-word operation
        .C_in       ( carrier ),

        .ALUControl ( ALUControl_E ),
        .ALUResult  ( ALUResult_E  ),
        .ALUFlags   ( ALUFlags   )
    );

    Extend u_Extend(
        .ImmSrc   ( ImmSrc_D   ),
        .InstrImm ( Instr_D[23:0]   ),
        .ExtImm   ( ExtImm_D   )
    );
wire [3:0] WA3_E_MCycle_wire;
wire RegWrite_E_MCycle_wire;
reg RegWrite_E_MCycle; 
wire MCycleResultstall;       
    hazard u_hazard(
        .StallF    ( Stall_F    ),
        .RA1D      ( RA1_D      ),
        .RA2D      ( RA2_D      ),
        .StallD    ( Stall_D    ),
        .FlushD    ( Flush_D    ),
        
        .RA1E      ( RA1_E      ),
        .RA2E      ( RA2_E      ),
        .WA3E      ( WA3_E      ),
        .MemtoRegE ( MemtoReg_E ),
        .PCSrcE    ( PCSrc_E    ),
        .RegWriteE ( RegWrite_E ),
        .ForwardAE ( ForwardA_E ),
        .ForwardBE ( ForwardB_E ),
        .FlushE    ( Flush_E    ),
        
        .WA3M      ( WA3_M      ),
        .RA2M      ( RD2_shifted_M  ),
        .RegWriteM ( RegWrite_M ),
        .MemWriteM ( MemWrite_M ),
        .ForwardM  ( Forward_M  ),
        
        .WA3W      ( WA3_W      ),
        .RegWriteW  ( RegWrite_W  ),
        .MemtoRegW ( MemtoReg_W ),
        
        .Start_MCycle_E(Start_MCycle_E),
        .FlushM(Flush_M),
        .WA3_E_MCycle(WA3_E_MCycle_wire),
        .WA3_D(WA3_D),
        .RegWrite_E_MCycle(RegWrite_E_MCycle),
        .Busy_MCycle_E(Busy_MCycle_E),
        .MCycleResultstall(MCycleResultstall)
    );

    assign MemWrite = MemWrite_M;
    assign Cond_D = Instr_D[31:28];
    assign Instr_F = Instr;
    assign PC_Plus_8_D = PC_Plus_4_F;
    assign ALUResult = ALUResult_M; // might change
    assign ReadData_M = ReadData;
    

    // MUX in the core
    assign SrcA_E = (ForwardA_E==2'b10) ? ALUResult_M : 
                     ((ForwardA_E==2'b01) ? Result_W : RD1_E);
    assign SrcB_RD2 = (ForwardB_E==2'b10) ? ALUResult_M : 
                     ((ForwardB_E==2'b01) ? Result_W : RD2_shifted_E);
    assign WriteData_E = SrcB_RD2;
    // assign Src_B = (!ALUSrc) ? RD2_shifted : ExtImm;
    assign SrcB_E = (ALUSrc_E) ? ExtImm_E : SrcB_RD2;
    // assign WriteData = RD2;
    assign WriteData = (Forward_M) ? Result_W : WriteData_M; 
    // assign Result = (MemtoReg) ? ReadData : ALUResult; 
    assign Result_W = (MemtoReg_W) ? ReadData_W : ALUResult_W;
    //获取mul的不同位置的数据
wire The_instr_is_MCycle;
assign The_instr_is_MCycle = (Instr_D[27:21]==7'b000_0000 && Instr_D[7:4]==4'b1001) || (Instr_D[27:20]==7'b0111_1111&&Instr_D[7:4]==4'b1111); 
    // assign A1 = (RegSrc[0]) ? 4'd15 : Instr[19:16];
    assign RA1_D = (The_instr_is_MCycle) ? Instr_D[11:8]:(RegSrc_D[0]) ? 4'd15 : Instr_D[19:16];
    //assign RA1_D = (RegSrc_D[0]) ? 4'd15 : Instr_D[19:16];
    // assign A2 = (RegSrc[1]) ? Instr[15:12] : Instr[3:0];
    assign RA2_D = (The_instr_is_MCycle) ? Instr_D[3:0]:(RegSrc_D[1]) ? Instr_D[15:12] : Instr_D[3:0];
    //assign RA2_D = (RegSrc_D[1]) ? Instr_D[15:12] : Instr_D[3:0];
    // assign A3 = Instr[15:12];
    assign WA3_D = (The_instr_is_MCycle) ? Instr_D[19:16]:Instr_D[15:12];
    //assign WA3_D = Instr_D[15:12];


    // Pipeline
    // FETCH -> DECODE
    always @(posedge CLK or posedge Reset) begin
        if(Reset) Instr_D <= 0;
        else if(Stall_D) Instr_D <= Instr_D;
        // How to define Flush operation?
        else if(Flush_D) Instr_D <= 0;
        else Instr_D <= Instr_F;
    end

    // DECODE -> EXECUTE
    always @(posedge CLK or posedge Reset) begin
        if(Reset) begin
            PCS_E <= 0;   RegW_E <= 0;  
            MemW_E <= 0;  FlagW_E <= 0;  
            ALUControl_E <= 0;  MemtoReg_E <= 0;  
            ALUSrc_E <= 0;  Cond_E <= 0;
            RD1_E <= 0;  RD2_shifted_E <= 0;
            WA3_E <= 0;  ExtImm_E <= 0;
            RA1_E <= 0;  RA2_E <= 0;
            NoWrite_E <= 0;
            Start_MCycle_E <= 0;
            //MCycleOp_MCycle_E <= 0;
        end
        else if(Flush_E) begin
            PCS_E <= 0;   RegW_E <= 0;  
            MemW_E <= 0;  FlagW_E <= 0;  
            ALUControl_E <= 0;  MemtoReg_E <= 0;  
            ALUSrc_E <= 0;  Cond_E <= 0;
            RD1_E <= 0;  RD2_shifted_E <= 0;
            WA3_E <= 0;  ExtImm_E <= 0;
            RA1_E <= 0;  RA2_E <= 0;
            NoWrite_E <= 0;
            Start_MCycle_E <= 0;
        end
        else begin
            PCS_E <= PCS_D;   RegW_E <= RegW_D;  
            MemW_E <= MemW_D;  FlagW_E <= FlagW_D;  
            ALUControl_E <= ALUControl_D;  MemtoReg_E <= MemtoReg_D;  
            ALUSrc_E <= ALUSrc_D;  Cond_E <= Cond_D;
            RD1_E <= RD1_D;  RD2_shifted_E <=(The_instr_is_MCycle) ?  RD2_D:RD2_shifted_D;
            WA3_E <= WA3_D;  ExtImm_E <= ExtImm_D;
            RA1_E <= RA1_D;  RA2_E <= RA2_D;
            NoWrite_E <= NoWrite_D;
            Start_MCycle_E <= Start_MCycle_D;
            
            MCycleOp_MCycle_E <= (Busy_MCycle_E == 1'b1) ? MCycleOp_MCycle_E:MCycleOp_MCycle_D;
        end
    end
    
    //以下备份mul的RegWrite_E和MemWrite_E以及WA3_E_MCycle
    
    reg MemWrite_E_MCycle; 
    reg [3:0] WA3_E_MCycle,RA1_E_MCycle,RA2_E_MCycle;
    assign WA3_E_MCycle_wire = WA3_E_MCycle;
    assign RegWrite_E_MCycle_wire = RegWrite_E_MCycle;
    reg [31:0] Operand1_MCycle_E,Operand2_MCycle_E;
 //   always @(negedge Start_MCycle_E) begin
 always @(negedge CLK ) begin
        if(Start_MCycle_E) begin
            RegWrite_E_MCycle <= RegWrite_E;  
            MemWrite_E_MCycle <= MemWrite_E;
            WA3_E_MCycle <= WA3_E;  
            Operand1_MCycle_E <= SrcA_E;
            Operand2_MCycle_E <= SrcB_RD2;
            RA1_E_MCycle <= RA1_E;
            RA2_E_MCycle <= RA2_E;
        end
    end
    //以上备份mul的RegWrite_E和MemWrite_E
localparam IDLE = 1'b0;
localparam COMPUTING = 1'b1;
reg state, n_state;
reg done;   
    //以下计时器，计时mul运算的32个周期        
        
        // state machine
      always @(posedge CLK or posedge Reset)
        begin
          if(Reset)
            state <= IDLE;
          else
            state <= n_state;
        end
      
      always @(*)
        begin
          case(state)
            IDLE:begin
                      if(Start_MCycle_E) begin
                          n_state = COMPUTING;
                         // Busy = 1'b1;
                      end else begin
                          n_state = IDLE;
                        //  Busy = 1'b0;
                      end
                 end
            COMPUTING:begin
                          if(~done)begin
                              n_state = COMPUTING ;
                          //    Busy = 1'b1 ;
                          end else begin
                              n_state = IDLE;
                           //   Busy = 1'b0;
                          end
                      end
          endcase
      end
      //乘法330，除法340，一个count10
      reg [5:0] count_MCycle;
      always @(posedge CLK or posedge Reset) begin
        if(Reset) begin
            count_MCycle <= 0;
        end else if(Busy_MCycle_E) begin
            count_MCycle <= count_MCycle + 1; 
        end else if(~Busy_MCycle_E) begin
            count_MCycle <= 0;
        end
      end
//reg [5:0] count = 0 ; // assuming no computation takes more than 64 cycles.假设没有计算需要超过64个周期。
//assign MCycleResultstall = count==6'd32 ;//mul结果输出阻塞
assign MCycleResultstall = (count_MCycle == 6'd33 && ~MCycleOp_MCycle_E) || (count_MCycle == 6'd34&&MCycleOp_MCycle_E);
//          // Multi-cycle Multiplier & divider
//        always@(posedge CLK or posedge Reset)
//          begin: COMPUTING_PROCESS // process which does the actual computation
//            if( Reset )
//            begin
//              count <= 0 ;
//              done <= 0;
//            end
//            // state: IDLE
//            else if(state == IDLE)
//            begin
//              if(n_state == COMPUTING)
//              begin
//                count <= 0 ;
//                done <= 0;
//              end
//              // else IDLE->IDLE: registers unchanged
//            end
//            // state: COMPUTING
//            else if(n_state == COMPUTING)
//            begin
            
//                //if(count == width-1)
//                if(count==6'd32)
//                begin // last cycle
//                  done <= 1'b1 ;
//                  count <= 0;
//                end
//                else
//                begin
//                  done <= 1'b0;
//                  count <= count + 1;
//                end                 
//            end
//          end
//    ////以上计时器，计时mul运算的32个周期  
    // EXECUTE -> MEM
 //经修改，count从0到31，31时将mul的RegWrite_E和MemWrite_E插入以及Result_MCycle_E插入   
    always @(posedge CLK or posedge Reset) begin
        if(Reset) begin
            RegWrite_M <= 0;
            MemWrite_M <= 0;
            MemtoReg_M <= 0;
            ALUResult_M <= 0;
            WriteData_M <= 0;
            WA3_M <= 0;
            RD2_shifted_M <= 0;
            
        end if(Flush_M) begin
            RegWrite_M <= 0;
            MemWrite_M <= 0;
            MemtoReg_M <= 0;
            ALUResult_M <= 0;
            WriteData_M <= 0;
            WA3_M <= 0;
            RD2_shifted_M <= 0;
        end
        else begin
            //RegWrite_M <= RegWrite_E;
           
            //RegWrite_M <= (count==6'd32 ) ? RegWrite_E_MCycle:RegWrite_E;
            RegWrite_M <= (count_MCycle == 6'd33 && ~MCycleOp_MCycle_E) || (count_MCycle == 6'd34&&MCycleOp_MCycle_E) ? RegWrite_E_MCycle:RegWrite_E;
            //MemWrite_M <= MemWrite_E;
            MemWrite_M <= (count_MCycle == 6'd33 && ~MCycleOp_MCycle_E) || (count_MCycle == 6'd34&&MCycleOp_MCycle_E) ? MemWrite_E_MCycle:MemWrite_E;
         //   MemWrite_M <= (count==6'd32 ) ? MemWrite_E_MCycle:MemWrite_E;
            MemtoReg_M <= MemtoReg_E;
            //ALUResult_M <= ALUResult_E;
            ALUResult_M <= (count_MCycle == 6'd33 && ~MCycleOp_MCycle_E) || (count_MCycle == 6'd34&&MCycleOp_MCycle_E) ? Result_MCycle_E:ALUResult_E;
          //   ALUResult_M <= (count==6'd32) ? Result_MCycle_E:ALUResult_E;
            WriteData_M <= WriteData_E;
            //WA3_M <= WA3_E;
            WA3_M <= (count_MCycle == 6'd33 && ~MCycleOp_MCycle_E) || (count_MCycle == 6'd34&&MCycleOp_MCycle_E)  ? WA3_E_MCycle:WA3_E;
          //  WA3_M <= (count==6'd32 )  ? WA3_E_MCycle:WA3_E;
            RD2_shifted_M <= RD2_shifted_E;
          
        end
    end

    // MEM -> WRITE_BACK
    always @(posedge CLK or posedge Reset) begin
        if(Reset) begin
            RegWrite_W <= 0;
            MemtoReg_W <= 0;
            ReadData_W <= 0;
            ALUResult_W <= 0;
            WA3_W <= 0;
        end
        
        else begin
            RegWrite_W <= RegWrite_M;
            MemtoReg_W <= MemtoReg_M;
            ReadData_W <= ReadData_M;
            ALUResult_W <= ALUResult_M;
            WA3_W <= WA3_M;
        end
    end

    
    MCycle u_MCycle(
        .CLK   ( CLK   ),
        .Reset ( Reset   ),
        .Start_MCycle   ( Start_MCycle_E   ),
        .MCycleOp_MCycle ( MCycleOp_MCycle_E   ),
        .Operand1_MCycle   ( Operand1_MCycle_E   ),
        .Operand2_MCycle ( Operand2_MCycle_E   ),
        .Result_MCycle   ( Result_MCycle_E   ),
        .Busy_MCycle   ( Busy_MCycle_E   )
    );


      
endmodule