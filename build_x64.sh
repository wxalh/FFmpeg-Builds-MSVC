#!/bin/sh
# ===== 修复 config.h 编码问题 =====

unset CFLAGS LDFLAGS LIBS CC

export LC_ALL=C
export LANG=C
export CC=cl

# 1. 指向 vcpkg 的 pkgconfig 目录（两个路径都加，pkg-config 会自动忽略不存在的）
export PKG_CONFIG_PATH="/d/lib/x64_md/lib/pkgconfig:$PKG_CONFIG_PATH"

rm -rf out

mkdir out && cd out

../third_party/FFmpeg/configure \
  --toolchain=msvc \
  --arch=x86_64  \
  --pkg-config-flags="--static"  \
  --pkg-config=pkg-config  \
  --enable-version3 \
  --enable-shared \
  --disable-static \
  --enable-zlib \
  --enable-libopenh264 \
  --enable-libvpl \
  --enable-nvenc \
  --enable-amf \
  --enable-cuvid \
  --enable-dxva2 \
  --enable-d3d11va \
  --extra-version=20260227 \
  --extra-cflags="-MD -D_WIN32_WINNT=0x0601 -DWINVER=0x0601" \
  --extra-ldflags="-SUBSYSTEM:CONSOLE,6.01" \
  --prefix=/d/lib/ffmpeg/ffmpeg-n7.1-latest-msvc64-lgpl-shared-7.1
   