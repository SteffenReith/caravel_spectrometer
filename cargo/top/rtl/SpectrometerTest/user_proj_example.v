// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * spectrometer
 *
 *-------------------------------------------------------------
 */

`ifdef SIM
`include "wbm2axisp.v"
`include "skidbuffer.v"
`include "SpectrometerTest.v"
`include "plusarg_reader.v"
`endif

module user_proj_example (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb
);

// Logic Analyzer Signals
    wire [127:0] la_data_in;
    wire [127:0] la_data_out;
    wire [127:0] la_oen;

// IOs
    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

// AXI write address channel signals
	wire 		w_o_axi_awvalid;	// Write address valid
	wire 		w_i_axi_awready; 	// Slave is ready to accept
	wire 		w_o_axi_awid;		// Write ID
	wire [33:0] w_o_axi_awaddr;		// Write address
	wire [7:0]  w_o_axi_awlen;		// Write Burst Length
	wire [2:0]  w_o_axi_awsize;		// Write Burst size
	wire [1:0]  w_o_axi_awburst;	// Write Burst type
	wire [0:0]  w_o_axi_awlock;		// Write lock type
	wire [3:0]  w_o_axi_awcache;	// Write Cache type
	wire [2:0]  w_o_axi_awprot;		// Write Protection type
	wire [3:0]  w_o_axi_awqos;		// Write Quality of Svc
// AXI write data channel signals
	wire 		w_o_axi_wvalid;		// Write valid
	wire 		w_i_axi_wready;  	// Write data ready
	wire [31:0]	w_o_axi_wdata;		// Write data
	wire [3:0]  w_o_axi_wstrb;		// Write strobes
	wire 		w_o_axi_wlast;		// Last write transaction
// AXI write response channel signals
 	wire 		w_i_axi_bvalid;		// Write reponse valid
	wire 		w_o_axi_bready;  	// Response ready
	wire 		w_i_axi_bid;		// Response ID
	wire [1:0]  w_i_axi_bresp;		// Write response
// AXI read address channel signals
	wire        w_o_axi_arvalid;	// Read address valid
	wire        w_i_axi_arready;	// Read address ready
	wire [0:0]  w_o_axi_arid;		// Read ID
	wire [33:0]	w_o_axi_araddr;		// Read address
	wire [7:0]  w_o_axi_arlen;		// Read Burst Length
	wire [2:0]  w_o_axi_arsize;		// Read Burst size
	wire [1:0]  w_o_axi_arburst;	// Read Burst type
	wire [0:0]  w_o_axi_arlock;		// Read lock type
	wire [3:0]  w_o_axi_arcache;	// Read Cache type
	wire [2:0]  w_o_axi_arprot;		// Read Protection type
	wire [3:0]  w_o_axi_arqos;		// Read Protection type
// AXI read data channel signals
	wire 		w_i_axi_rvalid;  	// Read reponse valid
	wire 		w_o_axi_rready;  	// Read Response ready
	wire [0:0] 	w_i_axi_rid;     	// Response ID
	wire [31:0] w_i_axi_rdata;    	// Read data
	wire [1:0]  w_i_axi_rresp;   	// Read response
	wire 		w_i_axi_rlast;    	// Read last

// Wires for inStream and outStream
	wire 	   w_inStream_ready;
	wire 	   w_inStream_valid;
	wire [7:0] w_inStream_data;
	wire 	   w_inStream_last;

	wire 	   w_outStream_ready;
	wire 	   w_outStream_valid;
	wire [7:0] w_outStream_data;
	wire 	   w_outStream_last;

// Wires for uart
	wire w_uart_int;
	wire w_uart_tx;
	wire w_uart_rx;

// Assign inStream signals
	genvar i;

	assign io_oeb[0]    = 1'b0;    //fix pin to output
	assign io_oeb[10:1] = 10'h3ff; //fix pins to inputs

	assign io_out[10:1] = 10'h333; // drive unused outputs

	assign io_out[0] 			= w_inStream_ready;
	assign w_inStream_valid  	= io_in[1];
	assign w_inStream_data[7:0] = io_in[9:2];
	assign w_inStream_last 		= io_in[10];

// Assign outStream signals
	assign io_oeb[11]    = 1'b1;    // fix pin to input
	assign io_oeb[21:12] = 10'h000; // fix pins to outputs

	assign io_out[11]    = 1'b1;	// drive unused outputs  

	assign w_outStream_ready = io_in[11];
	assign io_out[12]        = w_outStream_valid;
	assign io_out[20:13] 	 = w_outStream_data[7:0];
	assign io_out[21]    	 = w_outStream_last;

