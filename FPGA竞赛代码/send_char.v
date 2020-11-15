
`define TAIL  "\n"
`define HEAD  "\n"

module send_char(
       input                           pixelclk,
	   input                           reset_n, 
	   input [1:0]                     vpframe_cnt,
	   input						   i_vsync,
       input         [15:0]            char_result1,	
       input         [7:0]             char_result2,
       input         [7:0]             char_result3,	
       input         [7:0]             char_result4,	
       input         [7:0]             char_result5,	
       input         [7:0]             char_result6,	
       input         [7:0]             char_result7,	
       input         [7:0]             char_result8,
	   
	   output                          Rs232_Tx
	   ); 
	   `include "char_city.vh"
parameter                       CLK_FRE = 33;//Mhz
localparam                       IDLE =  0;
localparam                       SEND =  1;   //send HELLO ALINX\r\n
localparam                       WAIT =  2;   //wait 1 second and send uart received data
reg[7:0]                         tx_data;
reg[7:0]                         tx_str;
reg                              tx_data_valid;
wire                             tx_data_ready;
reg[7:0]                         tx_cnt;
reg[3:0]                         state;

reg i_vsync_r;
reg i_vsync_r1;
reg i_vsync_r2;

wire vsync_pos =i_vsync_r1&(!i_vsync_r2);

always @(posedge pixelclk)begin
    i_vsync_r<=i_vsync;
    i_vsync_r1<=i_vsync_r;
    i_vsync_r2<=i_vsync_r1;
end

always@(posedge pixelclk or negedge reset_n)
begin
	if(reset_n == 1'b0)
	begin
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
			state <= SEND;
		SEND:
		begin
			tx_data <= tx_str;

			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < 8'd9)//Send 12 bytes data
			begin
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else if(tx_data_valid && tx_data_ready)//last byte sent is complete
			begin
				tx_cnt <= 8'd0;
				tx_data_valid <= 1'b0;
				state <= WAIT;
			end
			else if(~tx_data_valid)
			begin
				tx_data_valid <= 1'b1;
			end
		end
		WAIT:
		begin
			if((vpframe_cnt==2'd0 ||vpframe_cnt==2'd1||vpframe_cnt==2'd2||vpframe_cnt==2'd3) && vsync_pos==1'b1) // wait for 1 second
				state <= SEND;
		end
		default:
			state <= IDLE;
	endcase
end

always@(*)
begin
	case(tx_cnt)
		8'd0 :  tx_str <= char_result1[15:8];
		8'd1 :  tx_str <= char_result1[7:0];
		8'd2 :  tx_str <= char_result2;
		8'd3 :  tx_str <= char_result4;
		8'd4 :  tx_str <= char_result5;
		8'd5 :  tx_str <= char_result6;
		8'd6 :  tx_str <= char_result7;
		8'd7 :  tx_str <= char_result8;
		8'd8:  tx_str <= "\r";
		8'd9:  tx_str <= "\n";
		default:tx_str <= 8'd0;
	endcase
end

uart_tx#
(
.CLK_FRE(CLK_FRE),
.BAUD_RATE(115200)
) uart_tx_inst
(
.clk                        (pixelclk                 ),
.rst_n                      (reset_n                  ),
.tx_data                    (tx_data                  ),
.tx_data_valid              (tx_data_valid            ),
.tx_data_ready              (tx_data_ready            ),
.tx_pin                     (Rs232_Tx                 )
);

endmodule