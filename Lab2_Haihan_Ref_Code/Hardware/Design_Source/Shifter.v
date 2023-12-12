module Shifter(
    input [1:0] Sh,
    input [4:0] Shamt5,
    input [31:0] ShIn,
    
    output [31:0] ShOut
);

    // always @* begin
    //     case(Sh)
    //         2'b00: ShOut = {ShIn[(31-Shamt5):0], {Shamt5{1'b0}}};
    //         2'b01: ShOut = {{Shamt5{1'b0}}, ShIn[31:Shamt5]};
    //         2'b10: ShOut = {{Shamt5{ShIn[31]}}, ShIn[31:Shamt5]};
    //         2'b11: ShOut = {ShIn[Shamt5-1:0], ShIn[31:Shamt5]};
    //     endcase
    // end

    reg [31:0] ShMid [4:0];

    always @* begin
        case(Sh)
            2'b00: begin
                ShMid[0] = (Shamt5[4]) ? {ShIn[15:0], {16{1'b0}}} : ShIn;
                ShMid[1] = (Shamt5[3]) ? {ShMid[0][23:0], {8{1'b0}}} : ShMid[0];
                ShMid[2] = (Shamt5[2]) ? {ShMid[1][27:0], {4{1'b0}}} : ShMid[1];
                ShMid[3] = (Shamt5[1]) ? {ShMid[2][29:0], {2{1'b0}}} : ShMid[2];
                ShMid[4] = (Shamt5[0]) ? {ShMid[3][30:0], 1'b0     } : ShMid[3];            
            end
            2'b01: begin
                ShMid[0] = (Shamt5[4]) ? {{16{1'b0}}, ShIn[31:16]} : ShIn;
                ShMid[1] = (Shamt5[3]) ? {{8{1'b0}}, ShMid[0][31:8]} : ShMid[0];
                ShMid[2] = (Shamt5[2]) ? {{4{1'b0}}, ShMid[1][31:4]} : ShMid[1];
                ShMid[3] = (Shamt5[1]) ? {{2{1'b0}}, ShMid[2][31:2]} : ShMid[2];
                ShMid[4] = (Shamt5[0]) ? {  {1'b0} , ShMid[3][31:1]} : ShMid[3];            
            end
            2'b10: begin
                ShMid[0] = (Shamt5[4]) ? {{16{ShIn[31]}}, ShIn[31:16]} : ShIn;
                ShMid[1] = (Shamt5[3]) ? {{8{ShIn[31]}}, ShMid[0][31:8]} : ShMid[0];
                ShMid[2] = (Shamt5[2]) ? {{4{ShIn[31]}}, ShMid[1][31:4]} : ShMid[1];
                ShMid[3] = (Shamt5[1]) ? {{2{ShIn[31]}}, ShMid[2][31:2]} : ShMid[2];
                ShMid[4] = (Shamt5[0]) ? {  {ShIn[31]} , ShMid[3][31:1]} : ShMid[3];             
            end
            2'b11: begin
                ShMid[0] = (Shamt5[4]) ? {ShIn[15:0], ShIn[31:16]} : ShIn;
                ShMid[1] = (Shamt5[3]) ? {ShMid[0][7:0], ShMid[0][31:8]} : ShMid[0];
                ShMid[2] = (Shamt5[2]) ? {ShMid[1][3:0], ShMid[1][31:4]} : ShMid[1];
                ShMid[3] = (Shamt5[1]) ? {ShMid[2][1:0], ShMid[2][31:2]} : ShMid[2];
                ShMid[4]  = (Shamt5[0]) ? {ShMid[3][0]  , ShMid[3][31:1]} : ShMid[3];         
            end
        endcase 
    end

    assign ShOut = ShMid[4];

    /*
        LSL 00
        LSR 01
        ASR 10
        ROR 11
    */
endmodule 
