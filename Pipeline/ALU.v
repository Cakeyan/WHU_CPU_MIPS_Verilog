`include "ctrl_encode_def.v"
//`include "D:/Cakeyan/CPU/mycode/pipeline/verilog/ctrl_encode_def.v"

module alu(input [31:0] A,
           input [31:0] B,
           input [4:0] ALUOp,
           output reg [31:0] C);
    
    always @(A or B or ALUOp) begin
        case(ALUOp)
            `ALUOp_ADDU: C    = A + B;
            `ALUOp_SUBU: C    = A - B;
            `ALUOp_ADD:  C    = $signed(A) + $signed(B);
            `ALUOp_SUB:  C    = $signed(A) - $signed(B);
            `ALUOp_AND:  C    = A & B;
            `ALUOp_OR:   C    = A | B;
            `ALUOp_SLT:  C    = ($signed(A) < $signed(B));
            `ALUOp_SLL:  C    = B << A[4:0];
            `ALUOp_SRL:  C    = B >> A[4:0];
            `ALUOp_SRA:  C    = $signed(B) >>> A[4:0];
            `ALUOp_LUI:  C    = B << 16;
        endcase
    end
    
endmodule
    
    
    
