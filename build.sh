#!/bin/sh

# Build paths - modify this to match your environment

R=/opt/fritz/freetz-trunk/trunk
TC=$R/toolchain/build/mips_gcc-4.9.4_uClibc-0.9.33.2-nptl_kernel-3.10/mips-linux-uclibc/bin
TA=$R/source/target-mips_gcc-4.9.4_uClibc-0.9.33.2-nptl_kernel-3.10
TO=$R/tools/build/bin 
PATH=$TC:$TO:/usr/bin:/bin

export OPENSSL=$TA/openssl-1.0.2l

export TARGET=mips-linux
export TARGET_CC="mips-linux-gcc"
export TARGET_CFLAGS="-Os -pipe -march=24kc -Wa,--trap"
export TARGET_LDFLAGS="-s"
umask 0022

export UNBOUND=unbound-1.7.0

fakeroot make "$@"
