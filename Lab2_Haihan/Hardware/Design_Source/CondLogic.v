module CondLogic(
    input CLK,
    input PCS,
    input RegW,
    input MemW,
    input [1:0] FlagW,
    input [3:0] Cond,
    input [3:0] ALUFlags,
    input NoWrite,
    
    output PCSrc,
    output RegWrite,
    output MemWrite,
    
    output C // for ALU ADC SBC operations, multi-words operation
); 
    
    reg CondEx;
    reg N = 0, Z = 0, C = 0, V = 0;
    
    always @(posedge CLK) begin
        N <= (FlagW[1]) ? ALUFlags[3] : N;  // && CondEx
        Z <= (FlagW[1]) ? ALUFlags[2] : Z;
        C <= (FlagW[0]) ? ALUFlags[1] : C;
        V <= (FlagW[0]) ? ALUFlags[0] : V;
    end

    always @* begin
        case(Cond)
            4'd0:  CondEx = Z;
            4'd1:  CondEx = ~Z;
            4'd2:  CondEx = C;
            4'd3:  CondEx = ~C;
            4'd4:  CondEx = N;
            4'd5:  CondEx = ~N;
            4'd6:  CondEx = V;
            4'd7:  CondEx = ~V;
            4'd8:  CondEx = (~Z) & C;
            4'd9:  CondEx = Z | (~C);
            4'd10: CondEx = ~((N & V) | ((~N) & (~V)));
            4'd11: CondEx = (N & V) | ((~N) & (~V));
            4'd12: CondEx = (~Z) & ~((N & V) | ((~N) & (~V)));
            4'd13: CondEx = Z | ((N & V) | ((~N) & (~V)));
            default: CondEx = 1;
        endcase
    end

    assign PCSrc = PCS & CondEx;
    assign RegWrite = RegW & CondEx & (~NoWrite);
    assign MemWrite = MemW & CondEx;
    
endmodule