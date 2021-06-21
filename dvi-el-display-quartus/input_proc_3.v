module input_proc_3 (DE, pixClk, pixClkDoubled, Vsync, Hsync, red, green, blue, addr, pixData, wrPix);

input [7:0] red, green, blue;
input DE, pixClk, pixClkDoubled, Vsync, Hsync;
output [14:0] addr;
output [7:0]  pixData;
output wrPix;

reg debug = 0;
reg [7:0]  pixData;
reg wrPix;
reg [9:0]  pixCounter;
reg [14:0] lineCounter;
reg [9:0] lineMem [0:320];
reg [14:0] addr;
wire [9:0] color;

//assign color[9:0] = (red + green + blue)/3;
assign color[9:0] = (red+blue) /2;

always @ (negedge pixClkDoubled) begin
	if (DE) begin
		if (pixClk) begin
			
		end else begin
			if (lineCounter[0]==0) begin
				if (pixCounter[0]==0) begin
					lineMem[pixCounter>>1] <= color;
				end else begin
					lineMem[pixCounter>>1] <= lineMem[pixCounter>>1] + color;
				end
			end else begin
				lineMem[pixCounter>>1] <= lineMem[pixCounter>>1] + color;
			end
			
		end
	end 
end

always @ (posedge pixClkDoubled) begin
	if (DE) begin
		if (pixClk) begin
			pixCounter <= pixCounter + 10'h0001;
			if( lineCounter%2 && ((pixCounter & 10'h0007) == 10'h0007) ) begin
				wrPix <= 1;
			end
		end else begin
			if( lineCounter%2 && (pixCounter & 10'h0007 == 10'h0007) ) begin
				pixData[3] <= (lineMem[(pixCounter>>1)-3] >>2) >10'd50;
				pixData[2] <= (lineMem[(pixCounter>>1)-2] >>2) >10'd50;
				pixData[1] <= (lineMem[(pixCounter>>1)-1] >>2) >10'd50;
				pixData[0] <= (lineMem[(pixCounter>>1)]   >>2) >10'd50;
				
				pixData[7] <= (lineMem[(pixCounter>>1)-3] >>2) >10'd150;
				pixData[6] <= (lineMem[(pixCounter>>1)-2] >>2) >10'd150;
				pixData[5] <= (lineMem[(pixCounter>>1)-1] >>2) >10'd150;
				pixData[4] <= (lineMem[(pixCounter>>1)]   >>2) >10'd150;
				
				addr <= (pixCounter>>3)+((lineCounter>>1)*15'h0050);
			end
			wrPix <= 0;
		end
	end else begin
		pixCounter <= 10'h0000;
	end
end

always @ (negedge Vsync or negedge DE) begin
	if (Vsync == 0) begin 
		lineCounter <= 0;
	end else begin
		lineCounter <= lineCounter +15'h0001;
	end

end

endmodule
