`include "ctrl_encode_def.v"

module EXT(
    input [15:0] Imm16,
    input [1:0] EXTOp,
    output reg [31:0] Imm32
    );

// 位移操作    
    always @(*) begin
        case (EXTOp)
            `EXT_ZERO:    Imm32 = {16'd0, Imm16};
            `EXT_SIGNED:  Imm32 = {{16{Imm16[15]}}, Imm16};
            `EXT_HIGHPOS: Imm32 = {Imm16, 16'd0};  // LUI
            default: ;
        endcase
    end // end always
    
endmodule
