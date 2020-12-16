# ---- Test patterns ----

.SUFFIXES:
.SILENT: clean all

PATTERNS = plfg_nco_fft_mag_acc_pout plfg_nco_fft_mag_acc_utx pin_fft_mag_acc_pout pin_nco_fft_mag_acc_pout

all:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		( cd $$i && make -f Makefile $${i}.vcd &> verify.log && grep Monitor verify.log) ; \
	done

clean:  ${PATTERNS}
	for i in ${PATTERNS}; do \
		rm -f verify.log; \
		( cd $$i && make clean ) ; \
	done

.PHONY: clean all
