SPECTROMETER_PATH = ./spectrometer
TOP_TEST_PATH = ./top/dv/SpectrometerTest/spectrometer

SIZE?=128
export FFT_SIZE=$(SIZE)

ENABLE_PLOT?=false

move_user_proj_example:
	mv ../verilog/rtl/user_proj_example.v ./user_proj_example.v

move_back_user_proj_example:
	mv ./user_proj_example.v ../verilog/rtl/user_proj_example.v 
	
verilog_spectrometer:
	cd $(SPECTROMETER_PATH); sbt "runMain spectrometer.SpectrometerTestApp $(FFT_SIZE)"; cd -;

test_spectrometer:
	cd $(SPECTROMETER_PATH); SBT_OPTS="-DfftSize=$(FFT_SIZE) -DenablePlot=$(ENABLE_PLOT)" sbt "testOnly spectrometer.SpectrometerTestSpec"; cd -;

.PHONY: test_top
test_top:
	make move_user_proj_example
	make verilog_spectrometer
	make test_spectrometer
	cd $(TOP_TEST_PATH); make all; cd -;
	make move_back_user_proj_example

clean_top:
	cd $(TOP_TEST_PATH); make clean; cd -;
	
check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif
ifndef RISCV32
	$(error RISCV32 is undefined, please export it before running make)
endif
