// In this document, we implement a scalable N-way set-associative cache
// Example: 4-Way 256-set associative cache

module Set_Asso_Cache #(
    parameter WAY_NUM = 4,
    parameter SET_NUM = 8
)(
    input clk,
    input nrst, 
    
    // to CPU
    input cpu_op, // read or write operation, R/W'
    input cpu_valid,
    input [31:0] cache_addr,
    input [31:0] cpu_write_data,
    output cache_ready,
    output [31:0] cache_data,

    // to Main Memory
    output cache_op, // read or write operation
    output cache_valid,
    output [31:0] mem_addr,
    output [31:0] cache_write_data,
    input mem_ready,
    input [31:0] mem_data  
);

    // Total number of sets
    localparam SET = 2 ** SET_NUM;
    // Define states
    localparam IDLE = 2'd0;
    localparam READ_FROM_MEM = 2'd1;
    localparam WRITE_BACK = 2'd2;

    // Cache architecture
    reg [31:0] CacheData [SET-1:0][WAY_NUM-1:0];
    reg [32-WAY_NUM-SET_NUM-1:0] tag [SET-1:0][WAY_NUM-1:0];
    reg V [SET-1:0][WAY_NUM-1:0];
    reg Dirty [SET-1:0][WAY_NUM-1:0];
    
    // Cache state machine
    reg [1:0] cache_state;
    wire read_hit, read_miss;
    wire write_hit, write_miss;
    wire read_mem_finish;
    wire write_back_allocate_finish;

    always @(posedge clk or negedge nrst) begin
        if(~nrst) cache_state <= IDLE;
        else if((cache_state==IDLE) && read_miss) cache_state <= READ_FROM_MEM;
        else if((cache_state==IDLE) && write_miss) cache_state <= WRITE_BACK;
        // How to go back to IDLE?
        else if((cache_state==READ_FROM_MEM) && read_mem_finish) cache_state <= IDLE;
        else if((cache_state==WRITE_BACK) && write_back_allocate_finish) cache_state <= IDLE;
        else state <= state;
    end

    // On one single set
    wire [SET_NUM-1:0] set_addr;
    wire input_tag;

    wire [32:0] set_data [WAY_NUM-1:0];
    wire [32-WAY_NUM-SET_NUM-1:0] set_tag [WAY_NUM-1:0];
    wire set_V [WAY_NUM-1:0];
    wire set_Dirty [WAY_NUM-1:0];
    wire hit_miss [WAY_NUM-1:0];
    wire [$clog2(WAY_NUM):0] hit_way_num;
    
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
    assign read_miss  = cpu_valid && cpu_op && ~(&hit_miss); // R, all misses
    assign read_hit   = cpu_valid && cpu_op && (|hit_miss); // R, one of them is hit, complementary to miss
    assign write_miss = cpu_valid && ~cpu_op && ~(&hit_miss); 
    assign write_hit  = cpu_valid && ~cpu_op && (|hit_miss);

    // If read hit
    assign cache_data = (cpu_op && read_hit) ? set_data[hit_way_num] : 0; 

    // If read miss, enter READ_FROM_MEM state, and read from mem
    // If write hit, load value to cache, set dirty blocks
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            V <= 0;
            tag <= 0;
            CacheData <= 0;
            Dirty <= 0;
        end
        // For write hit
        else if(write_hit) begin
            CacheData[set_addr][hit_way_num] <= cpu_write_data;
            // If the original value and the new loaded value are different, set Dirty
            Dirty[set_addr][hit_way_num] <= (CacheData[set_addr][hit_way_num] != cpu_write_data); 
        end
        // For read miss
        else if((cache_state==READ_FROM_MEM) && mem_ready) begin
            // WHICH WAY TO USE?
            /*
                1. check V on the set, if one of them is 0, then put the data in the block
                2. replace clean blocks
            */
            if(&V[set_addr] == 0) begin // V[0] & V[1] & V[2] & V[3]

            end
            else if(&Dirty[set_addr] == 0) begin
                
            end


            // CacheData[set_addr][hit_way_num] <= mem_data;
        end
        // For write miss
        // else if() begin end
        else begin
            CacheData <= CacheData;
            V <= V;
            tag <= tag;
            Dirty <= Dirty;
        end
    end

    // set cache_op to control R/W' from MEM
    assign cache_op = (cache_state==READ_FROM_MEM) ? 1 : 0;
    assign mem_addr = cache_addr;

    // bit string 0000..010..000, but only one character is 1
    FindOne#(
        .IN_WIDTH ( WAY_NUM )
    )u_FindOne(
        .in       (hit_miss),
        .out      (hit_way_num)
    );


    // read hit / read miss and the value is loaded from mem
    assign cache_ready = read_hit | (); 

    // write hit / write miss, write back, write allocate, replace it with the value


    assign cache_write_data = () ? CacheData[set_addr][hit_way_num] : ;

endmodule