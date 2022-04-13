module RF(A1,
          A2,
          A3,
          WD,
          clk,
          RFWr,
          jal_signal,
          PC,
          RD1,
          RD2);
// 输入输出
    input         clk; // 时钟
    input         RFWr; // RegWrite信号
    input         jal_signal; // jal
    input  [4:0]  A1, A2, A3; // 读寄存器1、2；写寄存器
    input  [31:0] WD; // 写数据
    input  [31:0] PC;
    output [31:0] RD1, RD2; // 读数据1、2
    
// 初始化寄存器堆：把32个寄存器都赋值零
    reg    [31:0] rf[31:0];
    integer i;
    initial begin
        for (i = 0; i<32; i = i+1)
            rf[i] = 0;
    end
    
// 时钟变化：读数据、写数据
    always @(posedge clk) begin
        // 写信号RegWrite为1，则写数据
        if (RFWr) begin
            if(jal_signal == 1) rf[31] <= PC + 4; // jal
            else rf[A3] <= WD;
        end
        // DEBUG
        // $display("WD = %X", WD);
        // 输出所有32个寄存器的值
        $display("  R[00-07] =   %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", 0, rf[1], rf[2], rf[3], rf[4], rf[5], rf[6], rf[7]);
        $display("  R[08-15] =   %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", rf[8], rf[9], rf[10], rf[11], rf[12], rf[13], rf[14], rf[15]);
        $display("  R[16-23] =   %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", rf[16], rf[17], rf[18], rf[19], rf[20], rf[21], rf[22], rf[23]);
        $display("  R[24-31] =   %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", rf[24], rf[25], rf[26], rf[27], rf[28], rf[29], rf[30], rf[31]);
        // 输出刚写入的寄存器A3的写数据
        $display("     R[%X] =   %8X", A3, rf[A3]);
    end // end always
    
// $0是零号寄存器，不能修改
    assign RD1 = (A1 == 0) ? 32'd0 : rf[A1];
    assign RD2 = (A2 == 0) ? 32'd0 : rf[A2];
   
endmodule
    
    
