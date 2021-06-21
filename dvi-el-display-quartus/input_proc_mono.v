module input_proc_mono (DE, pixClk, Vsync, Hsync, red, green, blue, addr, pixData, wrPix);

input [7:0] red, green, blue;
input DE, pixClk, Vsync, Hsync;
output [14:0] addr;
output [3:0]  pixData;
output wrPix;

reg debug = 0;
reg [3:0]  pixData;
reg [1:0]  pixCounter;
reg lineOdd;
reg wrPix;
reg [14:0] lineCounter;
reg [14:0] colCounter;

assign addr = colCounter+(lineCounter*15'h0050);

//assign addr = 16'h0000;

always @ (posedge pixClk) begin
	if (!Hsync) begin 
		colCounter <= 15'h0000;
		wrPix <= 0;
		pixCounter <= 0;
	end
	if (!Vsync) begin
		colCounter <= 15'h0000;
		wrPix <= 0;
		pixCounter <= 0;
	end
	if (!lineOdd && DE) begin
		case (pixCounter)
			0: begin
				wrPix <= 0;
				pixData[3] <= red > 50;
			end
			1: begin
				pixData[2] <= red > 50;
			end
			2: begin
				pixData[1] <= red > 50;
			end
			3: begin
				pixData[0] <= red > 50;
				wrPix <= 1;
				colCounter <= colCounter +15'h0001;
			end
		endcase
		
		pixCounter <= pixCounter +1;
		
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
