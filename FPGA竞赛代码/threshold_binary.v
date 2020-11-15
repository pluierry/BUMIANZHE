

`timescale 1ns/1ps
module	threshold_binary#(
        parameter IMG_WIDTH_DATA = 24,
		parameter IMG_WIDTH_Y    = 8
        )(
        input						     pixel_clk,
        input                            reset_n,
     
		input                            th_mode,
		
		input  [IMG_WIDTH_Y-1:0]         th1,    
		
		input  [IMG_WIDTH_Y-1:0]         th2,    
        input [IMG_WIDTH_DATA-1:0]       i_gray,
        input                            i_h_sync,
        input                            i_v_sync,
        input                            i_de,
		
        output[IMG_WIDTH_DATA-1:0]       inv_binary,
        output[IMG_WIDTH_DATA-1:0]       o_binary,
        output                           o_h_sync,
        output                           o_v_sync,                                                                                                  
        output                           o_de                                                                                                
	    );
		 
wire [IMG_WIDTH_Y-1:0]	y;//Ycbcr --y
reg  [IMG_WIDTH_Y-1:0]  binary_r;
reg                     h_sync_r;
reg                     v_sync_r;
reg                     de_r;
reg                     h_sync_r1;
reg                     v_sync_r1;
reg                     de_r1;

assign y = i_gray[23:16]; 


always @(pixel_clk)begin
  h_sync_r<= i_h_sync;
  v_sync_r<= i_v_sync;
  de_r    <= i_de;
  
  h_sync_r1<= h_sync_r;
  v_sync_r1<= v_sync_r;
  de_r1 <= de_r;
end	

always @(posedge pixel_clk or negedge reset_n) begin
  if(!reset_n)
    binary_r <= 8'h00;
  else if(th_mode == 1'b0) begin 
    if(y <= th1) 
      binary_r <= 8'h00;
	else 
      binary_r <= 8'hFF;
  end
  else if(th_mode == 1'b1) begin
    if(y > th1 && y <= th2) 
      binary_r <= 8'hFF;
	else 
      binary_r <= 8'h00;
  end  
end 

assign o_binary = {binary_r,binary_r,binary_r};  
assign inv_binary = ~o_binary;

assign o_h_sync = h_sync_r1;
assign o_v_sync = v_sync_r1;
assign o_de     = de_r1;
						
endmodule 