# Jetson TX2メモ

## 方針
以下の主要ライブラリはubuntuが提供するパッケージは使わず、自前でビルドする。
- CMake
- Ninja
- Boost
- Eigen
- OpenCV
- TBB

自前でビルドしたライブラリは`/usr/local`以下に追加していく。

`~/.bashrc`を編集してパス追加
```bash
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64
↓
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64:/usr/local/lib
```

## 初期設定

### 時刻合わせ
タイムゾーンの変更
```bash
$ sudo timedatectl set-timezone Asia/Tokyo
```

`/etc/systemd/timesyncd.conf`編集
```bash
#NTP=
↓
NTP=islntp.islab.secom.corp
```

サービス再起動
```bash
$ sudo systemctl stop systemd-timesyncd.service
$ sudo systemctl start systemd-timesyncd.service
```

ステータス確認
```bash
$ sudo systemctl status systemd-timesyncd.service
```

### Unity不具合修正
aptitudeインストール
```bash
$ sudo apt install aptitude
```

主要コンポーネントの再インストール
```bash
$ sudo aptitude reinstall apt apt-utils aptdaemon aptdaemon-data update-manager update-manager-core dbus
```


### デフォルトのOpenCVをアンインストール
```bash
$ sudo apt purge libopencv4tegra libopencv4tegra-dev libopencv4tegra-python libtbb-dev libtbb2
$ sudo apt purge libopencv4tegra-repo
```


## ライブラリビルド
### Boost
bzip2のインストール
```bash
$ sudo apt install libbz2-dev
```

bootstrap実行
```bash
$ ./bootstrap.sh --with-python=python3 --with-icu
```

コンパイラ設定を`project-config.jam`に記述
```bash
using gcc : : : <cxxflags>-std=c++14 ;
```

以下のコマンドでビルド
```bash
$ ./b2 -j6 link=shared runtime-link=shared threading=multi variant=release --build-dir=Build_gcc_arm_Shared_Release --stagedir=Stage_gcc_arm_Shared_Release --without-mpi stage
```

以下のコマンドでインストール
```bash
$ sudo ./b2 -j6 link=shared runtime-link=shared threading=multi variant=release --build-dir=Build_gcc_arm_Shared_Release --stagedir=Stage_gcc_arm_Shared_Release --without-mpi install
```


### TBB
`build`ディレクトリで以下を実行
```bash
$ make stdver=c++14
```
ライブラリファイルとインクルードファイルは手動でコピーする。

### Ninja
`re2c`をインストール
```bash
$ sudo apt install re2c
```

ビルド
```bash
$ CXXFLAGS=-std=c++14 ./configure.py --bootstrap
```
バイナリファイルは手動でコピーする。

### CMake
ccmakeをビルドするためにncursesをインストール
```bash
$ sudo apt install libncurses5-dev
```

cmake-guiをビルドするためにqtをインストール
```bash
$ sudo apt install qt5-default
```

bootstrapしてmakeしてinstall
```bash
$ ./bootstrap --parallel=6 --qt-gui
$ make
$ sudo make install
```

### Halide
llvmとclangをインストール

※OpemMPがgcc用のものになっている気がしたけど大丈夫だろうか。。。
```bash
$ sudo apt install llvm-4.0 clang-4.0
```

cmake実行
```bash
$ cmake /usr/local/src/Halide-release_2017_05_03 -G Ninja -DBUILD_AOT_TUTORIAL=OFF -DTARGET_AARCH64=OFF -DTARGET_ARM=OFF -DTARGET_HEXAGON=OFF -DTARGET_METAL=OFF -DTARGET_MIPS=OFF -DTARGET_POWERPC=OFF -DTARGET_X86=OFF -DWITH_APPS=OFF -DWITH_TESTS=OFF -DWITH_TEST_CORRECTNESS=OFF -DWITH_TEST_ERROR=OFF -DWITH_TEST_GENERATORS=OFF -DWITH_TEST_INTERNAL=OFF -DWITH_TEST_OPENGL=OFF -DWITH_TEST_PERFORMANCE=OFF -DWITH_TEST_WARNING=OFF -DWITH_TUTORIALS=OFF
$ buildninja -j6
```
手動でバイナリ・ライブラリ・インクルードファイルは手動でコピーする。

### Protobuf
aptのprotobufはバージョンが古いので、自前でビルド
```bash
$ cmake /usr/local/src/protobuf-3.4.0 -G Ninja -DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_MSVC_STATIC_RUNTIME=OFF
$ ninja -j6
$ sudo ninja install
```

