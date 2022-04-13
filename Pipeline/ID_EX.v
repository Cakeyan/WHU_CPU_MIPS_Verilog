module id_ex(
             input      clk,
             input      rst,
             input      stall,
             input      [1:0]WB_MemtoReg_id,
             input      WB_RegWrite_id,
             input      MEM_MemWrite_id,
             input      MEM_MemRead_id,
             input      [4:0]EX_ALUOp_id,
             input      EX_ALUSrcA_id,
             input      EX_ALUSrcB_id,
             input      [1:0]EX_RegDst_id,
             input      [4:0]rsAddr_id,
             input      [4:0]rtAddr_id,
             input      [4:0]rdAddr_id,
             input      [31:0]PC_id,
             input      [31:0]Imm_id,
             input      [31:0]rsData_id,
             input      [31:0]rtData_id,
             output reg [1:0] WB_MemtoReg_ex,
             output reg WB_RegWrite_ex,
             output reg MEM_MemWrite_ex,
             output reg MEM_MemRead_ex,
             output reg [4:0] EX_ALUOp_ex,
             output reg EX_ALUSrcA_ex,
             output reg EX_ALUSrcB_ex,
             output reg [1:0] EX_RegDst_ex,
             output reg [4:0] rsAddr_ex,
             output reg [4:0] rtAddr_ex,
             output reg [4:0] rdAddr_ex,
             output reg [31:0] PC_ex,
             output reg [31:0] Imm_ex,
             output reg [31:0] rsData_ex,
             output reg [31:0] rtData_ex
             );

    // rst
    always @(posedge rst) 
        begin
            WB_MemtoReg_ex          <= 0;
            WB_RegWrite_ex          <= 0;
            MEM_MemWrite_ex         <= 0;
            MEM_MemRead_ex          <= 0;
            EX_ALUOp_ex           <= 0;
            EX_ALUSrcA_ex           <= 0;
            EX_ALUSrcB_ex           <= 0;
            EX_RegDst_ex            <= 0;
            rsAddr_ex               <= 0;
            rtAddr_ex               <= 0;
            rdAddr_ex               <= 0;
            PC_ex                   <= 0;
            Imm_ex                  <= 0;
            rsData_ex               <= 0;
            rtData_ex               <= 0;
        end
    
    // clk
    always @ (posedge clk)
        begin
            // stall: clear all
            if (stall) 
                begin
                    WB_MemtoReg_ex  <= 0;
                    WB_RegWrite_ex  <= 0;
                    MEM_MemWrite_ex <= 0;
                    MEM_MemRead_ex  <= 0;
                    EX_ALUOp_ex   <= 0;
                    EX_ALUSrcA_ex   <= 0;
                    EX_ALUSrcB_ex   <= 0;
                    EX_RegDst_ex    <= 0;
                end

            else 
                begin
                    WB_MemtoReg_ex  <= WB_MemtoReg_id;
                    WB_RegWrite_ex  <= WB_RegWrite_id;
                    MEM_MemWrite_ex <= MEM_MemWrite_id;
                    MEM_MemRead_ex  <= MEM_MemRead_id;
                    EX_ALUOp_ex   <= EX_ALUOp_id;
                    EX_ALUSrcA_ex   <= EX_ALUSrcA_id;
                    EX_ALUSrcB_ex   <= EX_ALUSrcB_id;
                    EX_RegDst_ex    <= EX_RegDst_id;
                    rsAddr_ex       <= rsAddr_id;
                    rtAddr_ex       <= rtAddr_id;
                    rdAddr_ex       <= rdAddr_id;
                    PC_ex           <= PC_id;
                    Imm_ex          <= Imm_id;
                    rsData_ex       <= rsData_id;
                    rtData_ex       <= rtData_id;
                end
        end
endmodule
