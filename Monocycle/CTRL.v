`include "ctrl_encode_def.v"
`include "instruction_def.v"

module Ctrl(
    
// Jump：用来控制j,jal,jr的跳转
    // 0: jr指令，使用寄存器中的地址进行跳转
	// 1: j, jal指令，使用imm26跳转
    output reg jump,

// RegDst：控制写RF的寄存器
    // 0: rt寄存器[20:16]
	// 1: rd寄存器[15:11]
    output reg RegDst,

// Branch：条件分支
    // 0: 不是条件分支
	// 1: beq/bne
    output reg Branch,

// MemRead：读数据存储器
    // 0：不读
    // 1：读DM，lw指令
    output reg MemRead,

// MemtoReg：写寄存器数据来源
    // 0：写RF数据来自ALU
    // 1：写RF数据来自DM
    output reg MemtoReg,

// ALUOp：控制ALU不同的操作
    // 详见ctrl_encode_def
    output reg[4:0] ALUOp,

// MemWrite：写数据存储器
	// 0: 不写
	// 1: 写DM，sw指令
    output reg MemWrite,
    
// ALUSrc：控制ALU第二个操作数来源
	// 0: 第二个ALU操作数来自RF的第二个输出RD2
	// 1: 第二个ALU操作数来自指令低16位符号扩展
    output reg ALUSrc,
    
// RegWrite：控制寄存器写
	// 0: 不写
	// 1: 写RF（R型、lw）
    output reg RegWrite,
    
// ExtOp：扩展形式
	// `EXT_ZERO: 无符号扩展
	// `EXT_SIGNED: 有符号扩展
    output reg [1:0] ExtOp,

// NCPOp：NPC的操作码
    // `NPC_BRANCH  2'b01  分支
    // `NPC_JUMP    2'b10  跳转
    // `NPC_PLUS4   2'b00  默认
    output reg [1:0] NPCOp,

    input [5:0] OpCode, // 操作码

    input [5:0]	funct // 功能码
            );
            
