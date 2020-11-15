
`timescale 1ns / 1ps

module character_match(
       input						    pixelclk,
	   input                            reset_n,
	   input                            i_vs,
	   input          [1:0]             frame_cnt,
	   input          [39:0]            char1,
	   input          [39:0]            char2,
	   input          [39:0]            char3,
	   input          [39:0]            char4,
	   input          [39:0]            char5,
	   input          [39:0]            char6,
	   input          [39:0]            char7,
	   input          [39:0]            char8,
	   output         [15:0]            char_result1,
	   output         [7:0]             char_result2,
	   output         [7:0]             char_result3,
	   output         [7:0]             char_result4,
	   output         [7:0]             char_result5,
	   output         [7:0]             char_result6,
	   output         [7:0]             char_result7,
	   output         [7:0]             char_result8
	   );
	   
char_city Uchar_city(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
	   .char(char1),
	   .char_result(char_result1)
	   );
	   
char_ln Uchar_ln2(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
	   .char(char2),
	   .char_result(char_result2)
	   );
	   
char_ln Uchar_ln4(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
	   .char(char4),
	   .char_result(char_result4)
	   );
	   
char_ln Uchar_ln5(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
	   .char(char5),
	   .char_result(char_result5)
	   );
	   
char_ln Uchar_ln6(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
	   .char(char6),
	   .char_result(char_result6)
	   );

char_ln Uchar_ln7(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
	   .char(char7),
	   .char_result(char_result7)
	   );
	   

char_ln Uchar_ln8(
       .pixelclk(pixelclk),
	   .reset_n(reset_n),
	   .char(char8),
	   .char_result(char_result8)
	   );
endmodule
