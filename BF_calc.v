module BF_calc#(
	parameter BW = 16
)
(
	input wire [BW-1:0] In_R,
	input wire [BW-1:0] In_I,
	input wire [BW-1:0] Sr_R, //16bit
	input wire [BW-1:0] Sr_I,
	
	output wire [BW:0] P_R,
	output wire [BW:0] P_I,
	output wire [BW:0] M_R,
	output wire [BW:0] M_I
);

assign P_R = In_R + Sr_R;
assign P_I = In_I + Sr_I;
assign M_R = In_R - Sr_R;
assign M_I = In_I - Sr_I;

endmodule