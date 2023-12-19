module FindOne#(
	parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = $clog2(IN_WIDTH)
) (
    input  [IN_WIDTH-1 :0] in,
    output [OUT_WIDTH-1:0] out
);

    wire [IN_WIDTH:0][OUT_WIDTH-1:0] num ;
    assign num[0] = {OUT_WIDTH{1'b1}};
    
    generate genvar i;
        for(i=0; i<IN_WIDTH; i=i+1) begin:stage
            assign num[i+1] = (in[i]) ? num[i]+i+1 : num[i];
        end
    endgenerate	
	
    assign out = num[IN_WIDTH];

endmodule