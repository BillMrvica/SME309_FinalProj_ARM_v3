// In this document, we implement a scalable N-way set-associative cache
// Example: 4-Way 256-set associative cache

// |  tag  | set_index | byte_offset | 
// | 31:10 |    9:2    |     1:0     |

module Set_Asso_Cache_4W_256S(
    input clk,
    input nrst, 
    
    // to CPU
    // Assume, From cpu_valid until cache_ready high-active, the input values of cache_addr and cpu_write_data and the same
    input cpu_op, // read or write operation, R/W'
    input cpu_valid, // to enable read or write
    input [31:0] cache_addr,
    input [31:0] cpu_write_data,
    output cache_ready, // used to control the CPU, if low, stall the CPU
    output [31:0] cache_data,

    // to Main Memory
    output cache_op, // read or write operation
    output cache_valid, // enable MEM write, read is not necessary in this case
    output [31:0] mem_addr,
    output [31:0] cache_write_data,
    input mem_ready,
    input [31:0] mem_data  
);

    // Total number of sets
    localparam SET_NUM = 8;
    localparam SET = 256;
    localparam WAY_NUM = 4;
    // Define states
    localparam IDLE = 2'd0;
    localparam WRITE_BACK = 2'd1;
    localparam LOAD_FROM_MEM = 2'd2;

    // Cache architecture
    reg [31:0] CacheData [SET-1:0][WAY_NUM-1:0];
    reg [32-2-SET_NUM-1:0] tag [SET-1:0][WAY_NUM-1:0];
    reg V [SET-1:0][WAY_NUM-1:0];
    reg Dirty [SET-1:0][WAY_NUM-1:0];
    // reg [SET-1:0][WAY_NUM-1:0][31:0] CacheData;
    // reg [SET-1:0][WAY_NUM-1:0][32-2-SET_NUM-1:0] tag;
    // reg [SET-1:0][WAY_NUM-1:0] V;
    // reg [SET-1:0][WAY_NUM-1:0] Dirty;
    
    // On one single set
    wire [SET_NUM-1:0] set_addr;
    wire [32-2-SET_NUM-1:0] input_tag;

    wire [31:0] set_data [WAY_NUM-1:0];
    wire [32-2-SET_NUM-1:0] set_tag [WAY_NUM-1:0];
    // wire [WAY_NUM-1:0][32:0] set_data;
    // wire [WAY_NUM-1:0][32-2-SET_NUM-1:0] set_tag;
    wire [WAY_NUM-1:0] set_V;
    wire [WAY_NUM-1:0] set_Dirty;
    wire [WAY_NUM-1:0] hit_miss;
    wire [1:0] hit_way_num;

    // Cache state machine
    reg [1:0] cache_state;
    wire read_hit, read_miss;
    wire write_hit, write_miss;
    wire no_clean_blocks; // from IDLE to WRITE_BACK

    always @(posedge clk or negedge nrst) begin
        if(~nrst) cache_state <= IDLE;
        else begin
            case(cache_state)
                IDLE: begin
                        if(read_miss|write_miss) cache_state <= no_clean_blocks ? WRITE_BACK : LOAD_FROM_MEM;
                        else cache_state <= IDLE;
                    end
                WRITE_BACK: cache_state <= LOAD_FROM_MEM; // for one clock cycle
                LOAD_FROM_MEM: cache_state <= (mem_ready) ? IDLE : LOAD_FROM_MEM;
                default: cache_state <= IDLE;
            endcase
        end
    end

    // Define cache location
    /*
        1. Check whether an empty block exists on a set
        2. Check whether a clean block exists on a set
        3. Switch to Write Back, set it to be 0
    */
    wire [1:0] find_way;
    assign find_way = (~set_V[0]) ? 2'd0 : 
                     ((~set_V[1]) ? 2'd1 : 
                     ((~set_V[2]) ? 2'd2 : 
                     ((~set_V[3]) ? 2'd3 : 
                     (~set_Dirty[0]) ? 2'd0 : 
                     ((~set_Dirty[1]) ? 2'd1 : 
                     ((~set_Dirty[2]) ? 2'd2 : 
                     ((~set_Dirty[3]) ? 2'd3 : 2'd0))))));

    // Set control
    assign set_addr = cache_addr[9:2];
    assign input_tag = cache_addr[31:10];

    genvar i;
    generate
        for(i=0; i<WAY_NUM; i=i+1) begin
            assign set_data[i]  = CacheData[set_addr][i];
            assign set_tag[i]   = tag[set_addr][i];
            assign set_V[i]     = V[set_addr][i];
            assign set_Dirty[i] = Dirty[set_addr][i];

            assign hit_miss[i]  = (input_tag == set_tag[i]) && set_V[i];
        end
    endgenerate

    // check hit or miss
    assign read_miss  = cpu_valid && cpu_op && ~(|hit_miss); // R, all misses
    assign read_hit   = cpu_valid && cpu_op && (|hit_miss); // R, one of them is hit, complementary to miss
    assign write_miss = cpu_valid && ~cpu_op && ~(|hit_miss); 
    assign write_hit  = cpu_valid && ~cpu_op && (|hit_miss);

    // write-back control signal
    assign no_clean_blocks = !((&set_V && &set_Dirty) == 0); // whether write-back
    assign cache_valid = (cache_state == WRITE_BACK);
    assign cache_write_data = set_data[find_way];

    // Cache to CPU
    assign cache_data = (cpu_op && read_hit) ? set_data[hit_way_num] : 0; 
    assign cache_ready = read_hit && (cache_state == IDLE); 
    
    assign mem_addr = (cache_state==WRITE_BACK) ? {set_tag[find_way], set_addr, 2'b00} : cache_addr; // the address of the dirty blocks
    assign cache_op = (cache_state==WRITE_BACK) ? 0 : 1;

    // Cache SRAM control
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for(integer i=0; i<WAY_NUM; i=i+1) begin
                for(integer j=0; j<SET; j=j+1) begin
                    V[j][i] <= 0;
                    tag[j][i] <= 0;
                    CacheData[j][i] <= 0;
                    Dirty[j][i] <= 0;
                end
            end
        end
        // For write hit
        else if(write_hit) begin
            CacheData[set_addr][hit_way_num] <= cpu_write_data;
            // If the original value and the new loaded value are different, set Dirty
            Dirty[set_addr][hit_way_num] <= (CacheData[set_addr][hit_way_num] != cpu_write_data); 
        end
        // For write back
        // Set Dirty = 0 for the address
        else if(cache_state==WRITE_BACK) begin
            V[set_addr][find_way] <= 1'b0;
            Dirty[set_addr][find_way] <= 1'b0;
        end
        // read from memory
        else if((cache_state==LOAD_FROM_MEM) && mem_ready) begin
            CacheData[set_addr][find_way] <= mem_data;
            V[set_addr][find_way] <= 1'b1;
            Dirty[set_addr][find_way] <= 1'b0;
            tag[set_addr][find_way] <= input_tag;
        end
    end

    assign hit_way_num = (hit_miss==4'b1000) ? 3'd3 : 
                        ((hit_miss==4'b0100) ? 2'd2 : 
                        ((hit_miss==4'b0010) ? 2'd1 : 2'd0));
    

endmodule