module rf(
           input clk,
           input rst,
           input [4:0] A1,
           input [4:0] A2,
           input [4:0] A3,
           input [31:0] WD,
           input RFWr,
           output [31:0] RD1,
           output [31:0] RD2);
    
    reg [31:0] RF[31:0];
    integer  i;
    
    always @(posedge clk or posedge rst) 
    begin
        if (rst)
            for(i = 0; i < 32; i = i+1)
                RF[i] = 0;

        else if (RFWr)
            begin
                RF[A3]               = (A3 == 0)?0:WD;
                $display("  R[00-07] = %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", 0, RF[1], RF[2], RF[3], RF[4], RF[5], RF[6], RF[7]);
                $display("  R[08-15] = %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", RF[8], RF[9], RF[10], RF[11], RF[12], RF[13], RF[14], RF[15]);
                $display("  R[16-23] = %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", RF[16], RF[17], RF[18], RF[19], RF[20], RF[21], RF[22], RF[23]);
                $display("  R[24-31] = %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", RF[24], RF[25], RF[26], RF[27], RF[28], RF[29], RF[30], RF[31]);
                $display("     R[%X] = %8X", A3, RF[A3]);
            end
    end
    
    assign RD1 = (A1 == 0) ? 0: RF[A1];
    assign RD2 = (A2 == 0) ? 0: RF[A2];
    
endmodule
