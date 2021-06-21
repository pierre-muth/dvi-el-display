module timing_gen (clock_in, HS, VS, Vclk);

parameter screenWidth = 80;
parameter screenHeight = 240;
parameter lineBlank = 10;

initial begin
	counterX = 0;
	counterY = 0;
end

input clock_in;
output HS;
output VS;
output Vclk;

reg [10:0] counterX;  
reg [10:0] counterY;  
wire HS = (counterX==screenWidth-1);
wire VS = (counterY==0);
wire Vclk = clock_in && (counterX < screenWidth);

always @(posedge clock_in) begin
	if (counterX >= screenWidth+lineBlank) begin
		counterX = 0;
		counterY = counterY +1;
	end else begin
		counterX = counterX +1;
	end
	if (counterY >= screenHeight) begin
		counterY = 0;
	end
end

endmodule