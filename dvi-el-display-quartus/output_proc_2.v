module output_proc_2 (clock_in, HS, VS, pixClk, addr, rdPix, pixBlankCheck);

parameter screenWidth = 15'h0050;
parameter screenHeight = 15'h00F0;
parameter lineBlank = 15'h000A;
parameter ramDummyRead = 15'h0001;

input clock_in;
input [7:0] pixBlankCheck;
output [14:0] addr;
output HS, VS, pixClk, rdPix;

reg [14:0] counterX;  
reg [14:0] counterY;
reg [14:0] addr;
reg clockPix, rdPix;

reg screenSaving;
reg [14:0] blankScreenCounter;
reg [14:0] pixCounter;


wire pixClk = clockPix && pixClkenable;
wire HS = (counterX==screenWidth+2);
wire VS = ((counterY==0) && !screenSaving);

wire counterXmaxed = counterX==screenWidth+lineBlank-1;
wire counterYmaxed = counterY==screenHeight-1;
wire pixClkenable = (counterX < (screenWidth + ramDummyRead)) && (counterX >= ramDummyRead);
wire rdPixEnable = (counterX < screenWidth + ramDummyRead);

always @ (negedge clockPix) begin
	if (pixBlankCheck > 2 && counterX < screenWidth && counterX > ramDummyRead) begin
		pixCounter <= pixCounter +1;
		screenSaving <= 0;
		blankScreenCounter <= 0;
	end 
	
	if (counterYmaxed && counterXmaxed) begin
		if (pixCounter < 4) begin
			blankScreenCounter <= blankScreenCounter +1;
		end
		pixCounter <= 0;
	end
	
	if (blankScreenCounter > 1000) begin 
		screenSaving <= 1;
		blankScreenCounter <= 100;
	end
end

always @ (posedge clock_in) begin
	clockPix <= !clockPix;
end

always @ (negedge clock_in) begin
	rdPix <= clockPix && rdPixEnable;
end

always @ (negedge clockPix) begin
	if (counterXmaxed) begin
		counterX <= 15'h0000;
	end else begin
		counterX <= counterX +15'h0001;
	end
end

always @ (negedge clockPix) begin	
	if (counterXmaxed) begin
		if (counterYmaxed) begin
			counterY <= 15'h0000;
		end else begin
			counterY <= counterY +15'h0001;
		end
	end
end

always @ (posedge clockPix) begin
   if (rdPixEnable) addr <= counterX+(counterY*screenWidth);
end

endmodule

/*
{ signal : [
  { name: "clock_in", wave: "P...........", period:2},
  { name: "clockPix", wave: "0.1.0.1.0.1.0.1.0.1.0.1."},
  { name: "counterX", wave: "=...=...=...=...=...=...",   data: ["90", "0", "1", "2", "3", "4"]},
  { name: "counterY", wave: "=...=...................",   data: ["240", "0", "1", "2", "3", "4"]},
  { name: "rdPixEnable", wave: "0...1..................."},
  { name: "picClkEnable", wave: "0.......1..............."},
  { name: "pixClk",   wave: "0.........1.0.1.0.1.0.1.",},
  { name: "rdPix",    wave: "0......1.0.1.0.1.0.1.0.1"},
  { name: "addr",     wave: "x.....=...=...=...=...=.",   data: ["$0", "$1", "$2", "$3", "$4"]},
  { name: "data",     wave: "x..........=...=...=...=",   data: ["0", "1", "2", "3", "4"]},
]}
*/
