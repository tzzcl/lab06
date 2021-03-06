module PipelineCPU(
input clk,
output [31:0]PC_out,Inst_IF_out,Inst_ID_out,
output [31:0]A_in_out,B_in_out,ALU_Shift_out_out,Shift_out_out,Rs_out_out,Rt_out_out,
output [4:0]Rs_ID_out,Shift_amount_out,
output [2:0]ALUSrcB_Ex_out,
output Shift_amountSrc_ID,
output Shift_amountSrc_Ex,
output [31:0]PCP4_IF
);
wire [31:0]PC;
//wire [31:0]PCP4_IF;
wire [31:0]PC_branch,PC_jump,NextPC;
wire [1:0]PCSource;
wire Keep_PC;
wire [31:0]Exception_Entry;
assign Exception_Entry=32'h0;
assign PCP4_IF=PC+4;
assign NextPC=(PCSource==2'b0)?PCP4_IF:(PCSource==2'b01)?PC_branch:(PCSource==2'b10)?PC_jump:Exception_Entry;
wire [31:0]Inst_IF;
//IF Register
PC_count pc(clk,Keep_PC,NextPC,PC);
//IF
wire Reset_IF_ID,Keep_IF_ID,Reset_ID_Ex_Control,Reset_ID_Ex,Reset_ID_Ex_LoadUse,Keep_ID_Ex,Reset_Ex_Mem,Keep_Ex_Mem,Reset_Mem_Wr,Keep_Mem_Wr;
wire [31:0]PCP4_ID,PCP4_Ex;
wire [31:0]Inst_ID,Inst_Ex;
IF_ID IF_ID_Reg(clk,Reset_IF_ID,Keep_IF_ID,PCP4_IF,Inst_IF,PCP4_ID,Inst_ID);
assign Reset_ID_Ex=(Reset_ID_Ex_Control)||(Reset_ID_Ex_LoadUse);
//ID 
wire [5:0]op,func;
wire [4:0]Rs_ID,Rt_ID,Rd_ID,Shamt_ID,Shamt_Ex;
wire [4:0]Rs_Ex,Rt_Ex,Rd_Ex,Rd_Mem,Rd_Wr;
wire [15:0]offset,offset_raw_ID,offset_raw_Ex;
wire [31:0]LoadAddr;
wire [25:0]Target_ID,Target_Ex;
wire [1:0]LoadByte_ID,LoadByte_Ex,LoadByte_Mem;
wire [1:0]LoadType_ID,LoadType_Ex,LoadType_Mem;
wire [31:0]offset_ID,offset_Ex;
wire [31:0]Rs_out_ID,Rt_out_ID,Rd_in;
wire [31:0]Rs_out_Ex,Rt_out_Ex;
wire [3:0]Rd_write_by_en_Mem,Rd_write_by_en_Wr;
wire Ext_op_ID;
wire RegWr_ID,RegWr_Ex,RegWr_Mem,RegWr_Wr;
wire MemWr_ID,MemWr_Ex,MemWr_Mem;
wire MemtoReg_ID,MemtoReg_Ex,MemtoReg_Mem,MemtoReg_Wr;
wire Exception_ID,Exception_Ex,Exception_Mem;
assign op=Inst_ID[31:26];
assign Rs_ID=Inst_ID[25:21];
assign Rs_ID_out=Rs_ID;
assign Rt_ID=Inst_ID[20:16];
assign Rd_ID=Inst_ID[15:11];
assign Shamt_ID=Inst_ID[10:6];
assign func=Inst_ID[5:0];
assign offset=Inst_ID[15:0];
assign offset_raw_ID=offset;
assign Target_ID=Inst_ID[25:0];
assign LoadAddr=offset_ID+PCP4_ID;
assign LoadByte_ID=LoadAddr[1:0];
//assign Rd_write_by_en=Rd_write_by_en_Mem;
Extender extend(Ext_op_ID,offset,offset_ID);
Register register(clk,Rs_ID,Rt_ID,Rd_Wr,Rd_in,RegWr_Wr,Rd_write_by_en_Wr,Rs_out_ID,Rt_out_ID);
//Control Part
wire [3:0]ALU_op_ID,ALU_op_Ex;
wire [1:0]ALUSrcA;
wire [2:0]ALUSrcB_ID,ALUSrcB_Ex;
wire [1:0]Shift_op_ID,Shift_op_Ex;
wire [4:0]Shift_amount_ID;
wire ALUShift_Sel_ID,ALUShift_Sel_Ex;
wire RegDst_ID,RegDst_Ex;
//wire Shift_amountSrc_ID,Shift_amountSrc_Ex;
wire Jump_ID,Jump_Ex,Jump_Mem;
wire RegDt0_ID,RegDt0_Ex;
wire [2:0]Condition_ID,Condition_Ex,Condition_Mem;
Controller control(op,func,Shamt_ID,Rs_ID,Rt_ID,Ext_op_ID,RegDst_ID,Shift_amountSrc_ID,Jump_ID,ALUShift_Sel_ID,RegDt0_ID,
ALU_op_ID,Shift_op_ID,ALUSrcB_ID,Condition_ID,LoadType_ID,RegWr_ID,MemWr_ID,MemtoReg_ID,Exception_ID);

ID_Ex ID_Ex_Reg(clk,Reset_ID_Ex,Rs_ID,Rt_ID,Rd_ID,Rs_out_ID,Rt_out_ID,offset_ID,offset_raw_ID,RegDst_ID,Shift_amountSrc_ID,Jump_ID,ALUShift_Sel_ID,RegDt0_ID,
ALU_op_ID,Shift_op_ID,ALUSrcB_ID,Condition_ID,LoadType_ID,LoadByte_ID,RegWr_ID,MemWr_ID,MemtoReg_ID,Exception_ID,PCP4_ID,Target_ID,Shamt_ID,
Rs_Ex,Rt_Ex,Rd_Ex,Rs_out_Ex,Rt_out_Ex,offset_Ex,offset_raw_Ex,RegDst_Ex,Shift_amountSrc_Ex,Jump_Ex,ALUShift_Sel_Ex,RegDt0_Ex,ALU_op_Ex,
Shift_op_Ex,ALUSrcB_Ex,Condition_Ex,LoadType_Ex,LoadByte_Ex,RegWr_Ex,MemWr_Ex,MemtoReg_Ex,Exception_Ex,PCP4_Ex,Target_Ex,Shamt_Ex);

//Ex Part
wire [31:0]PC_Ex,PC_jump_Ex,PC_jump_Mem,PC_branch_Ex,PC_branch_Mem;
wire [31:0]A,B,ALU_out,Shift_out,ALUShift_out_Ex,ALUShift_out_Mem,ALUShift_out_Wr;
wire Zero,Zero_Ex,Zero_Mem,Overflow,Overflow_Ex,Overflow_Mem,Overflow_Wr,Less,Less_Ex,Less_Mem;
wire [4:0]Shift_amount;
wire [2:0]ALUSrcB;
assign PC_Ex=PCP4_Ex-4;
assign PC_jump_Ex={PC_Ex[31:28],Target_Ex,2'b0};
assign PC_branch_Ex=PCP4_Ex+(offset_Ex<<2);
assign A=(ALUSrcA==2'b0)?Rs_out_Ex:(ALUSrcA==2'b1)?ALUShift_out_Ex:Rd_in;
assign B=(ALUSrcB==3'b000)?Rt_out_Ex:(ALUSrcB==3'b001)?offset_Ex:(ALUSrcB==3'b010)?(ALUShift_Sel_Ex):(ALUSrcB==3'b011)?Rd_in:{offset_raw_Ex,16'b0};
ALU alu(A,B,ALU_op_Ex,Zero,Less,Overflow,ALU_out);
assign Shift_amount=(Shift_amountSrc_Ex==0)?Shamt_Ex:Rs_out_Ex[4:0];
assign Shift_amount_out=Shift_amount;
Shifter shifter(Rt_out_Ex,Shift_amount,Shift_op_Ex,Shift_out);
assign ALUShift_out_Ex=(ALUShift_Sel_Ex==0)?ALU_out:Shift_out;
assign ALUSrcB_Ex_out=ALUSrcB_Ex;
//assign Rd_in=ALUShift_out_Ex;
//assign Rd_write_by_en_Ex=(Overflow==1)?4'b0:4'b1111;
assign Less_Ex=Less;
assign Overflow_Ex=Overflow;
assign Zero_Ex=Zero;

//Mem Part
wire [31:0]Din_Mem;
wire [31:0]Data_Mem,Dout_Mem,Dout_Wr;
assign Din_Mem=Rd_Mem;
Ex_Mem Ex_mem_Reg(clk,Reset_Ex_Mem,PC_branch_Ex,PC_jump_Ex,ALUShift_out_Ex,Jump_Ex,Less_Ex,Zero_Ex,Overflow_Ex,Condition_Ex,
LoadType_Ex,LoadByte_Ex,RegWr_Ex,MemWr_Ex,MemtoReg_Ex,Exception_Ex,Rd_Ex,PC_branch_Mem,PC_jump_Mem,ALUShift_out_Mem,
Jump_Mem,Less_Mem,Zero_Mem,Overflow_Mem,Condition_Mem,LoadType_Mem,LoadByte_Mem,RegWr_Mem,MemWr_Mem,MemtoReg_Mem,Exception_Mem,
Rd_Mem);
PCSourceGen PCSrc(PC_branch_Mem,PC_jump_Mem,Condition_Mem,Less_Mem,Zero_Mem,Jump_Mem,Exception_Mem,PCSource,PC_branch,PC_jump);
Memory Instr_Data_Mem(clk,MemWr_Mem,PC,ALUShift_out_Mem,Din_Mem,Inst_IF,Data_Mem);
LoadProcess loadproc (RegWr_Mem,Data_Mem,LoadType_Mem,LoadByte_Mem,Dout_Mem,Rd_write_by_en_Mem);
//Mem_Wr Reg
Mem_Wr Mem_Wr_Reg(clk,Reset_Mem_Wr,ALUShift_out_Mem,Dout_Mem,Rd_write_by_en_Mem,Overflow_Mem,RegWr_Mem,MemtoReg_Mem,Rd_Mem,
ALUShift_out_Wr,Rd_write_by_en_Wr,Dout_Wr,Overflow_Wr,RegWr_Wr,MemtoReg_Wr,Rd_Wr);

//Wr Part
assign Rd_in=(MemtoReg_Wr==1'b0)?ALUShift_out_Wr:Dout_Wr;
//Output Part 
assign PC_out=PC_Ex;
assign Inst_IF_out=Inst_IF;
assign Inst_ID_out=Inst_ID;
assign ALU_Shift_out_out=ALUShift_out_Ex;
assign A_in_out=A;
assign B_in_out=B;
assign Shift_out_out=Shift_out;
assign Rs_out_out=Rs_out_Ex;
assign Rt_out_out=Rt_out_Ex;
ControlHazard ch(PCSource,Reset_IF_ID, Reset_ID_Ex_Control, Reset_Ex_Mem);
ForwardUnit fw(Rs_Ex,Rt_Ex,Rd_Mem,Rd_Wr,RegWr_Mem,RegWr_Wr,ALUSrcB_Ex,ALUSrcA,ALUSrcB);
LoadUseDetector load_use(LoadType_ID, LoadType_Ex,Rs_ID, Rt_ID, Rt_Ex,Reset_ID_Ex_LoadUse,Keep_IF_ID,Keep_PC);
endmodule
