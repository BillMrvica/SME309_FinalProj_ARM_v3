/* 
    BHT-BTB for dynamic branch prediction
    one-way 16-entries associative architecture is utilized to avoid address collision.
*/

// |  Entry PC tag  | entry_index | byte_offset | 
// |      31:8      |     9:2     |     1:0     |

module Branch_Predictor_with_tag#(
    parameter ENTRY_BITS = 4
)(
    input clk,
    input RESET,

    input [31:0] PC_F, // the program counter
    
    // For branch taken
    output [31:0] PrALUResult_F,
    output PrPCSrc_F,
    
    // for branch miss prediction, update
    input [31:0] PC_E,
    input WE_PrPCSrc, // branch mispredicted, so update new PCSrc_E 
    input WE_PrALUResult, // BTA mispredicted, so update new ALUResult_E 
    input [31:0] ALUResult_E,
    input PCSrc_E
);

    // Could be modified localparam
    localparam PRD_BITS = 2; // Prediction bits
    
    // changed according to the value above
    localparam ENTRIES = 2 ** ENTRY_BITS;

    reg [PRD_BITS-1:0] EntryPB  [ENTRIES-1:0];
    reg [31:0]         EntryTA  [ENTRIES-1:0]; // the target address stored in the entry
    reg [31-2-ENTRY_BITS:0] EntryTag [ENTRIES-1:0];

    // for PC_F
    wire [ENTRY_BITS-1:0]  set_addr_F, set_addr_E;
    wire [31:0]         set_TA_F,   set_TA_E;
    wire [PRD_BITS-1:0] set_PB_F,   set_PB_E;
    wire [31-2-ENTRY_BITS:0] set_Tag_F, set_Tag_E;

    // wire [$clog2(WAYS)-1:0] hit_way_num; // If more than 4 ways
    wire taken_F, taken_E;

    always @(posedge clk or posedge RESET) begin
        if(RESET) begin
            for(integer j=0; j<ENTRIES; j=j+1) begin
                EntryTA[j] <= 0;
                EntryTag[j] <= 0;
            end
        end
        // find correct way to update the new Vale
        // What is the TRIGGERING condition?
        // if the branch instruction pc is not stored in the predictor, load it
        else if(WE_PrALUResult) begin 
            EntryTA[set_addr_E] <= ALUResult_E;
            EntryTag[set_addr_E] <= (PCSrc_E) ? PC_E[31:(ENTRY_BITS+2)]: EntryTag[set_addr_E];
        end
    end 

    // Taken: 00, 01
    // Not taken: 11, 10
    /*
        For mis-prediction:
        1. If taken,     00->01->11->11... or 10->11->11...
        2. If not taken, 11->10->00->00... or 01->00->00...
    */
    always @(posedge clk or posedge RESET) begin
        if(RESET) 
            for(integer j=0; j<ENTRIES; j=j+1) 
                EntryPB[j] <= 2'b10;
        else if(WE_PrPCSrc) begin // PCSrc_E=1 means the branch is taken
            case(set_PB_E)
                2'b00: EntryPB[set_addr_E] <= (taken_E) ? 2'b01 : 2'b00;
                2'b01: EntryPB[set_addr_E] <= (taken_E) ? 2'b11 : 2'b00;
                2'b10: EntryPB[set_addr_E] <= (taken_E) ? 2'b11 : 2'b00;
                2'b11: EntryPB[set_addr_E] <= (taken_E) ? 2'b11 : 2'b10;
            endcase
        end
    end

    // Set control
    assign set_addr_F = PC_F[(ENTRY_BITS+1):2];
    assign set_addr_E = PC_E[(ENTRY_BITS+1):2];

    assign set_TA_F  = EntryTA[set_addr_F];
    assign set_PB_F  = EntryPB[set_addr_F];       
    assign set_TA_E  = EntryTA[set_addr_E];
    assign set_PB_E  = EntryPB[set_addr_E];
    assign set_Tag_F = EntryTag[set_addr_F];
    assign set_Tag_E = EntryTag[set_addr_E];

    assign taken_F = (set_PB_F >= 2'b10) && (set_Tag_F == PC_F[31:(ENTRY_BITS+2)]);
    assign taken_E = PCSrc_E;

    assign PrALUResult_F = (taken_F) ? set_TA_F : 32'd0;
    assign PrPCSrc_F = (taken_F) ? 1'b1 : 1'b0;

    initial begin
        for(integer j=0; j<ENTRIES; j=j+1) begin
            EntryPB[j] = 2'b01;
            EntryTA[j] = 0;
            EntryTag[j] = 0;
        end
    end

endmodule