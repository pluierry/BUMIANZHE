
`timescale 1ns / 1ps

module char_ln(
       input						    pixelclk,
	   input                            reset_n,
	   input          [39:0]            char,
	   output         [7:0]            char_result
	   );

`include "char_temp.vh"


wire [5:0] score_0,score_1,score_2,score_3,score_4,score_5,score_6,score_7,score_8,score_9;

wire [5:0] score_a,score_b,score_c,score_d,score_e,score_f,score_g,score_h,score_i,score_j,score_k,score_l,score_m,score_n,score_p,score_q,score_r,score_s,score_t,score_u,score_v,score_w,score_x,score_y,score_z;

reg [5:0] max1,max2,max3,max4,max5;
reg [5:0] max;
reg  [7:0] char_result_r;

always @(posedge pixelclk or negedge reset_n) begin
  if(reset_n == 1'b0) begin
    max1 <= 6'd0;
	max2 <= 6'd0;
	max3 <= 6'd0;
	max4 <= 6'd0;
	max5 <= 6'd0;
	max <= 6'd0;
  end
  else begin
    max1 <= MAX7(score_0,score_1,score_2,score_3,score_4,score_5,score_6);
	max2 <= MAX7(score_7,score_8,score_9,score_a,score_b,score_c,score_d);
	max3 <= MAX7(score_e,score_f,score_g,score_h,score_i,score_j,score_k);
	max4 <= MAX7(score_l,score_m,score_n,score_p,score_q,score_r,score_s);
	max5 <= MAX7(score_t,score_u,score_v,score_w,score_x,score_y,score_z);
	max <= MAX5(max1,max2,max3,max4,max5);
  end
end
 
always @(posedge pixelclk or negedge reset_n) begin
  if(reset_n == 1'b0)
    char_result_r <= 8'b0;
  else begin
    if(max == score_0) char_result_r <= `NUM0;
    if(max == score_1) char_result_r <= `NUM1;
	if(max == score_2) char_result_r <= `NUM2;
	if(max == score_3) char_result_r <= `NUM3;
	if(max == score_4) char_result_r <= `NUM4;
	if(max == score_5) char_result_r <= `NUM5;
	if(max == score_6) char_result_r <= `NUM6;
	if(max == score_7) char_result_r <= `NUM7;
	if(max == score_8) char_result_r <= `NUM8;
	if(max == score_9) char_result_r <= `NUM9;
	
    if(max == score_a) char_result_r <= `A;
	if(max == score_b) char_result_r <= `B;
	if(max == score_c) char_result_r <= `C;
	if(max == score_d) char_result_r <= `D;
	if(max == score_e) char_result_r <= `E;
	if(max == score_f) char_result_r <= `F;
	if(max == score_g) char_result_r <= `J;
	if(max == score_h) char_result_r <= `H;
	if(max == score_i) char_result_r <= `I;
	if(max == score_j) char_result_r <= `J;
	if(max == score_k) char_result_r <= `K;
	if(max == score_l) char_result_r <= `L;
	if(max == score_m) char_result_r <= `M;
	if(max == score_n) char_result_r <= `N;
	if(max == score_p) char_result_r <= `P;
	if(max == score_q) char_result_r <= `Q;
	if(max == score_r) char_result_r <= `R;
	if(max == score_s) char_result_r <= `S;
	if(max == score_t) char_result_r <= `T;
	if(max == score_u) char_result_r <= `U;
	if(max == score_v) char_result_r <= `V;
	if(max == score_w) char_result_r <= `W;
	if(max == score_x) char_result_r <= `X;
	if(max == score_y) char_result_r <= `Y;
	if(max == score_z) char_result_r <= `Z;
  end
end

assign char_result = char_result_r;

assign score_0 = SCORE(char,`Temp_0);
assign score_1 = SCORE(char,`Temp_1);
assign score_2 = SCORE(char,`Temp_2);
assign score_3 = SCORE(char,`Temp_3);
assign score_4 = SCORE(char,`Temp_4);
assign score_5 = SCORE(char,`Temp_5);
assign score_6 = SCORE(char,`Temp_6);
assign score_7 = SCORE(char,`Temp_7);
assign score_8 = SCORE(char,`Temp_8);
assign score_9 = SCORE(char,`Temp_9);

assign score_a = SCORE(char,`Temp_A);
assign score_b = SCORE(char,`Temp_B);
assign score_c = SCORE(char,`Temp_C);
assign score_d = SCORE(char,`Temp_D);
assign score_e = SCORE(char,`Temp_E);
assign score_f = SCORE(char,`Temp_F);
assign score_g = SCORE(char,`Temp_G);
assign score_h = SCORE(char,`Temp_H);
assign score_i = SCORE(char,`Temp_I);
assign score_j = SCORE(char,`Temp_J);
assign score_k = SCORE(char,`Temp_K);
assign score_l = SCORE(char,`Temp_L);
assign score_m = SCORE(char,`Temp_M);
assign score_n = SCORE(char,`Temp_N);
assign score_p = SCORE(char,`Temp_P);
assign score_q = SCORE(char,`Temp_Q);
assign score_r = SCORE(char,`Temp_R);
assign score_s = SCORE(char,`Temp_S);
assign score_t = SCORE(char,`Temp_T);
assign score_u = SCORE(char,`Temp_U);
assign score_v = SCORE(char,`Temp_V);
assign score_w = SCORE(char,`Temp_W);
assign score_x = SCORE(char,`Temp_X);
assign score_y = SCORE(char,`Temp_Y);
assign score_z = SCORE(char,`Temp_Z);

function [5:0] SCORE(input [39:0] char1,char2);
     reg [39:0] char;
	 begin
		char = ~(char1^char2);
	    SCORE =  char[0] + char[1] + char[2] + char[3] + char[4] + 
                 char[5] + char[6] + char[7] + char[8] + char[9] + 
				 char[10] + char[11] + char[12] + char[13] + char[14] + 
				 char[15] + char[16] + char[17] + char[18] + char[19] + 
				 char[20] + char[21] + char[22] + char[23] + char[24] + 
				 char[25] + char[26] + char[27] + char[28] + char[29] + 
				 char[30] + char[31] + char[32] + char[33] + char[34] + 
				 char[35] + char[36] + char[37] + char[38] + char[39];
	end
endfunction

function [5:0] MAX7;
    input [5:0] a,b,c,d,e,f,g;
    reg [5:0] Maxab,Maxabc,Maxabcd,Maxabcde,Maxabcdef;
    begin 
        Maxab = a > b ? a : b;
        Maxabc = Maxab > c ? Maxab : c;
		Maxabcd = Maxabc > d ? Maxabc : d;
		Maxabcde = Maxabcd > e ? Maxabcd : e;
		Maxabcdef = Maxabcde > f ? Maxabcde : f;
		MAX7 = Maxabcdef > g ? Maxabcdef : g;
    end
endfunction

function [5:0] MAX5;
    input [5:0] a,b,c,d,e;
    reg [5:0] Maxab,Maxabc,Maxabcd;
    begin 
        Maxab = a > b ? a : b;
        Maxabc = Maxab > c ? Maxab : c;
		Maxabcd = Maxabc > d ? Maxabc : d;
		MAX5 = Maxabcd > e ? Maxabcd : e;
    end
endfunction
				 
endmodule

 