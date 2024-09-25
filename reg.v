module REG#(
	parameter N = 1
)
(
	input wire			reset_n,
	input wire			clk,
	input wire			en,
	input wire [N-1:0]	d,
	output reg [N-1:0] 	q
);

always@(posedge clk) begin
	if(!reset_n) begin
		q <= 0;
	end
	else if(en) begin
		q <= d;
	end
end

endmodule