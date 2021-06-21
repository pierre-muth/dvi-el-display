module output_proc (clock_in, HS, VS, pixClk, addr, rdPix, outData);

parameter screenWidth = 14'h0050;
parameter screenHeight = 14'h00F0;
parameter lineBlank = 14'h000A;

input clock_in;
output [14:0] addr;
output HS, VS, pixClk, rdPix;
output [7:0] outData;

//reg [14:0] addr;
reg [14:0] counterX;  
reg [14:0] counterY;

wire pixClk = clock_in && (counterX < screenWidth);
wire HS = (counterX==screenWidth);
wire VS = (counterY==0);
wire rdPix = pixClk;

assign addr = counterX+(counterY*screenWidth);
assign outData = addr;

always @ (posedge clock_in) begin

	if (counterX >= screenWidth+lineBlank) begin
		counterX = 14'h0000;
		counterY = counterY +14'h0001;
	end else begin
		counterX = counterX +14'h0001;
	end
	
	if (counterY >= screenHeight) begin
		counterY = 14'h0000;
	end

end

endmodule
