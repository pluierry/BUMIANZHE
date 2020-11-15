
`timescale 1ns / 1ps

module char_city(
       input						    pixelclk,
	   input                            reset_n,
	   input          [39:0]            char,
	   output         [15:0]            char_result
	   );

`include "char_city.vh"

wire [5:0] score_bj,score_tj,score_hb,score_sx,score_nm,score_ln,score_jl,score_hl,score_sh,score_js,score_zz,score_ah,score_fj,score_jx,score_sd,score_nh,score_ub,score_un,score_gd,score_gx,score_hn,score_cc,score_sc,score_gz,score_yn,score_xz,score_ax,score_gs,score_qs,score_nx,score_xj;


reg [5:0] max1,max2,max3,max4,max5;
reg [5:0] max;
reg  [15:0] char_result_r;

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
    max1 <= MAX7(score_bj,score_tj,score_hb,score_sx,score_nm,score_ln,score_jl);
	max2 <= MAX7(score_hl,score_sh,score_js,score_zz,score_ah,score_fj,score_jx);
	max3 <= MAX7(score_sd,score_nh,score_ub,score_un,score_gd,score_gx,score_hn);
	max4 <= MAX7(score_cc,score_sc,score_gz,score_yn,score_xz,score_ax,score_gs);
	max5 <= MAX3(score_qs,score_nx,score_xj);
	max <= MAX5(max1,max2,max3,max4,max5);
  end
end
 
always @(posedge pixelclk or negedge reset_n) begin
  if(reset_n == 1'b0)
    char_result_r <= 16'b0;
  else begin
    if(max == score_bj) char_result_r <= {`B,`J};  //北京
    if(max == score_tj) char_result_r <= {`T,`J};  //天津
	if(max == score_hb) char_result_r <= {`H,`B};  //河北
	if(max == score_sx) char_result_r <= {`S,`X};  //山西
	if(max == score_nm) char_result_r <= {`N,`M};  //内蒙
	if(max == score_ln) char_result_r <= {`L,`N};  //辽宁
	if(max == score_jl) char_result_r <= {`J,`L};  //吉林
	if(max == score_hl) char_result_r <= {`H,`L};  //黑龙�?
	if(max == score_sh) char_result_r <= {`S,`H};  //上海
	if(max == score_js) char_result_r <= {`J,`S};  //江苏
    if(max == score_zz) char_result_r <= {`Z,`Z};  //浙江
	if(max == score_ah) char_result_r <= {`A,`H};  //安徽
	if(max == score_fj) char_result_r <= {`F,`J};  //福建
	if(max == score_jx) char_result_r <= {`J,`X};  //江西
	if(max == score_sd) char_result_r <= {`S,`D};  //山东
	if(max == score_nh) char_result_r <= {`N,`H};  //河南
	if(max == score_ub) char_result_r <= {`U,`B};  //湖北
	if(max == score_un) char_result_r <= {`U,`N};  //湖南
	if(max == score_gd) char_result_r <= {`G,`D};  //广东
	if(max == score_gx) char_result_r <= {`G,`X};  //广西
	if(max == score_hn) char_result_r <= {`H,`N};  //海南
	if(max == score_cc) char_result_r <= {`C,`C};  //重庆
	if(max == score_sc) char_result_r <= {`S,`C};  //四川
	if(max == score_gz) char_result_r <= {`G,`Z};  //贵州
	if(max == score_yn) char_result_r <= {`Y,`N};  //云南
	if(max == score_xz) char_result_r <= {`X,`Z};  //西藏
	if(max == score_ax) char_result_r <= {`A,`X};  //陕西
	if(max == score_gs) char_result_r <= {`G,`S};  //甘肃
	if(max == score_qs) char_result_r <= {`Q,`S};  //青海
	if(max == score_nx) char_result_r <= {`N,`X};  //宁夏
	if(max == score_xj) char_result_r <= {`X,`J};  //新疆
  end
end

assign char_result = char_result_r;

assign score_bj = SCORE(char,`Temp_BJ);
assign score_tj = SCORE(char,`Temp_TJ);
assign score_hb = SCORE(char,`Temp_HB);
assign score_sx = SCORE(char,`Temp_SX);
assign score_nm = SCORE(char,`Temp_NM);
assign score_ln = SCORE(char,`Temp_LN);
assign score_jl = SCORE(char,`Temp_JL);
assign score_hl = SCORE(char,`Temp_HL);
assign score_sh = SCORE(char,`Temp_SH);
assign score_js = SCORE(char,`Temp_JS);
assign score_zz = SCORE(char,`Temp_ZZ);
assign score_ah = SCORE(char,`Temp_AH);
assign score_fj = SCORE(char,`Temp_FJ);
assign score_jx = SCORE(char,`Temp_JX);
assign score_sd = SCORE(char,`Temp_SD);
assign score_nh = SCORE(char,`Temp_NH);
assign score_ub = SCORE(char,`Temp_UB);
assign score_un = SCORE(char,`Temp_UN);
assign score_gd = SCORE(char,`Temp_GD);
assign score_gx = SCORE(char,`Temp_GX);
assign score_hn = SCORE(char,`Temp_HN);
assign score_cc = SCORE(char,`Temp_CC);
assign score_sc = SCORE(char,`Temp_SC);
assign score_gz = SCORE(char,`Temp_GZ);
assign score_yn = SCORE(char,`Temp_YN);
assign score_xz = SCORE(char,`Temp_XZ);
assign score_ax = SCORE(char,`Temp_AX);
assign score_gs = SCORE(char,`Temp_GS);
assign score_qs = SCORE(char,`Temp_QS);
assign score_nx = SCORE(char,`Temp_NX);
assign score_xj = SCORE(char,`Temp_XJ);


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

function [5:0] MAX3;
    input [5:0] a,b,c;
    reg [5:0] Maxab;
    begin 
        Maxab = a > b ? a : b;
        MAX3= Maxab > c ? Maxab : c;
    end
endfunction
				 
endmodule

 