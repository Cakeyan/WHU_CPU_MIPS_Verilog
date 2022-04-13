module dm(
    input [31:0] addr,
    input [31:0] din,
    input DMWr,
    input clk,
    input rst,
    output [31:0] dout
    );
	 
reg [31:0] DMem[1023:0];
integer i;
initial begin
        for (i=0; i<1024; i=i+1)
            DMem[i] = 0;
end
always@(posedge clk)
	begin
		if(DMWr) DMem[addr[11:2]] <= din;
		$display("      addr = %8X",addr);
       	$display("       din = %8X",din);
       	$display("Mem[00-07] = %8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X",DMem[0],DMem[1],DMem[2],DMem[3],DMem[4],DMem[5],DMem[6],DMem[7]);
	end	
	
assign dout = DMem[addr[11:2]];

endmodule