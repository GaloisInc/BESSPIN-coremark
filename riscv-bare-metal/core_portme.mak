# Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# Original Author: Shay Gal-on

#File : core_portme.mak

# Allow users to override the UART's baud rate.
UART_BAUD_RATE ?= 115200

COMMON_DIR := ./riscv-common
LINKER_SCRIPT := $(COMMON_DIR)/test.ld
NEWLIB_DIR ?=

# Make sure user explicitly defines the target GFE platform.
ifeq ($(GFE_TARGET),P1)
	RISCV_FLAGS := -target riscv32-unknown-elf -march=rv32imacxcheri -mabi=il32pc64 -DPOINTER_SPACE=16
	COMPILER_RT := clang_rt.builtins-riscv32
	# 50 MHz clock
	CLOCKS_PER_SEC := 50000000
else ifeq ($(GFE_TARGET),P2)
	RISCV_FLAGS := -target riscv64-unknown-elf -march=rv64imafdcxcheri -mabi=l64pc128d -DPOINTER_SPACE=16
	COMPILER_RT := clang_rt.builtins-riscv64
	# 50 MHz clock
	CLOCKS_PER_SEC := 50000000
else ifeq ($(GFE_TARGET),P3)
$(error P3 target has not been tested yet, use P1 or P2)
else
$(error Please define GFE_TARGET to P1, P2, or P3 (e.g. make GFE_TARGET=P1))
endif

# Flag : OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o
# Flag : CC
#	Use this flag to define compiler to use
CC 		= clang
# Flag : CFLAGS
#	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
PORT_CFLAGS = \
	$(RISCV_FLAGS) \
	-DCLOCKS_PER_SEC=$(CLOCKS_PER_SEC) \
	-DUART_BAUD_RATE=$(UART_BAUD_RATE) \
	-mno-relax \
	-O2 \
	-mcmodel=medium \
	-static \
	-std=gnu99 \
	-ffast-math \
	-fno-common \
	-fno-builtin-printf \
	-I$(COMMON_DIR)
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS) $(XLFLAGS) $(LFLAGS_END)"
CFLAGS = $(PORT_CFLAGS) -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"
#Flag : LFLAGS_END
#	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts).
#	Note : On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
LFLAGS_END = \
	-static \
	-nostdlib \
	-nostartfiles \
	-lm \
	-l$(COMPILER_RT) \
	-T $(LINKER_SCRIPT)
# Flag : PORT_SRCS
# 	Port specific source files can be added here
#	You may also need cvt.c if the fcvt functions are not provided as intrinsics by your compiler!
PORT_SRCS = \
	$(COMMON_DIR)/crt.S \
	$(COMMON_DIR)/syscalls.c \
	$(COMMON_DIR)/uart_16550.c \
	$(PORT_DIR)/core_portme.c \
	$(PORT_DIR)/cvt.c \
	$(PORT_DIR)/ee_printf.c

# Flag : LOAD
#	For a simple port, we assume self hosted compile and run, no load needed.

# Flag : RUN
#	For a simple port, we assume self hosted compile and run, simple invocation of the executable

LOAD = echo "Please set LOAD to the process of loading the executable to the flash"
RUN = echo "Please set RUN to the process of running the executable (e.g. via jtag, or board reset)"

OEXT = .o
EXE = .bin

# Target : port_pre% and port_post%
# For the purpose of this simple port, no pre or post steps needed.

.PHONY : port_prebuild port_postbuild port_prerun port_postrun port_preload port_postload
port_pre% port_post% : 

# FLAG : OPATH
# Path to the output folder. Default - current folder.
OPATH = ./
MKDIR = mkdir -p

