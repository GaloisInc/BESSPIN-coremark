#!/bin/bash
# The benchmark needs to run for at least 10 seconds, 10k iterations is sufficient
ITERATIONS=10000

function build() {
    echo "Building $PORT_DIR for $GFE_TARGET with $ITERATIONS iterations"
    make PORT_DIR=$PORT_DIR GFE_TARGET=$GFE_TARGET ITERATIONS=$ITERATIONS clean
    make PORT_DIR=$PORT_DIR GFE_TARGET=$GFE_TARGET ITERATIONS=$ITERATIONS compile
    cp coremark.elf binaries/coremark_$GFE_TARGET-$PORT_DIR.elf
}

# Build for P1 bare-metal
PORT_DIR=riscv-bare-metal
for CPU in P1 P2
do
    GFE_TARGET=$CPU
    build
done

# Build for linux
GFE_TARGET=P2
for PORT in linux64 freebsd
do
    PORT_DIR=$PORT
    build
done

echo "Done!"
