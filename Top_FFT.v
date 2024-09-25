module Top_FFT
#(
	parameter N_pt = 128,
	parameter cnt_num = $clog2(N_pt/2), // 6 => 64(2^6)
	parameter in_BW = 16,
	parameter cut_BW = 7,
	parameter out_BW = in_BW + cut_BW
)
(
	input wire reset_n,
	input wire clk,
	input wire valid,
	input wire start,
	input wire [in_BW-1:0] inReal,
	input wire [in_BW-1:0] inImag,

	output wire [(out_BW - cut_BW)-1:0] outReal,
	output wire [(out_BW- cut_BW)-1:0] outImag
);

//declare
wire [in_BW	:0]  sig1[1:0];
wire [in_BW+1:0] sig2[1:0];
wire [in_BW+2:0] sig3[1:0];
wire [in_BW+3:0] sig4[1:0];
wire [in_BW+4:0] sig5[1:0];
wire [in_BW+5:0] sig6[1:0];

wire [cnt_num:0] cnt; //7bit
wire en_s1;
wire en_s2;
wire [1:0] en_s3;
wire [2:0] en_s4;
wire 		en_s5;
wire en_s6;
wire en_s7;

//Stage1~7
Stage#(.BW(in_BW),.N_pt(64))
Stage1(
	.clk		(clk),
	.reset_n	(reset_n),
	.inReal		(inReal),
	.inImag		(inImag),
	.cnt		(cnt[cnt_num-1:0]), //64
	.bf_en		(en_s1),
	.valid		(valid),
	.outReal	(sig1[0]),
	.outImag 	(sig1[1])
);

Stage#(.BW(in_BW + 1),.N_pt(32))
Stage2(
	.clk		(clk),
	.reset_n	(reset_n),
	.inReal		(sig1[0]),
	.inImag		(sig1[1]),
	.cnt		(cnt[cnt_num-2:0]), //32
	.bf_en		(en_s2),
	.valid		(valid),
	.outReal	(sig2[0]),
	.outImag 	(sig2[1])
);

Stage#(.BW(in_BW + 2),.N_pt(16))
Stage3(
	.clk		(clk),
	.reset_n	(reset_n),
	.inReal		(sig2[0]),
	.inImag		(sig2[1]),
	.cnt		(cnt[cnt_num-3:0]), //16
	.bf_en		(en_s3[1]),
	.valid		(valid),
	.outReal	(sig3[0]),
	.outImag 	(sig3[1])
);

Stage#(.BW(in_BW + 3),.N_pt(8))
Stage4(
	.clk		(clk),
	.reset_n	(reset_n),
	.inReal		(sig3[0]),
	.inImag		(sig3[1]),
	.cnt		(cnt[cnt_num-4:0]), //8
	.bf_en		(en_s4[2]),
	.valid		(valid),
	.outReal	(sig4[0]),
	.outImag 	(sig4[1])
);

Stage#(.BW(in_BW + 4),.N_pt(4))
Stage5(
	.clk		(clk),
	.reset_n	(reset_n),
	.inReal		(sig4[0]),
	.inImag		(sig4[1]),
	.cnt		(cnt[cnt_num-5:0]), //4
	.bf_en		(en_s5),
	.valid		(valid),
	.outReal	(sig5[0]),
	.outImag 	(sig5[1])
);

Stage#(.BW(in_BW + 5),.N_pt(2))
Stage6(
	.clk		(clk),
	.reset_n	(reset_n),
	.inReal		(sig5[0]),
	.inImag		(sig5[1]),
	.cnt		(cnt[cnt_num-6:0]), //2
	.bf_en		(en_s6),
	.valid		(valid),
	.outReal	(sig6[0]),
	.outImag 	(sig6[1])
);

Last_Stage#(.BW(in_BW + 6))
Stage7(
	.clk		(clk),
	.reset_n	(reset_n),
	.inReal		(sig6[0]),
	.inImag		(sig6[1]),
	.bf_en		(en_s7),
	.valid		(valid),
	.outReal	(outReal),
	.outImag 	(outImag)
);

//counter
counter#(.N(N_pt))
Counter(
	.clk		(clk),
	.valid		(valid),
	.start		(start),
	.reset_n	(reset_n),
	.cnt		(cnt) //7bit[6:0]
);

//Butterfly_Enable_gen
BF_En_gen
bf_gen(
	.clk		(clk),
	.reset_n	(reset_n),
	.valid		(valid),
	.cnt		(cnt),

	.en_s1		(en_s1),
	.en_s2		(en_s2),
	.en_s3		(en_s3),
	.en_s4		(en_s4),
	.en_s5		(en_s5),
	.en_s6		(en_s6),
	.en_s7		(en_s7)
);




endmodule