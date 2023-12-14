`timescale 1ns/1ps

module Shifter_tb;

    reg [1:0] Sh;
    reg [4:0] Shamt5;
    reg [31:0] ShIn;
    
    wire [31:0] ShOut;
    
    Shifter u_Shifter(
        .Sh     ( Sh     ),
        .Shamt5 ( Shamt5 ),
        .ShIn   ( ShIn   ),
        .ShOut  ( ShOut  )
    );

    integer out_shift;

    initial begin
         // store the simulation output as a Value Change Dump (VCD) file
        $dumpfile("Simulation_Source/shifter.vcd");
        // store everything at the current level and below
        $dumpvars(0, Shifter_tb);

        ShIn = 32'h2914AB4E; Shamt5 = 0; Sh = 0;
        
        #50 Sh = 1;
        #50 Sh = 2;
        #50 Sh = 3;

        #50 Shamt5 = 1; Sh = 0;  out_shift = ShIn << Shamt5;
        #50 Sh = 1; out_shift = ShIn >> Shamt5;
        #50 Sh = 2; out_shift = ShIn >>> Shamt5;
        #50 Sh = 3; out_shift = (ShIn >> Shamt5) + (ShIn << (32-Shamt5));

        #50 Shamt5 = 2; Sh = 0;  out_shift = ShIn << Shamt5;
        #50 Sh = 1; out_shift = ShIn >> Shamt5;
        #50 Sh = 2; out_shift = ShIn >>> Shamt5;
        #50 Sh = 3; out_shift = (ShIn >> Shamt5) + (ShIn << (32-Shamt5));

        #50 Shamt5 = 3; Sh = 0;  out_shift = ShIn << Shamt5;
        #50 Sh = 1; out_shift = ShIn >> Shamt5;
        #50 Sh = 2; out_shift = ShIn >>> Shamt5;
        #50 Sh = 3; out_shift = (ShIn >> Shamt5) + (ShIn << (32-Shamt5));

        #50 Shamt5 = 7; Sh = 0;  out_shift = ShIn << Shamt5;
        #50 Sh = 1; out_shift = ShIn >> Shamt5;
        #50 Sh = 2; out_shift = ShIn >>> Shamt5;
        #50 Sh = 3; out_shift = (ShIn >> Shamt5) + (ShIn << (32-Shamt5));

        #50 Shamt5 = 15; Sh = 0;  out_shift = ShIn << Shamt5;
        #50 Sh = 1; out_shift = ShIn >> Shamt5;
        #50 Sh = 2; out_shift = ShIn >>> Shamt5;
        #50 Sh = 3; out_shift = (ShIn >> Shamt5) + (ShIn << (32-Shamt5));

        #50 Shamt5 = 31; Sh = 0;  out_shift = ShIn << Shamt5;
        #50 Sh = 1; out_shift = ShIn >> Shamt5;
        #50 Sh = 2; out_shift = ShIn >>> Shamt5;
        #50 Sh = 3; out_shift = (ShIn >> Shamt5) + (ShIn << (32-Shamt5));

        #100 $finish;
    end

endmodule 