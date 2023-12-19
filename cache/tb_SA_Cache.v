`timescale 1ns/1ps

module tb_SA_Cache;
    reg clk;
    reg nrst; 

    // to CPU
    // Assume, From cpu_valid until cache_ready high-active, the reg values of cache_addr and cpu_write_data and the same
    reg cpu_op; // read or write operation, R/W'
    reg cpu_valid; // to enable read or write
    reg [31:0] cache_addr;
    reg [31:0] cpu_write_data;
    wire cache_ready; // used to control the CPU, if low, stall the CPU
    wire [31:0] cache_data;

    // to Main Memory
    wire cache_op; // read or write operation
    wire cache_valid; // enable MEM write, read is not necessary in this case
    wire [31:0] mem_addr;
    wire [31:0] cache_write_data;
    reg mem_ready;
    reg [31:0] mem_data;

    always begin
        #5 clk = ~clk;
    end

    initial begin
        // store the simulation output as a Value Change Dump (VCD) file
        $dumpfile("Cache.vcd");

        // store everything at the current level and below
        $dumpvars(0, tb_SA_Cache);
        
        clk = 1'b1;
        nrst = 1'b0;

        cpu_op = 1'b1;  cpu_valid = 1'b0;
        cache_addr = 32'd0;  cpu_write_data = 32'd0;
        mem_ready = 1'b0; mem_data = 32'd0;

        // enable cache
        #100 nrst = 1;
        #1;
    // I. Different set read tests
        // 1st read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'd0;  mem_data = 32'h1111_1111;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 2nd read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'd4;  mem_data = 32'h2222_2222;
        #40 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;
        
        // 3rd read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'd8;  mem_data = 32'h3333_3333;
        #50 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 4th read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'd12;  mem_data = 32'h4444_4444;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        #100;
    // II. Occupation on the same sets
        // 1st read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h1000;  mem_data = 32'h1111_1111;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 2nd read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h2000;  mem_data = 32'h2222_2222;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;
        
        // 3rd read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h3000;  mem_data = 32'h3333_3333;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 4th read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h4000;  mem_data = 32'h4444_4444;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 5st read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h5000;  mem_data = 32'h5555_5555;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 6nd read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h6000;  mem_data = 32'h6666_6666;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;
        
        // 7rd read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h7000;  mem_data = 32'h7777_7777;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 8th read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h8000;  mem_data = 32'h8888_8888;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 9th read, read miss and load from mem
        #50 cpu_op = 1'b1;  cpu_valid = 1'b1; cache_addr = 32'h9000;  mem_data = 32'h9999_9999;
        #30 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        #100;
    // III. write test
        // 1st write, write miss and load from mem
        #100 cpu_op = 1'b0;  cpu_valid = 1'b1; cache_addr = 32'h10;  cpu_write_data = 32'h1111_0000;
        #50 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 2nd read, read miss and load from mem
        #100 cpu_op = 1'b0;  cpu_valid = 1'b1; cache_addr = 32'h10;  cpu_write_data = 32'h2222_0000;
        #50 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 3rd write, write miss and load from mem
        #100 cpu_op = 1'b0;  cpu_valid = 1'b1; cache_addr = 32'h10000;  cpu_write_data = 32'h1010_1010;
        #50 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        // 4th read, read miss and load from mem
        #100 cpu_op = 1'b0;  cpu_valid = 1'b1; cache_addr = 32'h20000;  cpu_write_data = 32'h2020_2020;
        #50 mem_ready = 1; 
        #10 mem_ready = 0;
        #10 cpu_valid = 0;

        #100;

        #100 $finish;
    end

    Set_Asso_Cache_4W_256S u_Set_Asso_Cache_4W_256S(
        .clk              ( clk              ),
        .nrst             ( nrst             ),
        
        .cpu_op           ( cpu_op           ),
        .cpu_valid        ( cpu_valid        ),
        .cache_addr       ( cache_addr       ),
        .cpu_write_data   ( cpu_write_data   ),
        .cache_ready      ( cache_ready      ),
        .cache_data       ( cache_data       ),
        
        .cache_op         ( cache_op         ),
        .cache_valid      ( cache_valid      ),
        .mem_addr         ( mem_addr         ),
        .cache_write_data ( cache_write_data ),
        .mem_ready        ( mem_ready        ),
        .mem_data         ( mem_data         )
    );

endmodule