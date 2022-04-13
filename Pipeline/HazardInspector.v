module HazardInspector(
                       input rst,
                       input Branch,
                       input Jump,
                       input[4:0] rsAddr_id,
                       input[4:0] rtAddr_id,
                       input[4:0] rtAddr_ex,
                       input MEM_MemRead_ex,
                       input [4:0]RegWriteAddr_ex,
                       output reg stall,
                       output reg flush);
    
    // rst
    always @(posedge rst)
        begin
            stall <= 0;
            flush <= 0;
        end

    always @(*)
        begin
            // flush
            if (Branch||Jump) 
                flush <= 1;
            // stall
            else if (MEM_MemRead_ex&&(RegWriteAddr_ex != 0)&&((rtAddr_ex == rsAddr_id)||(rtAddr_ex == rtAddr_id)))
                begin
                    stall <= 1;
                    flush <= 0;
                end
            // normal
            else
                begin
                    stall <= 0;
                    flush <= 0;
                end
    
        end

    // display
    always @(*)
        begin
            if (stall == 1) $display("     stall = %X",stall);
            if (flush == 1) $display("     flush = %X",flush);
        end
endmodule
