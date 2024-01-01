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


module Control_tb;

    reg [31:0] Instr;
    reg [3:0] ALUFlags;
    reg clk;

    wire MemtoReg;
    wire MemWrite;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire RegWrite;
    wire [1:0] RegSrc;
    wire [1:0] ALUControl;	
    wire PCSrc;

    ControlUnit u_ControlUnit(
        .Instr      ( Instr      ),
        .ALUFlags   ( ALUFlags   ),
        .CLK        ( clk        ),
        
        .MemtoReg   ( MemtoReg   ),
        .MemWrite   ( MemWrite   ),
        .ALUSrc     ( ALUSrc     ),
        .ImmSrc     ( ImmSrc     ),
        .RegWrite   ( RegWrite   ),
        .RegSrc     ( RegSrc     ),
        .ALUControl ( ALUControl ),
        .PCSrc      ( PCSrc      )
    );

    always begin
        #5; clk = !clk;
    end

    initial begin
        // store the simulation wire as a Value Change Dump (VCD) file
        $dumpfile("Simulation_Source/control.vcd");
        // store everything at the current level and below
        $dumpvars(0, Control_tb);
        clk = 1; ALUFlags = 0; Instr = 0;

        #10 Instr = 32'b1110_00_001000_0010_0001_00000000_0011; // ADD R1, R2, R3
        #10 Instr = 32'b1110_00_100100_0011_0010_1110_11111111; // SUB R2, R3, #0xFF0
        #10 Instr = 32'b1110_01_011001_1011_0101_000000000100;  // STR R11, [R5, #4]
        #10 Instr = 32'b1110_10_11_111111111111111111111010;    // BL to previous 6 instructions

        // STR R9, [R1, R3, LSL #2],  32'b1110_01_111000_1001_0001_0011_001000

        #100 $finish;
    end


endmodule
