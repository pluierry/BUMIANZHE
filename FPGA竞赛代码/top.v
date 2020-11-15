
`define DATA_WIDTH 8
`define PICTURE_LENGTH 800
module top(
input                            sys_clk,               
input                            rst_n,                 
inout                            cmos_scl,              
inout                            cmos_sda,              
input                            cmos_vsync,            
input                            cmos_href,             
input                            cmos_pclk,             
output                           cmos_xclk,             
input   [7:0]                    cmos_db,               
output                           lcd_dclk,	
output                           lcd_hs,                
output                           lcd_vs,                
output                           lcd_de,                
output[7:0]                      lcd_r,                 
output[7:0]                      lcd_g,                 
output[7:0]                      lcd_b,	                
output                           lcd_pwm,               
output                         	 Rs232_Tx, 
inout [31:0]                     ddr3_dq,               
inout [3:0]                      ddr3_dqs_n,            
inout [3:0]                      ddr3_dqs_p,            
output [14:0]                    ddr3_addr,             
output [2:0]                     ddr3_ba,               
output                           ddr3_ras_n,            
output                           ddr3_cas_n,            
output                           ddr3_we_n,             
output                           ddr3_reset_n,          
output [0:0]                     ddr3_ck_p,             
output [0:0]                     ddr3_ck_n,             
output [0:0]                     ddr3_cke,              
output [0:0]                     ddr3_cs_n,             
output [3:0]                     ddr3_dm,               
output [0:0]                     ddr3_odt               
); 
parameter MEM_DATA_BITS          = 64;                  
parameter ADDR_BITS              = 25;                  
parameter BUSRT_BITS             = 10;                  
wire                             wr_burst_data_req;     
wire                             wr_burst_finish;       
wire                             rd_burst_finish;       
wire                             rd_burst_req;          
wire                             wr_burst_req;          
wire[BUSRT_BITS - 1:0]           rd_burst_len;          
wire[BUSRT_BITS - 1:0]           wr_burst_len;          
wire[ADDR_BITS - 1:0]            rd_burst_addr;         
wire[ADDR_BITS - 1:0]            wr_burst_addr;         
wire                             rd_burst_data_valid;   
wire[MEM_DATA_BITS - 1 : 0]      rd_burst_data;         
wire[MEM_DATA_BITS - 1 : 0]      wr_burst_data;         
wire                             read_req;              
wire                             read_req_ack;          
wire                             read_en;               
wire[63:0]                       read_data;             
wire                             write_en;              
wire[63:0]                       write_data;            
wire                             write_req;             
wire                             write_req_ack;         

wire                             video_clk;             
wire                             hs;                    
wire                             vs;                    
wire                             de;                    
wire[15:0]                       vout_data;             

wire[15:0]                      cmos_16bit_data;        
wire                            cmos_16bit_wr;          
wire[1:0]                       write_addr_index;       
wire[1:0]                       read_addr_index;        
wire[9:0]                       lut_index;              
wire[31:0]                      lut_data;               

wire                            ui_clk;                 
wire                            ui_clk_sync_rst;        
wire                            init_calib_complete;    

wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;    
wire [2:0]                      s00_axi_awsize;   
wire [1:0]                      s00_axi_awburst;  
wire                            s00_axi_awlock;   
wire [3:0]                      s00_axi_awcache;  
wire [2:0]                      s00_axi_awprot;   
wire [3:0]                      s00_axi_awqos;    
wire [0:0]                      s00_axi_awuser;   
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
wire [63:0]                     s00_axi_wdata;
wire [7:0]                      s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
wire [3:0]                      s00_axi_rid;
wire [63:0]                     s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;
wire                            clk_200Mhz;


assign lcd_dclk = ~video_clk;

assign write_en = cmos_16bit_wr;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};

