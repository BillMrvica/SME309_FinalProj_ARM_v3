`timescale 1ns/1ps

module tb_FindOne; /* this is automatically generated */
	parameter IN_WIDTH = 6;
    parameter OUT_WIDTH = $clog2(IN_WIDTH); // out uses one extra bit for not-found

	reg  [IN_WIDTH-1 :0] in = 6'b001000;
	wire [OUT_WIDTH-1:0] out;

    initial begin
        // store the simulation output as a Value Change Dump (VCD) file
        $dumpfile("FindOne.vcd");

        // store everything at the current level and below
        $dumpvars(0, tb_FindOne);
        
        in = 6'b001000; 
        #10 $display("Where is one in %b? %d", in, out);
        #100 in = 6'b100000; 
        #10 $display("Where is one in %b? %d", in, out);
        #100 in = 6'b000010; 
        #10 $display("Where is one in %b? %d", in, out);
        #100 in = 6'b000001; 
        #10 $display("Where is one in %b? %d", in, out);
        #100 in = 6'b000000; 
        #10 $display("Where is one in %b? %d", in, out);
        #100 $finish;
    end

	FindOne #(
			.OUT_WIDTH(OUT_WIDTH),
			.IN_WIDTH(IN_WIDTH)
		) nth_one_inst (
			.in  (in),
			.out (out)
		);

endmodule
