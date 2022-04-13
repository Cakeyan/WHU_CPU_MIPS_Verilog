`include "ctrl_encode_def.v"
`include "instruction_def.v"

module mips(clk, rst);
    input clk;
    input rst;

// 各字段意义
	wire [31:0] instr;
    wire [5:0] Op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] Funct;
    wire [15:0] Imm16;
    wire [25:0] Imm26;
    assign Op    = instr[31:26];
    assign rs    = instr[25:21];
    assign rt    = instr[20:16];
    // R型
    assign rd    = instr[15:11];
    assign shamt = instr[10:6];
    assign Funct = instr[5:0];
    // I型
    assign Imm16 = instr[15:0];
    // J型
    assign Imm26   = instr[25:0];
    
// Control
    wire       jump;
    wire       RegDst;
    wire       Branch;
    wire       MemRead;
    wire       MemtoReg;
    wire [4:0] ALUOp;
    wire       DMWr;
    wire       ALUSrc;
    wire       RFWr;
    wire [1:0] NPCOp;
    wire [1:0] EXTOp;
    Ctrl U_Ctrl (
        .jump(jump),
        .RegDst(RegDst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(DMWr),
        .ALUSrc(ALUSrc),
        .RegWrite(RFWr),
        .ExtOp(EXTOp),
        .OpCode(Op),
        .funct(Funct),
        .NPCOp(NPCOp)
    );

// RF、MUX2
    // MUX2-WIDTH = 5
	wire [4:0]  A3;
    // mux2 #(5) RF_write_register_select(
	// 	.d0(rt), 
	// 	.d1(rd),
    //     .s(RegDst),
  	//     .y(A3)
	// );
    assign A3 = (RegDst==1) ? rd : rt;

    // RF
	wire [4:0]  A2, A1;
	wire [31:0] WD;
	wire [31:0] RD1,RD2;
	wire [31:0] PC;	
    wire jal_signal;
    assign jal_signal = jump & RFWr; // 如果是1，说明是jal
    RF U_RF (
        .A1(rs), 
        .A2(rt), 
        .A3(A3), 
        .WD(WD), 
        .clk(clk),
        .RFWr(RFWr), 
        .jal_signal(jal_signal),
        .PC(PC),
        .RD1(RD1), 
        .RD2(RD2)
    );

// PC、MUX2
    wire PCWr;
    // wire [31:0] NPC;			
    wire Zero;
    // The following sentence can be implemented by a MUX2
    assign PCWr = Branch & Zero; // 分支指令标志，1代表分支，0代表分支判断错误不分支
    PC U_PC (
        .clk(clk),
        .rst(rst),
        .PCWr(PCWr), 
        .jump(jump),
        .jr_addr(RD1),
        .PC(PC),
        .NPCOp(NPCOp),
        .IMM(Imm26)
    );
    // NPC merge into PC

    // NPC npc(
    //     .PC(PC), 
    //     .NPCOp(NPCOp), 
    //     .IMM(Imm26), 
    //     .NPC(NPC)
    // );

// IM
    // wire [31:0] im_dout;
    im_4k U_IM (
        .addr(PC[11:2]), 
        .dout(instr)
    );

// IR
    // wire IRWr;
    // assign IRWr = 1'b1;
    // IR U_IR(
    //     .clk(clk),
    //     .rst(rst),
    //     .IRWr(IRWr),
    //     .im_dout(im_dout),
    //     .instr(instr));

// EXT
    wire [31:0] Imm32;
    EXT U_EXT(
            .Imm16(Imm16),
            .EXTOp(EXTOp),
            .Imm32(Imm32)
            );

// ALU、MUX2
    // MUX2-WIDTH = 32
    wire [31:0] alu_op2;
    // mux2 #(32) ALU_OP2_select(
	// 	.d0(RD2), 
	// 	.d1(Imm32),
    //     .s(ALUSrc),
  	//     .y(alu_op2)
	// );
    assign alu_op2 = (ALUSrc==1) ? Imm32 : RD2;
    wire [31:0] alu_result;
    alu U_ALU(
        .A(RD1),
        .B(alu_op2),
        .ALUOp(ALUOp),
        .C(alu_result),
        .Zero(Zero),
        .shamt(shamt)
    );

// DM、MUX2
    wire [31:0] DM_out;
    dm_4k U_DM(
        .addr(alu_result[11:2]),
        .din(RD2),
        .DMWr(DMWr),
        .clk(clk),
        .dout(DM_out)
    );
    // MUX2-WIDTH = 32
    // mux2 #(32) RF_WriteData_select(
	// 	.d0(DM_out), 
	// 	.d1(alu_result),
    //     .s(MemtoReg),
  	//     .y(WD)
	// );
   assign WD = (MemtoReg == 1) ? DM_out : alu_result;
    
endmodule