### Ceres Solver
opencv_sfmモジュールを高速化するためのライブラリ
```bash
$ cmake /usr/local/src/ceres-solver-1.13.0 -G Ninja -DCXX11=ON -DEIGENSPARSE=ON -DOPENMP=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF
$ ninja -j6
$ sudo ninja install
```

### OpenCV
GUIフレームワーク関連
```bash
$ sudo apt install libgtk-3-dev freeglut3-dev libvtk6-qt-dev libgtkglext1-dev
```

画像フォーマット関連
```bash
$ sudo apt install libjpeg-dev libjasper-dev libpng++-dev libtiff-dev libopenexr-dev libwebp-dev
```

追加機能
```bash
$ sudo apt install ccache
$ sudo apt install coinor-libclp-dev
$ sudo apt install libgdcm2-dev
$ sudo apt install liblapacke-dev
$ sudo apt install libopenblas-dev
$ sudo apt install tesseract-ocr libtesseract-dev libleptonica-dev
$ sudo apt install protobuf-compiler libprotobuf-dev
$ sudo apt install libleveldb-dev libsnappy-dev
$ sudo apt install libhdf5-serial-dev
$ sudo apt install libgflags-dev
$ sudo apt install libgoogle-glog-dev
$ sudo apt install liblmdb-dev
```

python関連
```bash
$ sudo apt install python3-dev python3-numpy python3-scipy python3-matplotlib
$ sudo apt install python-dev python-numpy python-scipy python-matplotlib
```

ビデオ関連
```bash
$ sudo apt install libva-dev
$ sudo apt install libdc1394-22-dev
$ sudo apt install libavresample-dev
$ sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
$ sudo apt install libv4l-dev v4l-utils qv4l2 v4l2ucp
$ sudo apt install libgphoto2-dev
$ sudo apt install libxine2-dev
```

cmake実行
```bash
$ cmake /usr/local/src/opencv-3.3.0 -G Ninja -DHALIDE_ROOT_DIR=/usr/local -DHalide_DIR=/usr/local -DPROTOBUF_UPDATE_FILES=ON -DBUILD_DOCS=OFF -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_PROTOBUF=OFF -DBUILD_TESTS=OFF -DBUILD_WITH_DEBUG_INFO=OFF -DBUILD_opencv_apps=OFF -DBUILD_opencv_ts=OFF -DCMAKE_BUILD_TYPE=Release -DCUDA_FAST_MATH=ON -DENABLE_CXX11=ON -DOPENVX_ROOT=/usr -DOPENVX_openvx_LIBRARY=/usr/lib/libvisionworks.so -DOPENVX_vxu_LIBRARY=/usr/lib/libvisionworks.so -DOPENCV_DOWNLOAD_PATH=/usr/local/src/opencv_3rdparty_cache -DOPENCV_ENABLE_NONFREE=ON -DOPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib-3.3.0/modules -DWITH_CLP=ON -DWITH_CUBLAS=ON -DWITH_GDAL=ON -DWITH_GDCM=ON -DWITH_HALIDE=ON -DWITH_ITT=OFF -DWITH_LIBV4L=ON -DWITH_MATLAB=OFF -DWITH_OPENCL=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENGL=ON -DWITH_OPENVX=ON -DWITH_PTHREADS_PF=OFF -DWITH_QT=ON -DWITH_TBB=ON -DWITH_VA=ON -DWITH_XINE=ON
```

`/usr/local/cuda-8.0/targets/aarch64-linux/include/cuda_gl_interop.h`の編集
```cpp
#if defined(__arm__) || defined(__aarch64__)
#ifndef GL_VERSION
#error Please include the appropriate gl headers before including cuda_gl_interop.h
#endif
#else
#include <GL/gl.h>
#endif

↓

//#if defined(__arm__) || defined(__aarch64__)
//#ifndef GL_VERSION
//#error Please include the appropriate gl headers before including cuda_gl_interop.h
//#endif
//#else
#include <GL/gl.h>
//#endif
```

ビルド＆インストール
```bash
$ ninja -j6
$ sudo ninja install
```

### Caffe
関連パッケージインストール
```bash
$ sudo apt install libleveldb-dev libsnappy-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev
```

ビルド＆インストール
```bash
$ cmake /usr/local/src/caffe-1.0 -G "Ninja" -DBUILD_docs=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DBLAS=Open -Dpython_version=3
$ ninja -6
$ sudo ninja install
```
