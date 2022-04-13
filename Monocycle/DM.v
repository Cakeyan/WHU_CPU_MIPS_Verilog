module dm_4k(
    input [11:2] addr,
    input [31:0] din,
    input DMWr,
    input clk,
    output [31:0] dout);

// 寄存器定义
    reg [31:0] dmem[1023:0];
    
// 初始化
    integer i;
    initial begin
            for (i=0; i<1024; i=i+1)
                dmem[i] = 0;
    end

// 时钟：
    always @(posedge clk) 
    begin
        if (DMWr) dmem[addr] <= din;
        $display("      addr =   %8X",addr);//addr to DM
        $display("       din =   %8X",din);//data to DM
        $display("Mem[00-07] =   %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X",dmem[0],dmem[1],dmem[2],dmem[3],dmem[4],dmem[5],dmem[6],dmem[7]);    
    end // end always
            
    assign dout = dmem[addr];
endmodule
