

`timescale 1ns/1ps
module frame_fifo_write
#
(
	parameter MEM_DATA_BITS          = 32,
	parameter ADDR_BITS              = 23,
	parameter BUSRT_BITS             = 10,
	parameter BURST_SIZE             = 128
)               
(
	input                            rst,                  
	input                            mem_clk,                    
	output reg                       wr_burst_req,               
	output reg[BUSRT_BITS - 1:0]     wr_burst_len,               
	output reg[ADDR_BITS - 1:0]      wr_burst_addr,              
	input                            wr_burst_data_req,          
	input                            wr_burst_finish,            
	input                            write_req,                  
	output reg                       write_req_ack,              
	output                           write_finish,               
	input[ADDR_BITS - 1:0]           write_addr_0,               
	input[ADDR_BITS - 1:0]           write_addr_1,               
	input[ADDR_BITS - 1:0]           write_addr_2,               
	input[ADDR_BITS - 1:0]           write_addr_3,               
	input[1:0]                       write_addr_index,           
	input[ADDR_BITS - 1:0]           write_len,                  
	output reg                       fifo_aclr,                  
	input[15:0]                      rdusedw                     
);
localparam ONE                       = 256'd1;                   
localparam ZERO                      = 256'd0;                   
//write state machine code
localparam S_IDLE                    = 0;                        
localparam S_ACK                     = 1;                        
localparam S_CHECK_FIFO              = 2;                        
localparam S_WRITE_BURST             = 3;                        
localparam S_WRITE_BURST_END         = 4;                        
localparam S_END                     = 5;                        

reg                                  write_req_d0;                
reg                                 write_req_d1;                
reg                                 write_req_d2;                
reg[ADDR_BITS - 1:0]                write_len_d0;                
reg[ADDR_BITS - 1:0]                write_len_d1;                
reg[ADDR_BITS - 1:0]                write_len_latch;             
reg[ADDR_BITS - 1:0]                write_cnt;                   
reg[1:0]                            write_addr_index_d0;
reg[1:0]                            write_addr_index_d1;
reg[3:0]                            state;                       

assign write_finish = (state == S_END) ? 1'b1 : 1'b0;            
always@(posedge mem_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		write_req_d0    <=  1'b0;
		write_req_d1    <=  1'b0;
		write_req_d2    <=  1'b0;
		write_len_d0    <=  ZERO[ADDR_BITS - 1:0];             
		write_len_d1    <=  ZERO[ADDR_BITS - 1:0];             
		write_addr_index_d0    <=  2'b00;
		write_addr_index_d1    <=  2'b00;
	end
	else
	begin
		write_req_d0    <=  write_req;
		write_req_d1    <=  write_req_d0;
		write_req_d2    <=  write_req_d1;
		write_len_d0    <=  write_len;
		write_len_d1    <=  write_len_d0;
		write_addr_index_d0 <= write_addr_index;
		write_addr_index_d1 <= write_addr_index_d0;
	end 
end


always@(posedge mem_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		state <= S_IDLE;
		write_len_latch <= ZERO[ADDR_BITS - 1:0];
		wr_burst_addr <= ZERO[ADDR_BITS - 1:0];
		wr_burst_req <= 1'b0;
		write_cnt <= ZERO[ADDR_BITS - 1:0];
		fifo_aclr <= 1'b0;
		write_req_ack <= 1'b0;
		wr_burst_len <= ZERO[BUSRT_BITS - 1:0];
	end
	else
		case(state)
			
			S_IDLE:
			begin
				if(write_req_d2 == 1'b1)
				begin
					state <= S_ACK;
				end
				write_req_ack <= 1'b0;
			end
			
			S_ACK:
			begin
				
				if(write_req_d2 == 1'b0)
				begin
					state <= S_CHECK_FIFO;
					fifo_aclr <= 1'b0;
					write_req_ack <= 1'b0;
				end
				else
				begin
					
					write_req_ack <= 1'b1;

					fifo_aclr <= 1'b1;
					
					if(write_addr_index_d1 == 2'd0)
						wr_burst_addr <= write_addr_0;
					else if(write_addr_index_d1 == 2'd1)
						wr_burst_addr <= write_addr_1;
					else if(write_addr_index_d1 == 2'd2)
						wr_burst_addr <= write_addr_2;
					else if(write_addr_index_d1 == 2'd3)
						wr_burst_addr <= write_addr_3;
		
					write_len_latch <= write_len_d1;                    
				end
			
				write_cnt <= ZERO[ADDR_BITS - 1:0];
			end
			S_CHECK_FIFO:
			begin
				
				if(write_req_d2 == 1'b1)
				begin
					state <= S_ACK;
				end
				
				else if(rdusedw >= BURST_SIZE)
				begin
					state <= S_WRITE_BURST;
					wr_burst_len <= BURST_SIZE[BUSRT_BITS - 1:0];
					wr_burst_req <= 1'b1;
				end
			end
			
			S_WRITE_BURST:
			begin
				//burst finish
				if(wr_burst_finish == 1'b1)
				begin
					wr_burst_req <= 1'b0;
					state <= S_WRITE_BURST_END;
					
					write_cnt <= write_cnt + BURST_SIZE[ADDR_BITS - 1:0];
				
					wr_burst_addr <= wr_burst_addr + BURST_SIZE[ADDR_BITS - 1:0];
				end     
			end
			S_WRITE_BURST_END:
			begin
				
				if(write_req_d2 == 1'b1)
				begin
					state <= S_ACK;
				end
				
				else if(write_cnt < write_len_latch)
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
