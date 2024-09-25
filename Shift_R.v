module Shift_Reg
#(
	parameter BW = 16,
	parameter N = 64
)
(
	input wire clk,
	input wire reset_n,
	input wire valid,
	input wire [BW-1: 0] Sr_in,
	output wire [BW-1:0] Sr_out
);
integer i;
reg [BW-1:0] sr [N-1:0];

always @(posedge clk) begin
	if(!reset_n) begin
		for(i = 0; i < N; i= i+1) begin
			sr[i] <= 0;	
		end
	end
	else if(valid) begin
		for(i =1; i < N; i= i+1) begin
			sr[i] <= sr [i-1];
		end	
	end
end

always@(posedge clk) begin
	if(!reset_n) begin
		sr[0] <= 0;
	end
	else if(valid) begin
		sr[0] <= Sr_in;
	end
end

assign Sr_out = sr[N-1];
endmodule