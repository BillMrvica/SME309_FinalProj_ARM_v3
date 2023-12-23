module RegisterFile(
    input CLK,
    input WE3,
    input [3:0] A1,
    input [3:0] A2,
    input [3:0] A3,
    input [31:0] WD3,
    input [31:0] R15,

    output [31:0] RD1,
    output [31:0] RD2
    );
    
    // declare RegBank
    reg [31:0] RegBank [14:0];
    integer i;
 
    always @(posedge CLK) begin
        if(WE3) begin
            for(i=0; i<15; i=i+1) begin
                if(i==A3) RegBank[i] <= WD3;
                else RegBank[i] <= RegBank[i];
            end
        end
        else 
            for(i=0; i<15; i=i+1) 
                 RegBank[i] <= RegBank[i];
    end

    assign RD1 = (A1 <= 4'd14) ? ((A3==A1 && WE3) ? WD3 : RegBank[A1]) : R15;
    assign RD2 = (A2 <= 4'd14) ? ((A3==A2 && WE3) ? WD3 : RegBank[A2]) : R15;

    initial begin
        for(i=0;i<15;i=i+1) begin
            RegBank[i] = 32'd0;
        end
    end 

endmodule