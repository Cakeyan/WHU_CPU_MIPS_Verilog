`include "ctrl_encode_def.v"
`include "instruction_def.v"

module PC(
    input clk,
    input rst,
    input PCWr, 
    input jump,
    input [31:0] jr_addr,
    output reg [31:0] PC, 
    input [1:0] NPCOp,
    input [25:0] IMM);

// 赋值
    reg [1:0] tmp;
    wire [31:0] PCPLUS4;
    assign PCPLUS4 = PC + 4;
    // wire reg [31:0] NPC;

// 时钟：PC持续变化
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            PC <= 32'h0000_3000;
        else
        begin
            case (NPCOp)
            `NPC_PLUS4:  PC = PCPLUS4;
            `NPC_BRANCH: begin
                            if (PCWr) // 如果分支判断正确，则分支
                                PC = PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00};
                            else
                                PC = PCPLUS4;
                            // DEBUG
                            // $display("PCPLUS4 = %X, PC = %X, imm = %X", PCPLUS4, PC, {{14{IMM[15]}}, IMM[15:0], 2'b00});
                         end
            `NPC_JUMP:   begin
                case (jump)
                    // j, jal
                    1: PC = {PCPLUS4[31:28], IMM[25:0], 2'b00};
                    // jr
                    0: PC = jr_addr;
                    // DEBUG
                    // $display("PC = %X, imm = %X", PC, {PCPLUS4[31:28], IMM[25:0], 2'b00});
                    default: $display("NPC jump default");
                endcase
                end
            default: $display("NPC default");
            endcase
        end
    end // end always
        
endmodule
            
