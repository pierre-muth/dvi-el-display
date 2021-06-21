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