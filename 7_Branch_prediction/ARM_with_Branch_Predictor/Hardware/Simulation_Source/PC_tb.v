`timescale 1ns/1ps

module PC_tb;

    reg CLK, Reset, PCSrc;
    reg [31:0] Result;
    wire [31:0] PC, PC_Plus_4;

    ProgramCounter u_ProgramCounter(
        .CLK    ( CLK    ),
        .Reset  ( Reset  ),
        .PCSrc  ( PCSrc  ),
        .Result ( Result ),
        .PC     ( PC     ),
        .PC_Plus_4  ( PC_Plus_4  )
    );

    always begin
        #5 CLK = ~CLK;
    end

    initial begin
         // store the simulation output as a Value Change Dump (VCD) file
        $dumpfile("Simulation_Source/PC.vcd");
        // store everything at the current level and below
        $dumpvars(0, PC_tb);

        CLK = 0; Reset = 1; PCSrc = 0;
        Result = 32'h2914AB4E; 

        #20 Reset = 0;
        
        #100 PCSrc = 1;
        #10 PCSrc = 0;

        #100 $finish;
    end

endmodule 