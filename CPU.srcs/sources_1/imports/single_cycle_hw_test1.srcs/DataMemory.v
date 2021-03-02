
module DataMemory(
           input reset, clk,
           input [31 : 0] Address, Write_data,
           input MemRead, MemWrite,
           output [31 : 0] Read_data,
           output Interrupt,
           output reg [7: 0] LEDs = 0,
           output [7: 0] bcds,
           output [3: 0] ano,
           output [15: 0] DataMemory_out
       );

parameter RAM_SIZE_BIT = 8;
parameter RAM_SIZE = 2 << (RAM_SIZE_BIT - 1);

reg [31 : 0] RAM_data [RAM_SIZE - 1: 0];

assign DataMemory_out = RAM_data[RAM_SIZE - 2];
// assign DataMemory_osut[0] = RAM_data[RAM_SIZE - 2 - 1];

reg [31: 0] Timer_TH = 0;				// 0x40000000
reg [31: 0] Timer_TL = 32'hffffffff;	// 0x40000004
reg [2: 0] Timer_TCON = 0;				// 0x40000008
// reg [7: 0] LEDs = 0;					// 0x4000000C
reg [11: 0] SegmentDisplay = 0;			// 0x40000010
reg [31: 0] SysTick = 0;				// 0x40000014

assign bcds = SegmentDisplay[7: 0];
assign ano = SegmentDisplay[11: 8];

assign Interrupt = Timer_TCON[2];


assign Read_data =				// 改成上升沿读取
       MemRead ?
       !Address[30] ? RAM_data[Address[RAM_SIZE_BIT + 1 : 2]] :
       Address[4: 2] == 3'b000 ? Timer_TH :
       Address[4: 2] == 3'b001 ? Timer_TL :
       Address[4: 2] == 3'b010 ? {29'b0, Timer_TCON} :
       Address[4: 2] == 3'b011 ? {24'b0, LEDs} :
       Address[4: 2] == 3'b100 ? {20'b0, SegmentDisplay} :
       Address[4: 2] == 3'b101 ? SysTick :
       32'h00000000 :
       32'h00000000;

always @(posedge clk)
    if (reset)
    begin : Loop
        SysTick <= 0;
        Timer_TH <= 0;
        Timer_TL <= 32'hffffffff;
        Timer_TCON <= 0;
        // integer i;
        // for (i = 0; i < RAM_SIZE; i = i + 1)
        //     RAM_data[i] <= 32'h00000000;
    end
    else
    begin
        SysTick <= SysTick + 1;
        if (MemWrite)
        case (Address[30])
            1'b0 : RAM_data[Address[RAM_SIZE_BIT + 1: 2]] <= Write_data;
            1'b1 :
            case (Address[4: 2])
                3'b000: Timer_TH <= Write_data;
                3'b010: Timer_TCON[1: 0] <= Write_data[1: 0];
                3'b011: LEDs <= Write_data[7: 0];
                3'b100: SegmentDisplay <= Write_data[11: 0];
            endcase
        endcase
        if(Timer_TCON[0])
            if(Timer_TL == 32'hffffffff)
            begin
                Timer_TL <= Timer_TH;
                // Timer_TCON[2] <= Timer_TCON[1] ? 1'b1 : 1'b0;
            end
            else
                Timer_TL <= Timer_TL + 1;
        Timer_TCON[2] <=
                  MemWrite && Address[30] && (Address[4: 2] == 3'b010) ? Write_data[2] :
                  Timer_TCON[0] && (Timer_TL == 32'hffffffff) ? Timer_TCON[1] : Timer_TCON[2];

    end



endmodule
