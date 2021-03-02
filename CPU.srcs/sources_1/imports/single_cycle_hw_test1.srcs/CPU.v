
module CPU(
           input reset, clk,
           output [7: 0] bcds, leds,
           output [3: 0] ano,
           //    output [31: 0] RegisterData [31: 0],
           output [15: 0] DataMemoryData
           //    input [1: 0] choose_RF_data_out,
           //    output reg [7: 0] RF_data_out_reg
       );

wire [31: 0] RegisterData [31: 0];

wire Stall;
wire [1: 0] Interrupt_out;
// reg IRQ_IF = 0;
reg [31 : 0] PC = 0;
wire [31 : 0] PC_next;
wire [31: 0] PC_next_next;
always @(posedge clk)
    if (reset)
    begin
        PC <= 32'h80000000;
        // IRQ_IF <= 0;
    end
    else
        if(Stall)
        begin
            PC <= PC;
            // IRQ_IF <= IRQ_IF;
        end
        else
        begin
            PC <= PC_next_next;
            // IRQ_IF <= Interrupt_out;
        end


wire Interrupt;
reg Exception = 0;
assign Interrupt_out = PC[31] ? 0 :
       Interrupt ? 2'b10 : Exception ? 2'b11 : 2'b00;
assign PC_next_next = Interrupt_out == 2'b11 ? 32'h80000008 : Interrupt_out == 2'b10 ? 32'h80000004 : PC_next;

wire [31 : 0] PC_plus_4_IF = PC + 32'd4;


wire [31 : 0] Instruction_IF;
InstructionMemory2 instruction_memory1(.Address(PC), .Instruction(Instruction_IF));


// IF / ID Register below
wire [31: 0] Instruction_ID;
wire [31: 0] PC_plus_4_ID;
wire JumpFlush;
wire BranchFlush;
// wire IRQ_ID;
IF_ID_reg IF_ID(.reset(reset), .clk(clk), .stall(Stall),
                .InstructionInput(Instruction_IF),
                .InstructionOutput(Instruction_ID),
                .PC_plus4_IF(PC_plus_4_IF),
                .PC_plus4_ID(PC_plus_4_ID),
                .PC_FlushIn(PC_next + 4),
                .Flush(JumpFlush || BranchFlush || Interrupt_out[1])
                // .IRQ_ID(IRQ_ID)
               );
// IF / ID Register above


wire RegWrite_ID;
wire [1: 0] MemtoReg_ID;
wire MemRead_ID;
wire MemWrite_ID;
wire ALUSrc1_ID;
wire ALUSrc2_ID;
wire LuOp_ID;
wire [3 : 0]ALUOp_ID;
wire [1: 0] RegDst_ID;
wire ExtOp;


wire [1: 0] PCSrc;
wire Branch;

wire ClearControl;
Control control1(
            .OpCode(Instruction_ID[31: 26]), .Funct(Instruction_ID[5: 0]),
            .Clear(ClearControl),
            .PCSrc(PCSrc), .Branch(Branch),
            .RegWrite(RegWrite_ID), .MemtoReg(MemtoReg_ID),
            .MemRead(MemRead_ID), .MemWrite(MemWrite_ID),
            .ALUSrc1(ALUSrc1_ID), .ALUSrc2(ALUSrc2_ID), .LuOp(LuOp_ID), .ALUOp(ALUOp_ID), .RegDst(RegDst_ID),
            .ExtOp(ExtOp),
            .Flush_IF_ID(JumpFlush)
        );
// wire [127: 0] RF_data_out;
// always @( * )
// case (choose_RF_data_out)
//     0:
//         RF_data_out_reg = RF_data_out[7: 0];
//     1:
//         RF_data_out_reg = RF_data_out[39: 32];
//     2:
//         RF_data_out_reg = RF_data_out[71: 64];
//     3:
//         RF_data_out_reg = RF_data_out[103: 96];
// endcase


wire [31: 0] RegReadData1_init, RegReadData2_init, WriteBackResult;
reg [4: 0] Write_register_ME = 0;
reg [31: 0] PC_plus_4 [3: 2] = '{4, 4};

