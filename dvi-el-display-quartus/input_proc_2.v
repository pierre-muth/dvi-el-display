module input_proc_2 (DE, pixClk, Vsync, Hsync, red, green, blue, addr, pixData, wrPix);

input [7:0] red, green, blue;
input DE, pixClk, Vsync, Hsync;
output [14:0] addr;
output [7:0]  pixData;
output wrPix;

reg debug = 0;
reg [7:0]  pixData;
reg [8:0]  pixCounter;
reg lineOdd;
reg wrPix;
reg [14:0] lineCounter;
reg [14:0] colCounter;
reg [7:0] lineMem [0:319];

assign addr = colCounter+(lineCounter*15'h0050);

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
	if (DE) begin
		if (lineOdd) begin
			case (pixCounter%8)
				0: begin
					pixData[3] <= red > 50;
					pixData[7] <= red > 150;
				end
				1: begin
					wrPix <= 0;
				end
				2: begin
					pixData[2] <= red > 50;
					pixData[6] <= red > 150;
				end
				3: begin
				end
				4: begin
					pixData[1] <= red > 50;
					pixData[5] <= red > 150;
				end
				5: begin
				end
				6: begin
					pixData[0] <= red > 50;
					pixData[4] <= red > 150;
					wrPix <= 1;
				end
				7: begin
					colCounter <= colCounter +15'h0001;
				end
			endcase
			pixCounter <= pixCounter + 8'b1;
		end else begin
			lineMem[pixCounter] <= red;
			pixCounter <= pixCounter + 8'b1;
		
		end
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
