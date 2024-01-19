/* 
    BHT-BTB for dynamic branch prediction
    Two-way 32-set associative architecture is utilized to avoid address collision.
*/

// |  Entry PC tag  | entry_index | byte_offset | 
// |      31:6      |     5:2     |     1:0     |

module Branch_Predictor(
    input clk,
    input nrst,

    input [31:0] PC_F, // the program counter
    
    // For branch taken
    input [31:0] PC_plus4_F,
    output [31:0] PC_BrP, // PC_BrP = (PrPCSrc_F) ? PrALUResult_F : PC_plus4_F
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
    localparam WAYS = 2;
    localparam ENTRY_BITS = 4;
    
    // changed according to the value above
    localparam ENTRIES = 2 ** ENTRY_BITS;
    localparam TAG_BITS = 32 - ENTRY_BITS - 2;

    reg [TAG_BITS-1:0] EntryTag [ENTRIES-1:0][WAYS-1:0];
    reg                EntryV   [ENTRIES-1:0][WAYS-1:0];
    reg [PRD_BITS-1:0] EntryPB  [ENTRIES-1:0][WAYS-1:0];
    reg [31:0]         EntryTA  [ENTRIES-1:0][WAYS-1:0]; // the target address stored in the entry

    // distinguish whether the PC_F is a branch instruction
    wire branch_instr;
        
    // for PC_F
    wire [ENTRIES-1:0]  set_addr_F, set_addr_E;
    wire [TAG_BITS-1:0] input_entry_tag_F, input_entry_tag_E;

    wire [31:0] set_TA_F, set_TA_E [WAYS-1:0];
    wire [TAG_BITS-1:0] set_tag_F, set_tag_E [WAYS-1:0];
    wire [WAY_NUM-1:0] set_V_F, set_V_E;
    wire [PRD_BITS-1:0] set_PB_F, set_PB_E [WAY_NUM-1:0];
    wire [WAY_NUM-1:0] hit_miss_F, hit_miss_E;
    wire hit_way_num_F, hit_way_num_E; 
    // wire [$clog2(WAYS)-1:0] hit_way_num; // If more than 4 ways
    wire taken_F, taken_E;

    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for(integer i=0; i<WAYS; i=i+1) begin
                for(integer j=0; j<ENTRIES; j=j+1) begin
                    EntryV[j][i] <= 0;
                    EntryTag[j][i] <= 0;
                    EntryPB[j][i] <= 0;
                    EntryTA[j][i] <= 0;
                end
            end
        end
        // find correct way to update the new Vale
        // What is the TRIGGERING condition?
        // if the branch instruction pc is not stored in the predictor, load it
        else if(WE_PrPCSrc || WE_PrALUResult) begin
            if(hit_miss_E==2'b00) begin
                EntryV[set_addr_E][hit_way_num_E] <= 1;
                EntryTag[set_addr_E][hit_way_num_E] <= input_entry_tag_E;
                EntryPB[set_addr_E][hit_way_num_E] <= ;
                EntryTA[set_addr_E][hit_way_num_E] <= (WE_PrALUResult_E) ? ALUResult_E : EntryTA[set_addr_E][hit_way_num_E];
            end
            else begin
                EntryV[set_addr_E][hit_way_num_E] <= 1;
                EntryTag[set_addr_E][hit_way_num_E] <= input_entry_tag_E;
                EntryPB[set_addr_E][hit_way_num_E] <= ;
                EntryTA[set_addr_E][hit_way_num_E] <= (WE_PrALUResult_E) ? ALUResult_E : EntryTA[set_addr_E][hit_way_num_E];
            end
            
            EntryV[set_addr_E][hit_way_num_E] <= 1;
            EntryTag[set_addr_E][hit_way_num_E] <= input_entry_tag_E;
            EntryPB[set_addr_E][hit_way_num_E] <= ;
            EntryTA[set_addr_E][hit_way_num_E] <= (WE_PrALUResult_E) ? ALUResult_E : EntryTA[set_addr_E][hit_way_num_E];
        end
        
    end 

    

    // Set control
    assign set_addr_F = PC_F[(ENTRY_BITS+1):2];
    assign input_entry_tag_F = PC_F[31:(ENTRY_BITS+2)];
    assign set_addr_E = PC_E[(ENTRY_BITS+1):2];
    assign input_entry_tag_E = PC_E[31:(ENTRY_BITS+2)];

    genvar i;
    generate
        for(i=0; i<WAY_NUM; i=i+1) begin
            assign set_TA_F[i]  = EntryTA[set_addr_F][i];
            assign set_tag_F[i] = EntryTag[set_addr_F][i];
            assign set_V_F[i]   = EntryV[set_addr_F][i];
            assign set_PB_F[i]  = EntryPB[set_addr_F][i];

            assign set_TA_E[i]  = EntryTA[set_addr_E][i];
            assign set_tag_E[i] = EntryTag[set_addr_E][i];
            assign set_V_E[i]   = EntryV[set_addr_E][i];
            assign set_PB_E[i]  = EntryPB[set_addr_E][i];

            assign hit_miss_F[i]  = (input_entry_tag_F == set_tag_F[i]) && set_V_F[i];
            assign hit_miss_E[i]  = (input_entry_tag_E == set_tag_E[i]) && set_V_E[i];
        end
    endgenerate

    assign hit_way_num_F = (hit_miss_F==2'b10) ? 1 : 0;
    assign hit_way_num_E = (hit_miss_E==2'b10) ? 1 : 0;
    
    // Taken: 00, 01
    // Not taken: 11, 10
    /*
        For mis-prediction:
        1. If taken,     00->01->11->11... or 10->11->11...
        2. If not taken, 11->10->00->00... or 01->00->00...
    */
    assign take_F = (hit_miss_F != 0) && (set_PB_F[hit_way_num_F]>=2'b10;);

    assign PC_BrP = (PrPCSrc_F) ? PrALUResult_F : PC_plus4_F;
    assign PrALUResult_F = (taken) ? set_TA_F[hit_way_num_F] : 32'd0;
    assign PrPCSrc_F = (taken) ? 1'b1 : 1'b0;

endmodule