RegisterFile register_file1(
                 .reset(reset), .clk(clk),
                 .RegWrite(RegWrite[3]),
                 .Read_register1(Instruction_ID[25: 21]), .Read_register2(Instruction_ID[20: 16]),
                 .Write_register(Write_register_ME), .Write_data(WriteBackResult),
                 .WriteData_26(PC_plus_4[2] - 4), .isWrite_26(Interrupt_out[1]),
                 .Read_data1(RegReadData1_init), .Read_data2(RegReadData2_init),
                 .RF_data_out(RegisterData)
                 //  .RF_data_out(RF_data_out)
             );

wire [1: 0] ForwardA, ForwardB;
wire [31: 0] ALU_out_EX;
wire [31: 0] RegReadData1_ID =
     (ForwardA == 0) ? RegReadData1_init :
     (ForwardA == 1) ? WriteBackResult : ALU_out_EX;
wire [31: 0] RegReadData2_ID =
     (ForwardB == 0) ? RegReadData2_init:
     (ForwardB == 1) ? WriteBackResult : ALU_out_EX;


wire [31: 0] ExtResult_ID = {ExtOp ? {16{Instruction_ID[15]}} : 16'h0000, Instruction_ID[15 : 0]};
wire [31: 0] LeftShift16Result_ID = {Instruction_ID[15 : 0],  16'h0000};

wire [4: 0] Write_register_EX;
HazardUnit hazardUnit1(
               .ID_EX_MenRead(MemRead[2]),
               .ID_EX_WriteRegister(Write_register_EX), .IF_ID_ReadRegister1(Instruction_ID[25: 21]), .IF_ID_ReadRegister2(Instruction_ID[20: 16]),
               .Stall(Stall), .ClearControl(ClearControl)
           );


// ID / EX Register below
reg RegWrite [3: 2] = '{0,0};
reg [1: 0] MemtoReg [3: 2] = '{0,0};
reg MemRead [3: 2] = '{0,0};
reg MemWrite [3: 2] = '{0,0};
reg ALUSrc1_EX = 0;
reg ALUSrc2_EX = 0;
reg LuOp_EX = 0;
reg [3 : 0] ALUOp_EX = 0;
reg [1: 0] RegDst_EX = 0;
reg [31: 0] RegReadData1_EX = 0, RegReadData2_EX = 0;
reg [31: 0] ExtResult_EX = 0, LeftShift16Result_EX = 0;
reg [31: 0] Instruction_EX = 0;
always @(posedge clk)
begin
    PC_plus_4[2] <= reset ? 4 : (BranchFlush || Interrupt_out[1]) ? PC_next + 4 : PC_plus_4_ID;
    if(reset || BranchFlush || Interrupt_out[1])
    begin
        RegWrite[2] <= 0;
        MemtoReg[2] <= 0;
        MemRead[2] <= 0;
        MemWrite[2] <= 0;
        ALUSrc1_EX <= 0;
        ALUSrc2_EX <= 0;
        LuOp_EX <= 0;
        ALUOp_EX <= 0;
        RegDst_EX <= 0;
        RegReadData1_EX <= 0;
        RegReadData2_EX <= 0;
        ExtResult_EX <= 0;
        LeftShift16Result_EX <= 0;
        Instruction_EX <= 0;
    end
    else
    begin
        RegWrite[2] <= RegWrite_ID;
        MemtoReg[2] <= MemtoReg_ID;
        MemRead[2] <= MemRead_ID;
        MemWrite[2] <= MemWrite_ID;
        ALUSrc1_EX <= ALUSrc1_ID;
        ALUSrc2_EX <= ALUSrc2_ID;
        LuOp_EX <= LuOp_ID;
        ALUOp_EX <= ALUOp_ID;
        RegDst_EX <= RegDst_ID;
        RegReadData1_EX <= RegReadData1_ID;
        RegReadData2_EX <= RegReadData2_ID;
        ExtResult_EX <= ExtResult_ID;
        LeftShift16Result_EX <= LeftShift16Result_ID;
        Instruction_EX <= Instruction_ID[31: 0];
    end
end
// ID / EX Register above

wire [31: 0] LU_out = LuOp_EX ? LeftShift16Result_EX : ExtResult_EX;

wire [4: 0] ALUCtrl;
wire Sign;
ALUControl alu_control1(
               .ALUOp(ALUOp_EX), .Funct(Instruction_EX[5: 0]),
               .ALUCtl(ALUCtrl), .Sign(Sign)
           );

reg [31: 0] ALU_out_ME = 0;
wire [31: 0] ALU_in1 =
     ALUSrc1_EX ? {17'h00000, Instruction_EX[10 : 6]} : RegReadData1_EX;

wire [31: 0] ALU_in2 =
     ALUSrc2_EX ? LU_out : RegReadData2_EX;

wire Zero;
ALU alu1(
        .in1(ALU_in1),
        .in2(ALU_in2),
        .ALUCtl(ALUCtrl),
        .Sign(Sign),
        .out(ALU_out_EX),
        .zero(Zero)
    );

assign Write_register_EX =
       (RegDst_EX == 0) ? Instruction_EX[20: 16] :
       (RegDst_EX == 1) ? Instruction_EX[15: 11] : 31;

wire isPCFromBranch;
BranchHazardUnit branchHazardUnit1(
                     .OpCode(Instruction_EX[31: 26]),
                     .ALU_in_1(ALU_in1), .ALU_in_2(ALU_in2),
                     .isPCFromBranch(isPCFromBranch),
                     .BranchFlush(BranchFlush)
                 );

assign PC_next =
       (isPCFromBranch) ? PC_plus_4[2] + {LU_out[29: 0], 2'b00} :
       (PCSrc == 0) ? PC_plus_4_IF :
       (PCSrc == 1) ? {PC_plus_4_IF[31: 28], Instruction_ID[25: 0], 2'b00}:
       RegReadData1_ID;


// EX / ME Register below
reg [31: 0] WriteData_ME = 0;
always @(posedge clk)
    if(reset || Interrupt_out[1])
    begin
        RegWrite[3] <= 0;
        MemtoReg[3] <= 0;
        MemRead[3] <= 0;
        MemWrite[3] <= 0;
        ALU_out_ME <= 0;
        WriteData_ME <= 0;
        Write_register_ME <= 0;
        PC_plus_4[3] <= 4;
    end
    else
    begin
        RegWrite[3] <= RegWrite[2];
        MemtoReg[3] <= MemtoReg[2];
        MemRead[3] <= MemRead[2];
        MemWrite[3] <= MemWrite[2];
        ALU_out_ME <= ALU_out_EX;
        WriteData_ME <= RegReadData2_EX;
        Write_register_ME <= Write_register_EX;
        PC_plus_4[3] <= PC_plus_4[2];
    end
// EX / ME Register above


wire [31: 0] Read_data_ME;
DataMemory data_memory1(
               .reset(reset),
               .clk(clk),
               .Address(ALU_out_ME),
               .Write_data(WriteData_ME),
               .Read_data(Read_data_ME),
               .MemRead(MemRead[3]),
               .MemWrite(MemWrite[3]),
               .Interrupt(Interrupt),
               .LEDs(leds),
               .bcds(bcds),
               .ano(ano),
               .DataMemory_out(DataMemoryData)
           );


ForwardingUnit forwardingUnit1(
                   .EX_ME_RegWrite(RegWrite[2]), .ME_WB_RegWrite(RegWrite[3]),
                   .EX_ME_WriteRegister(Write_register_EX), .ME_WB_WriteRegister(Write_register_ME),
                   .ID_EX_ReadRegister1(Instruction_ID[25: 21]), .ID_EX_ReadRegister2(Instruction_ID[20: 16]),
                   .ForwardA(ForwardA), .ForwardB(ForwardB));

// ME / WB Register
// reg [31: 0] Read_data_WB = 0;
// reg [31: 0] ALU_out_WB = 0;
// always @(posedge clk)
//     if(reset)
//     begin
//         // Read_data_WB <= 0;
//         // ALU_out_WB <= 0;
//         // RegWrite[4] <= 0;
//         // MemtoReg[4] <= 0;
//         // Write_register[4] <= 0;
//         // PC_plus_4[4] <= 0;
//     end
//     else
//     begin
//         // Read_data_WB <= Read_data_ME;
//         // ALU_out_WB <= ALU_out_ME;
//         // RegWrite[4] <= RegWrite[3];
//         // MemtoReg[4] <= MemtoReg[3];
//         // Write_register[4] <= Write_register[3];
//         // PC_plus_4[4] <= PC_plus_4[3];
//     end
// ME / WB Register


assign WriteBackResult = (MemtoReg[3] == 2'b00) ? ALU_out_ME : (MemtoReg[3] == 2'b01) ? Read_data_ME : PC_plus_4[3];


endmodule

