module BranchHazardUnit(
           input [5: 0] OpCode,
           input [31: 0] ALU_in_1, ALU_in_2,
           output isPCFromBranch, BranchFlush
       );

assign isPCFromBranch =
       OpCode == 6'h04 && ALU_in_1 == ALU_in_2 ? 1 :
       OpCode == 6'h05 && ALU_in_1 != ALU_in_2 ? 1 :
       OpCode == 6'h07 && $signed(ALU_in_1) > 0 ? 1 :
       OpCode == 6'h06 && $signed(ALU_in_1) <= 0 ? 1 :
       OpCode == 6'h01 && $signed(ALU_in_1) < 0 ? 1 : 0;
assign BranchFlush = isPCFromBranch;

endmodule
