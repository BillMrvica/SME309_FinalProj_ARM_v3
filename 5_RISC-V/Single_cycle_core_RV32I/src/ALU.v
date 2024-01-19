module ALU(
    input FuncSel, // ALU or Bool operation
    input [2:0] AluFunc,
    input Alu_bit, // Instr[30], indicating ADD/SUB, SRL/SRA
    input [2:0] BrFunc,

    input [31:0] A,
    input [31:0] B,

    output [31:0] Out,
    output branch
);

    localparam ALU  = 1'b0;
    localparam BOOL = 1'b1;

/*
    ADD add rd, rs1, rs2   | Add                    | reg[rd] <= reg[rs1] + reg[rs2]
    SUB sub rd, rs1, rs2   | Subtract               | reg[rd] <= reg[rs1] - reg[rs2]
    SLL sll rd, rs1, rs2   | Shift Left Logical     | reg[rd] <= reg[rs1] « reg[rs2][4:0]
    SLT slt rd, rs1, rs2   | Compare < (Signed)     | reg[rd] <= (reg[rs1] <s reg[rs2]) ? 1 : 0
    SLTU sltu rd, rs1, rs2 | Compare < (Unsigned)   | reg[rd] <= (reg[rs1] <u reg[rs2]) ? 1 : 0
    XOR xor rd, rs1, rs2   | Xor                    | reg[rd] <= reg[rs1] ˆ reg[rs2]
    SRL srl rd, rs1, rs2   | Shift Right Logical    | reg[rd] <= reg[rs1] »u reg[rs2][4:0]
    SRA sra rd, rs1, rs2   | Shift Right Arithmetic | reg[rd] <= reg[rs1] »s reg[rs2][4:0]
    OR or rd, rs1, rs2     | Or                     | reg[rd] <= reg[rs1] | reg[rs2]
    AND and rd, rs1, rs2   | And                    | reg[rd] <= reg[rs1] & reg[rs2]
*/
    always @* begin
        if(FuncSel==ALU) begin
            case(AluFunc)
                3'b000: Out = (Alu_bit) ? (A-B) : (A+B);
                3'b001: Out = A << B[4:0];
                3'b010: Out = (A < B) ? 1 : 0;
                3'b011: Out = ({1'b0, A} < {1'b0, B}) ? 1 ; 0;
                3'b100: Out = A ^ B;
                3'b101: Out = (Alu_bit) ? {{B[4:0]{A[31]}}, A[31:B[4:0]]} : {{B[4:0]{1'b0}}, A[31:B[4:0]]};
                3'b110: Out = A | B;
                3'b111: Out = A & B;
            endcase
        end
        else Out = 0;
    end

/*
    BEQ beq rs1, rs2, label   | Branch if =            | pc <= (reg[rs1] == reg[rs2]) ? label: pc + 4
    BNE bne rs1, rs2, label   | Branch if ~=           | pc <= (reg[rs1] != reg[rs2]) ? label: pc + 4
    BLT blt rs1, rs2, label   | Branch if < (Signed)   | pc <= (reg[rs1] <s reg[rs2]) ? label: pc + 4
    BGE bge rs1, rs2, label   | Branch if ≥ (Signed)   | pc <= (reg[rs1] >=s reg[rs2]) ? label: pc + 4
    BLTU bltu rs1, rs2, label | Branch if < (Unsigned) | pc <= (reg[rs1] <u reg[rs2]) ? label: pc + 4
    BGEU bgeu rs1, rs2, label | Branch if ≥ (Unsigned) | pc <= (reg[rs1] >=u reg[rs2]) ? label: pc + 4
*/

    always @* begin
        if(FuncSel==BOOL) begin
            case(BrFunc)
                3'b000: branch = (A == B);
                3'b001: branch = ~(A == B);
                3'b100: branch = (A < B);
                3'b101: branch = (A >= B);
                3'b110: branch = ({1'b0, A} < {1'b0, B});
                3'b111: branch = ({1'b0, A} >= {1'b0, B});
                default: branch = 0;
            endcase
        end
        else branch = 0;
    end

endmodule