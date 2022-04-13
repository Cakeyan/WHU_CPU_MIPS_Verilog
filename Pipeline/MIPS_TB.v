 module mips_tb();
    
   reg clk, rst;
    
   mips U_MIPS(
      .clk(clk), .rst(rst)
   );
    
    initial begin
        $readmemh("Test_Instr.txt" , U_MIPS.IM.IMem) ;
        //$readmemh("D:/Cakeyan/CPU/mycode/pipeline/verilog/Test_Instr.txt" , U_MIPS.IM.IMem) ;
        $monitor("        PC = 0x%8X\n        IR = 0x%8X", U_MIPS.PC_.PC, U_MIPS.IM.Out);
        
        clk = 1 ;
        rst = 0 ;
        #5 ;
        rst = 1 ;
        #20 ;
        rst = 0 ;
    end

    always
    #(50) clk = ~clk;
endmodule
