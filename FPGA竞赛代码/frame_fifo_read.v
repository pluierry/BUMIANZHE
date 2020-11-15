

`timescale 1ns/1ps
module frame_fifo_read
#
(
	parameter MEM_DATA_BITS          = 32,
	parameter ADDR_BITS              = 23,
	parameter BUSRT_BITS             = 10,
	parameter FIFO_DEPTH             = 256,
	parameter BURST_SIZE             = 128
)               
(
	input                            rst,                  
	input                            mem_clk,                   
	output reg                       rd_burst_req,              
	output reg[BUSRT_BITS - 1:0]     rd_burst_len,              
	output reg[ADDR_BITS - 1:0]      rd_burst_addr,             
	input                            rd_burst_data_valid,       
	input                            rd_burst_finish,           
	input                            read_req,                  
	output reg                       read_req_ack,              
	 output                           read_finish,              
	input[ADDR_BITS - 1:0]           read_addr_0,               
	input[ADDR_BITS - 1:0]           read_addr_1,               
	input[ADDR_BITS - 1:0]           read_addr_2,               
	input[ADDR_BITS - 1:0]           read_addr_3,               
	input[1:0]                       read_addr_index,           
	input[ADDR_BITS - 1:0]           read_len,                  
	output reg                       fifo_aclr,                 
	input[15:0]                      wrusedw                    
); 
localparam ONE                       = 256'd1;                  
localparam ZERO                      = 256'd0;                  
//read state machine code
localparam S_IDLE                    = 0;                       
localparam S_ACK                     = 1;                       
localparam S_WAIT                    = 2;
localparam S_CHECK_FIFO              = 3;                       
localparam S_READ_BURST              = 4;                       
localparam S_READ_BURST_END          = 5;                       
localparam S_END                     = 6;                       

reg                                  read_req_d0;               
reg                                  read_req_d1;               
reg                                  read_req_d2;               
reg[ADDR_BITS - 1:0]                 read_len_d0;               
reg[ADDR_BITS - 1:0]                 read_len_d1;               
reg[ADDR_BITS - 1:0]                 read_len_latch;            
reg[ADDR_BITS - 1:0]                 read_cnt;                  
reg[3:0]                             state;                     
reg[1:0]                             read_addr_index_d0;        
reg[1:0]                             read_addr_index_d1;        
reg[15:0]                            wait_cnt;
assign read_finish = (state == S_END) ? 1'b1 : 1'b0;            
always@(posedge mem_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		read_req_d0    <=  1'b0;
		read_req_d1    <=  1'b0;
		read_req_d2    <=  1'b0;
		read_len_d0    <=  ZERO[ADDR_BITS - 1:0];               
		read_len_d1    <=  ZERO[ADDR_BITS - 1:0];               
		read_addr_index_d0 <= 2'b00;
		read_addr_index_d1 <= 2'b00;
	end
	else
	begin
		read_req_d0    <=  read_req;
		read_req_d1    <=  read_req_d0;
		read_req_d2    <=  read_req_d1;     
		read_len_d0    <=  read_len;
		read_len_d1    <=  read_len_d0; 
		read_addr_index_d0 <= read_addr_index;
		read_addr_index_d1 <= read_addr_index_d0;
	end 
end


always@(posedge mem_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		state <= S_IDLE;
		read_len_latch <= ZERO[ADDR_BITS - 1:0];
		rd_burst_addr <= ZERO[ADDR_BITS - 1:0];
		rd_burst_req <= 1'b0;
		read_cnt <= ZERO[ADDR_BITS - 1:0];
		fifo_aclr <= 1'b0;
		rd_burst_len <= ZERO[BUSRT_BITS - 1:0];
		read_req_ack <= 1'b0;
		wait_cnt <= 16'd0;
	end
	else
		case(state)
			
			S_IDLE:
			begin
				if(read_req_d2 == 1'b1)
				begin
					state <= S_ACK;
				end
				read_req_ack <= 1'b0;
			end
		
			S_ACK:
			begin
				if(read_req_d2 == 1'b0)
				begin
					state <= S_WAIT;
					wait_cnt <= 16'd0;
					fifo_aclr <= 1'b0;
					read_req_ack <= 1'b0;
				end
				else
				begin
					
					read_req_ack <= 1'b1;
				
					fifo_aclr <= 1'b1;
					
					if(read_addr_index_d1 == 2'd0)
						rd_burst_addr <= read_addr_0;
					else if(read_addr_index_d1 == 2'd1)
						rd_burst_addr <= read_addr_1;
					else if(read_addr_index_d1 == 2'd2)
						rd_burst_addr <= read_addr_2;
					else if(read_addr_index_d1 == 2'd3)
						rd_burst_addr <= read_addr_3;
				
					read_len_latch <= read_len_d1;
				end
			
				read_cnt <= ZERO[ADDR_BITS - 1:0];
			end
			S_WAIT:
			begin
				if(wait_cnt >= 16'd200)
				begin
					state <= S_CHECK_FIFO;
				end
				else
				begin
					wait_cnt <= wait_cnt + 16'd1;
				end
			end
			S_CHECK_FIFO:
			begin
				
				if(read_req_d2 == 1'b1)
				begin
					state <= S_ACK;
				end
				
				else if(wrusedw < (FIFO_DEPTH - BURST_SIZE - 2))
				begin
					state <= S_READ_BURST;
					rd_burst_len <= BURST_SIZE[BUSRT_BITS - 1:0];
					rd_burst_req <= 1'b1;
				end
			end
			
			S_READ_BURST:
			begin
				if(rd_burst_data_valid)
					rd_burst_req <= 1'b0;
 
				if(rd_burst_finish == 1'b1)
				begin
					state <= S_READ_BURST_END;
					
					read_cnt <= read_cnt + BURST_SIZE[ADDR_BITS - 1:0];
					
					rd_burst_addr <= rd_burst_addr + BURST_SIZE[ADDR_BITS - 1:0];
				end     
			end
			S_READ_BURST_END:
			begin
				
				if(read_req_d2 == 1'b1)
				begin
					state <= S_ACK;
				end
			
				else if(read_cnt < read_len_latch)
				begin
					state <= S_CHECK_FIFO;
				end
				else
				begin
					state <= S_END;
				end
			end
			S_END:
			begin
				state <= S_IDLE;
			end
			default:
				state <= S_IDLE;
		endcase
end
endmodule