// set uart pins
	assign io_oeb[22] = 1'b0;		// uart_int is output
	assign io_out[22] = w_uart_int;
	assign io_oeb[23] = 1'b0;		// uart_tx is output
	assign io_out[23] = w_uart_tx;
	assign io_out[24] = 1'b0;		
	assign io_oeb[24] = 1'b1;		// uart_rx is input
	assign w_uart_rx  = io_in[24];

// Drive remaining io pins
	assign io_out[`MPRJ_IO_PADS-1:25] = 13'h1666;
	assign io_oeb[`MPRJ_IO_PADS-1:25] = 13'h0000;

// Drive LA with zeroes
	assign la_data_out = {128{1'b0}};

// Wishbone to AXI4
	wbm2axisp #(
		.C_AXI_DATA_WIDTH(32),	// Width of the AXI R&W data
		.C_AXI_ADDR_WIDTH(34),	// AXI Address width (log wordsize)
		.C_AXI_ID_WIDTH(1),
		.DW(32),				// Wishbone data width
		.AW(32),   				// Wishbone address width (log wordsize)
		.AXI_WRITE_ID(1'b0),
		.AXI_READ_ID(1'b0)
	) wb2axi (
		.i_clk(wb_clk_i),						// System clock
		.i_reset(wb_rst_i),					// Reset signal,drives AXI rst
	// AXI write address channel signals
		.o_axi_awvalid(w_o_axi_awvalid),	// Write address valid
		.i_axi_awready(w_i_axi_awready), 	// Slave is ready to accept
		.o_axi_awid(w_o_axi_awid),			// Write ID [C_AXI_ID_WIDTH-1:0]	
		.o_axi_awaddr(w_o_axi_awaddr),		// Write address [C_AXI_ADDR_WIDTH-1:0]	
		.o_axi_awlen(w_o_axi_awlen),		// Write Burst Length [7:0]		
		.o_axi_awsize(w_o_axi_awsize),		// Write Burst size [2:0]		
		.o_axi_awburst(w_o_axi_awburst),	// Write Burst type [1:0]		
		.o_axi_awlock(w_o_axi_awlock),		// Write lock type [0:0]		
		.o_axi_awcache(w_o_axi_awcache),	// Write Cache type [3:0]		
		.o_axi_awprot(w_o_axi_awprot),		// Write Protection type [2:0]		
		.o_axi_awqos(w_o_axi_awqos),		// Write Quality of Svc [3:0]		
	// AXI write data channel signals
		.o_axi_wvalid(w_o_axi_wvalid),		// Write valid
		.i_axi_wready(w_i_axi_wready),  	// Write data ready
		.o_axi_wdata(w_o_axi_wdata),		// Write data [C_AXI_DATA_WIDTH-1:0]	
		.o_axi_wstrb(w_o_axi_wstrb),		// Write strobes [C_AXI_DATA_WIDTH/8-1:0] 
		.o_axi_wlast(w_o_axi_wlast),		// Last write transaction
	// AXI write response channel signals
		.i_axi_bvalid(w_i_axi_bvalid),  	// Write reponse valid
		.o_axi_bready(w_o_axi_bready),  	// Response ready
		.i_axi_bid(w_i_axi_bid),			// Response ID [C_AXI_ID_WIDTH-1:0]	
		.i_axi_bresp(w_i_axi_bresp),		// Write response [1:0]		
	// AXI read address channel signals
		.o_axi_arvalid(w_o_axi_arvalid),	// Read address valid
		.i_axi_arready(w_i_axi_arready),	// Read address ready
		.o_axi_arid(w_o_axi_arid),			// Read ID [C_AXI_ID_WIDTH-1:0]	
		.o_axi_araddr(w_o_axi_araddr),		// Read address [C_AXI_ADDR_WIDTH-1:0]	
		.o_axi_arlen(w_o_axi_arlen),		// Read Burst Length [7:0]		
		.o_axi_arsize(w_o_axi_arsize),		// Read Burst size [2:0]		
		.o_axi_arburst(w_o_axi_arburst),	// Read Burst type [1:0]		
		.o_axi_arlock(w_o_axi_arlock),		// Read lock type [0:0]		
		.o_axi_arcache(w_o_axi_arcache),	// Read Cache type [3:0]		
		.o_axi_arprot(w_o_axi_arprot),		// Read Protection type [2:0]		
		.o_axi_arqos(w_o_axi_arqos),		// Read Protection type [3:0]		
	// AXI read data channel signals
		.i_axi_rvalid(w_i_axi_rvalid),  	// Read reponse valid
		.o_axi_rready(w_o_axi_rready),  	// Read Response ready
		.i_axi_rid(w_i_axi_rid),     		// Response ID [C_AXI_ID_WIDTH-1:0]	
		.i_axi_rdata(w_i_axi_rdata),   		// Read data [C_AXI_DATA_WIDTH-1:0] 
		.i_axi_rresp(w_i_axi_rresp),   		// Read response [1:0]		
		.i_axi_rlast(w_i_axi_rlast),   		// Read last
	// We'll share the clock and the reset
		.i_wb_cyc(wbs_cyc_i),
		.i_wb_stb(wbs_stb_i),
		.i_wb_we(wbs_we_i),
		.i_wb_addr(wbs_adr_i),     // [(AW-1):0]
		.i_wb_data(wbs_dat_i),     // [(DW-1):0]
		.i_wb_sel(wbs_sel_i),      // [(DW/8-1):0]
		.o_wb_stall(),
		.o_wb_ack(wbs_ack_o),
		.o_wb_data(wbs_dat_o), // [(DW-1):0]
		.o_wb_err()
	);

// Spectrometer
	SpectrometerTest spectrometer (
		.clock(wb_clk_i),
		.reset(wb_rst_i),
	// AXI write address channel signals
		.ioMem_0_aw_ready(w_i_axi_awready),
		.ioMem_0_aw_valid(w_o_axi_awvalid),
		.ioMem_0_aw_bits_id(w_o_axi_awid),
		.ioMem_0_aw_bits_addr(w_o_axi_awaddr[33:2]),//[31:0]
		.ioMem_0_aw_bits_len(w_o_axi_awlen), 		// [7:0]  
		.ioMem_0_aw_bits_size(w_o_axi_awsize), 		// [2:0]  
		.ioMem_0_aw_bits_burst(w_o_axi_awburst), 	// [1:0]  
		.ioMem_0_aw_bits_lock(w_o_axi_awlock),
		.ioMem_0_aw_bits_cache(w_o_axi_awcache), 	// [3:0]  
		.ioMem_0_aw_bits_prot(w_o_axi_awprot), 		// [2:0]  
		.ioMem_0_aw_bits_qos(w_o_axi_awqos), 		// [3:0]  
	// AXI write data channel signals
		.ioMem_0_w_ready(w_i_axi_wready),
		.ioMem_0_w_valid(w_o_axi_wvalid),
		.ioMem_0_w_bits_data(w_o_axi_wdata), 		// [31:0] 
		.ioMem_0_w_bits_strb(w_o_axi_wstrb), 		// [3:0]  
		.ioMem_0_w_bits_last(w_o_axi_wlast),
	// AXI write response channel signals
		.ioMem_0_b_ready(w_o_axi_bready),
		.ioMem_0_b_valid(w_i_axi_bvalid),
		.ioMem_0_b_bits_id(w_i_axi_bid),
		.ioMem_0_b_bits_resp(w_i_axi_bresp), 		// [1:0] 
	// AXI read address channel signals
		.ioMem_0_ar_ready(w_i_axi_arready),
		.ioMem_0_ar_valid(w_o_axi_arvalid),
		.ioMem_0_ar_bits_id(w_o_axi_arid),
		.ioMem_0_ar_bits_addr(w_o_axi_araddr[33:2]),// [31:0] 
		.ioMem_0_ar_bits_len(w_o_axi_arlen), 		// [7:0]  
		.ioMem_0_ar_bits_size(w_o_axi_arsize), 		// [2:0]  
		.ioMem_0_ar_bits_burst(w_o_axi_arburst), 	// [1:0]  
		.ioMem_0_ar_bits_lock(w_o_axi_arlock),
		.ioMem_0_ar_bits_cache(w_o_axi_arcache), 	// [3:0]  
		.ioMem_0_ar_bits_prot(w_o_axi_arprot), 		// [2:0]  
		.ioMem_0_ar_bits_qos(w_o_axi_arqos), 		// [3:0]  
	// AXI read data channel signals
		.ioMem_0_r_ready(w_o_axi_rready),
		.ioMem_0_r_valid(w_i_axi_rvalid),
		.ioMem_0_r_bits_id(w_i_axi_rid),
		.ioMem_0_r_bits_data(w_i_axi_rdata), 		// [31:0] 
		.ioMem_0_r_bits_resp(w_i_axi_rresp), 		// [1:0]  
		.ioMem_0_r_bits_last(w_i_axi_rlast),
	// AXI-stream
        .inStream_0_ready(w_inStream_ready),
  		.inStream_0_valid(w_inStream_valid),
  		.inStream_0_bits_data(w_inStream_data),
  		.inStream_0_bits_last(w_inStream_last),
		.outStream_0_ready(w_outStream_ready),
  		.outStream_0_valid(w_outStream_valid),
  		.outStream_0_bits_data(w_outStream_data),
  		.outStream_0_bits_last(w_outStream_last),
        .int_0(w_uart_int),
        .uTx(w_uart_tx),
        .uRx(w_uart_rx)
	);
endmodule
`default_nettype wire