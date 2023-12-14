module Adder_32 (
    input [31:0] a, b,
    input c_in,
    
    output [31:0] sum,
    output c_out
);

    wire [8:0] carrier;

    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin
            CarrierAheadFullAdder u_CarrierAheadFullAdder4（
                .a    ( a[(4*i+3):i*4]    ),
                .b    ( b[(4*i+3):i*4]    ),
                .c_in ( carrier[i] ),
                .sum  ( sum[(4*i+3):i*4]  ),
                .c_out  ( carrier[i+1]  )
            );
        end
    endgenerate

    assign carrier[0] = c_in;
    assign c_out = carrier[8];

endmodule