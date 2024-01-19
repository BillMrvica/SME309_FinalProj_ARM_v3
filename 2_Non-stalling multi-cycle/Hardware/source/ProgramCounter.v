module ProgramCounter(
    input CLK,
    input Reset,
    input PCSrc,
    input [31:0] Result,
    input en,
    
    output reg [31:0] PC,
    output [31:0] PC_Plus_4
); 

//fill your Verilog code here

    always @(posedge CLK or posedge Reset) begin
        if(Reset) PC <= 0;
        else if(~en) PC <= PC;
        else PC <= (PCSrc) ? Result : PC_Plus_4;
    end

    assign PC_Plus_4 = PC + 32'd4; 

endmodule