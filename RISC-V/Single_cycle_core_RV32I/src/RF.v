module RF(
    input clk,
    input nrst, 

    input [4:0] RA1,
    input [4:0] RA2, 
    input [4:0] WA,

    output [31:0] RD1,
    output [31:0] RD2,
    
    input WE,
    input [31:0] WD
);

    // For RISC-V processor, R0 is always zero.

    reg [31:0] RegBank [31:0];
    integer i;
 
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for(i=0; i<32; i=i+1) begin
                RegBank[i] <= 32'd0;
            end
        end
        else if(WE) begin
            RegBank[0] <= 0;
            for(i=1; i<32; i=i+1) begin
                if(i==WA) RegBank[i] <= WD;
                else RegBank[i] <= RegBank[i];
            end
        end
        else begin
            RegBank[0] <= 0;
            for(i=1; i<32; i=i+1) 
                 RegBank[i] <= RegBank[i];
        end
    end

    assign RD1 = RegBank[RA1];
    assign RD2 = RegBank[RA2];

    initial begin
        for(i=0;i<31;i=i+1) begin
            RegBank[i] = 32'd0;
        end
    end 

endmodule