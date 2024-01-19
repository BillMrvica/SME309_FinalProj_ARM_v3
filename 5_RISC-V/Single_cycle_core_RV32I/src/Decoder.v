module Decoder(
    input [31:0] Instr,

    output [4:0] rs1, 
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm,
    
    output [2:0] BrFunc,
    output [2:0] AluFunc,
    output FuncSel, // ALU or BOOL
    output Alu_bit, // to distiguish Add/Sub, SRL/SRA
    
    output [1:0] PCSEL,
    output [1:0] WDSEL,
    output BSEL, // RD2/imm select
    output WERF, // write-back to RF enable signal
    output MemFunc, // R/W'
    output MemEnable // enable read or write
);

    localparam ALU  = 1'b0;
    localparam BOOL = 1'b1;

    wire branch_instr, load_instr, store_instr, alu_instr_reg, alu_instr_i;

    assign branch_instr  = (Instr[6:0] == 7'b1100011);
    assign load_instr    = (Instr[6:0] == 7'b0000011);
    assign store_instr   = (Instr[6:0] == 7'b0100011);
    assign alu_instr_reg = (Instr[6:0] == 7'b0110011);
    assign alu_instr_i   = (Instr[6:0] == 7'b0010011);

    assign rs1 = Instr[19:15];
    assign rd = (store_instr | branch_instr) ? 5'd0 : Instr[11:7];
    assign rs2 = (alu_instr_reg || branch_instr || store_instr) ? Instr[24:20] : 5'd0;
    assign imm = (branch_instr) ? {Instr[31], Instr[7], Instr[30:25], Instr[11:8]} : 
                ((store_instr) ? {Instr[31:25], Instr[11:7]} : 
                ((alu_instr_i && (AluFunc==3'b001 || AluFunc==3'b101)) ? Instr[19:15] : Instr[31:20]));

    assign Alu_bit = Instr[30];
    assign BrFunc = Instr[14:12];
    assign AluFunc = Instr[14:12];
    assign FuncSel = (branch_instr) ? BOOL : ALU;

    // could be expand to support more instruction
    assign PCSEL = (branch_instr) ? 2'd1 : 2'd0;
    /* 
        2'd0: remaining instr (e.g. Jalr)
        2'd1: others
        2'd2: Load instr, write back data from MEM
    */
    assign WDSEL = (load_instr) ? 2'd2 : 2'd1;
    assign BSEL  = (load_instr || alu_instr_i) ? 1'b1 : 1'b0;
    assign WERF  = load_instr || alu_instr_i || alu_instr_reg;
    assign MemEnable = load_instr || store_instr;
    assign MemFunc   = (store_instr) ? 1'b0 : 1'b1;

endmodule 