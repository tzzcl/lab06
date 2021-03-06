module Memory(
input clk,
input Mem_Wr_en,
input [31:0]Instr_Addr, Data_Addr,
input [31:0]Din,
output reg[31:0] Inst, Dout
);
reg [7:0] ram[131:0];
reg [64:0] Instrcache[3:0];
reg [1:0]ReadInstemp;
reg CacheInsHit;
integer i;
initial
begin 
//cache init
Instrcache[0]=65'b0;
Instrcache[1]=65'b0;
Instrcache[2]=65'b0;
Instrcache[3]=65'b0;
CacheInsHit=1'b0;
//add  R3=R1(7ffffffe)+R2(2) 溢出 R3应该保持不变
ram[0]=8'b00000000;ram[1]=8'b00100010;ram[2]=8'b00011000;ram[3]=8'b00100000;
		//addi R3=R1(7ffffffe)+4 溢出 R3应该保持不变
ram[4]=8'b00100000;ram[5]=8'b00100011;ram[6]=8'b00000000;ram[7]=8'b00000100;
		//addiu R3=R1+4 R3应等于80000002 无溢出，存入R3
ram[8]=8'b00100100;ram[9]=8'b00100011;ram[10]=8'b00000000;ram[11]=8'b00000100;
		//sub R4=R3(80000002)-R8(7ff32432) R4应溢出,不保存值
ram[12]=8'b00000000;ram[13]=8'b01101000;ram[14]=8'b00100000;ram[15]=8'b00100010;
		//subu R4=R3(80000002)-R8(7ff32432) R4应不溢出,保存值 R4=32'h000cdbd0
ram[16]=8'b00000000;ram[17]=8'b01101000;ram[18]=8'b00100000;ram[19]=8'b00100011;
		//seb R13 R15 把R15低八位带符号扩展之后存入R13 R13=ffffff92
ram[20]=8'b01111100;ram[21]=8'b00001111;ram[22]=8'b01101100;ram[23]=8'b00100000;
		//lui R11 0x4344 R11=0x43440000 
ram[24]=8'b00111100;ram[25]=8'b00001011;ram[26]=8'b01000011;ram[27]=8'b01000100;
		//xori R13 R12 0x3243 R12=43443243
ram[28]=8'b00111001;ram[29]=8'b10101100;ram[30]=8'b00110010;ram[31]=8'b01000011;
		//clo R6 R5 R6=12
ram[32]=8'b01110000;ram[33]=8'b10100000;ram[34]=8'b00110000;ram[35]=8'b00100001;
		//clz R6 R1 R6=1
ram[36]=8'b01110000;ram[37]=8'b00100000;ram[38]=8'b00110000;ram[39]=8'b00100000;
		//srav R1 R15 R9 R9=0x1
ram[40]=8'b00000000;ram[41]=8'b00101111;ram[42]=8'b01001000;ram[43]=8'b00000111;
		//rotr R7 R5 4 R7=5fff1234
ram[44]=8'b00000000;ram[45]=8'b00100101;ram[46]=8'b00111001;ram[47]=8'b00000010;
		//sltu R8 R1 R4 R4=1
ram[48]=8'b00000001;ram[49]=8'b00000001;ram[50]=8'b00100000;ram[51]=8'b00101011;
		//slti R5 R3 0x0 R3=1
ram[52]=8'b00101000;ram[53]=8'b10100011;ram[54]=8'b00000000;ram[55]=8'b00000000;
		//sw R3 ram[0+128]
ram[56]=8'b10101100;ram[57]=8'b00000011;ram[58]=8'b00000000;ram[59]=8'b10000000;
		//lw R14 ram[0+128]
ram[60]=8'b10001100;ram[61]=8'b00001110;ram[62]=8'b00000000;ram[63]=8'b10000000;
		//lwl R14 ram[128-131] offset=3;
ram[64]=8'b10001111;ram[65]=8'b11001110;ram[66]=8'b00000000;ram[67]=8'b00000100;
		//swr R14 ram[128] offset=2;ram[128-131]=r14[23:0],0
