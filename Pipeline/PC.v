module pc(
          input [31:0] NPC,
          input clk,
          input rst,
          input stall,
          output [31:0] PC);
    
    reg [31:0] temp;
    
    always@(posedge clk or posedge rst)
    begin
        if (rst) temp <= 32'h00003000;
        else if (stall == 0)
            temp <= NPC;
    end
    
    assign PC = temp;
    
endmodule
