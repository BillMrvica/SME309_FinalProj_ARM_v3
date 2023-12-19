module PC(
    input clk,
    input nrst, 

    input [1:0] PCSEL,
    input [31:0] label, // label
    input branch,

    output reg [31:0] PC
);

    always @(posedge clk or negedge nrst) begin
        if(~nrst) PC <= 0;
        // could be expand to support remaining instructions such as Jalr
        else PC <= (PCSEL==2'd1 && branch) ? label : (PC+4);
    end

endmodule