ram[68]=8'b10111011;ram[69]=8'b11001011;ram[70]=8'b00000000;ram[71]=8'b00000010;
		//lw R14 ram[128]
ram[72]=8'b10001100;ram[73]=8'b00001110;ram[74]=8'b00000000;ram[75]=8'b10000000;
		//j 0x74
ram[76]=8'b00001000;ram[77]=8'b00000000;ram[78]=8'b00000000;ram[79]=8'b00011100;
		//no-use 
ram[80]=8'b00101000;
ram[81]=8'b10100011;
ram[82]=8'b00000000;
ram[83]=8'b00000000;
ram[84]=8'b00101000;
ram[85]=8'b10100011;
ram[86]=8'b00000000;
ram[87]=8'b00000000;
ram[88]=8'b00101000;
ram[89]=8'b10100011;
ram[90]=8'b00000000;
ram[91]=8'b00000000;
ram[92]=8'b00101000;
ram[93]=8'b10100011;
ram[94]=8'b00000000;
ram[95]=8'b00000000;
ram[96]=8'b00101000;
ram[97]=8'b10100011;
ram[98]=8'b00000000;
ram[99]=8'b00000000;
ram[100]=8'b00101000;
ram[101]=8'b10100011;
ram[102]=8'b00000000;
ram[103]=8'b00000000;
ram[104]=8'b00101000;
ram[105]=8'b10100011;
ram[106]=8'b00000000;
ram[107]=8'b00000000;
ram[108]=8'b00101000;
ram[109]=8'b10100011;
ram[110]=8'b00000000;
ram[111]=8'b00000000;
		//bgez R1 -16*4
ram[112]=8'b00000100;ram[113]=8'b00110001;
ram[114]=8'b11111111;ram[115]=8'b11111100;
ram[116]=8'b0;
ram[117]=8'b0;ram[118]=8'b0;ram[119]=8'b0;ram[120]=8'b0;
ram[121]=8'b0;ram[122]=8'b0;ram[123]=8'b0;ram[124]=8'b0;
ram[125]=8'b0;ram[126]=8'b0;ram[127]=8'b0;
ram[128]=8'hf1;ram[129]=8'h1f;ram[130]=8'h3d;ram[131]=8'hd3;
end 
always @ (negedge clk)
begin
	if (Mem_Wr_en==1'b1)//Write Allocate
	begin 
		{ram[Data_Addr],ram[Data_Addr+1],ram[Data_Addr+2],ram[Data_Addr+3]}=Din;
	end
end
always @(posedge clk)
begin 
	ReadInstemp=Instr_Addr[3:2];
	if (Instrcache[ReadInstemp][64]==1'b0)
		begin 
			Instrcache[ReadInstemp]={1'b1,Instr_Addr,ram[Instr_Addr],ram[Instr_Addr+1],ram[Instr_Addr+2],ram[Instr_Addr+3]};
			CacheInsHit=1'b0;
		end
		else 
		begin 
			if (Instrcache[ReadInstemp][63:32]==Instr_Addr)
			begin 
				CacheInsHit=1'b1;
			end
			else 
			begin 
				Instrcache[ReadInstemp]={1'b1,Instr_Addr,ram[Instr_Addr],ram[Instr_Addr+1],ram[Instr_Addr+2],ram[Instr_Addr+3]};
				CacheInsHit=1'b0;
			end 
		end 
Inst=Instrcache[ReadInstemp][31:0];
Dout={ram[Data_Addr],ram[Data_Addr+1],ram[Data_Addr+2],ram[Data_Addr+3]};
end 
//assign Inst={ram[Instr_Addr],ram[Instr_Addr+1],ram[Instr_Addr+2],ram[Instr_Addr+3]};
//assign Dout={ram[Data_Addr],ram[Data_Addr+1],ram[Data_Addr+2],ram[Data_Addr+3]};
endmodule
