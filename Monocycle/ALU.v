`include "ctrl_encode_def.v"

module alu (
    input [31:0] A,
    input [31:0] B,
    input [4:0] ALUOp,
    input [4:0] shamt,
    output reg [31:0] C,
    output reg Zero);
    
// ALU运算
    always @(A or B or ALUOp) begin
        case (ALUOp)
            `ALUOp_ADDU: C = A + B;
            `ALUOp_ADD:  C = A + B;
            `ALUOp_AND:  C = A & B;
            `ALUOp_SUBU: C = A - B;
            `ALUOp_SUB:  C = A - B;
            `ALUOp_OR:   C = A | B;
            `ALUOp_BEQ: Zero = (A == B) ? 1 : 0; // 分支语句使用零标来判断是否分支
            `ALUOp_BNE: Zero = (A != B) ? 1 : 0;
            `ALUOp_SLL:  C = B << shamt;
            `ALUOp_SRL:  C = B >> shamt;
            `ALUOp_SRA:  C = ($signed(B)) >>> shamt;
            `ALUOp_SLT:  C = ($signed(A)) < ($signed(B)); // 有符号小于

            default:;
        endcase
    end
    
// 零标志
    // assign Zero = (A == B) ? 1 : 0;
    
endmodule
    
