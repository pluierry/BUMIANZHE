`timescale 1ns / 1ps

module VP8#(
       parameter IMG_WIDTH_LINE = 1920,
       parameter IMG_WIDTH_DATA = 24
	   )(
       input                          pixelclk,
	   input                          reset_n,    
	   input  [IMG_WIDTH_DATA-1:0]    i_binary,
	   input                          i_hs,
	   input                          i_vs,
	   input                          i_de,       

	   input [11:0]                   i_hcount,
	   input [11:0]                   i_vcount,
	   
	   output    reg        [11:0]    hcount_l1,
       output    reg        [11:0]    hcount_r1,
	   output    reg        [11:0]    hcount_l2,
       output    reg        [11:0]    hcount_r2,
	   output    reg        [11:0]    hcount_l3,
       output    reg        [11:0]    hcount_r3,
	   output    reg        [11:0]    hcount_l4,
       output    reg        [11:0]    hcount_r4,
	   output    reg        [11:0]    hcount_l5,
       output    reg        [11:0]    hcount_r5,
	   output    reg        [11:0]    hcount_l6,
       output    reg        [11:0]    hcount_r6,
	   output    reg        [11:0]    hcount_l7,
       output    reg        [11:0]    hcount_r7,
	   output    reg        [11:0]    hcount_l8,
       output    reg        [11:0]    hcount_r8,
       output    reg        [11:0]    vcount_l,
       output    reg        [11:0]    vcount_r
	   );
		  

parameter INIT    = 2'd0; 
parameter WAIT_WR = 2'd1; 
parameter WR_RAM  = 2'd2; 
parameter RD_RAM  = 2'd3; 
                          reg                  vs_r;
wire                 vsync_fall;
wire                 vsync_rize;
wire                 th_flag;
wire [11:0]          hcount;
wire [11:0]          vcount;

reg [1:0] c_state;
reg [11:0] i;

reg  [11:0] hcount_l1_r;
reg  [11:0] hcount_r1_r;
reg  [11:0] hcount_l2_r;
reg  [11:0] hcount_r2_r;
reg  [11:0] hcount_l3_r;
reg  [11:0] hcount_r3_r;
reg  [11:0] hcount_l4_r;
reg  [11:0] hcount_r4_r;
reg  [11:0] hcount_l5_r;
reg  [11:0] hcount_r5_r;
reg  [11:0] hcount_l6_r;
reg  [11:0] hcount_r6_r;
reg  [11:0] hcount_l7_r;
reg  [11:0] hcount_r7_r;
reg  [11:0] hcount_l8_r;
reg  [11:0] hcount_r8_r;
reg  [11:0] hcount_l9_r;
reg  [11:0] hcount_r9_r;
reg  [11:0] hcount_l10_r;
reg  [11:0] hcount_r10_r;
 
 
reg  [11:0] hcount_l1_rr;
reg  [11:0] hcount_r1_rr;
reg  [11:0] hcount_l2_rr;
reg  [11:0] hcount_r2_rr;
reg  [11:0] hcount_l3_rr;
reg  [11:0] hcount_r3_rr;
reg  [11:0] hcount_l4_rr;
reg  [11:0] hcount_r4_rr;
reg  [11:0] hcount_l5_rr;
reg  [11:0] hcount_r5_rr;
reg  [11:0] hcount_l6_rr;
reg  [11:0] hcount_r6_rr;
reg  [11:0] hcount_l7_rr;
reg  [11:0] hcount_r7_rr;
reg  [11:0] hcount_l8_rr;
reg  [11:0] hcount_r8_rr;
 
reg  [11:0] vcount_l1_r;
reg  [11:0] vcount_r1_r;
  
reg h_we;
reg [11:0] h_waddr;
reg [11:0] h_raddr;
reg  h_di;
wire h_dout;
reg  h_dout_r;
reg  v_we;
reg [11:0] v_waddr;
reg [11:0] v_raddr;
reg  v_di;
wire v_dout;
reg  v_dout_r;
 

reg h_pedge_r;
reg h_nedge_r;
reg v_pedge_r;
reg v_nedge_r;

reg h_pedge_r0;
reg h_nedge_r0;
reg v_pedge_r0;
reg v_nedge_r0;


reg  [3:0] h_pedge_cnt;
reg  [3:0] h_nedge_cnt;
reg  [3:0] v_pedge_cnt;
reg  [3:0] v_nedge_cnt;

wire h_pedge = (h_dout & (!h_dout_r));
wire h_nedge = ((!h_dout) & h_dout_r);
wire v_pedge = (v_dout & (!v_dout_r));
wire v_nedge = ((!v_dout) & v_dout_r);

reg [1:0] frame_cnt;

assign vsync_fall = (!i_vs & (vs_r))?1'b1:1'b0;
assign vsync_rize = (i_vs & (!vs_r))?1'b1:1'b0;

assign th_flag = (i_binary == 24'h000000)?1'b0:1'b1;

assign hcount = i_hcount;
assign vcount = i_vcount;

always @(posedge pixelclk or negedge reset_n) begin
   if(!reset_n)
     frame_cnt <= 0;
   else if(frame_cnt == 2'd3 && vsync_rize == 1'b1)
     frame_cnt <= 0;
   else if(vsync_fall == 1'b1)
     frame_cnt <= frame_cnt + 1;
end

always @(posedge pixelclk or negedge reset_n) begin
   if(!reset_n) begin
	hcount_l1 <= 12'd0;
    hcount_r1 <= 12'd0;
    hcount_l2 <= 12'd0;
    hcount_r2 <= 12'd0;
	hcount_l3 <= 12'd0;
	hcount_r3 <= 12'd0;
	hcount_l4 <= 12'd0;
	hcount_r4 <= 12'd0;
	hcount_l5 <= 12'd0;
	hcount_r5 <= 12'd0;
	hcount_l6 <= 12'd0;
	hcount_r6 <= 12'd0;
	hcount_l7 <= 12'd0;
	hcount_r7 <= 12'd0;
	hcount_l8 <= 12'd0;
	hcount_r8 <= 12'd0;
	vcount_l  <= 12'd0;
	vcount_r  <= 12'd0;
   end
   else if(frame_cnt == 2'd3 && vsync_rize == 1'b1) begin
	hcount_l1 <= hcount_l1_rr;
    hcount_r1 <= hcount_r1_rr;
    hcount_l2 <= hcount_l2_rr;
    hcount_r2 <= hcount_r2_rr;
	hcount_l3 <= hcount_l3_rr;
	hcount_r3 <= hcount_r3_rr;
	hcount_l4 <= hcount_l4_rr;
	hcount_r4 <= hcount_r4_rr;
	hcount_l5 <= hcount_l5_rr;
	hcount_r5 <= hcount_r5_rr;
	hcount_l6 <= hcount_l6_rr;
	hcount_r6 <= hcount_r6_rr;
	hcount_l7 <= hcount_l7_rr;
	hcount_r7 <= hcount_r7_rr;
	hcount_l8 <= hcount_l8_rr;
	hcount_r8 <= hcount_r8_rr;
	vcount_l  <= vcount_l1_r;
	vcount_r  <= vcount_r1_r;
   end
end

//assign       hcount_l1 = hcount_l1_rr;
//assign       hcount_r1 = hcount_r1_rr;
//assign       hcount_l2 = hcount_l2_rr;
//assign       hcount_r2 = hcount_r2_rr;
//assign       hcount_l3 = hcount_l3_rr;
//assign       hcount_r3 = hcount_r3_rr;
//assign       hcount_l4 = hcount_l4_rr;
//assign       hcount_r4 = hcount_r4_rr;
//assign       hcount_l5 = hcount_l5_rr;
//assign       hcount_r5 = hcount_r5_rr;
//assign       hcount_l6 = hcount_l6_rr;
//assign       hcount_r6 = hcount_r6_rr;
//assign       hcount_l7 = hcount_l7_rr;
//assign       hcount_r7 = hcount_r7_rr;
//assign       hcount_l8 = hcount_l8_rr;
//assign       hcount_r8 = hcount_r8_rr;
//
//assign       vcount_l  = vcount_l1_r;
//assign       vcount_r  = vcount_r1_r;

//å·? é„?
always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin
    hcount_l1_rr<=12'b0;
    hcount_r1_rr<=12'b0;
    hcount_l2_rr<=12'b0;
    hcount_r2_rr<=12'b0;
    hcount_l3_rr<=12'b0;
    hcount_r3_rr<=12'b0;
    hcount_l4_rr<=12'b0;
    hcount_r4_rr<=12'b0;
    hcount_l5_rr<=12'b0;
    hcount_r5_rr<=12'b0;
    hcount_l6_rr<=12'b0;
    hcount_r6_rr<=12'b0;
    hcount_l7_rr<=12'b0;
    hcount_r7_rr<=12'b0;
    hcount_l8_rr<=12'b0;
    hcount_r8_rr<=12'b0;
  end
  else if(h_raddr == (IMG_WIDTH_LINE-1) && h_pedge_cnt == 4'd7)begin
    hcount_l1_rr<=hcount_l1_r;
    hcount_r1_rr<=hcount_r1_r;
    hcount_l2_rr<=hcount_l2_r;
    hcount_r2_rr<=hcount_r2_r;
    hcount_l3_rr<=hcount_l3_r;
    hcount_r3_rr<=hcount_r3_r;
    hcount_l4_rr<=hcount_l4_r;
    hcount_r4_rr<=hcount_r4_r;
    hcount_l5_rr<=hcount_l5_r;
    hcount_r5_rr<=hcount_r5_r;
    hcount_l6_rr<=hcount_l6_r;
    hcount_r6_rr<=hcount_r6_r;
    hcount_l7_rr<=hcount_l7_r;
    hcount_r7_rr<=hcount_r7_r;
    hcount_l8_rr<=hcount_l8_r;
    hcount_r8_rr<=hcount_r8_r;
  end
  else if(h_raddr == (IMG_WIDTH_LINE-1)&& h_pedge_cnt == 4'd8)begin
    hcount_l1_rr<=hcount_l1_r;
    hcount_r1_rr<=hcount_r1_r;
    hcount_l2_rr<=hcount_l2_r;
    hcount_r2_rr<=hcount_r2_r;
    hcount_l3_rr<=hcount_l3_r;
    hcount_r3_rr<=hcount_r3_r;
    hcount_l4_rr<=hcount_l4_r;
    hcount_r4_rr<=hcount_r4_r;
    hcount_l5_rr<=hcount_l5_r;
    hcount_r5_rr<=hcount_r5_r;
    hcount_l6_rr<=hcount_l6_r;
    hcount_r6_rr<=hcount_r6_r;
    hcount_l7_rr<=hcount_l7_r;
    hcount_r7_rr<=hcount_r7_r;
    hcount_l8_rr<=hcount_l8_r;
    hcount_r8_rr<=hcount_r8_r;
  end
  else if(h_raddr == (IMG_WIDTH_LINE-1) && h_pedge_cnt == 4'd9)begin
    hcount_l1_rr<=hcount_l1_r;
    hcount_r1_rr<=hcount_r2_r;
    hcount_l2_rr<=hcount_l3_r;
    hcount_r2_rr<=hcount_r3_r;
    hcount_l3_rr<=hcount_l4_r;
    hcount_r3_rr<=hcount_r4_r;
    hcount_l4_rr<=hcount_l5_r;
    hcount_r4_rr<=hcount_r5_r;
    hcount_l5_rr<=hcount_l6_r;
    hcount_r5_rr<=hcount_r6_r;
    hcount_l6_rr<=hcount_l7_r;
    hcount_r6_rr<=hcount_r7_r;
    hcount_l7_rr<=hcount_l8_r;
    hcount_r7_rr<=hcount_r8_r;
    hcount_l8_rr<=hcount_l9_r;
    hcount_r8_rr<=hcount_r9_r;
  end
  else if(h_raddr == (IMG_WIDTH_LINE-1) && h_pedge_cnt == 4'd10)begin
    hcount_l1_rr<=hcount_l1_r;
    hcount_r1_rr<=hcount_r3_r;
    hcount_l2_rr<=hcount_l4_r;
    hcount_r2_rr<=hcount_r4_r;
    hcount_l3_rr<=hcount_l5_r;
    hcount_r3_rr<=hcount_r5_r;
    hcount_l4_rr<=hcount_l6_r;
    hcount_r4_rr<=hcount_r6_r;
    hcount_l5_rr<=hcount_l7_r;
    hcount_r5_rr<=hcount_r7_r;
    hcount_l6_rr<=hcount_l8_r;
    hcount_r6_rr<=hcount_r8_r;
    hcount_l7_rr<=hcount_l9_r;
    hcount_r7_rr<=hcount_r9_r;
    hcount_l8_rr<=hcount_l10_r;
    hcount_r8_rr<=hcount_r10_r;
  end
end

//pipeline
always @(posedge pixelclk ) begin
  vs_r     <= i_vs;

  h_dout_r <= h_dout;
  v_dout_r <= v_dout;
  
  h_pedge_r <= h_pedge;
  h_nedge_r <= h_nedge;
  v_pedge_r <= v_pedge;
  v_nedge_r <= v_nedge;
  
  h_pedge_r0 <= h_pedge_r;
  h_nedge_r0 <= h_nedge_r;
  v_pedge_r0 <= v_pedge_r;
  v_nedge_r0 <= v_nedge_r;
end

//FSM1
always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) 
     c_state <= INIT;
  else case(c_state)
    INIT:begin
	   if(i > (IMG_WIDTH_LINE-1))      // initial ram
		  c_state <= WAIT_WR;
		else 
		  c_state <= INIT;
	 end
	 WAIT_WR:begin
	   if(vsync_rize  == 1'b1)
		  c_state <= WR_RAM;
		else
		  c_state <= WAIT_WR;
	 end
	 WR_RAM:begin
	   if(vsync_fall  == 1'b1) //One Frame Time
		  c_state <= RD_RAM;
		else
		  c_state <= WR_RAM;
	 end
	 RD_RAM:begin
	   if(h_raddr > (IMG_WIDTH_LINE-2))
		  c_state <= INIT;
		else
		  c_state <= RD_RAM;
	 end
  endcase      
end

//FMS2
always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin 
     h_we <= 1'b0;
	 h_waddr <= 12'b0;
	 h_raddr <= 12'b0;
	 h_di <= 0;
	 v_we <= 1'b0;
	 v_waddr <= 12'b0;
	 v_raddr <= 12'b0;
	 v_di <= 0;
	 i <= 12'd0;

     h_pedge_cnt<=4'b0;
     h_nedge_cnt<=4'b0;
     v_pedge_cnt<=4'b0;
     v_nedge_cnt<=4'b0;
	 
	 hcount_l1_r<= 12'b0;
     hcount_r1_r<= 12'b0;
	 hcount_l2_r<= 12'b0;
     hcount_r2_r<= 12'b0;
	 hcount_l3_r<= 12'b0;
     hcount_r3_r<= 12'b0;
	 hcount_l4_r<= 12'b0;
	 hcount_r4_r<= 12'b0;
	 hcount_l5_r<= 12'b0;
	 hcount_r5_r<= 12'b0;
	 hcount_l6_r<= 12'b0;
	 hcount_r6_r<= 12'b0;
	 hcount_l7_r<= 12'b0;
	 hcount_r7_r<= 12'b0;
	 hcount_l8_r<= 12'b0;
	 hcount_r8_r<= 12'b0;
	 hcount_l9_r<= 12'b0;
	 hcount_r9_r<= 12'b0;
	 hcount_l10_r<= 12'b0;
	 hcount_r10_r<= 12'b0;
	 
     vcount_l1_r<= 12'b0;
     vcount_r1_r<= 12'b0;
  end	 
  else case(c_state)
    INIT: begin
		h_raddr <= 0;
	    v_raddr <= 0;
		h_pedge_cnt <= 4'b0;
		h_nedge_cnt <= 4'b0;
		v_pedge_cnt <= 4'b0;
		v_nedge_cnt <= 4'b0;
	   if(i > (IMG_WIDTH_LINE-1)) begin
		  i<=i;
		  h_we <= 0;
		  h_waddr <= 0;
		  h_di <= 0;
		  v_we <= 0;
		  v_waddr <= 0;
		  v_di <= 0;
		end  
		else begin
		  i <= i +1;
		  h_we <= 1;
		  h_waddr <= h_waddr +1;
		  h_di <= 0;
		  v_we <= 1;
		  v_waddr <= v_waddr +1;
		  v_di <= 0;
		end
	 end
    WR_RAM:begin
	   if((hcount > 1)&& (vcount > 1)&& (!th_flag)) begin
		  h_we <= 1;
		  h_waddr <= hcount;
		  h_di <= 1;
		  v_we <= 1;
		  v_waddr <= vcount;
		  v_di <= 1;
		end
		else begin
		  h_we <= 0;
		  h_waddr <= 0;
		  h_di <= 0;
		  v_we <= 0;
		  v_waddr <= 0;
		  v_di <= 0;
		end
	 end
	 RD_RAM:begin
	  if(h_raddr < (IMG_WIDTH_LINE-1)) begin 
	     i <= 0;
	     h_raddr <= h_raddr + 1;
		 v_raddr <= v_raddr + 1;
		  
	    if(h_pedge) h_pedge_cnt <= h_pedge_cnt +1;
	    if(h_pedge_r0 && h_pedge_cnt == 1) hcount_l1_r <= (h_raddr-2);
	    if(h_pedge_r0 && h_pedge_cnt == 2) hcount_l2_r <= (h_raddr-2);
	    if(h_pedge_r0 && h_pedge_cnt == 3) hcount_l3_r <= (h_raddr-2);
	    if(h_pedge_r0 && h_pedge_cnt == 4) hcount_l4_r <= (h_raddr-2);
	    if(h_pedge_r0 && h_pedge_cnt == 5) hcount_l5_r <= (h_raddr-2);
	    if(h_pedge_r0 && h_pedge_cnt == 6) hcount_l6_r <= (h_raddr-2);
	    if(h_pedge_r0 && h_pedge_cnt == 7) hcount_l7_r <= (h_raddr-2);
		if(h_pedge_r0 && h_pedge_cnt == 8) hcount_l8_r <= (h_raddr-2);
		if(h_pedge_r0 && h_pedge_cnt == 9) hcount_l9_r <= (h_raddr-2);
		if(h_pedge_r0 && h_pedge_cnt == 10) hcount_l10_r <= (h_raddr-2);
	  
	    if(h_nedge) h_nedge_cnt <= h_nedge_cnt +1;
	    if(h_nedge_r0 && h_nedge_cnt == 1) hcount_r1_r <= (h_raddr-3);
	    if(h_nedge_r0 && h_nedge_cnt == 2) hcount_r2_r <= (h_raddr-3);
	    if(h_nedge_r0 && h_nedge_cnt == 3) hcount_r3_r <= (h_raddr-3);
		if(h_nedge_r0 && h_nedge_cnt == 4) hcount_r4_r <= (h_raddr-3);
	    if(h_nedge_r0 && h_nedge_cnt == 5) hcount_r5_r <= (h_raddr-3);
	    if(h_nedge_r0 && h_nedge_cnt == 6) hcount_r6_r <= (h_raddr-3);
	    if(h_nedge_r0 && h_nedge_cnt == 7) hcount_r7_r <= (h_raddr-3);
		if(h_nedge_r0 && h_nedge_cnt == 8) hcount_r8_r <= (h_raddr-3);
	    if(h_nedge_r0 && h_nedge_cnt == 9) hcount_r9_r <= (h_raddr-3);
		if(h_nedge_r0 && h_nedge_cnt == 10) hcount_r10_r <= (h_raddr-3);
		 
		if(v_pedge) v_pedge_cnt <= v_pedge_cnt +1;
	    if(v_pedge_r0 && v_pedge_cnt == 1) vcount_l1_r <= (v_raddr-2);
	  
	    if(v_nedge) v_nedge_cnt <= v_nedge_cnt +1;
	    if(v_nedge_r0 && v_nedge_cnt == 1) vcount_r1_r <= (v_raddr-3);
	  end
	  else begin
	     h_pedge_cnt <= h_pedge_cnt;
		 h_nedge_cnt <= h_nedge_cnt;
		  
		 v_pedge_cnt <= v_pedge_cnt;
		 v_nedge_cnt <= v_nedge_cnt;
		  
		 h_raddr <= h_raddr;
	     v_raddr <= v_raddr;
	  end
	 end
  endcase
end

ram #(
       .IMG_WIDTH_LINE(IMG_WIDTH_LINE)
      )h_ram_inst(
	 .clka(pixelclk),
	 .rst_n(reset_n),
	
	 .wea(h_we),
     .addra(h_waddr),
     .addrb(h_raddr),
     .dina(h_di),
     .doutb(h_dout)
	);
	
ram #(
      .IMG_WIDTH_LINE(IMG_WIDTH_LINE)
      )v_ram_inst(
	 .clka(pixelclk),
	 .rst_n(reset_n),
	
	 .wea(v_we),
     .addra(v_waddr),
     .addrb(v_raddr),
     .dina(v_di),
     .doutb(v_dout)
	);

/*		 
ram #(
       .IMG_WIDTH_LINE(IMG_WIDTH_LINE)
      )h_ram_inst(
	 .clk(pixelclk),
	 .rst_n(reset_n),
	
	 .we(h_we),
    .waddr(h_waddr),
    .raddr(h_raddr),
    .di(h_di),
    .dout(h_dout)
	);
	
ram #(
      .IMG_WIDTH_LINE(IMG_WIDTH_LINE)
      )v_ram_inst(
	 .clk(pixelclk),
	 .rst_n(reset_n),
	
	 .we(v_we),
    .waddr(v_waddr),
    .raddr(v_raddr),
    .di(v_di),
    .dout(v_dout)
	);
*/
endmodule 
/*
module ram #(
    parameter IMG_WIDTH_LINE = 1920
    )(
	input        clk,
	input        rst_n,
	
	input        we,
    input [11:0] waddr,
    input [11:0] raddr,
    input  [0:0] di,
    output [0:0] dout
	);

reg [0:0] mem [0:IMG_WIDTH_LINE-1]; //800
reg [0:0] rdata;
assign dout = rdata;

always @ (posedge clk or negedge rst_n)
   if (1'b0 == rst_n) begin
       rdata <= 0;
       end
   else begin
       if (we) mem[waddr] <= di;
       rdata <= mem[raddr];
       end	

endmodule 
*/