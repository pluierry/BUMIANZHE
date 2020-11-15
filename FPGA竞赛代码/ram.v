module ram#(
  parameter IMG_WIDTH_LINE =1920
  )(	
  input wire  [11:0]   addra,
  input wire  [11:0]   addrb,
  input wire           clka,
  input wire  [0:0]    dina,
  output reg  [0:0]    doutb,
  input wire           wea,
  input wire           rst_n
);
   
   (* RAM_STYLE="{AUTO | BLOCK |  BLOCK_POWER1 | BLOCK_POWER2}" *)
   reg [0:0] buffer_ram [IMG_WIDTH_LINE-1:0];
   integer n;
   always @(posedge clka or negedge rst_n) begin
   if(!rst_n)begin
     for (n = 0; n <= 1023; n = n +1)   buffer_ram[n] <= 0;
     doutb <= 0;
   end
   else begin
      if (wea)
         buffer_ram[addra] <= dina;
      doutb <= buffer_ram[addrb];
    end
   end 

   
endmodule