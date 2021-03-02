
module RegisterFile(
           input reset, clk, RegWrite,
           input [4: 0] Read_register1, Read_register2, Write_register,
           input [31: 0] Write_data, WriteData_26,
           input isWrite_26,
           output [31: 0] Read_data1, Read_data2,
           output [31: 0] RF_data_out [31: 0]
           //    output [127: 0] RF_data_out
       );
parameter InitialSp = 32'h00003ffc;

reg  [31: 0] RF_data [31: 1];
assign RF_data_out [31: 1] = RF_data;

initial RF_data[29] = InitialSp;
// assign RF_data_out = {RF_data[2], RF_data[4], RF_data[29], RF_data[31]};

assign Read_data1 = (Read_register1 == 5'b00000) ? 32'h00000000 : RF_data[Read_register1];
assign Read_data2 = (Read_register2 == 5'b00000) ? 32'h00000000 : RF_data[Read_register2];

// wire inverseReset = ~reset;
always @(posedge reset or posedge clk)
    if (reset)
    begin : Loop
        integer i;
        for (i = 1; i < 32; i = i + 1)
            if (i == 29)
                RF_data[i] = InitialSp;
            else
                RF_data[i] <= 32'h00000000;
    end
    else
    begin
        if (RegWrite && Write_register != 5'b00000 &&
                Write_register != 5'd26)
            RF_data[Write_register] <= Write_data;
        if (isWrite_26)
            RF_data[26] <= WriteData_26;
    end

endmodule

