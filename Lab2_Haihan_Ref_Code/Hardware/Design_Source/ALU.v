module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [1:0] ALUControl,

    output [31:0] ALUResult,
    output [3:0] ALUFlags
);

    wire N, Z, C, V;
    wire [32:0] A, B, sum; // addition or subtraction
    wire carrier;

    assign A = Src_A;
    assign B = (ALUControl==2'b01) ? (~Src_B + 1'b1) : Src_B; // if SUB, take the 2's complement

    Adder_32 u_Adder_32(
        .a    ( A    ),
        .b    ( B    ),
        .c_in ( 1'b0 ),
        .sum  ( sum  ),
        .c_out  ( carrier  )
    );

    // always @* begin
    //     case(ALUControl)
    //         2'b00: ALUResult = sum;
    //         2'b01: ALUResult = sum;
    //         2'b10: ALUResult = Src_A & Src_B;
    //         2'b11: ALUResult = Src_A | Src_B;
    //     endcase
    // end

    assign ALUResult = (ALUControl==2'b00 || ALUControl==2'b01) ? sum : ((ALUControl==2'b10) ? (Src_A & Src_B) : (Src_A | Src_B));

    assign N = (ALUResult <0);
    assign Z = (ALUResult == 0);
    assign C = ((ALUControl==2'b01) || (ALUControl==2'b00)) & carrier;
    assign V = ((ALUResult>0 && A<0) || (ALUResult<0 && A>0)) && 
               (((ALUControl==2'b01) && ((A>0 && B<0) || (A<0 && B>0))) || 
                ((ALUControl==2'b00) && ((A>0 && B>0) || (A<0 && B<0))));
    
    assign ALUFlags = {N, Z, C, V};
endmodule













