module pixel_gen (Vclk, VS, HS, pixData);

input Vclk, VS, HS;
output [3:0] pixData;
reg [3:0] pixData;
reg [7:0] pix4count;
reg [7:0] lineCount;
reg  frame;

always @ (posedge Vclk) begin
	if (pix4count >= 80) pix4count = 0; 
	else pix4count = pix4count +1;

	case (frame) 
		0 : begin
			if (pix4count<50 && pix4count>20) begin
				if (lineCount%2) pixData <= 4'b1010;
				else pixData <= 4'b0101;
			end
			else pixData <= 4'b0000;
		end
		1 : begin
			if (pix4count<50 && pix4count>20) begin
				if (lineCount%2) pixData <= 4'b1010;
				else pixData <= 4'b0101;
			end
			else pixData <= 4'b0000;
		end
	endcase 

end

always @(posedge VS) begin
	frame = !frame;
end

always @(posedge HS) begin
	lineCount = lineCount +1;
	if (lineCount >= 240) lineCount = 0;
end

endmodule

