module output_proc_3 (clock_in, HS, VS, videoClk, addr, rdPix, outData);

parameter screenWidth = 15'h0050;
parameter screenHeight = 15'h00F0;
parameter lineBlank = 15'h000A;

input clock_in;
output [14:0] addr;
output HS, VS, videoClk, rdPix;
output [7:0] outData;

reg [14:0] counterX;  
reg [14:0] counterY;
reg [14:0] addr;
reg clockPix, rdPix;

wire videoClk = clockPix && (counterX < screenWidth);
wire HS = (counterX==screenWidth);
wire VS = (counterY==0);

assign outData = addr[7:0];

always @ (posedge clock_in) begin
	clockPix <= !clockPix;
end

always @ (negedge clock_in) begin
	rdPix <= clockPix;
end

always @ (posedge clockPix) begin
	if (counterX >= screenWidth +lineBlank) begin
		counterX <= 15'h0000;
		counterY <= counterY +15'h0001;
	end else begin
		counterX <= counterX +15'h0001;
	end
	
	if (counterY >= screenHeight) begin
		counterY <= 15'h0000;
	end
end

always @ (negedge clock_in) begin
	if (addr > 15'h4B00) addr <= 15'h0000;
	else if (!rdPix) addr <= addr + 15'h0001;
end

endmodule
