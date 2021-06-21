module divider ( clock_in, clock_out);

input clock_in;
output clock_out;

reg [12:0] count;
reg clock_out;

parameter factor = 1000;

initial begin

	count = 0;

end

always @ (posedge clock_in) begin
	count = count +1;
	if (count >= factor) begin
		count = 0;
		clock_out = !clock_out;
	end
end

endmodule