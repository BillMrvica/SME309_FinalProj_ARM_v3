`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/21 20:23:25
// Design Name: 
// Module Name: tb_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RF_tb;

    reg clk;
    reg WE3;
    reg [3:0] A1;
    reg [3:0] A2;
    reg [3:0] A3;
    reg [31:0] WD3;
    reg [31:0] R15;

    wire [31:0] RD1;
    wire [31:0] RD2;

    RegisterFile u_RegisterFile(
        .CLK ( clk ),
        .WE3 ( WE3 ),
        .A1  ( A1  ),
        .A2  ( A2  ),
        .A3  ( A3  ),
        .WD3 ( WD3 ),
        .R15 ( R15 ),

        .RD1 ( RD1 ),
        .RD2  ( RD2  )
    );


    always begin
        #5; clk = !clk;
    end

    initial begin
        // store the simulation wire as a Value Change Dump (VCD) file
        $dumpfile("Simulation_Source/RF.vcd");
        // store everything at the current level and below
        $dumpvars(0, RF_tb);
        clk = 1; 
        A1 = 0; A2 = 0; A3 = 0; 
        WE3 = 0; WD3 = 0; R15 = 0;

        #50 WE3 = 1; WD3 = 32'h0000_0000; A3 = 1;
        for(int i=1; i<15; i=i+1) begin
            #10 WD3 = i+i*16; A3 = i+1;
        end
        #10 WE3 = 0;

        #100 A1 = 2; A2 = 4;
        #10  A1 = 15; A2 = 3;

        #100 $finish;
        
    end


endmodule
