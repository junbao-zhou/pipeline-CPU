module ID_EXE_reg(
           input reset, clk,
           input [31: 0] InstructionInput,
           output reg [31: 0] InstructionOutput
       );

always @(posedge reset or posedge clk)
begin
    if(reset)
        InstructionOutput <= 0;
    else
        InstructionOutput <= InstructionInput;
end

endmodule
