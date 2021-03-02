`timescale 1ns / 1ns
`define PERIOD 10
module test_cpu();

reg reset = 1;
reg clk = 1;

// wire [31: 0] RegisterData [31: 0];
wire [15: 0] DataMemoryData;

CPU cpu1(.reset(reset), .clk(clk), .DataMemoryData(DataMemoryData));

initial
begin
    #15 reset = 0;
end

always #6 clk = ~clk;

endmodule
