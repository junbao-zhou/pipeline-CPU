module ForwardingUnit(
           input EX_ME_RegWrite, ME_WB_RegWrite,
           input [4: 0] EX_ME_WriteRegister, ME_WB_WriteRegister,
           input [4: 0] ID_EX_ReadRegister1, ID_EX_ReadRegister2,
           output [1: 0] ForwardA, ForwardB);

assign ForwardA =
       (EX_ME_RegWrite && (EX_ME_WriteRegister != 0) && EX_ME_WriteRegister == ID_EX_ReadRegister1) ? 2'b10 :
       (ME_WB_RegWrite && (ME_WB_WriteRegister != 0) && ME_WB_WriteRegister == ID_EX_ReadRegister1) ? 2'b01 : 2'b00;

assign ForwardB =
       (EX_ME_RegWrite && (EX_ME_WriteRegister != 0) && EX_ME_WriteRegister == ID_EX_ReadRegister2) ? 2'b10 :
       (ME_WB_RegWrite && (ME_WB_WriteRegister != 0) && ME_WB_WriteRegister == ID_EX_ReadRegister2) ? 2'b01 : 2'b00;

endmodule
