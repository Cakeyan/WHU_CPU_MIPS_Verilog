`include "ctrl_encode_def.v"
//`include "D:/Cakeyan/CPU/mycode/pipeline/verilog/ctrl_encode_def.v"

module npc(
           input [31:0] ID_rs_Forwarding,    
           input [31:0] PC,
           input [31:0] ID_PC,
           input [31:0] Instr,
           input branch,
           input [1:0] NPCOp,  
           output reg [31:0] NPC
           );
    
    always @(PC or Instr or branch or NPCOp or ID_rs_Forwarding)
    begin
        case(NPCOp)
            2'b00: NPC = PC + 4;
            2'b01:
            if (branch == 1) 
                   NPC = ID_PC + 4 + {{14{Instr[15]}},Instr[15:0],2'b00};
            else 
                   NPC = PC + 4;
            2'b10: NPC  = {ID_PC[31:28], Instr[25:0], 2'b00};
            2'b11: NPC = ID_rs_Forwarding;
        endcase
    end
    
endmodule
