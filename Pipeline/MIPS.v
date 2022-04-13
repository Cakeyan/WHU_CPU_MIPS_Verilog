
module mips(clk,
            rst);

    // 输入
    input clk;
    input rst;

    // $ra == $31
    parameter RA_ADDRESS = 5'b11111;
    
    // PC
    wire [1:0]  NPCOp;
    wire [31:0] PC;
    
    // NPC
    wire [31:0] NPC;
    wire branch;
    
    // IM
    wire [31:0] Instr;
    
    // ID
    wire flush;
    wire IF_ID_stall;
    wire [31:0] ID_PC;
    wire [31:0] Instr_id;
    
    // EXT
    wire EXTOp;
    wire [31:0] EXT_Out;
    
    // RF
    wire [1:0]  MemtoReg;
    wire [31:0] RegWriteData_wb;
    wire [1:0]  RegDst;
    wire [4:0]  RegWriteAddress_ex;
    wire RegWrite;
    wire [31:0] RF_Out1;
    wire [31:0] RF_Out2;
    
    // CTRL
    wire ALUSrcA;
    wire ALUSrcB;
    wire [4:0]  ALUOp;
    wire [31:0] ALU_out;
    wire Jump;
    
    // ID_EX
    wire stall;
    wire [1:0] WB_MemtoReg_ex;
    wire WB_RegWrite_ex;
    wire MEM_MemWrite_ex;
    wire MEM_MemRead_ex;
    wire EX_ALUSrcA_ex;
    wire EX_ALUSrcB_ex;
    wire [4:0] EX_ALUCode_ex;
    wire [1:0] EX_RegDst_ex;
    wire [31:0] PC_ex;
    wire [31:0] Imm_ex;
    wire [4:0] RsAddress_ex;
    wire [4:0] RtAddress_ex;
    wire [4:0] RdAddress_ex;
    wire [31:0] RealOut1_ex;
    wire [31:0] RealOut2_ex;
    
    // ALU Input
    wire [31:0] ALU_a;
    wire [31:0] ALU_b;
    wire [31:0] ALU_IN_1;
    wire [31:0] ALU_IN_2;
    
    
    
    // Forward
    wire[1:0] ForwardA;
    wire[1:0] ForwardB;
    wire[1:0] ForwardC;
    wire[1:0] ForwardD;
    wire[31:0] ID_rs_Forwarding;
    wire[31:0] ID_rt_Forwarding;
    
    // EX_MEM
    wire [1:0] WB_MemtoReg_mem;
    wire WB_RegWrite_mem;
    wire MEM_MemWrite_mem;
    wire MEM_MemRead_mem;
    wire [4:0] RegWriteAddress_mem;
    wire [31:0] PC_mem;
    wire [31:0] ALUResult_mem;
    wire [31:0] MemWriteData_mem;
    
    // DM
    wire [31:0] DM_Data_Out;
    wire MemWrite;
    wire MemRead;
    
    //MEM_WB
    wire [1:0] WB_MemtoReg_wb;
    wire WB_RegWrite_wb;
    wire [4:0] RegWriteAddress_wb;
    wire [31:0] PC_wb;
    wire [31:0] ALUResult_wb;
    wire [31:0] MemOut_wb;
    
    // WB-ID
    wire rs_Select;
    wire rt_Select;
    wire [31:0] MUX_rf_Write_A;
    wire [31:0] MUX_rf_Write_B;
    
    //decompose Instruction
    wire[5:0] OpCode;
    wire[5:0] funct;
    wire [4:0] RsAddress_id;
    wire [4:0] RtAddress_id;
    wire [4:0] RdAddress_id;
    
    assign OpCode       = Instr_id[31:26];
    assign funct        = Instr_id[5:0];
    assign RsAddress_id = Instr_id[25:21];
    assign RtAddress_id = Instr_id[20:16];
    assign RdAddress_id = Instr_id[15:11];


    /*****************/
    /**
     * IF Stage
     */
    
    // IM
    im  IM(
        PC[11:2],
        Instr
        );

    // PC/NPC
    npc NPC_(
        ID_rs_Forwarding,
        PC,
        ID_PC,
        Instr_id,
        branch,
        NPCOp,
        NPC);
    pc  PC_(
        NPC,
        clk,
        rst,
        stall,
        PC
        );
    
    // IF-ID register
    if_id IF_ID(
        clk,
        rst,
        flush,
        stall,
        PC,
        Instr,
        ID_PC,
        Instr_id
        );
    

    /*****************/
    /**
     * ID stage
     */

    // solution for lw
    Solution_of_RAW solution_of_RAW(
        RsAddress_id,
        RtAddress_id,
        RegWriteAddress_wb,
        WB_RegWrite_wb,
        rs_Select,
        rt_Select
        );
    
    // RF
    rf RF(
        clk,
        rst,
        RsAddress_id,
        RtAddress_id,
        RegWriteAddress_wb,
        RegWriteData_wb,
        WB_RegWrite_wb,
        RF_Out1,
        RF_Out2
        );

    // Ctrl
    ctrl CTRL(
        OpCode,
        funct,
        RegDst,
        ALUSrcA,
        ALUSrcB,
        MemRead,
        RegWrite,
        MemWrite,
        MemtoReg,
        NPCOp,
        EXTOp,
        ALUOp,
        Jump
        );
    
    // Forward-ID: branch
    MuxOne_out_of_three IDRealRS(
        RF_Out1,
        ALUResult_mem,
        ALU_out,
        ForwardC,
        ID_rs_Forwarding
        );
    MuxOne_out_of_three IDRealRT(
        RF_Out2,
        ALUResult_mem,
        ALU_out,
        ForwardD,
        ID_rt_Forwarding
        );
    
    // EXT
    ext EXT(
        EXTOp,
        Instr_id[15:0],
        EXT_Out
        );
    
    // MUX-RegDst: rt/rd/$ra
    MuxOne_out_of_three MUX_RegDst(
        RtAddress_ex,
        RdAddress_ex,
        RA_ADDRESS,
        EX_RegDst_ex,
        RegWriteAddress_ex
        );
    
    // MUX-RegWrite Data
    MuxOne_out_of_two writebackRF_muxA(
        rs_Select,
        RF_Out1,
        RegWriteData_wb,
        MUX_rf_Write_A
        );
    MuxOne_out_of_two writebackRF_muxB(
        rt_Select,
        RF_Out2,
        RegWriteData_wb,
        MUX_rf_Write_B
        );
    
    // ID Branch Judge
    ID_Branch ID_Branch_Judge(
        ID_rs_Forwarding,
        ID_rt_Forwarding,
        ALUOp,
        branch
        );
    
    // ID-EX register
    id_ex ID_EX(
        clk,
        rst,
        stall,
        MemtoReg,
        RegWrite,
        MemWrite,
        MemRead,
        ALUOp,
        ALUSrcA,
        ALUSrcB,
        RegDst,
        RsAddress_id,
        RtAddress_id,
        RdAddress_id,
        ID_PC,
        EXT_Out,
        MUX_rf_Write_A,
        MUX_rf_Write_B,
        WB_MemtoReg_ex,
        WB_RegWrite_ex,
        MEM_MemWrite_ex,
        MEM_MemRead_ex,
        EX_ALUCode_ex,
        EX_ALUSrcA_ex,
        EX_ALUSrcB_ex,
        EX_RegDst_ex,
        RsAddress_ex,
        RtAddress_ex,
        RdAddress_ex,
        PC_ex,
        Imm_ex,
        RealOut1_ex,
        RealOut2_ex
        );
    

    /*****************/
    /**
     * EX stage
     */

     // Hazard
    HazardInspector hazardinspector(
        rst,
        branch,
        Jump,
        RsAddress_id,
        RtAddress_id,
        RtAddress_ex,
        MEM_MemRead_ex,
        RegWriteAddress_ex,
        stall,
        flush);
    
    // ALU Forward: Register, Memory, ALUResult
    Forwarding forwarding(
        WB_RegWrite_mem,
        WB_RegWrite_wb,
        WB_RegWrite_ex,
        RegWriteAddress_mem,
        RegWriteAddress_wb,
        RegWriteAddress_ex,
        RsAddress_ex,
        RtAddress_ex,
        RsAddress_id,
        RtAddress_id,
        ForwardA,
        ForwardB,
        ForwardC,
        ForwardD
        );
    MuxOne_out_of_three alua(
        RealOut1_ex,
        RegWriteData_wb,
        ALUResult_mem,
        ForwardA,
        ALU_a
        );
    MuxOne_out_of_three alub(
        RealOut2_ex,
        RegWriteData_wb,
        ALUResult_mem,
        ForwardB,
        ALU_b
        );

    // ALU and MUX
    MuxOne_out_of_two aluSrcA(
        EX_ALUSrcA_ex,
        ALU_a,
        {27'b0, Imm_ex[10:6]}, // shamt
        ALU_IN_1
        );
    MuxOne_out_of_two aluSrcB(
        EX_ALUSrcB_ex,
        ALU_b,
        Imm_ex,
        ALU_IN_2
        );
    alu ALU(
        ALU_IN_1, 
        ALU_IN_2, 
        EX_ALUCode_ex,
        ALU_out
        );
    
    // EX-MEM register
    ex_mem EX_MEM(
        clk,
        rst,
        WB_MemtoReg_ex,
        WB_RegWrite_ex,
        MEM_MemWrite_ex,
        RegWriteAddress_ex,
        PC_ex,
        ALU_out,
        ALU_b,
        WB_MemtoReg_mem,
        WB_RegWrite_mem,
        MEM_MemWrite_mem,
        RegWriteAddress_mem,
        PC_mem,
        ALUResult_mem,
        MemWriteData_mem
        );
    

    /*****************/
    /**
     * MEM Stage
     */

    // DM
    dm DM(
        ALUResult_mem,
        MemWriteData_mem,
        MEM_MemWrite_mem,
        clk,
        rst,
        DM_Data_Out
        );
    // MEM-WB register
    mem_wb MEM_WB(
        clk,
        rst,
        WB_MemtoReg_mem,
        WB_RegWrite_mem,
        RegWriteAddress_mem,
        PC_mem,
        ALUResult_mem,
        DM_Data_Out,
        WB_MemtoReg_wb,
        WB_RegWrite_wb,
        RegWriteAddress_wb,
        PC_wb,
        ALUResult_wb,
        MemOut_wb
        );
    

    /*****************/
    /**
     * WB Stage
     */
    // MUX-Data Write Back
    MuxOne_out_of_three datatoreg(
        ALUResult_wb,
        MemOut_wb,
        PC_wb+32'd4,
        WB_MemtoReg_wb,
        RegWriteData_wb
        );

endmodule
