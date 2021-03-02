
module Control(input [5: 0] OpCode, Funct,
               input Clear,
               output [1: 0] PCSrc, output Branch, RegWrite,
               output [1: 0] RegDst,
               output MemRead, MemWrite,
               output [1: 0] MemtoReg,
               output ALUSrc1, ALUSrc2, ExtOp, LuOp,
               output [3: 0] ALUOp,
               output Flush_IF_ID);

// Your code below

assign PCSrc =
       Clear ? 0 :
       (OpCode == 6'h0 && (Funct == 6'h08 || Funct == 6'h09)) ? 2 :
       (OpCode == 6'h02 || OpCode == 6'h03) ? 1 : 0;
assign Branch =
       Clear ? 0 :
       (OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h07||
        OpCode == 6'h06 || OpCode == 6'h01) ? 1 : 0;
assign RegWrite =
       Clear ? 0 :
       (OpCode == 6'h2b ||
        OpCode == 6'h04 || OpCode == 6'h05 ||
        OpCode == 6'h07 || OpCode == 6'h06 || OpCode == 6'h01 ||
        OpCode == 6'h02) ? 0 :
       (OpCode == 0 && Funct == 6'h08) ? 0 : 1;
assign RegDst =
       Clear ? 0 :
       (OpCode == 6'h00) ? 1 :
       (OpCode == 6'h03 ) ? 2 : 0;
assign MemRead =
       Clear ? 0 :
       (OpCode == 6'h23) ? 1 : 0;
assign MemWrite =
       Clear ? 0 :
       (OpCode == 6'h2b) ? 1 : 0;
assign MemtoReg =
       Clear ? 0 :
       (OpCode == 6'h03 || (OpCode == 6'h00 && Funct == 6'h09)) ? 2 :
       (OpCode == 6'h23) ? 1 : 0;
assign ALUSrc1 =
       Clear ? 0 :
       (OpCode == 0 && (Funct == 0 || Funct == 2 || Funct == 3)) ? 1 : 0;
assign ALUSrc2 =
       Clear ? 0 :
       (OpCode == 0 || OpCode == 6'h04 || OpCode == 6'h05 ||
        OpCode == 6'h07 || OpCode == 6'h06 || OpCode == 6'h01) ? 0 : 1;
assign ExtOp =
       Clear ? 0 :
       (OpCode == 6'h0c) ? 0 : 1;
assign LuOp =
       Clear ? 0 :
       (OpCode == 6'h0f) ? 1 : 0;
assign Flush_IF_ID =
       Clear ? 0:
       (OpCode == 6'h02 || OpCode == 6'h03) ? 1:
       (OpCode == 0 && (Funct == 6'b001000 || Funct == 6'b001001)) ? 1 :
       0;
// Your code above

assign ALUOp[2: 0] =
       Clear ? 0 :
       (OpCode == 6'h00) ? 3'b010 :
       (OpCode == 6'h04) ? 3'b001 :
       (OpCode == 6'h0c) ? 3'b100 :
       (OpCode == 6'h0a || OpCode == 6'h0b) ? 3'b101 :
       3'b000;

assign ALUOp[3] =
       Clear ? 0 :
       OpCode[0];

endmodule
