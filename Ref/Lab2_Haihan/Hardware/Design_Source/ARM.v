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

    wire PCSrc;
    wire [31:0] PC_Plus_4;
    wire [3:0] ALUFlags;
    wire [31:0] Result;

    wire MemtoReg;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire RegWrite;
    wire [1:0] RegSrc;
    wire [1:0] ALUControl;	

    wire [3:0] A1;
    wire [3:0] A2;
    wire [3:0] A3;
    wire [31:0] R15;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] RD2_shifted;

    wire [31:0] Src_B;
    wire [31:0] ExtImm;

    ProgramCounter u_ProgramCounter(
        .CLK    ( CLK    ),
        .Reset  ( Reset  ),
        .PCSrc  ( PCSrc  ),
        .Result ( Result ),
        .PC     ( PC     ),
        .PC_Plus_4  ( PC_Plus_4  )
    );


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
        .PCSrc      ( PCSrc      )
    );


    RegisterFile u_RegisterFile(
        .CLK ( CLK ),
        .WE3 ( RegWrite ),
        .A1  ( A1  ),
        .A2  ( A2  ),
        .A3  ( A3  ),
        .WD3 ( Result ),
        .R15 ( R15 ),
        .RD1 ( RD1 ),
        .RD2  ( RD2  )
    );

    Shifter u_Shifter(
        .Sh     ( Instr[6:5] ),
        .Shamt5 ( Instr[11:7] ),
        .ShIn   ( RD2 ),
        .ShOut  ( RD2_shifted )
    );

    ALU u_ALU(
        .Src_A      ( RD1 ),
        .Src_B      ( Src_B ),
        .ALUControl ( ALUControl ),
        .ALUResult  ( ALUResult  ),
        .ALUFlags   ( ALUFlags   )
    );

    Extend u_Extend(
        .ImmSrc   ( ImmSrc   ),
        .InstrImm ( Instr[23:0]   ),
        .ExtImm   ( ExtImm   )
    );

    assign Src_B = (!ALUSrc) ? RD2_shifted : ExtImm;
    assign WriteData = RD2;
    assign Result = (MemtoReg) ? ReadData : ALUResult; 
    assign A1 = (RegSrc[0]) ? 4'd15 : Instr[19:16];
    assign A2 = (RegSrc[1]) ? Instr[15:12] : Instr[3:0];
    assign A3 = Instr[15:12];
    assign R15 = PC_Plus_4 + 4;

endmodule