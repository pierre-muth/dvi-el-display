module address_scanner (Vclk, VS, HS, address);

input Vclk, VS, HS;
output [14:0] address;
reg [14:0] address;

always @ (posedge Vclk) begin
	if (VS && address > 100) address = 0;
	else address = address +1'b1;
end


endmodule
