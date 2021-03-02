module HazardUnit(
           input ID_EX_MenRead,
           input [4: 0] ID_EX_WriteRegister, IF_ID_ReadRegister1, IF_ID_ReadRegister2,
           output Stall, ClearControl
       );

wire isStall = (ID_EX_MenRead &&
                ((ID_EX_WriteRegister == IF_ID_ReadRegister1) ||
                 (ID_EX_WriteRegister == IF_ID_ReadRegister2)
                )) ? 1 : 0;
assign Stall = isStall;
assign ClearControl = isStall;


endmodule
