
module rgb2#(
     parameter DW 				= 24
      )(
    input                      	pixelclk,
    input                      	reset_n,
    input [DW-1:0] 			   	din,	
    input                      	i_hsync,
    input                      	i_vsync,
    input                      	i_de,
    

    output [DW-1:0]				dout,	
    output                     	o_hsync,
    output                     	o_vsync,
    output                     	o_de
    );
	
wire [7:0] r,g,b;
reg [7:0] rr,gg,bb;

 
reg         hsync_r1;
reg         vsync_r1;
reg         de_r1;

reg         hsync_r2;
reg         vsync_r2;
reg         de_r2;

assign r = din[23:16];
assign g = din[15:8];
assign b = din[7:0];

assign o_hsync = hsync_r2;
assign o_vsync = vsync_r2;
assign o_de = de_r2;

assign dout = {rr,gg,bb};

reg  [7:0] rg;
reg  [7:0] rb;
reg  [7:0] gr;
reg  [7:0] gb;
reg  [7:0] br;
reg  [7:0] bg;

always @(posedge pixelclk) begin
  rg<=(r>g)?r-g:8'b0;
  rb<=(r>b)?r-b:8'b0; 
  gr<=(g>r)?g-r:8'b0; 
  gb<=(g>b)?g-b:8'b0; 
  br<=(b>r)?b-r:8'b0; 
  bg<=(b>g)?b-g:8'b0; 
end

wire  [8:0] rgrb=rg+rb;
wire  [8:0] gbgr=gb+gr;
wire  [8:0] brbg=br+bg;



always @(posedge pixelclk) begin
  hsync_r1 <= i_hsync;
  vsync_r1 <= i_vsync;
  de_r1 <= i_de;
  
  hsync_r2 <= hsync_r1;
  vsync_r2 <= vsync_r1;
  de_r2 <= de_r1;
end 

always @(posedge pixelclk or negedge reset_n)begin
  if(reset_n == 1'b0)begin
    rr<=8'b0;
	gg<=8'b0;
	bb<=8'b0;
  end	
  else begin
    rr <= (rgrb>9'hff)?8'hff:rgrb[7:0];
	gg <= (gbgr>9'hff)?8'hff:gbgr[7:0];
	bb <= (brbg>9'hff)?8'hff:brbg[7:0];
  end
end

endmodule