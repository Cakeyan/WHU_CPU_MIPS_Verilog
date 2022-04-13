`include "ctrl_encode_def.v"
//`include "D:/Cakeyan/CPU/mycode/pipeline/verilog/ctrl_encode_def.v"

module ID_Branch (
                  input [31:0] A,
                  input [31:0] B,
                  input [4:0] ALUOp,
                  output reg Branch);
    
    always @(*) begin
        case (ALUOp)
            `ALUOp_EQL:  Branch = (A == B)?1'b1:1'b0;
            `ALUOp_BNE:  Branch = (A == B)?1'b0:1'b1;
            default: Branch     = 0;
        endcase
    end
    
endmodule
