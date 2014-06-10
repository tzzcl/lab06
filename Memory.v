module Memory(
input Mem_Wr_en,
input [31:0]Instr_Addr, Data_Addr,
input [31:0]Din,
output [31:0]Inst, Dout
);
reg [7:0] ram[32:0];
integer i;
initial
begin 
for (i=0;i<32;i=i+1)
	ram[i]=8'b0;
//add  R3=R1(7ffffffe)+R2(2) 溢出 R3应该保持不变
{ram[3],ram[2],ram[1],ram[0]}=32'b00000000001000100001100000100000;
//addi R3=R1(7ffffffe)+4 溢出 R3应该保持不变
{ram[7],ram[6],ram[5],ram[4]}=32'b00100000001000110000000000000100;
//addiu R3=R1+4 R3应等于80000002 无溢出，存入R3
{ram[11],ram[10],ram[9],ram[8]}=32'b00100100001000110000000000000100;
end 
always @ (Din or Mem_Wr_en)
begin
	if (Mem_Wr_en==1'b1)
		{ram[Data_Addr],ram[Data_Addr+1],ram[Data_Addr+2],ram[Data_Addr+3]}=Din;
end
assign Inst={ram[Instr_Addr],ram[Instr_Addr+1],ram[Instr_Addr+2],ram[Instr_Addr+3]};
assign Dout={ram[Data_Addr],ram[Data_Addr+1],ram[Data_Addr+2],ram[Data_Addr+3]};
endmodule