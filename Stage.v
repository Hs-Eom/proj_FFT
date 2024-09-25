module Stage#(
	parameter BW = 16,
	parameter N_pt = 64,
	parameter cnt_num = $clog2(N_pt)
)
(
	input wire 					clk,
	input wire 					reset_n,
	input wire [BW-1:0] 		inReal,
	input wire [BW-1:0] 		inImag,
	input wire [cnt_num-1 :0] 	cnt,
	input wire 					bf_en,
	input wire					valid,
	
	output wire [BW: 0] 		outReal,
	output wire [BW: 0] 		outImag
);

//declare
wire [BW-1:0] r_Real; 
wire [BW-1:0] r_Imag;
wire [BW : 0] bf_P [1:0];
wire [BW : 0] bf_M [1:0];
wire [BW : 0] sr_out [1:0];
wire [BW:0] Mux_P[1:0];
wire [BW:0] Mux_M[1:0];
wire [BW:0] mult_out [1:0];
//D FF
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

//butterfly calc
BF_calc#(.BW(BW))
BF(
	.In_R(r_Real),
    .In_I(r_Imag),
    .Sr_R({sr_out[0][BW], sr_out[0][BW-2:0]}), //bit reduction
	.Sr_I({sr_out[1][BW],sr_out[1][BW-2:0]}),
    
	.P_R(bf_P[0]),
    .P_I(bf_P[1]),
    .M_R(bf_M[0]),
    .M_I(bf_M[1])
);

//Shift_Register(N/2)
Shift_Reg#(.BW(BW+1), .N(N_pt))
Sr_R(
	.clk		(clk),
	.reset_n	(reset_n),
	.valid		(valid),
	.Sr_in		(Mux_M[0]),
	.Sr_out		(sr_out[0])
);

Shift_Reg#(.BW(BW+1), .N(N_pt))
Sr_I(
	.clk		(clk),
	.reset_n	(reset_n),
	.valid		(valid),
	.Sr_in		(Mux_M[1]),
	.Sr_out		(sr_out[1])
);

//mux
assign Mux_P[0] = bf_en ? bf_P[0] : sr_out[0];
assign Mux_P[1] = bf_en ? bf_P[1] : sr_out[1];

assign Mux_M[0] = bf_en ? bf_M[0] : {r_Real[BW-1],r_Real};
assign Mux_M[1] = bf_en ? bf_M[1] : {r_Imag[BW-1],r_Imag};

//Multiplier
Mult#(.BW(BW+1), .N_pt(N_pt))
uMult(
	.in_Real(Mux_P[0]),
	.in_Imag(Mux_P[1]),
	.cnt(cnt), 

	.out_Real(mult_out[0]),
	.out_Imag(mult_out[1])
);

//mux
assign outReal = bf_en? Mux_P[0] : mult_out[0];
assign outImag = bf_en? Mux_P[1] : mult_out[1];

endmodule