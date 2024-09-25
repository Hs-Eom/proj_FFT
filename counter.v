module counter
#(
	parameter N = 128,
	parameter num = $clog2(N)
)
(
	input wire 		clk,
	input wire 		valid,
	input wire 		start,
	input wire 		reset_n,

	output reg [num-1:0] cnt
);

always@(posedge clk) begin
	if(!reset_n) begin
		cnt <= ~(0);
	end
	else if(!(start) && valid)
		cnt <= ~(0);
	else if(valid) begin
		cnt <= cnt + 1;
	end
end

endmodule