sys_pll sys_pll_m0
(
.clk_in1                        (sys_clk                  ),
.clk_out1                       (cmos_xclk                ),
.clk_out2                       (clk_200Mhz               ),
.reset                          (1'b0                     ),
.locked                         (                         )
);

video_pll video_pll_m0
(
.clk_in1                        (sys_clk                  ),
.clk_out1                       (video_clk                ),
.reset                          (1'b0                     ),
.locked                         (                         )
);

ax_pwm#(.N(22)) ax_pwm_m0(
.clk                            (sys_clk                  ),
.rst                            (~rst_n                   ),
.period                         (22'd17                   ),
.duty                           (22'd1258291              ),
.pwm_out                        (lcd_pwm                  )
);	

i2c_config i2c_config_m0
(
.rst                            (~rst_n                   ),
.clk                            (sys_clk                  ),
.clk_div_cnt                    (16'd99                   ),
.i2c_addr_2byte                 (1'b1                     ),
.lut_index                      (lut_index                ),
.lut_dev_addr                   (lut_data[31:24]          ),
.lut_reg_addr                   (lut_data[23:8]           ),
.lut_reg_data                   (lut_data[7:0]            ),
.error                          (                         ),
.done                           (                         ),
.i2c_scl                        (cmos_scl                 ),
.i2c_sda                        (cmos_sda                 )
);

lut_ov5640_rgb565_800_480 lut_ov5640_rgb565_800_480_m0
(
.lut_index                      (lut_index                ),
.lut_data                       (lut_data                 )
);

cmos_8_16bit cmos_8_16bit_m0
(
.rst                            (~rst_n                   ),
.pclk                           (cmos_pclk                ),
.pdata_i                        (cmos_db                  ),
.de_i                           (cmos_href                ),
.pdata_o                        (cmos_16bit_data          ),
.hblank                         (                         ),
.de_o                           (cmos_16bit_wr            )
);

cmos_write_req_gen cmos_write_req_gen_m0
(
.rst                            (~rst_n                   ),
.pclk                           (cmos_pclk                ),
.cmos_vsync                     (cmos_vsync               ),
.write_req                      (write_req                ),
.write_addr_index               (write_addr_index         ),
.read_addr_index                (read_addr_index          ),
.write_req_ack                  (write_req_ack            )
);

video_timing_data video_timing_data_m0
(
.video_clk                      (video_clk                ),
.rst                            (~rst_n                   ),
.read_req                       (read_req                 ),
.read_req_ack                   (read_req_ack             ),
.read_en                        (read_en                  ),
.read_data                      (read_data                ),
.hs                             (hs                       ),
.vs                             (vs                       ),
.de                             (de                       ),
.vout_data                      (vout_data                )
);




wire [`DATA_WIDTH*3-1:0] rgb2;
wire r_hsync;
wire r_vsync;
wire r_de;
	
rgb2#(
     .DW(`DATA_WIDTH*3)
      ) Urgb2(
    .pixelclk(video_clk),
    .reset_n(rst_n),
    .din({{vout_data[15:11],3'd0},{vout_data[10:5],2'd0},{vout_data[4:0],3'd0}}),	//rgb in
    .i_hsync(hs),
    .i_vsync(vs),
    .i_de(de),
    
    .dout(rgb2),	//gray out
    .o_hsync(r_hsync),
    .o_vsync(r_vsync),
    .o_de(r_de)
    );
	
wire [`DATA_WIDTH*3-1:0] th_binary;
wire [`DATA_WIDTH*3-1:0] inv_binary;
wire th_hsync;
wire th_vsync;
wire th_de;	
	
threshold_binary#(
        .IMG_WIDTH_DATA(`DATA_WIDTH*3),
		.IMG_WIDTH_Y(`DATA_WIDTH)
        )U_threshold_binary(
        .pixel_clk(video_clk),
        .reset_n(rst_n),
        
		.th_mode(0),//0--global threshold  1--Contour threshold
		.th1(85),    //0-255
        
		.th2(),    //0-255
        .i_gray({rgb2[7:0],rgb2[7:0],rgb2[7:0]}),
        .i_h_sync(r_hsync),
        .i_v_sync(r_vsync),
        .i_de(r_de),
        
		.inv_binary(inv_binary),
        .o_binary(th_binary),
        .o_h_sync(th_hsync),
        .o_v_sync(th_vsync),                                                                                                  
        .o_de(th_de)                                                                                                
	    );
	
  
wire [11:0] hcount;
wire [11:0] vcount;

wire HV_o_hsync;
wire HV_o_vsync;
wire HV_o_de;
wire [`DATA_WIDTH*3-1:0] HV_dout;
	
HVcount#(
     .DW(`DATA_WIDTH*3),
	 .IW(`PICTURE_LENGTH)
      )U_HVcount(
    .pixelclk(video_clk),
    .reset_n(rst_n),
    .i_data(inv_binary),
    .i_hsync(th_hsync),
    .i_vsync(th_vsync),
    .i_de(th_de),
    
    .hcount(hcount),
    .vcount(vcount),
    .o_data(HV_dout),
    .o_hsync(HV_o_hsync),
    .o_vsync(HV_o_vsync),
    .o_de(HV_o_de)
    );
	
wire [11:0] hcount_l;
wire [11:0] hcount_r;

wire [11:0] vcount_l;
wire [11:0] vcount_r;
		
Vertical_Projection#(
       .IMG_WIDTH_LINE(`PICTURE_LENGTH),
       .IMG_WIDTH_DATA(`DATA_WIDTH*3)
	   )U_Vertical_Projection(
       .pixelclk(video_clk),
	   .reset_n(rst_n),    
	   .i_binary(HV_dout),
	   .i_hs(HV_o_hsync),
	   .i_vs(HV_o_vsync),
	   .i_de(HV_o_de),       
      
	   .i_hcount(hcount),
	   .i_vcount(vcount),
	   
	   .hcount_l(hcount_l),
       .hcount_r(hcount_r),
       .vcount_l(vcount_l),
       .vcount_r(vcount_r)
	   );

wire c_o_hsync;
wire c_o_vsync;
wire c_o_de;
wire [`DATA_WIDTH*3-1:0] c_dout;
	
//capture lpr
capture_lpr U_capture_lpr(
       .pixelclk(video_clk),
	   .reset_n(rst_n),
      
	   .hcount(hcount),
       .vcount(vcount),
  	   .i_rgb(HV_dout),
	   .i_hsync(HV_o_hsync),
	   .i_vsync(HV_o_vsync),
	   .i_de(HV_o_de),
	   
	   .hcount_l(hcount_l),
       .hcount_r(hcount_r),
       .vcount_l(vcount_l),
       .vcount_r(vcount_r),
	  
       .o_rgb(c_dout),
	   .o_hsync(c_o_hsync),
	   .o_vsync(c_o_vsync),                                                                                                  
	   .o_de(c_o_de)                                                                                               
	   );

wire [11:0] hcount1;
wire [11:0] vcount1;

wire HV1_o_hsync;
wire HV1_o_vsync;
wire HV1_o_de;
wire [`DATA_WIDTH*3-1:0] HV1_dout;	
	   
HVcount#(
     .DW(`DATA_WIDTH*3),
	 .IW(`PICTURE_LENGTH)
      )U1_HVcount(
    .pixelclk(video_clk),
    .reset_n(rst_n),
    .i_data(c_dout),
    .i_hsync(c_o_hsync),
    .i_vsync(c_o_vsync),
    .i_de(c_o_de),
    
    .hcount(hcount1),
    .vcount(vcount1),
	
    .o_data(HV1_dout),
    .o_hsync(HV1_o_hsync),
    .o_vsync(HV1_o_vsync),
    .o_de(HV1_o_de)
    );	   

wire            [11:0]       hcount_l1;
wire            [11:0]       hcount_r1;
wire            [11:0]       hcount_l2;
wire            [11:0]       hcount_r2;
wire            [11:0]       hcount_l3;
wire            [11:0]       hcount_r3;
wire            [11:0]       hcount_l4;
wire            [11:0]       hcount_r4;
wire            [11:0]       hcount_l5;
wire            [11:0]       hcount_r5;
wire            [11:0]       hcount_l6;
wire            [11:0]       hcount_r6;
wire            [11:0]       hcount_l7;
wire            [11:0]       hcount_r7;
wire            [11:0]       hcount_l8;
wire            [11:0]       hcount_r8;
wire            [11:0]       vcount_l1;
wire            [11:0]       vcount_r1;
//wire            [2:0]        vpframe_cnt;

VP8#(
       .IMG_WIDTH_LINE(`PICTURE_LENGTH),
       .IMG_WIDTH_DATA(`DATA_WIDTH*3)
	   )U_VP8(
       .pixelclk(video_clk),
	   .reset_n(rst_n),    
	   .i_binary(HV1_dout),
	   .i_hs(HV1_o_hsync),
	   .i_vs(HV1_o_vsync),
	   .i_de(HV1_o_de),       
       
	   .i_hcount(hcount1),
	   .i_vcount(vcount1),
	   .hcount_l1(hcount_l1),
       .hcount_r1(hcount_r1),
	   .hcount_l2(hcount_l2),
       .hcount_r2(hcount_r2),
	   .hcount_l3(hcount_l3),
       .hcount_r3(hcount_r3),
	   .hcount_l4(hcount_l4),
       .hcount_r4(hcount_r4),
	   .hcount_l5(hcount_l5),
       .hcount_r5(hcount_r5),
	   .hcount_l6(hcount_l6),
       .hcount_r6(hcount_r6),
	   .hcount_l7(hcount_l7),
       .hcount_r7(hcount_r7),
	   .hcount_l8(hcount_l8),
       .hcount_r8(hcount_r8),
       .vcount_l(vcount_l1),
       .vcount_r(vcount_r1)
		);		
		
wire di1_o_hsync;
wire di1_o_vsync;
wire di1_o_de;
wire [`DATA_WIDTH*3-1:0] di1_dout;

assign lcd_hs = di1_o_hsync;
assign lcd_vs = di1_o_vsync;
assign lcd_de = di1_o_de;
assign lcd_r  = di1_dout[23:16];
assign lcd_g  = di1_dout[15:8];
assign lcd_b  = di1_dout[7:0];
	
display U_display(
       .pixelclk(video_clk),
	   .reset_n(rst_n),
       
  	   .i_rgb(HV1_dout),
	   .i_hsync(HV1_o_hsync),
	   .i_vsync(HV1_o_vsync),
	   .i_de(HV1_o_de),
	  
	   .hcount(hcount1),
       .vcount(vcount1),
	   
	   .hcount_l1(hcount_l1),
       .hcount_r1(hcount_r1),
	   .hcount_l2(hcount_l2),
       .hcount_r2(hcount_r2),
	   .hcount_l3(hcount_l3),
       .hcount_r3(hcount_r3),
	   .hcount_l4(hcount_l4),
       .hcount_r4(hcount_r4),
	   .hcount_l5(hcount_l5),
       .hcount_r5(hcount_r5),
	   .hcount_l6(hcount_l6),
       .hcount_r6(hcount_r6),
	   .hcount_l7(hcount_l7),
       .hcount_r7(hcount_r7),
	   .hcount_l8(hcount_l8),
       .hcount_r8(hcount_r8),
       .vcount_l(vcount_l1),
       .vcount_r(vcount_r1),
	   
       .o_rgb(di1_dout),
	   .o_hsync(di1_o_hsync),
	   .o_vsync(di1_o_vsync),                                                                                                  
	   .o_de(di1_o_de)                                                                                               
	   );  
	   
wire [39:0] char1;
wire [39:0] char2;
wire [39:0] char3;
wire [39:0] char4;
wire [39:0] char5;
wire [39:0] char6;
wire [39:0] char7;
wire [39:0] char8;
wire            [1:0]        vpframe_cnt;

lpr_recognition U_lpr_recognition(
       .pixelclk(video_clk),
	   .reset_n(rst_n),    
	   .i_binary(HV1_dout),
	   .i_hs(HV1_o_hsync),
	   .i_vs(HV1_o_vsync),
	   .i_de(HV1_o_de),       
	   
	   .i_hcount(hcount1),
	   .i_vcount(vcount1),
	   
	   .hcount_l1(hcount_l1),
       .hcount_r1(hcount_r1),
	   .hcount_l2(hcount_l2),
       .hcount_r2(hcount_r2),
	   .hcount_l3(hcount_l3),
       .hcount_r3(hcount_r3),
	   .hcount_l4(hcount_l4),
       .hcount_r4(hcount_r4),
	   .hcount_l5(hcount_l5),
       .hcount_r5(hcount_r5),
	   .hcount_l6(hcount_l6),
       .hcount_r6(hcount_r6),
	   .hcount_l7(hcount_l7),
       .hcount_r7(hcount_r7),
	   .hcount_l8(hcount_l8),
       .hcount_r8(hcount_r8),
       .vcount_l(vcount_l1),
       .vcount_r(vcount_r1),
	   .frame_cnt(vframe_cnt),
	   .char1(char1),
	   .char2(char2),
	   .char3(char3),
	   .char4(char4),
	   .char5(char5),
	   .char6(char6),
	   .char7(char7),
	   .char8(char8)
	   );
   
wire         [15:0]            char_result1;	
wire         [7:0]             char_result2;
wire         [7:0]             char_result3;	
wire         [7:0]             char_result4;	
wire         [7:0]             char_result5;	
wire         [7:0]             char_result6;	
wire         [7:0]             char_result7;	
wire         [7:0]             char_result8;

character_match U_character_match(
       .pixelclk(video_clk),
	   .reset_n(rst_n),
	   .i_vs(HV1_o_vsync),
	   .frame_cnt(vframe_cnt),
	   .char1(char1),
	   .char2(char2),
	   .char3(char3),
	   .char4(char4),
	   .char5(char5),
	   .char6(char6),
	   .char7(char7),
	   .char8(char8),
	   .char_result1(char_result1),
	   .char_result2(char_result2),
	   .char_result3(char_result3),
	   .char_result4(char_result4),
	   .char_result5(char_result5),
	   .char_result6(char_result6),
	   .char_result7(char_result7),
	   .char_result8(char_result8)
	   );

//wire 	Rs232_Tx;   
send_char U_send_char(
       .pixelclk(video_clk),
	   .reset_n(rst_n), 
	   .i_vsync(HV1_o_vsync),
	   .vpframe_cnt(vframe_cnt),
       .char_result1(char_result1),	
       .char_result2(char_result2),
       .char_result3(char_result3),	
       .char_result4(char_result4),	
       .char_result5(char_result5),	
       .char_result6(char_result6),	
       .char_result7(char_result7),	
       .char_result8(char_result8),
	   
	   .Rs232_Tx(Rs232_Tx)
	   );
   
  
ila_0 ila_0 (
	.clk(video_clk), // input wire clk

	.probe0(char2), 
	.probe1(char4),
	.probe2(char6),
	.probe3(char7)

);


frame_read_write frame_read_write_m0
(
.rst                            (~rst_n                    ),
.mem_clk                        (ui_clk                    ),
.rd_burst_req                   (rd_burst_req              ),
.rd_burst_len                   (rd_burst_len              ),
.rd_burst_addr                  (rd_burst_addr             ),
.rd_burst_data_valid            (rd_burst_data_valid       ),
.rd_burst_data                  (rd_burst_data             ),
.rd_burst_finish                (rd_burst_finish           ),
.read_clk                       (video_clk                 ),
.read_req                       (read_req                  ),
.read_req_ack                   (read_req_ack              ),
.read_finish                    (                          ),
.read_addr_0                    (24'd0                     ), 
.read_addr_1                    (24'd2073600               ), 
.read_addr_2                    (24'd4147200               ),
.read_addr_3                    (24'd6220800               ),
.read_addr_index                (read_addr_index           ),
.read_len                       (24'd96000                 ),
.read_en                        (read_en                   ),
.read_data                      (read_data                 ),

.wr_burst_req                   (wr_burst_req              ),
.wr_burst_len                   (wr_burst_len              ),
.wr_burst_addr                  (wr_burst_addr             ),
.wr_burst_data_req              (wr_burst_data_req         ),
.wr_burst_data                  (wr_burst_data             ),
.wr_burst_finish                (wr_burst_finish           ),
.write_clk                      (cmos_pclk                 ),
.write_req                      (write_req                 ),
.write_req_ack                  (write_req_ack             ),
.write_finish                   (                          ),
.write_addr_0                   (24'd0                     ),
.write_addr_1                   (24'd2073600               ),
.write_addr_2                   (24'd4147200               ),
.write_addr_3                   (24'd6220800               ),
.write_addr_index               (write_addr_index          ),
.write_len                      (24'd96000                 ),//frame size 800 * 480 * 16 / 64
.write_en                       (write_en                  ),
.write_data                     (write_data                )
);

ddr3 u_ddr3 
(
// Memory interface ports
.ddr3_addr                      (ddr3_addr                 ), 
.ddr3_ba                        (ddr3_ba                   ), 
.ddr3_cas_n                     (ddr3_cas_n                ), 
.ddr3_ck_n                      (ddr3_ck_n                 ), 
.ddr3_ck_p                      (ddr3_ck_p                 ),
.ddr3_cke                       (ddr3_cke                  ),  
.ddr3_ras_n                     (ddr3_ras_n                ), 
.ddr3_reset_n                   (ddr3_reset_n              ), 
.ddr3_we_n                      (ddr3_we_n                 ),  
.ddr3_dq                        (ddr3_dq                   ),  
.ddr3_dqs_n                     (ddr3_dqs_n                ),  
.ddr3_dqs_p                     (ddr3_dqs_p                ),  
.init_calib_complete            (init_calib_complete       ),  
 
.ddr3_cs_n                      (ddr3_cs_n                 ),  
.ddr3_dm                        (ddr3_dm                   ),  
.ddr3_odt                       (ddr3_odt                  ),  
// Application interface ports
.ui_clk                         (ui_clk                    ), 
.ui_clk_sync_rst                (ui_clk_sync_rst           ), 
.mmcm_locked                    (                          ), 
.aresetn                        (1'b1                      ), 
.app_sr_req                     (1'b0                      ), 
.app_ref_req                    (1'b0                      ), 
.app_zq_req                     (1'b0                      ), 
.app_sr_active                  (                          ), 
.app_ref_ack                    (                          ), 
.app_zq_ack                     (                          ), 
// Slave Interface Write Address Ports
.s_axi_awid                     (s00_axi_awid              ), 
.s_axi_awaddr                   (s00_axi_awaddr            ), 
.s_axi_awlen                    (s00_axi_awlen             ), 
.s_axi_awsize                   (s00_axi_awsize            ), 
.s_axi_awburst                  (s00_axi_awburst           ), 
.s_axi_awlock                   (s00_axi_awlock            ), 
.s_axi_awcache                  (s00_axi_awcache           ), 
.s_axi_awprot                   (s00_axi_awprot            ), 
.s_axi_awqos                    (s00_axi_awqos             ), 
.s_axi_awvalid                  (s00_axi_awvalid           ), 
.s_axi_awready                  (s00_axi_awready           ), 
// Slave Interface Write Data Ports
.s_axi_wdata                    (s00_axi_wdata             ), 
.s_axi_wstrb                    (s00_axi_wstrb             ), 
.s_axi_wlast                    (s00_axi_wlast             ), 
.s_axi_wvalid                   (s00_axi_wvalid            ), 
.s_axi_wready                   (s00_axi_wready            ), 
// Slave Interface Write Response Ports
.s_axi_bid                      (s00_axi_bid               ), 
.s_axi_bresp                    (s00_axi_bresp             ), 
.s_axi_bvalid                   (s00_axi_bvalid            ), 
.s_axi_bready                   (s00_axi_bready            ), 
// Slave Interface Read Address Ports
.s_axi_arid                     (s00_axi_arid              ), 
.s_axi_araddr                   (s00_axi_araddr            ), 
.s_axi_arlen                    (s00_axi_arlen             ), 
.s_axi_arsize                   (s00_axi_arsize            ), 
.s_axi_arburst                  (s00_axi_arburst           ), 
.s_axi_arlock                   (s00_axi_arlock            ), 
.s_axi_arcache                  (s00_axi_arcache           ), 
.s_axi_arprot                   (s00_axi_arprot            ), 
.s_axi_arqos                    (s00_axi_arqos             ), 
.s_axi_arvalid                  (s00_axi_arvalid           ), 
.s_axi_arready                  (s00_axi_arready           ), 
// Slave Interface Read Data Ports
.s_axi_rid                      (s00_axi_rid               ), 
.s_axi_rdata                    (s00_axi_rdata             ), 
.s_axi_rresp                    (s00_axi_rresp             ), 
.s_axi_rlast                    (s00_axi_rlast             ), 
.s_axi_rvalid                   (s00_axi_rvalid            ), 
.s_axi_rready                   (s00_axi_rready            ), 
// System Clock Ports
.sys_clk_i                      (clk_200Mhz                ), 
.sys_rst                        (rst_n                     )  
);

aq_axi_master u_aq_axi_master
(
.ARESETN                        (~ui_clk_sync_rst         ),
.ACLK                           (ui_clk                   ),
.M_AXI_AWID                     (s00_axi_awid             ),
.M_AXI_AWADDR                   (s00_axi_awaddr           ),
.M_AXI_AWLEN                    (s00_axi_awlen            ),
.M_AXI_AWSIZE                   (s00_axi_awsize           ),
.M_AXI_AWBURST                  (s00_axi_awburst          ),
.M_AXI_AWLOCK                   (s00_axi_awlock           ),
.M_AXI_AWCACHE                  (s00_axi_awcache          ),
.M_AXI_AWPROT                   (s00_axi_awprot           ),
.M_AXI_AWQOS                    (s00_axi_awqos            ),
.M_AXI_AWUSER                   (s00_axi_awuser           ),
.M_AXI_AWVALID                  (s00_axi_awvalid          ),
.M_AXI_AWREADY                  (s00_axi_awready          ),
.M_AXI_WDATA                    (s00_axi_wdata            ),
.M_AXI_WSTRB                    (s00_axi_wstrb            ),
.M_AXI_WLAST                    (s00_axi_wlast            ),
.M_AXI_WUSER                    (s00_axi_wuser            ),
.M_AXI_WVALID                   (s00_axi_wvalid           ),
.M_AXI_WREADY                   (s00_axi_wready           ),
.M_AXI_BID                      (s00_axi_bid              ),
.M_AXI_BRESP                    (s00_axi_bresp            ),
.M_AXI_BUSER                    (s00_axi_buser            ),
.M_AXI_BVALID                   (s00_axi_bvalid           ),
.M_AXI_BREADY                   (s00_axi_bready           ),
.M_AXI_ARID                     (s00_axi_arid             ),
.M_AXI_ARADDR                   (s00_axi_araddr           ),
.M_AXI_ARLEN                    (s00_axi_arlen            ),
.M_AXI_ARSIZE                   (s00_axi_arsize           ),
.M_AXI_ARBURST                  (s00_axi_arburst          ),
.M_AXI_ARLOCK                   (s00_axi_arlock           ),
.M_AXI_ARCACHE                  (s00_axi_arcache          ),
.M_AXI_ARPROT                   (s00_axi_arprot           ),
.M_AXI_ARQOS                    (s00_axi_arqos            ),
.M_AXI_ARUSER                   (s00_axi_aruser           ),
.M_AXI_ARVALID                  (s00_axi_arvalid          ),
.M_AXI_ARREADY                  (s00_axi_arready          ),
.M_AXI_RID                      (s00_axi_rid              ),
.M_AXI_RDATA                    (s00_axi_rdata            ),
.M_AXI_RRESP                    (s00_axi_rresp            ),
.M_AXI_RLAST                    (s00_axi_rlast            ),
.M_AXI_RUSER                    (s00_axi_ruser            ),
.M_AXI_RVALID                   (s00_axi_rvalid           ),
.M_AXI_RREADY                   (s00_axi_rready           ),
.MASTER_RST                     (1'b0                     ),
.WR_START                       (wr_burst_req             ),
.WR_ADRS                        ({wr_burst_addr,3'd0}     ),
.WR_LEN                         ({wr_burst_len,3'd0}      ),
.WR_READY                       (                         ),
.WR_FIFO_RE                     (wr_burst_data_req        ),
.WR_FIFO_EMPTY                  (1'b0                     ),
.WR_FIFO_AEMPTY                 (1'b0                     ),
.WR_FIFO_DATA                   (wr_burst_data            ),
.WR_DONE                        (wr_burst_finish          ),
.RD_START                       (rd_burst_req             ),
.RD_ADRS                        ({rd_burst_addr,3'd0}     ),
.RD_LEN                         ({rd_burst_len,3'd0}      ),
.RD_READY                       (                         ),
.RD_FIFO_WE                     (rd_burst_data_valid      ),
.RD_FIFO_FULL                   (1'b0                     ),
.RD_FIFO_AFULL                  (1'b0                     ),
.RD_FIFO_DATA                   (rd_burst_data            ),
.RD_DONE                        (rd_burst_finish          ),
.DEBUG                          (                         )
);
endmodule