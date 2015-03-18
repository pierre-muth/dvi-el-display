# Quartus2 project #

![http://muth.inc.free.fr/planar/screen03.jpg](http://muth.inc.free.fr/planar/screen03.jpg)

# Output process #

Output process generate horizontal and vertical timings signals for the EL320.240.36 and the address bus for the dual port RAM storing the image. VS is off if screen is blank for some time as screen saver.

## Code Details ##

```
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
	if (pixBlankCheck > 2) begin
		pixCounter <= pixCounter +1;
		screenSaving <= 0;
		blankScreenCounter <= 0;
	end 
	
	if (counterYmaxed && counterXmaxed) begin
		if (pixCounter < 2) begin
			blankScreenCounter <= blankScreenCounter +1;
		end else begin
			pixCounter <= 0;
		end
	end
	
	if (blankScreenCounter > 2000) begin 
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
http://wavedrom.googlecode.com/svn/trunk/editor.html

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

```

# Half tone  generator #

To generate one half-tone, skip one frame over two. In the frame buffer, pixels are coded on 2 bits reprenting the two frames alternating each other.

## Code Details ##
```
module half_tone_gen (data_in, VS, pix_data);

input [7:0] data_in;
input VS;
output [3:0] pix_data;
reg frame;

assign pix_data = (frame) ? data_in[7:4] : data_in[3:0];

always @(posedge VS) begin
	frame <= !frame;
end

endmodule
```

# Input Process #

Input process use signals from TFP401 to fill the frame buffer. the 3 colors red, green, blue, are averaged, and dither according the black, grey and white of the EL screen.

## Code Details ##
```
module input_proc_6 (DE, pixClk, pixClkshift, Vsync, Hsync, red, green, blue, addr, pixData, wrPix);

//parameter pixBlank = 15'h000A;

input [7:0] red, green, blue;
input DE, pixClk, pixClkshift, Vsync, Hsync;
output [14:0] addr;
output [7:0]  pixData;
output wrPix;

reg debug = 0;
reg [7:0]  pixData;
reg wrPix, lineOdd;
reg [14:0]  pixCounter;
reg [14:0] lineCounter;
reg [9:0] lineMem [0:3];
reg [14:0] addr;
reg [9:0] th;
wire [9:0] color;

assign color[9:0] = (red + green + blue)/3;

//thMap44 = {{1, 9, 3, 11},{13, 5, 15, 7},{4, 12, 2, 10},{16, 8, 14, 6}};

always @ (posedge pixClk) begin
	if (DE) begin
		if (pixCounter >= 200 && pixCounter < 520) begin
			addr <= ((pixCounter-200)>>2)+((lineCounter)*15'h0050);					
			
			case (lineCounter%4)
				0: begin
					case (pixCounter%4)
						0: th <= 1;
						1: th <= 9;
						2: th <= 3;
						3: th <= 11;
					endcase
				end
				1: begin
					case (pixCounter%4)
						0: th <= 13;
						1: th <= 5;
						2: th <= 15;
						3: th <= 7;
					endcase
				end
				2: begin
					case (pixCounter%4)
						0: th <= 4;
						1: th <= 12;
						2: th <= 2;
						3: th <= 10;
					endcase
				end
				3: begin
					case (pixCounter%4)
						0: th <= 16;
						1: th <= 8;
						2: th <= 14;
						3: th <= 6;
					endcase
				end
			endcase
			
			lineMem[pixCounter%4] <= color+(th*6);
		end
		
	end 
end

always @ (posedge pixClkshift) begin
	if (DE) begin
		if ( ((pixCounter & 10'h0003) == 10'h0003) ) begin
			pixData[3] <= (lineMem[(pixCounter%4)-3]) >10'd120;
			pixData[2] <= (lineMem[(pixCounter%4)-2]) >10'd120;
			pixData[1] <= (lineMem[(pixCounter%4)-1]) >10'd120;
			pixData[0] <= (lineMem[(pixCounter%4)]  ) >10'd120;
			
			pixData[7] <= (lineMem[(pixCounter%4)-3]) >10'd230;
			pixData[6] <= (lineMem[(pixCounter%4)-2]) >10'd230;
			pixData[5] <= (lineMem[(pixCounter%4)-1]) >10'd230;
			pixData[4] <= (lineMem[(pixCounter%4)]  ) >10'd230;			
		end
	end 
end

always @ (negedge pixClkshift) begin
	if (DE ) begin
		
		pixCounter <= pixCounter + 10'h0001;	
		
		if ((pixCounter & 10'h0003) == 10'h0003) begin
			wrPix <= 1;
		end else begin
			wrPix <= 0;
		end	
		
	end else begin
		wrPix <= 0;
		pixCounter <= 0;
	end
	
	
end

always @ (negedge Vsync or negedge DE) begin
	if (Vsync == 0) begin 
		lineCounter <= 0;
		lineOdd <= 0;
	end else begin
		lineOdd <= !lineOdd;
		lineCounter <= lineCounter +15'h0001;
	end 

end

endmodule

```