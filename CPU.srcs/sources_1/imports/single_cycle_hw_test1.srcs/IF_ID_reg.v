module IF_ID_reg(
           input reset, clk, stall, Flush,//, IRQ_IF,
           input [31: 0] InstructionInput, PC_plus4_IF, PC_FlushIn,
           output reg [31: 0] InstructionOutput, PC_plus4_ID
           //    output reg IRQ_ID
       );

always @(posedge clk)
begin
    if(reset)
    begin
        InstructionOutput <= 0;
        PC_plus4_ID <= 4;
        // IRQ_ID <= 0;
    end
    else if (Flush)
    begin
        InstructionOutput <= 0;
        PC_plus4_ID <= PC_FlushIn;
    end
    else
        if(stall)
        begin
            InstructionOutput <= InstructionOutput;
            PC_plus4_ID <= PC_plus4_ID;
            // IRQ_ID <= IRQ_ID;
        end
        else
        begin
            InstructionOutput <= InstructionInput;
            PC_plus4_ID <= PC_plus4_IF;
            // IRQ_ID <= IRQ_IF;
        end
end

endmodule
