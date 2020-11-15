
module area_cnt(
     input        pixelclk,
	 input        reset_n,
	 
     input        i_vsync_pos,
	 input        wb,
	 input [11:0] hcount,
	 input [11:0] vcount,
	 input [11:0] hcount_l,
	 input [11:0] hcount_r,
	 input [11:0] vcount_l,
	 input [11:0] vcount_r,
	 output [11:0] area
	 );
reg [11:0] area_r;

assign area = area_r;
	 
always @(posedge pixelclk or negedge reset_n) begin
   if(!reset_n)
     area_r <= 12'd0;
   else if(i_vsync_pos == 1'b1)
      area_r <= 12'd0;
   else if((vcount > vcount_l && vcount < vcount_r && hcount > hcount_l && hcount < hcount_r))
     if(wb == 1'b0)
	   area_r <= area_r +1;
   else
     area_r <= area_r;
end
 
endmodule