// 控制信号赋值
    always@(OpCode or funct)
    begin
        // Jump
        case (OpCode)
            `INSTR_J_OP,
            `INSTR_JAL_OP: jump = 1;
            default:       jump = 0;
        endcase

        // RegDst
        case (OpCode)
            `INSTR_LW_OP,
            `INSTR_ORI_OP,
            `INSTR_LUI_OP,
            `INSTR_SLTI_OP,
            `INSTR_ADDI_OP,
            `INSTR_J_OP,
            `INSTR_JAL_OP: RegDst = 0;
            `INSTR_RTYPE_OP:  
                begin
                    case(funct)
                        `INSTR_SUBU_FUNCT,
                        `INSTR_ADDU_FUNCT, 
                        `INSTR_OR_FUNCT,
                        `INSTR_ADD_FUNCT,
                        `INSTR_SUB_FUNCT,
                        `INSTR_SLL_FUNCT,
                        `INSTR_SRL_FUNCT,
                        `INSTR_SRA_FUNCT,
                        `INSTR_SLT_FUNCT,
                        `INSTR_AND_FUNCT: RegDst = 1;
                        `INSTR_JR_FUNCT:  RegDst = 0;
                        default: ;
                        // $display ("Control RegDst Funct default, funct = %X", funct);
                    endcase
                end  
            default : ;
            // $display ("Control RegDst Opcode default, OpCode = %X", OpCode);
        endcase

        // Branch
        case (OpCode)
            `INSTR_BEQ_OP,
            `INSTR_BNE_OP: Branch = 1;
            // 对j和jal和jr，branch无所谓
            default: Branch = 0;
        endcase
        
        // MemRead
        case (OpCode)
            `INSTR_LW_OP: MemRead = 1;
            default: MemRead = 0;
        endcase
        
        // MemtoReg
        case (OpCode)
            `INSTR_LW_OP: MemtoReg = 1;
            `INSTR_ORI_OP,
            `INSTR_LUI_OP,
            `INSTR_SLTI_OP,
            `INSTR_ADDI_OP,
            `INSTR_J_OP,
            `INSTR_JAL_OP: MemtoReg = 0;
            `INSTR_RTYPE_OP:  
                begin
                    case(funct)
                        `INSTR_SUBU_FUNCT,
                        `INSTR_ADDU_FUNCT,
                        `INSTR_OR_FUNCT,
                        `INSTR_ADD_FUNCT,
                        `INSTR_SUB_FUNCT,
                        `INSTR_SLL_FUNCT,
                        `INSTR_SRL_FUNCT,
                        `INSTR_SRA_FUNCT,
                        `INSTR_SLT_FUNCT,
                        `INSTR_JR_FUNCT,
                        `INSTR_AND_FUNCT: MemtoReg = 0;
                        default: ;
                        // $display ("Control MemtoReg Funct default, funct = %X", funct);
                    endcase
                end  
            default : ;
            // $display ("Control MemtoReg Opcode default, OpCode = %X", OpCode);
        endcase
        
        // ALUOp
        case (OpCode)
            `INSTR_LUI_OP,
            `INSTR_ADDI_OP,
            `INSTR_LW_OP,
            `INSTR_SW_OP:   ALUOp = `ALUOp_ADDU;
            `INSTR_J_OP,
            `INSTR_JAL_OP:  ALUOp = `ALUOp_NOP;
            `INSTR_ORI_OP:  ALUOp = `ALUOp_OR;
            `INSTR_SLTI_OP: ALUOp = `ALUOp_SLT;
            `INSTR_BEQ_OP:  ALUOp = `ALUOp_BEQ;
            `INSTR_BNE_OP:  ALUOp = `ALUOp_BNE;
            `INSTR_RTYPE_OP:
                    case(funct)
                        `INSTR_SUBU_FUNCT: ALUOp = `ALUOp_SUBU;
                        `INSTR_ADDU_FUNCT: ALUOp = `ALUOp_ADDU;
                        `INSTR_OR_FUNCT:   ALUOp = `ALUOp_OR;
                        `INSTR_ADD_FUNCT:  ALUOp = `ALUOp_ADD;
                        `INSTR_SUB_FUNCT:  ALUOp = `ALUOp_SUB;
                        `INSTR_SLL_FUNCT:  ALUOp = `ALUOp_SLL;
                        `INSTR_SRL_FUNCT:  ALUOp = `ALUOp_SRL;
                        `INSTR_SRA_FUNCT:  ALUOp = `ALUOp_SRA;
                        `INSTR_SLT_FUNCT:  ALUOp = `ALUOp_SLT;
                        `INSTR_JR_FUNCT:   ALUOp = `ALUOp_NOP;
                        `INSTR_AND_FUNCT:  ALUOp = `ALUOp_AND;
                        default: ;
                        // $display ("Control ALUOp Funct default, funct = %X", funct);
                    endcase
            default : ;
            // $display ("Control ALUOp Opcode default, OpCode = %X", OpCode);
        endcase
        
        // MemWrite
        case (OpCode)
            `INSTR_SW_OP: MemWrite = 1;
            default: MemWrite = 0;
        endcase
        
        // ALUSrc
        case (OpCode)
            `INSTR_ORI_OP,
            `INSTR_ADDI_OP,
            `INSTR_LW_OP,
            `INSTR_LUI_OP,
            `INSTR_SLTI_OP,
            `INSTR_SW_OP:  ALUSrc = 1;
            `INSTR_BEQ_OP,
            `INSTR_BNE_OP,
            `INSTR_J_OP,
            `INSTR_JAL_OP: ALUSrc = 0;
            `INSTR_RTYPE_OP:  
                begin
                    case(funct)
                        `INSTR_SUBU_FUNCT,
                        `INSTR_ADDU_FUNCT,
                        `INSTR_OR_FUNCT,
                        `INSTR_ADD_FUNCT,
                        `INSTR_SUB_FUNCT,
                        `INSTR_SLL_FUNCT,
                        `INSTR_SRL_FUNCT,
                        `INSTR_SRA_FUNCT,
                        `INSTR_SLT_FUNCT,
                        `INSTR_JR_FUNCT,
                        `INSTR_AND_FUNCT: ALUSrc = 0;
                        default: ;
                        // $display ("Control ALUSrc Funct default, funct = %X", funct);
                    endcase
                end  
            default : ;
            // $display ("Control ALUSrc OpCode default, OpCode = %X", OpCode);
        endcase

        // RegWrite
        case(OpCode)
            `INSTR_SW_OP,
            `INSTR_BEQ_OP,
            `INSTR_BNE_OP,
            `INSTR_J_OP:   RegWrite = 0;
            `INSTR_LW_OP,
            `INSTR_ORI_OP,
            `INSTR_LUI_OP,
            `INSTR_SLTI_OP,
            `INSTR_ADDI_OP,
            `INSTR_JAL_OP: RegWrite = 1;
            `INSTR_RTYPE_OP:  
                begin
                    case(funct)
                        `INSTR_SUBU_FUNCT,
                        `INSTR_ADDU_FUNCT,
                        `INSTR_OR_FUNCT,
                        `INSTR_ADD_FUNCT,
                        `INSTR_SUB_FUNCT,
                        `INSTR_SLL_FUNCT,
                        `INSTR_SRL_FUNCT,
                        `INSTR_SRA_FUNCT,
                        `INSTR_SLT_FUNCT,
                        `INSTR_AND_FUNCT: RegWrite = 1;
                        `INSTR_JR_FUNCT:  RegWrite = 0;
                        default: ;
                        // $display ("Control RegWrite Funct default, funct = %X", funct);
                    endcase
                end  
            default: ;
            // $display ("Control RegWrite OpCode default, OpCode = %X", OpCode);
        endcase
        
        // ExtOp
        case (OpCode)
            `INSTR_LW_OP,
            `INSTR_SW_OP,
            `INSTR_ADDI_OP,
            `INSTR_SLTI_OP,
            `INSTR_BEQ_OP,
            `INSTR_BNE_OP:  ExtOp = `EXT_SIGNED;
			`INSTR_LUI_OP:  ExtOp = `EXT_HIGHPOS;
            default:        ExtOp = `EXT_ZERO;
        endcase
         
        // NPCOp
        case (OpCode)
            `INSTR_J_OP,
            `INSTR_JAL_OP: NPCOp = `NPC_JUMP;
            `INSTR_BEQ_OP,
            `INSTR_BNE_OP: NPCOp = `NPC_BRANCH;
            `INSTR_RTYPE_OP:
                begin
                    case(funct)
                        `INSTR_JR_FUNCT: NPCOp = `NPC_JUMP;
                        default:         NPCOp = `NPC_PLUS4;
                    endcase
                end
            default:       NPCOp = `NPC_PLUS4;
        endcase
    end

endmodule
