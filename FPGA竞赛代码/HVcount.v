`timescale 1ns / 1ps

module HVcount#(
     parameter DW = 24,
	 parameter IW             = 1920
      )(
    input                      pixelclk,
    input                      reset_n,
    input [DW-1:0] i_data,
    input                      i_hsync,
    input                      i_vsync,
    input                      i_de,
    
    output [11:0]              hcount,
    output [11:0]              vcount,
    output [DW-1:0]o_data,
    output                     o_hsync,
    output                     o_vsync,
    output                     o_de
    );
    
reg [11:0]              hcount_r;
reg [11:0]              vcount_r;
reg [DW-1:0]VGA_RGB_r;
reg                     vid_pVDE_r;
reg                     VGA_HS_r;
reg                     VGA_VS_r;
reg                     VGA_DE_r;
wire                    vid_pVDEneg_flag;


always @(posedge pixelclk) begin
  vid_pVDE_r <= i_de;
  VGA_RGB_r <= i_data;
  VGA_HS_r <= i_hsync;
  VGA_VS_r <= i_vsync;
  VGA_DE_r <= i_de;
end  
  
assign vid_pVDEneg_flag = (!i_de & vid_pVDE_r);

always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n)
    hcount_r <= 12'd0;
  else if(i_de == 1'b1)  
    hcount_r <= hcount_r + 12'd1;
  else 
    hcount_r <= 12'd0;
   
   if(!reset_n) 
     vcount_r <= 12'd0;
   else if(hcount_r == (IW-1))
     vcount_r <= vcount_r + 12'd1;
   else if(i_vsync == 1'b0)
     vcount_r <= 12'd0;

end

 assign  o_data  =  VGA_RGB_r;
 assign  o_hsync =  VGA_HS_r;
 assign  o_vsync =   VGA_VS_r;
 assign  o_de    =   VGA_DE_r;
 assign  hcount  =   hcount_r;
 assign  vcount  =   vcount_r;
 
endmodule
