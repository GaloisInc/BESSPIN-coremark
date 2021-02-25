#!/bin/bash
# clean current binaries
rm binaries/*

# The benchmark needs to run for at least 10 seconds, 10k iterations is sufficient
ITERATIONS=10000

function build() {
    echo "Building $PORT_DIR for $GFE_TARGET with $ITERATIONS iterations"
    make SYSROOT_DIR=$SYSROOT_DIR TOOLCHAIN=$TOOLCHAIN PORT_DIR=$PORT_DIR GFE_TARGET=$GFE_TARGET ITERATIONS=$ITERATIONS POINTER_SPACE=16 clean
    make SYSROOT_DIR=$SYSROOT_DIR TOOLCHAIN=$TOOLCHAIN PORT_DIR=$PORT_DIR GFE_TARGET=$GFE_TARGET ITERATIONS=$ITERATIONS POINTER_SPACE=16 compile
    cp coremark.elf binaries/coremark_$GFE_TARGET-$PORT_DIR-$TOOLCHAIN.elf
}

for TOOLCHAIN in GCC LLVM
do
    # Build for P1 bare-metal
    PORT_DIR=riscv-bare-metal
    # Set proper sysroot
    SYSROOT_DIR=$RISCV32_CLANG_BAREMETAL_SYSROOT
    GFE_TARGET=P1
    echo "Building for P1 bare-metal-$TOOLCHAIN"
    build

    SYSROOT_DIR=$RISCV64_CLANG_BAREMETAL_SYSROOT
    GFE_TARGET=P2
    echo "Building for P2 bare-metal-$TOOLCHAIN"
    build

    GFE_TARGET=P3
    echo "Building for P3 bare-metal-$TOOLCHAIN"
    build

    # Build for freebsd
    PORT_DIR=freebsd
    GFE_TARGET=P2
    SYSROOT_DIR=$FETT_GFE_FREEBSD_SYSROOT
    echo "Building for freebsd-$TOOLCHAIN"
    build
done

# Build for linux
PORT_DIR=linux64
GFE_TARGET=P2
TOOLCHAIN=GCC
echo "Building for linux64-$TOOLCHAIN"
build


echo "Done!"
