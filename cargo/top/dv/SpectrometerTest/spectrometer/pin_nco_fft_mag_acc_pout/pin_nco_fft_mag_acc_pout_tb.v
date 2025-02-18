// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

`include "caravel.v"
`include "spiflash.v"

module pin_nco_fft_mag_acc_pout_tb;
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
	reg 	    out_ready = 0;
	wire 	    out_valid;
	wire  [7:0] out_data;
	reg   [7:0] out_temp;

	// Input stream data wires
	wire 	    in_ready;
	reg 	    in_valid = 0;
	reg  [7:0]  in_data = 8'h04;
	reg			in_last = 0;

	reg [15:0] dataCounter = 16'b0;
	reg [1:0] dataSentCounter = 2'b0;

	// Assign wires
	assign mprj_io[11]  = out_ready;
	assign out_valid    = mprj_io[12];
	assign out_data     = mprj_io[20:13];

	assign in_ready 	= mprj_io[0];
	assign mprj_io[1]   = in_valid;
	assign mprj_io[9:2] = in_data[7:0];
	assign mprj_io[10]  = in_last;

	
	// toggle clock
	always #500 clock <= (clock === 1'b0);

	// Read golden data
	initial $readmemh("./../../../../../../cargo/spectrometer/test_run_dir/SpectrometerTest/pin_nco_fft_mag_acc_pout/GoldenData.txt", goldenData);

	// open file for writting
	initial begin
		$printtimescale(pin_nco_fft_mag_acc_pout_tb);
		file = $fopen("output.txt","w");
		if (file) $display("File was opened successfully : %0d", file);
    	else $display("File was NOT opened successfully : %0d", file);
	end

	initial begin
		clock = 0;
		#500 out_ready = 1'b1; // Set out_ready
	end

	// Check inStream.ready and inStream.valid and send data
	always @ (posedge clock) begin
		if (in_ready == 1'b1) begin
			in_valid = 1'b1;
			if (dataSentCounter % 4 == 0) in_data <= 8'h04;
			else in_data <= 8'h00;
			dataSentCounter <= dataSentCounter + 1'b1;
		end
	end

	// Check outStream.ready and outStream.valid and collect data
	always @ (posedge clock) begin
		if (out_ready == 1'b1 && out_valid == 1'b1) begin
			if (dataCounter % 2 == 0) out_temp <= out_data;
			else begin
				$fwriteh(file, "%h" ,out_data);
				$fwriteh(file, "%h\n" ,out_temp);
				if ({out_data,out_temp} != goldenData[dataCounter/2]) begin
					$display("%c[1;31m",27);
					$display ("Monitor: Test pin_nco_fft_mag_acc_pout failed!!! Read data was %h, but should be %h.", {out_data,out_temp}, goldenData[dataCounter/2]);
					$display("%c[0m",27);
					$fclose(file); 
					$finish;
				end
			end
			dataCounter <= dataCounter + 1'b1;
		end
	end

	initial begin
		$dumpfile("pin_nco_fft_mag_acc_pout.vcd");
		$dumpvars(0, pin_nco_fft_mag_acc_pout_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (30) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		$display ("Monitor: Test pin_nco_fft_mag_acc_pout failed!!! Timeout.");
		$display("%c[0m",27);
		$fclose(file); 
		$finish;
	end

	// Check if enough data was send, and if so terminate test
	initial begin
		wait(dataCounter == 16'd 2*`FFT_SIZE);
		$display("%c[1;32m",27);
		$display("Monitor: Test pin_nco_fft_mag_acc_pout passed.");
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
		.FILENAME("pin_nco_fft_mag_acc_pout.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),
		.io3()
	);

endmodule
`default_nettype wire
