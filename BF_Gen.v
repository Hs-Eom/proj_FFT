module BF_En_gen(
	input wire clk,
	input wire reset_n,
	input wire valid,
	input wire [6:0] cnt,

	output wire 		en_s1,
	output reg 			en_s2,
	output reg [1:0] 	en_s3,
	output reg [2:0]	en_s4,
	output wire 		en_s5,
	output reg			en_s6,
	output wire			en_s7
);

assign en_s1 = cnt[6]; // counting 64cycle

always@(posedge clk) begin
	if(!reset_n) begin
		en_s2 <= 0;
	end
	else begin
		en_s2 <= cnt[5]; //+1 clk
	end
end
 	
always@(posedge clk) begin
	if(!reset_n) begin
		en_s3 <= 0;
	end
	else begin
		en_s3[0] <= cnt[4]; //+2clk
		en_s3[1] <= en_s3[0];
	end
end

always@(posedge clk) begin
	if(!reset_n) begin
		en_s4 <= 0;
	end
	else begin
		en_s4[1:0] <= cnt[3]; //+3clk
		en_s4[2:1] <= en_s4[1:0];
	end
end

assign en_s5 = ~cnt[2]; //+4clk = ~cnt[2]

always@(posedge clk) begin
	if(!reset_n) begin
		en_s6 <= 0;
	end
	else begin
		en_s6 <= cnt[1]; //+5clk = +1clk
	end
end

assign en_s7 = cnt[0]; // +6clk equal cnt[0]

endmodule