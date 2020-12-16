// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

`include "caravel.v"
`include "spiflash.v"
`include "uart_rx.v"

module plfg_nco_fft_mag_acc_utx_tb;
	// declare file for writing data
	integer file;

	// Golden data
	reg [15:0] goldenData [0:`FFT_SIZE-1];

	// clk, rst, power signals
	reg clock;
    reg RSTB;
	reg power1, power2;

	// testbench signals
    wire 		gpio;
    wire [37:0] mprj_io;

	// Output stream data wires
	reg 	    out_ready = 1'b0;
	wire 	    out_valid;
	wire  [7:0] out_data;

	// uart data
	reg  uRx = 1'b1;
	wire uTx;
	wire [7:0] utx_data;
	reg  [7:0] utx_temp;
	wire utx_valid;

	reg [15:0] dataCounter = 16'b0;
	reg [9:0] cntReg = 10'b0;


	// Assign wires
	assign mprj_io[11] = out_ready;
	assign out_valid = mprj_io[12];
	assign out_data  = mprj_io[20:13];

	assign uTx = mprj_io[23];
	assign mprj_io[24] = uRx;

	assign mprj_io[10:1] = cntReg[9:0];

	
	// toggle clock
	always #500 clock <= (clock === 1'b0);

	// Read golden data
	initial $readmemh("./../../../../../../cargo/spectrometer/test_run_dir/SpectrometerTest/plfg_nco_fft_mag_acc_utx/GoldenData.txt", goldenData);

	// send data to input stream
	always @ (posedge clock) begin
		cntReg <= cntReg + 1'b1;
	end

	// open file for writting
	initial begin
		file = $fopen("output.txt","w");
		if (file) $display("File was opened successfully : %0d", file);
    	else $display("File was NOT opened successfully : %0d", file);
	end

	initial begin
		clock = 0;
	end

	// Collect data from uTx
	always @ (posedge clock) begin
		if (utx_valid) begin
			if (dataCounter % 2 == 0) utx_temp <= utx_data;
			else begin
				$fwriteh(file, "%h" ,utx_data);
				$fwriteh(file, "%h\n" ,utx_temp);
				if ({utx_data,utx_temp} != goldenData[dataCounter/2]) begin
					$display("%c[1;31m",27);
					$display ("Monitor: Test plfg_nco_fft_mag_acc_utx failed!!! Read data was %h, but should be %h.", {utx_data,utx_temp}, goldenData[dataCounter/2]);
					$display("%c[0m",27);
					$fclose(file); 
					$finish;
				end
			end
			dataCounter <= dataCounter + 1'b1;
		end
	end

	initial begin
		$dumpfile("plfg_nco_fft_mag_acc_utx.vcd");
		$dumpvars(4, plfg_nco_fft_mag_acc_utx_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (300) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		$display ("Monitor: Test plfg_nco_fft_mag_acc_utx failed!!! Timeout.");
		$display("%c[0m",27);
		$fclose(file); 
		$finish;
	end

	// Check if enough data was send, and if so terminate test
	initial begin
		wait(dataCounter == 16'd 2*`FFT_SIZE);
		$display("%c[1;32m",27);
		$display("Monitor: Test plfg_nco_fft_mag_acc_utx passed.");
		$display("%c[0m",27);
		$fclose(file); 
		$finish;
	end

	initial begin
		RSTB <= 1'b0;
		#10000;
		RSTB <= 1'b1;	    // Release reset
		#20000;
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

    wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD1V8;
    wire VDD3V3;
	wire VSS;
    
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        .mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("plfg_nco_fft_mag_acc_utx.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),
		.io3()
	);

	uart_rx  #(.CLKS_PER_BIT(3)
	) urx_tb (
   		.i_Clock(clock),
   		.i_Rx_Serial(uTx),
   		.o_Rx_DV(utx_valid),
   		.o_Rx_Byte(utx_data)
    );

endmodule
`default_nettype wire
