module CarrierAheadFullAdder (
    input [3:0] a, b,
    input c_in,
    
    output [3:0] sum,
    output c_out
);

    wire p0, p1, p2, p3, g0, g1, g2, g3;
    wire c4, c3, c2, c1;

    assign p0 = a[0] ^ b[0],
           p1 = a[1] ^ b[1],
           p2 = a[2] ^ b[2],
           p3 = a[3] ^ b[3];

    assign g0 = a[0] & b[0],
           g1 = a[1] & b[1],
           g2 = a[2] & b[2],
           g3 = a[3] & b[3];

    assign c1 = g0 | ( p0 & c_in ),
           c2 = g1 | ( p1 & g0 ) | ( p1 & p0 & c_in ),
           c3 = g2 | ( p2 & g1 ) | ( p2 & p1 & g0 ) | ( p2 & p1 & p0 & c_in ),
           c4 = g3 | ( p3 & g2 ) | ( p3 & p2 & g1 ) | ( p3 & p2 & p1 & g0 ) | ( p3 & p2 & p1 & p0 & c_in );

    assign sum[0] = p0 ^ c_in,
           sum[1] = p1 ^ c1,
           sum[2] = p2 ^ c2,
           sum[3] = p3 ^ c3;

    assign c_out = c4;

endmodule