module input_proc_5 (DE, pixClk, pixClkshift, Vsync, Hsync, red, green, blue, addr, pixData, wrPix);

input [7:0] red, green, blue;
input DE, pixClk, pixClkshift, Vsync, Hsync;
output [14:0] addr;
output [7:0]  pixData;
output wrPix;

reg debug = 0;
reg [7:0]  pixData;
reg wrPix, lineOdd;
reg [9:0]  pixCounter;
reg [14:0] lineCounter;
reg [9:0] lineMem [0:3];
reg [14:0] addr;
reg [9:0] th;
wire [9:0] color;

assign color[9:0] = (red + green + blue)/3;

//thMap44 = {{1, 9, 3, 11},{13, 5, 15, 7},{4, 12, 2, 10},{16, 8, 14, 6}};

always @ (posedge pixClk) begin
	if (DE) begin
		if (!lineOdd) begin
			addr <= (pixCounter>>2)+((lineCounter)*15'h0050);					
			
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
			
			lineMem[pixCounter%4] <= color+(th*3);
		end
		
	end 
end

always @ (posedge pixClkshift) begin
	if (DE) begin
		if (!lineOdd && ((pixCounter & 10'h0003) == 10'h0003) ) begin
			pixData[3] <= (lineMem[(pixCounter%4)-3]) >10'd100;
			pixData[2] <= (lineMem[(pixCounter%4)-2]) >10'd100;
			pixData[1] <= (lineMem[(pixCounter%4)-1]) >10'd100;
			pixData[0] <= (lineMem[(pixCounter%4)]  ) >10'd100;
			
			pixData[7] <= (lineMem[(pixCounter%4)-3]) >10'd200;
			pixData[6] <= (lineMem[(pixCounter%4)-2]) >10'd200;
			pixData[5] <= (lineMem[(pixCounter%4)-1]) >10'd200;
			pixData[4] <= (lineMem[(pixCounter%4)]  ) >10'd200;			
		end
	end 
end

always @ (negedge pixClkshift) begin
	if (DE && !lineOdd) begin
		
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
		if (lineOdd) lineCounter <= lineCounter +15'h0001;
	end 

end

endmodule
