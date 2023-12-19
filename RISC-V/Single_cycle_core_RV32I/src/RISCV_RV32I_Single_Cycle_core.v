module RISCV_RV32I_Single_Cycle_core(
    input clk,
    input nrst,
    input [31:0] Instr,
    input [31:0] RD,

    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult, // for SW instr, the ALU result is the memory address
    output [31:0] WriteData
); 

    wire [4:0] RA1;
    wire [4:0] RA2;
    wire [4:0] WA;

    wire [31:0] RD1;
    wire [31:0] RD2;
    wire WE;
    wire [31:0] imm;
    
    wire [2:0] BrFunc;
    wire [2:0] AluFunc;
    wire FuncSel; // ALU or BOOL
    wire Alu_bit; // to distiguish Add/Sub, SRL/SRA
    
    wire [1:0] PCSEL;
    wire [1:0] WDSEL;
    wire BSEL; // RD2/imm select
    wire WERF; // write-back to RF enable signal
    wire MemFunc; // R/W'
    wire MemEnable; // enable read or write

    wire [31:0] A;
    wire [31:0] B;
    wire branch;

    assign A = RD1;
    assign B = (BSEL) ? imm : RD2;
    assign WD = (WDSEL==2'd1) ? ALUResult : RD;
    assign MemWrite = ~MemFunc;
    assign WriteData = RD2;

    PC u_PC(
        .clk   ( clk   ),
        .nrst  ( nrst  ),
        
        .PCSEL ( PCSEL ),
        .label ( label ),
        .branch( branch ),

        .PC    ( PC    )
    );

    ALU u_ALU(
        .FuncSel ( FuncSel ),
        .AluFunc ( AluFunc ),
        .Alu_bit ( Alu_bit ),
        .BrFunc  ( BrFunc  ),
        .A       ( A       ),
        .B       ( B       ),
        .Out     ( ALUResult ),
        .branch  ( branch  )
    );


    Decoder u_Decoder(
        .Instr   ( Instr   ),
        
        .rs1     ( rs1     ),
        .rs2     ( rs2     ),
        .rd      ( rd      ),
        .imm     ( imm     ),
        .BrFunc  ( BrFunc  ),
        .AluFunc ( AluFunc ),
        .FuncSel ( FuncSel ),
        .Alu_bit ( Alu_bit ),
        .PCSEL   ( PCSEL   ),
        .WDSEL   ( WDSEL   ),
        .BSEL    ( BSEL    ),
        .WERF    ( WERF    ),
        .MemFunc ( MemFunc ),
        .MemEnable  ( MemEnable  )
    );


    RF u_RF(
        .clk  ( clk  ),
        .nrst ( nrst ),
        
        .RA1  ( RA1  ),
        .RA2  ( RA2  ),
        .WA   ( WA   ),
        
        .RD1  ( RD1  ),
        .RD2  ( RD2  ),
        .WE   ( WE   ),
        .WD   ( WD   )
    );



endmodule