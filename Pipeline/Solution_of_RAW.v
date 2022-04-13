// for lw
module Solution_of_RAW(
                       input [4:0]rsAddr_id,
                       input [4:0]rtAddr_id,
                       input [4:0]RegWriteAddr_wb,
                       input RegWrite_wb,
                       output reg rs_selection,
                       output reg rt_selection);

    always@(*)
    begin
        if (RegWrite_wb && (RegWriteAddr_wb != 0) && (RegWriteAddr_wb == rsAddr_id))
            rs_selection <= 1;
        else
            rs_selection = 0;
        
        if (RegWrite_wb && (RegWriteAddr_wb != 0) && (RegWriteAddr_wb == rtAddr_id))
            rt_selection <= 1;
        else
            rt_selection <= 0;
    end

endmodule
