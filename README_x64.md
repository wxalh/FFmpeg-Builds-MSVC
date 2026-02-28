# 目标：
生成FFmpeg的动态链接库，但是FFmpeg自身依赖的第三方库使用静态链接（也就是说最终生成的dll只有FFmpeg家族的，不需要再补其它dll库）
# 一、克隆github仓库
比如：下载到 `D:\c_workspace` 目录下

```bash
git submodule update --init --recursive
```

# 二、编译openh264（开启通用的软编码和软解码）

## 1、安装meson依赖

```bash
python -m pip install meson ninja
```

## 2、编译openh264
重新打开  x64 Native Tools Command Prompt for VS 2019，然后执行
```bash
cd /d D:\c_workspace\FFmpeg-Builds-MSVC\third_party\openh264
mkdir out && cd out
set CL=/D_WIN32_WINNT=0x0601 /DWINVER=0x0601
# 关键：指定 Release + /MD (动态 CRT)
meson setup .. --buildtype=release -Db_vscrt=md --default-library=static -Dprefix=D:\lib\x64_md --wipe

meson compile && meson install

move D:\lib\x64_md\lib\libopenh264.a D:\lib\x64_md\lib\openh264.lib
```
## 3、编译libvpl（开启intel显卡硬编码和硬解码）
需要安装cmake，推荐3.31版本
```bash
cd /d D:\c_workspace\FFmpeg-Builds-MSVC\third_party\libvpl
# 清理旧构建
mkdir out && cd out

cmake -G "Visual Studio 16 2019" -A x64   -DCMAKE_C_FLAGS_RELEASE="/D_WIN32_WINNT=0x0601 /DWINVER=0x0601"   -DCMAKE_CXX_FLAGS_RELEASE="/D_WIN32_WINNT=0x0601 /DWINVER=0x0601" -DBUILD_SHARED_LIBS=OFF -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="D:\\lib\\x64_md" .. 

cmake --build . --config Release --target INSTALL
```
## 4、编译SDL2
需要安装cmake，推荐3.31版本
```bash
cd /d D:\c_workspace\FFmpeg-Builds-MSVC\third_party\sdl

mkdir out && cd out

cmake -G "Visual Studio 16 2019" -A x64   -DCMAKE_C_FLAGS_RELEASE="/D_WIN32_WINNT=0x0601 /DWINVER=0x0601"   -DCMAKE_CXX_FLAGS_RELEASE="/D_WIN32_WINNT=0x0601 /DWINVER=0x0601" -DBUILD_SHARED_LIBS=OFF -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="D:\\lib\\x64_md" .. 

cmake --build . --config Release --target INSTALL
```

## 5、编译zlib（nvidia需要）
需要安装cmake，推荐3.31版本
重新打开  x64 Native Tools Command Prompt for VS 2019，然后执行
```bash
cd /d D:\c_workspace\FFmpeg-Builds-MSVC\third_party\zlib

mkdir out && cd out

cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="/MD" -DCMAKE_C_FLAGS_RELEASE="/MD /D_WIN32_WINNT=0x0601 /DWINVER=0x0601" -DZLIB_BUILD_SHARED=OFF -DZLIB_BUILD_STATIC=ON -DCMAKE_INSTALL_PREFIX="D:\lib\x64_md" ..

nmake && nmake install

move D:\lib\x64_md\lib\zs.lib D:\lib\x64_md\lib\zlib.lib
```

# 三、部署msys2环境

## 1、安装[msys2](https://github.com/msys2/msys2-installer/releases/download/2025-12-13/msys2-x64_64-20251213.exe)
然后，把安装目录添加到系统环境变量
## 2、运行cmd，执行
重新打开  x64 Native Tools Command Prompt for VS 2019，然后执行
```bash
msys2_shell.cmd -full-path
```
## 3、安装依赖
```bash
mv /usr/bin/link.exe /usr/bin/link.exe.bak
pacman -S pkg-config make yasm nasm diffutils --noconfirm
```
## 4、部署amf（开启amd显卡硬编码和硬解码）
进入项目目录
```bash
cd /d/c_workspace/FFmpeg-Builds-MSVC
```
下载地址 

```bash
wget https://github.com/GPUOpen-LibrariesAndSDKs/AMF/releases/download/v1.5.0/AMF-headers-v1.5.0.tar.gz
tar -xf ./AMF-headers-v1.5.0.tar.gz
mv amf-headers-v1.5.0/AMF/ /d/lib/x64_md/include/
rm -rf amf-headers-v1.5.0
```

## 5、部署nv-codec-builds（开启nvidia显卡硬编码和硬解码）
```bash
cd /d/c_workspace/FFmpeg-Builds-MSVC/third_party/nv-codec-headers
make install PREFIX=/d/lib/x64_md
```
## 6、修改libvpl的依赖不完整问题
```bash
perl -i -pe 's/^Libs:.*$/Libs: -L\$\{libdir\} -lvpl -ladvapi32 -lole32 -luuid/' /d/lib/x64_md/lib/pkgconfig/vpl.pc
```

# 四、 编译FFmpeg

## 1、应用补丁

```bash

cd D:\c_workspace\FFmpeg-Builds-MSVC\third_party\FFmpeg
git apply ..\..\patch\ffmpeg_7.1.patch

```
## 2、执行build_x64.sh

重新打开  x64 Native Tools Command Prompt for VS 2019，然后执行
```bash
msys2_shell.cmd -full-path
```
在新打开的msys2窗口执行
```bash
cd /d/c_workspace/FFmpeg-Builds-MSVC
bash build_x64.sh
```
## 3、执行成功后，开始编译

```bash
cd out
make V=1 -j8 2>&1 | tee make.log
```
## 4、编译完成后，执行安装

```bash
make install
```
