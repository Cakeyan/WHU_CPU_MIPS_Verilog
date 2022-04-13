module if_id(
             input clk,
             input rst,
             input flush,
             input stall,
             input[31:0] PC_if,
             input[31:0] Instr_if,
             output reg[31:0] PC_id,
             output reg[31:0] Instr_id);
    
    
    
    always @ (posedge clk,posedge rst)
    begin
        if (rst||flush)
            begin
                PC_id   <= 0;
                Instr_id <= 0;
            end

        else if (stall == 0)
            begin
                PC_id   <= PC_if;
                Instr_id <= Instr_if;
            end
    end
endmodule
