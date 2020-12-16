// SPDX-License-Identifier: Apache-2.0

#include "../../defs.h"
#include "../../stub.c"

#include "../../spectrometerDefs.h"

/*
	Spectrometer Test:
		- Set spectrometer to pass data through:
                        pin
                        nco
                        fft
                        mag
                        acc
                        pout
*/

int clk = 0;
int i;

void main()
{
	// Configure GPIO pins
        reg_mprj_io_24 = GPIO_MODE_USER_STD_INPUT_PULLUP;
        reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;

        reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_11 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;

        reg_mprj_io_10 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_9  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_8  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_7  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_6  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_5  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_4  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_3  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_2  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_1  = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
        reg_mprj_io_0  = GPIO_MODE_USER_STD_OUTPUT;

        /* Apply configuration */
        reg_mprj_xfer = 1;
        while (reg_mprj_xfer == 1);

        int segmentNumsArrayOffset = 6 * BEATBYTES;
        int repeatedChirpNumsArrayOffset = segmentNumsArrayOffset + 4 * BEATBYTES;
        int chirpOrdinalNumsArrayOffset = repeatedChirpNumsArrayOffset + 8 * BEATBYTES;

        PLFG_RAM(0) = 0x24000000;
        PLFG_REG(2*BEATBYTES) = 8;
        PLFG_REG(4*BEATBYTES) = 1;
        PLFG_REG(5*BEATBYTES) = 4;
        PLFG_REG(segmentNumsArrayOffset) = 1;
        PLFG_REG(repeatedChirpNumsArrayOffset) = 1;
        PLFG_REG(chirpOrdinalNumsArrayOffset) = 0;
        PLFG_REG(1*BEATBYTES) = 0;
        PLFG_REG(0*BEATBYTES) = 1;

        MAG_REG(0) = 0x2; // set jpl magnitude
        
        ACC_REG(0)           = FFT_SIZE;
        ACC_REG(1*BEATBYTES) = 4;

        NCO_MUX_1_REG(0)           = 0;
        FFT_MUX_1_REG(0)           = 0;
        MAG_MUX_1_REG(0)           = 0;

        PLFG_MUX_0_REG(0)          = 1;
        NCO_MUX_0_REG(0)           = 0;
        NCO_MUX_0_REG(1*BEATBYTES) = 1;
        FFT_MUX_0_REG(0)           = 0;
        FFT_MUX_0_REG(1*BEATBYTES) = 1;
        MAG_MUX_0_REG(0)           = 0;
        MAG_MUX_0_REG(1*BEATBYTES) = 1;

        OUT_MUX_REG(0)             = 0;
        OUT_MUX_REG(2*BEATBYTES)   = 5;

}

