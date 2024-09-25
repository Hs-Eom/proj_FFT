module Last_Stage
#(
	parameter BW = 22
)
(
	input wire clk,
	input wire reset_n,
	input wire [BW-1:0] inReal,
	input wire [BW-1:0] inImag,
	input wire bf_en,
	input wire valid,

	output wire [BW:0] outReal,
	output wire [BW:0] outImag
);

//declare wire
wire [BW-1:0] r_Real;
wire [BW-1:0] r_Imag;
wire [BW: 0] sr_out [1:0];
wire [BW:0] Mux_P[1:0];
wire [BW:0] Mux_M[1:0];
wire [BW : 0] bf_P [1:0];
wire [BW : 0] bf_M [1:0];

REG#(.N(BW))
uReg_R(
	.reset_n	(reset_n),
    .clk		(clk),
    .en			(1),
    .d			(inReal),
	.q			(r_Real)
);
REG#(.N(BW))
uReg_I(
	.reset_n	(reset_n),
    .clk		(clk),
    .en			(1),
    .d			(inImag),
	.q			(r_Imag)
);

BF_calc#(.BW(BW))
BF(
	.In_R(r_Real),
    .In_I(r_Imag),
    .Sr_R({sr_out[0][BW],sr_out[0][BW-2:0]}),
	.Sr_I({sr_out[1][BW],sr_out[1][BW-2:0]}),
    
	.P_R(bf_P[0]),
    .P_I(bf_P[1]),
    .M_R(bf_M[0]),
    .M_I(bf_M[1])
);

REG#(.N(BW+1))
Sr_R(
	.clk		(clk),
	.reset_n	(reset_n),
	.en			(1),
	.d			(Mux_M[0]),
	.q			(sr_out[0])
);

REG#(.N(BW+1))
Sr_I(
	.clk		(clk),
	.reset_n	(reset_n),
	.en			(1),
	.d			(Mux_M[1]),
	.q			(sr_out[1])
);


assign Mux_P[0] = bf_en ? bf_P[0] : sr_out[0];
assign Mux_P[1] = bf_en ? bf_P[1] : sr_out[1];

assign Mux_M[0] = bf_en ? bf_M[0] : {r_Real[BW-1],r_Real};
assign Mux_M[1] = bf_en ? bf_M[1] : {r_Imag[BW-1],r_Imag};

REG#(.N(BW+1))
out_Real(
	.reset_n	(reset_n),
    .clk		(clk),
    .en			(1),
    .d			(Mux_P[0]),
	.q			(outReal)
);

REG#(.N(BW+1))
out_Imag(
	.reset_n	(reset_n),
    .clk		(clk),
    .en			(1),
    .d			(Mux_P[1]),
	.q			(outImag)
);

endmodule
