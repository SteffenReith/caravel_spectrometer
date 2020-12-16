// SPDX-License-Identifier: Apache-2.0

#ifndef _SPECTROMETERDEF_H_
#define _SPECTROMETERDEF_H_

#include <stdint.h>
#include <stdbool.h>

// Helper functions
#define _AC(X,Y)        (X##Y)

#define _REG32(p, i) (*(volatile uint32_t *) ((p) + (i)))

#define BEATBYTES 4

#define IN_SPL_BASE     _AC(0x30000000,UL)

#define PLFG_RAM_BASE   _AC(0x30001000,UL)
#define PLFG_BASE       _AC(0x30002100,UL)
#define PLFG_SPL_BASE   _AC(0x30002200,UL)
#define PLFG_MUX_0_BASE _AC(0x30002210,UL)
#define PLFG_MUX_1_BASE _AC(0x30002220,UL)

#define NCO_BASE        _AC(0x30003000,UL)
#define NCO_SPL_BASE    _AC(0x30003100,UL)
#define NCO_MUX_0_BASE  _AC(0x30003110,UL)
#define NCO_MUX_1_BASE  _AC(0x30003120,UL)

#define FFT_BASE        _AC(0x30004000,UL)
#define FFT_SPL_BASE    _AC(0x30004100,UL)
#define FFT_MUX_0_BASE  _AC(0x30004110,UL)
#define FFT_MUX_1_BASE  _AC(0x30004120,UL)

#define MAG_BASE        _AC(0x30005000,UL)
#define MAG_SPL_BASE    _AC(0x30005100,UL)
#define MAG_MUX_0_BASE  _AC(0x30005110,UL)
#define MAG_MUX_1_BASE  _AC(0x30005120,UL)

#define ACC_QUEUE_BASE  _AC(0x30006000,UL)
#define ACC_BASE        _AC(0x30007000,UL)

#define OUT_MUX_BASE    _AC(0x30008000,UL)
#define OUT_SPL_BASE    _AC(0x30008010,UL)

#define UART_BASE       _AC(0x30009000,UL)
#define UART_SPL_BASE   _AC(0x30009100,UL)

// REGS
#define IN_SPL_REG(offset)     _REG32(IN_SPL_BASE, offset)

#define PLFG_RAM(offset)       _REG32(PLFG_RAM_BASE, offset)
#define PLFG_REG(offset)       _REG32(PLFG_BASE, offset)
#define PLFG_SPL_REG(offset)   _REG32(PLFG_SPL_BASE, offset)
#define PLFG_MUX_0_REG(offset) _REG32(PLFG_MUX_0_BASE, offset)
#define PLFG_MUX_1_REG(offset) _REG32(PLFG_MUX_1_BASE, offset)

#define NCO_REG(offset)        _REG32(NCO_BASE, offset)
#define NCO_SPL_REG(offset)    _REG32(NCO_SPL_BASE, offset)
#define NCO_MUX_0_REG(offset)  _REG32(NCO_MUX_0_BASE, offset)
#define NCO_MUX_1_REG(offset)  _REG32(NCO_MUX_1_BASE, offset)

#define FFT_REG(offset)        _REG32(FFT_BASE, offset)
#define FFT_SPL_REG(offset)    _REG32(FFT_SPL_BASE, offset)
#define FFT_MUX_0_REG(offset)  _REG32(FFT_MUX_0_BASE, offset)
#define FFT_MUX_1_REG(offset)  _REG32(FFT_MUX_1_BASE, offset)

#define MAG_REG(offset)        _REG32(MAG_BASE, offset)
#define MAG_SPL_REG(offset)    _REG32(MAG_SPL_BASE, offset)
#define MAG_MUX_0_REG(offset)  _REG32(MAG_MUX_0_BASE, offset)
#define MAG_MUX_1_REG(offset)  _REG32(MAG_MUX_1_BASE, offset)

#define ACC_QUEUE_REG(offset)  _REG32(ACC_QUEUE_BASE, offset)
#define ACC_REG(offset)        _REG32(ACC_BASE, offset)

#define OUT_MUX_REG(offset)    _REG32(OUT_MUX_BASE, offset)
#define OUT_SPL_REG(offset)    _REG32(OUT_SPL_BASE, offset)

#define UART_REG(offset)       _REG32(UART_BASE, offset)
#define UART_SPL_REG(offset)   _REG32(UART_SPL_BASE, offset)

/* Register offsets */
#define uart_txfifo     0x00
#define uart_rxfifo 	0x04
#define uart_txctrl 	0x08
#define uart_txmark 	0x0a
#define uart_rxctrl 	0x0c
#define uart_rxmark		0x0e

#define uart_ie     	0x10
#define uart_ip    		0x14
#define uart_div    	0x18
#define uart_parity		0x1c
#define uart_wire4		0x20
#define uart_either8or9 0x24

#define mux_output_0    0x0*BEATBYTES
#define mux_output_1    0x1*BEATBYTES
#define mux_output_2    0x2*BEATBYTES

#define spl_ctrl        0x0*BEATBYTES
#define spl_mask        0x1*BEATBYTES

// --------------------------------------------------------
#endif
