
`timescale 1ns / 1ps

module lpr_recognition(
       input                          pixelclk,
	   input                          reset_n,    
	   input  [23:0]                  i_binary,
	   input                          i_hs,
	   input                          i_vs,
	   input                          i_de,        

	   input [11:0]                   i_hcount,
	   input [11:0]                   i_vcount,
	      
	   input            [11:0]       hcount_l1,
       input            [11:0]       hcount_r1,
	   input            [11:0]       hcount_l2,
       input            [11:0]       hcount_r2,
	   input            [11:0]       hcount_l3,
       input            [11:0]       hcount_r3,
	   input            [11:0]       hcount_l4,
       input            [11:0]       hcount_r4,
	   input            [11:0]       hcount_l5,
       input            [11:0]       hcount_r5,
	   input            [11:0]       hcount_l6,
       input            [11:0]       hcount_r6,
	   input            [11:0]       hcount_l7,
       input            [11:0]       hcount_r7,
	   input            [11:0]       hcount_l8,
       input            [11:0]       hcount_r8,
       input            [11:0]       vcount_l,
       input            [11:0]       vcount_r,
	   
	   output   reg    [1:0]         frame_cnt,     
	   
	   output   reg      [39:0]         char1,
	   output   reg      [39:0]         char2,
	   output   reg      [39:0]         char3,
	   output   reg      [39:0]         char4,
	   output   reg      [39:0]         char5,
	   output   reg      [39:0]         char6,
	   output   reg      [39:0]         char7,
	   output   reg      [39:0]         char8
	   
       
	   
	   );
	   
wire         [39:0]         char1_r;
wire         [39:0]         char2_r;

//reg [1:0] frame_cnt;
reg vs_r;

wire i_vsync_neg;
wire i_vsync_pos;

assign i_vsync_neg = (!i_vs & vs_r);
assign i_vsync_pos = (i_vs & !vs_r);
always @(posedge pixelclk) begin
  vs_r <= i_vs;
end

always @(posedge pixelclk or negedge reset_n) begin
   if(!reset_n)
     frame_cnt <= 0;
   else if(i_vsync_neg)
     frame_cnt <= frame_cnt + 1;
end

	 
reg            [11:0]       hcount_l1_r;
reg            [11:0]       hcount_r1_r;
reg            [11:0]       hcount_l2_r;
reg            [11:0]       hcount_r2_r;

always @(posedge pixelclk or negedge reset_n) begin
   if(!reset_n) begin
     hcount_l1_r <= 12'd0;
     hcount_r1_r <= 12'd0;
     hcount_l2_r <= 12'd0;
     hcount_r2_r <= 12'd0;
	 char1 <= 40'h0;
     char2 <= 40'h0;
     char3 <= 40'h0;
     char4 <= 40'h0;
     char5 <= 40'h0;
     char6 <= 40'h0;
     char7 <= 40'h0;
     char8 <= 40'h0;
   end
   else if(frame_cnt == 2'd0 && i_vsync_pos) begin
     hcount_l1_r <= hcount_l1;
     hcount_r1_r <= hcount_r1;
     hcount_l2_r <= hcount_l2;
     hcount_r2_r <= hcount_r2;
     char7 <= char1_r;
     char8 <= char2_r;	
   end
   else if(frame_cnt == 2'd1 && i_vsync_pos) begin
     hcount_l1_r <= hcount_l3;
     hcount_r1_r <= hcount_r3;
     hcount_l2_r <= hcount_l4;
     hcount_r2_r <= hcount_r4;
     char1 <= char1_r;
     char2 <= char2_r; 
   end
   else if(frame_cnt == 2'd2 && i_vsync_pos) begin
     hcount_l1_r <= hcount_l5;
     hcount_r1_r <= hcount_r5;
     hcount_l2_r <= hcount_l6;
     hcount_r2_r <= hcount_r6;
     char3 <= char1_r;
     char4 <= char2_r;	 
   end
   else if(frame_cnt == 2'd3 && i_vsync_pos) begin
     hcount_l1_r <= hcount_l7;
     hcount_r1_r <= hcount_r7;
     hcount_l2_r <= hcount_l8;
     hcount_r2_r <= hcount_r8;
     char5 <= char1_r;
     char6 <= char2_r;	 
   end
end

wire ds1_o_hsync;
wire ds1_o_vsync;
wire ds1_o_de;
wire [23:0] ds1_dout;


capture_single U_capture_single1(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
       
  	   .i_rgb(i_binary),
	   .i_hsync(i_hs),
	   .i_vsync(i_vs),
	   .i_de(i_de),
	   
	   .hcount(i_hcount),
       .vcount(i_vcount),
	   
	   .hcount_l(hcount_l1_r),
       .hcount_r(hcount_r1_r),
       .vcount_l(vcount_l),
       .vcount_r(vcount_r),
	   
       .o_rgb(ds1_dout),
	   .o_hsync(ds1_o_hsync),
	   .o_vsync(ds1_o_vsync),                                                                                                  
	   .o_de(ds1_o_de)                                                                                               
	   );

character_recognition U_character_recognition1(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),

  	   .i_rgb(ds1_dout),
	   .i_hsync(ds1_o_hsync),
	   .i_vsync(ds1_o_vsync),
	   .i_de(ds1_o_de),
	   
	   .hcount(i_hcount),
       .vcount(i_vcount),
	   
	   .hcount_l(hcount_l1_r),
       .hcount_r(hcount_r1_r),
       .vcount_l(vcount_l),
       .vcount_r(vcount_r),
       .char(char1_r) 	   
	   );
	   
wire ds2_o_hsync;
wire ds2_o_vsync;
wire ds2_o_de;
wire [23:0] ds2_dout;	

capture_single U_capture_single2(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
       
  	   .i_rgb(i_binary),
	   .i_hsync(i_hs),
	   .i_vsync(i_vs),
	   .i_de(i_de),
	   
	   .hcount(i_hcount),
       .vcount(i_vcount),
	   
	   .hcount_l(hcount_l2_r),
       .hcount_r(hcount_r2_r),
       .vcount_l(vcount_l),
       .vcount_r(vcount_r),
	   
       .o_rgb(ds2_dout),
	   .o_hsync(ds2_o_hsync),
	   .o_vsync(ds2_o_vsync),                                                                                                  
	   .o_de(ds2_o_de)                                                                                               
	   );
   

 
character_recognition U_character_recognition2(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),

  	   .i_rgb(ds2_dout),
	   .i_hsync(ds2_o_hsync),
	   .i_vsync(ds2_o_vsync),
	   .i_de(ds2_o_de),
	   
	   .hcount(i_hcount),
       .vcount(i_vcount),
	   
	   .hcount_l(hcount_l2_r),
       .hcount_r(hcount_r2_r),
       .vcount_l(vcount_l),
       .vcount_r(vcount_r),
       .char(char2_r)	   
	   );


endmodule