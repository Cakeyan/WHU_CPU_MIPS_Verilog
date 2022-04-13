module Forwarding(
                  input RegWrite_mem,
                  input RegWrite_wb,
                  input RegWrite_ex,
                  input[4:0] RegWriteAddr_mem,
                  input[4:0] RegWriteAddr_wb,
                  input[4:0] RegWriteAddr_ex,
                  input[4:0] rsAddr_ex,
                  input[4:0] rtAddr_ex,
                  input[4:0] rsAddr_id,
                  input[4:0] rtAddr_id,
                  output reg[1:0] ForwardA,
                  output reg[1:0] ForwardB,
                  output reg[1:0] ForwardC,
                  output reg[1:0] ForwardD);
    

    always @(*)
        begin
            if (RegWrite_mem&&(RegWriteAddr_mem!= 0)&&(RegWriteAddr_mem == rsAddr_ex)) // EX旁路
                ForwardA = 2'b10;
            else if (RegWrite_wb&&(RegWriteAddr_wb!= 0)&&(RegWriteAddr_wb == rsAddr_ex)) // MEM旁路
                ForwardA = 2'b01;
            else
                ForwardA = 2'b00;
                if (RegWrite_mem&&(RegWriteAddr_mem!= 0)&&(RegWriteAddr_mem == rtAddr_ex)) // EX旁路
                    ForwardB = 2'b10;
                else if (RegWrite_wb&&(RegWriteAddr_wb!= 0)&&(RegWriteAddr_wb == rtAddr_ex)) // MEM旁路
                    ForwardB = 2'b01;
                else
                    ForwardB = 2'b00;
            
            // ID-Branch
            if (RegWrite_ex&&(RegWriteAddr_ex!= 0)&&(RegWriteAddr_ex == rsAddr_id))
                ForwardC = 2'b10;
            else if (RegWrite_wb&&(RegWriteAddr_wb!= 0)&&(RegWriteAddr_wb == rsAddr_id))
                ForwardC = 2'b01;
            else
                ForwardC = 2'b00;
            if (RegWrite_ex&&(RegWriteAddr_ex!= 0)&&(RegWriteAddr_ex == rtAddr_id))
                ForwardD = 2'b10;
            else if (RegWrite_wb&&(RegWriteAddr_wb!= 0)&&(RegWriteAddr_wb == rtAddr_id))
                ForwardD = 2'b01;
            else
                ForwardD = 2'b00;
        end
endmodule
