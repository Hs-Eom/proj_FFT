`timescale 1ns/1ps

module axi_slave_FFT_f_ps#(
    parameter   WIDTH_ID = 15,
    parameter   WIDTH_AD = 14,
    parameter   WIDTH_DA = 32,
    parameter   WIDTH_DS = 4
)
(

    //ctrl input
    input   wire                    S_AXI_ACLK,
    input   wire                    S_AXI_ARESETN,
    
    //Addr Write
    input   wire [WIDTH_SID-1:0]    S_AXI_AWID,
    input   wire [WIDTH_AD-1:0]     S_AXI_AWADDR,
    input   wire [7:0]              S_AXI_AWLEN,
    input   wire [2:0]              S_AXI_AWSIZE,
    input   wire [1:0]              S_AXI_AWBURST,
    input   wire                    S_AXI_AWVALID,
    output  wire                    S_AXI_AWREADY,

    //Write Data
    input   wire [WIDTH_SID-1:0]    S_AXI_WID,
    input   wire [WIDTH_DA-1:0]     S_AXI_WDATA,
    input   wire [WIDTH_DS-1:0]     S_AXI_WSTRB,
    input   wire                    S_AXI_WLAST,
    input   wire                    S_AXI_WVALID,
    output  wire                    S_AXI_WREADY,

    //Response(B)
    output  wire [WIDTH_SID-1:0]    S_AXI_BID,
    output  wire [1:0]              S_AXI_BRESP,
    output  reg                     S_AXI_BVALID,
    input   wire                    S_AXI_BREADY,

    //Addr Read
    input   wire [WIDTH_SID-1:0]    S_AXI_ARID,
    input   wire [WIDTH_AD-1:0]     S_AXI_ARADDR,
    input   wire [7:0]              S_AXI_ARLEN,
    input   wire [2:0]              S_AXI_ARSIZE,
    input   wire [1:0]              S_AXI_ARBURST,
    input   wire                    S_AXI_ARVALID,
    output  wire                    S_AXI_ARREADY,

    //Read Data
    output wire [WIDTH_SID-1:0]     S_AXI_RID,
    output wire [WIDTH_DA-1:0]      S_AXI_RDATA,
    output wire [1:0]               S_AXI_RRESP,
    output wire                     S_AXI_RLAST,
    output wire                     S_AXI_RVALID,
    input  wire                     S_AXI_RREADY
);

/////////////// Signal  //////////////////////////////
//////////  WFIFO signals   ///////////////
wire W_wr_vld;
wire W_rd_rdy;
wire W_rd_vld;
//////////  RFIFO signals   ///////////////
wire R_wr_vld;
wire R_rd_rdy;
wire R_rd_vld;
///////////  AW signal   /////////////////
wire [WIDTH_SID-1:0] awid;

////////////////////////////////////////////////////

////////////////    Channel ////////////////////////
//////////// AW Channel //////////////////

assign W_wr_vld = S_AXI_AWREADY && S_AXI_AWVALID;

//////////// W Channel ///////////////////

assign S_AXI_WREADY = W_rd_vld;

assign W_rd_rdy = S_AXI_WLAST && S_AXI_WVALID && S_AXI_WREADY;
//////////// B Channel/////////////////////
always @(S_AXI_ACLK) begin
    if(!S_AXI_ARESETN) begin
        S_AXI_BID <= 0;
    end
    else begin
        if(S_AXI_WLAST && S_AXI_WVALID && S_AXI_WREADY) begin
            s_axi_bid <= awid;
        end
    end
end

always @(S_AXI_ACLK) begin
    if(!S_AXI_ARESETN) begin
        S_AXI_BVALID <= 0;
    end
    else begin
        if(S_AXI_WLAST && S_AXI_WVALID && S_AXI_WREADY) begin
            S_AXI_BVALID <= 1;
        end
        else if(S_AXI_BREADY) begin
            S_AXI_BVALID <= 0;
        end
    end
end

assign S_AXI_BRESP = 2'b00;
//////////// AR Channel ///////////////////
assign R_wr_vld = S_AXI_ARVALID && S_AXI_ARREADY;

//////////// R Channel ////////////////////
assign R_rd_rdy = S_AXI_RLAST && S_AXI_RVALID && S_AXI_RREADY;

assign S_AXI_RRESP = 2'b00;

assign S_AXI_RVALID = R_rd_vld;
assign S_AXI_RLAST = R_rd_vld; 
//////////////////////////////////////////////

/////////////////   FIFO //////////////////////////////////////
////////// W_FIFO /////////////////////////////////
axi_slave_fifo_sync
W_FIFO(
    .reset_n    (S_AXI_ARESETN),
    .clk        (S_AXI_ACLK),    
    .wr_rdy     (S_AXI_AWREADY), //output to ps
    .wr_vld     (W_wr_vld), //valid write addr => need handshake
    .wr_din     (S_AXI_AWID), 
    .rd_rdy     (W_rd_rdy), //input from ps
    .rd_vld     (W_rd_vld),     //output to ps
    .rd_dout    (awid)          //
);

////////// W_FIFO /////////////////////////////////
axi_slave_fifo_sync
R_FIFO(
    .reset_n    (S_AXI_ARESETN),
    .clk        (S_AXI_ACLK),
    .wr_rdy     (S_AXI_ARREADY),
    .wr_vld     (R_wr_vld),
    .wr_din     (S_AXI_ARID), 
    .rd_rdy     (R_rd_rdy), 
    .rd_vld     (R_rd_vld), 
    .rd_dout    (S_AXI_RID)  
);

//////////////////IP(FFT)//////////////////////
wire start_FFT = !(S_AXI_WDATA == 32'h7FFFFFFF);

Top_FFT
FFT_128pt(
    .reset_n    (start_FFT),
    .clk        (S_AXI_ACLK),
    .valid      (S_AXI_WREADY && saxi S_AXI_WVALID),

    .start      (start_FFT),
    .inReal     (S_AXI_WDATA[31:16]),
    .inImag     (S_AXI_WDATA[15:0]),

    .outReal    (S_AXI_RDATA[31:16]),
    .outImag    (S_AXI_RDATA[15:0])
);

endmodule