#!/usr/bin/env bash
#
#  build.sh - Automic kernel building script for Rosemary Kernel
#
#  Copyright (C) 2021, Crepuscular's AOSP WorkGroup
#  Author: EndCredits <alicization.han@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License version 2 as
#  published by the Free Software Foundation.
#
#  Add clang to your PATH before using this script.
#

ARCH=arm64;
CC=clang;
CLANG_TRIPLE=aarch64-linux-gnu-;
CROSS_COMPILE=aarch64-linux-gnu-;
CROSS_COMPILE_ARM32=arm-linux-gnueabi-;
THREAD=$(nproc --all);
OUT=out;

TARGET_KERNEL_FILE=arch/arm64/boot/Image.gz-dtb;
TARGET_KERNEL_DTB=arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-tiffany.dtb;
TARGET_KERNEL_NAME=Rosemary-Kernel;
TARGET_KERNEL_MOD_VERSION=2.2;

DEFCONFIG_NAME=tiffany_defconfig;

START_SEC=$(date +%s);
CURRENT_TIME=$(date '+%Z-%Y-%m-%d-%H%M');

ANYKERNEL_URL=https://codeload.github.com/EndCredits/AnyKernel3/zip/refs/heads/rosemary;
ANYKERNEL_PATH=AnyKernel3-rosemary;
ANYKERNEL_FILE=anykernel.zip;

make_defconfig(){
    echo "------------------------------";
    echo " Building Kernel Defconfig..";
    echo "------------------------------";

    make CC=$CC ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32 O=$OUT -j$THREAD $DEFCONFIG_NAME;
}

build_kernel(){
    echo "------------------------------";
    echo " Building Kernel ...........";
    echo "------------------------------";

    make CC=$CC ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32 O=$OUT -j$THREAD;
    END_SEC=$(date +%s);
    COST_SEC=$[ $END_SEC-$START_SEC ];
    echo "Kernel Build Costed $(($COST_SEC/60))min $(($COST_SEC%60))s"

}

generate_flashable(){
    echo "------------------------------";
    echo " Generating Flashable Kernel";
    echo "------------------------------";

    cd $OUT;
    
    echo ' Getting AnyKernel ';
    curl $ANYKERNEL_URL -o $ANYKERNEL_FILE;

    unzip -o $ANYKERNEL_FILE;

    echo ' Copying Kernel File '; 
    cp -r $TARGET_KERNEL_FILE $ANYKERNEL_PATH/;
    cp -r $TARGET_KERNEL_DTB $ANYKERNEL_PATH/;

    echo ' Packaging flashable Kernel ';
    cd $ANYKERNEL_PATH;
    zip -q -r $TARGET_KERNEL_NAME-$CURRENT_TIME-$TARGET_KERNEL_MOD_VERSION.zip *;

    echo " Target File:  $OUT/$ANYKERNEL_PATH/$TARGET_KERNEL_NAME-$CURRENT_TIME-$TARGET_KERNEL_MOD_VERSION.zip ";
}

make_defconfig;
build_kernel;
generate_flashable;