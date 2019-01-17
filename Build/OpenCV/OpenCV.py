"""
OpenCV Build
"""

# -*- coding: utf-8 -*-

import argparse
import os
import subprocess
import sys
from pathlib import Path

sys.path.append(str((Path(__file__).parent.parent / "Common").resolve()))
import Common as com


def result_copy(final_dir, build_dir, platform_name, enable_shared,
                enable_debug, args):
    """ビルド結果コピー処理"""
    # include
    include_dir = final_dir / "include"
    result_state = com.copy_command(args, "/exclude=cvconfig.h",
                                    str(build_dir / "install" / "include"),
                                    "/to={:s}".format(str(include_dir)))

    # Configヘッダ
    result_state &= com.copy_command(
        args,
        str(build_dir / "install" / "include" / "opencv2" / "cvconfig.h"),
        "/to={:s}".format(str(include_dir)))

    # Configヘッダのリネーム
    config_header_src = include_dir / "cvconfig.h"
    config_header_dst = include_dir / "cvconfig_{:s}_{:s}_{:s}.h".format(
        platform_name, "Shared" if enable_shared else "Static",
        "Debug" if enable_debug else "Release")
    if config_header_dst.exists():
        config_header_dst.unlink()
    config_header_src.rename(config_header_dst)

    # セットヘッダ
    files_path = Path(__file__).resolve().parent / "files"
    result_state &= com.copy_command(args, str(files_path / "opencvset.h"),
                                     "/to={:s}".format(str(include_dir)))

    # bin
    result_state &= com.copy_command(
        args, "/include=*.dll;*.pdb", "/exclude=opencv_waldboost_detector*",
        str(build_dir / "bin"), "/to={:s}".format(
            str(final_dir / "bin" / platform_name)))

    # lib
    result_state &= com.copy_command(
        args, "/include=opencv_*.lib", str(build_dir / "lib"),
        "/to={:s}".format(str(final_dir / "lib" / platform_name)))

    # Inte Media SDK
    intel_media_sdk_dir = Path(
        r"C:\Program Files (x86)\IntelSWTools\Intel(R) Media SDK 2018 R2\Software Development Kit"
    )
    result_state &= com.copy_command(
        args, str(intel_media_sdk_dir / "bin" / platform_name),
        "/to={:s}".format(str(final_dir / "bin" / platform_name)))

    # コピーバッチ
    result_state &= com.copy_command(args, str(files_path / "OpenCvCopy.bat"),
                                     "/to={:s}".format(str(final_dir)))

    return result_state


def python_copy(final_dir, build_dir, platform_name, enable_shared,
                enable_debug, args):
    """ビルド結果コピー処理"""
    return True
    # # .pydファイル
    # result_state = com.copy_command(
    #     args, "/include=*.pyd", str(build_dir / "lib" / "python3"),
    #     "/to={:s}".format(str(final_dir / "Python3" / "cv2")))

    # # __init__.py
    # script_dir = Path(__file__).resolve().parent
    # files_path = script_dir / "files"
    # result_state &= com.copy_command(
    #     args, str(files_path / "__init__.py"), "/to={:s}".format(
    #         str(final_dir / "Python3" / "cv2")))

    # # ffmpeg
    # result_state = com.copy_command(
    #     args, "/include=opencv_ffmpeg*.dll", str(build_dir / "bin"),
    #     "/to={:s}".format(str(final_dir / "Python3" / "cv2")))

    # # CUDA
    # cuda_path = script_dir.parent.parent / "CUDA"
    # result_state &= com.copy_command(
    #     args,
    #     "/include=cublas64_*.dll;cudart64_*.dll;cufft64_*.dll;nppc64_*.dll;nppial64_*.dll;nppicc64_*.dll;nppidei64_*.dll;nppif64_*.dll;nppig64_*.dll;nppim64_*.dll;nppist64_*.dll;nppitc64_*.dll;npps64_*.dll",
    #     str(cuda_path / "bin"), "/to={:s}".format(
    #         str(final_dir / "Python3" / "cv2")))

    # # Halide
    # tmp_path = build_dir
    # tmp_dir = tmp_path.stem
    # while tmp_dir != platform_name:
    #     tmp_path = tmp_path.parent
    #     tmp_dir = tmp_path.stem
    # halide_path = tmp_path / "Shared" / "Halide" / "install"
    # result_state &= com.copy_command(
    #     args, "/include=*.dll", str(halide_path / "bin" / "Halide.dll"),
    #     "/to={:s}".format(str(final_dir / "Python3" / "cv2")))

    # # TBB
    # intel_lib_dir = Path(
    #     r"C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows")
    # platform_intel = "intel64" if platform_name == "x64" else "ia32"
    # vc_ver_intel = "vc{:s}".format(str(final_dir.parent.name)[1:3])
    # result_state &= com.copy_command(
    #     args, "/include=*.dll",
    #     str(intel_lib_dir / "redist" / platform_intel / "tbb" / vc_ver_intel /
    #         "tbb.dll"), "/to={:s}".format(str(final_dir / "Python3" / "cv2")))

    # # Inte Media SDK
    # intel_media_sdk_dir = Path(
    #     r"C:\Program Files (x86)\IntelSWTools\Intel(R) Media SDK 2018 R2\Software Development Kit"
    # )
    # result_state &= com.copy_command(
    #     args, str(intel_media_sdk_dir / "bin" / platform_name),
    #     "/to={:s}".format(str(final_dir / "Python3" / "cv2")))

    # return result_state


def create_cmake_args(cmake_args, source_path, platform_name, vs_ver, vc_ver,
                      args, enable_shared, enable_debug):
    """CMakeの引数作成"""
    # CUDAのリンク作成
    cuda_path_orig = os.getenv(
        "CUDA_PATH_V10_0",
        r"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.0")
    cuda_path = source_path / "CUDA"
    if not cuda_path.exists():
        subprocess.check_call([
            "powershell", "-Command", "Start-Process", "-Wait", "-FilePath",
            "cmd", "-Verb", "runas", "-ArgumentList",
            '/c, "mklink /D ""{:s}"" ""{:s}"" "'.format(
                str(cuda_path), cuda_path_orig)
        ])
    env_cuda_path = os.getenv("CUDA_PATH")
    if env_cuda_path == None or env_cuda_path != cuda_path_orig or env_cuda_path != cuda_path:
        os.environ['CUDA_PATH'] = cuda_path_orig
    # バージョン
    if vc_ver == 110:
        enable_cpp11 = False
        enable_halide = False
        enable_msmf = True
        vc_name = "vc11"
        arch_flag = ""
    elif vc_ver == 120:
        enable_cpp11 = False
        enable_halide = False
        enable_msmf = True
        vc_name = "vc12"
        arch_flag = ""
    elif vc_ver == 140:
        enable_cpp11 = True
        enable_halide = True
        enable_msmf = True
        vc_name = "vc14"
        arch_flag = ""
    elif vc_ver == 141:
        enable_cpp11 = True
        enable_halide = True
        enable_msmf = True
        vc_name = "vc14"
        arch_flag = "/arch:AVX2" if args.enable_avx2 else "/arch:AVX"
    elif vc_ver == 100:
        enable_cpp11 = False
        enable_halide = False
        enable_msmf = False
        vc_name = "vc10"
        arch_flag = ""
    # Intelライブラリのパス
    intel_lib_path = Path(
        r"C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows")
    # MKLのパス作成
    mkl_path = intel_lib_path / "mkl"
    # TBBのパス作成
    tbb_path = intel_lib_path / "tbb"
    tbb_lib_path = tbb_path / "lib" / ("intel64" if platform_name == "x64" else
                                       "ia32") / vc_name
    # ビルドパス
    build_dir = args.build_buf / vs_ver / platform_name
    # ProtoBufコンパイラのパス作成
    protoc_path = build_dir / "ProtoBuf" / "install" / "bin" / "protoc.exe"
    # デバッグ版
    if enable_debug:
        build_dir /= "Debug"
    # Gflagsのパス作成
    gflags_path = build_dir / "gflags" / "install"
    # Glogのパス作成
    glog_path = build_dir / "glog" / "install"
    # Halideのパス作成
    halide_path = build_dir / "Shared" / "Halide" / "install"
    # HDF5のパス作成
    hdf5_path = build_dir / "HDF5" / "install"
    # libjpegのパス作成
    libjpeg_path = build_dir / "libJpeg-turbo" / "install"
    # ProtoBufのパス作成
    protobuf_path = build_dir / "ProtoBuf" / "install"
    # Zlibのパス作成
    zlib_path = build_dir / "Zlib" / "install"

    # 機能別フラグ
    enable_cuda = True
    enable_no_free = False
    if not enable_shared and not enable_debug:
        enable_gstreamer = False
        enable_protobuf = False
        enable_python = True
        enable_world = False
    else:
        enable_gstreamer = True
        enable_protobuf = True
        enable_python = False
        enable_world = True

    # Build項目
    cmake_args.append("-DBUILD_DOCS=OFF")
    cmake_args.append("-DBUILD_PACKAGE=OFF")
    cmake_args.append("-DBUILD_PERF_TESTS=OFF")
    cmake_args.append("-DBUILD_TESTS=OFF")
    cmake_args.append("-DBUILD_WITH_STATIC_CRT=OFF")
    cmake_args.append("-DBUILD_opencv_apps=OFF")
    cmake_args.append("-DBUILD_opencv_java_bindings_generator=OFF")
    cmake_args.append("-DBUILD_opencv_js=OFF")
    cmake_args.append("-DBUILD_opencv_sfm=ON")
    cmake_args.append("-DBUILD_opencv_ts=OFF")
    cmake_args.append(
        "-DBUILD_SHARED_LIBS={:s}".format("ON" if enable_shared else "OFF"))
    cmake_args.append(
        "-DBUILD_opencv_world={:s}".format("ON" if enable_world else "OFF"))

    # CMake項目
    glog_static_flag = "/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL= /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS="
    cpp11_flag = "/std:c++14 /DCV_CXX_STD_ARRAY=1" if enable_cpp11 else ""
    cmake_args.append(
        "-DCMAKE_CXX_FLAGS=/DWIN32 /D_WINDOWS /W0 /GR /EHsc /bigobj {:s} {:s} {:s}"
        .format(arch_flag, glog_static_flag, cpp11_flag))
    cmake_args.append(
        "-DCMAKE_C_FLAGS=/DWIN32 /D_WINDOWS /W0 /bigobj {:s} {:s}".format(
            arch_flag, glog_static_flag))
    if enable_debug:
        cmake_args.append("-DCMAKE_DEBUG_POSTFIX=d")

    # OpenCV項目
    cmake_args.append(
        "-DCPU_BASELINE={:s}".format("AVX2" if args.enable_avx2 else "AVX"))
    cmake_args.append(
        "-DENABLE_CXX11={:s}".format("ON" if enable_cpp11 else "OFF"))
    cmake_args.append(
        "-DENABLE_LTO={:s}".format("OFF" if enable_debug else "ON"))
    cmake_args.append("-DOPENCV_DOWNLOAD_PATH={:s}".format(
        str(source_path / "opencv_3rdparty")).replace("\\", "/"))
    cmake_args.append("-DOPENCV_ENABLE_NONFREE={:s}".format(
        "ON" if enable_no_free else "OFF"))
    cmake_args.append("-DOPENCV_EXTRA_MODULES_PATH={:s}".format(
        str(source_path / "opencv_contrib" / "modules")).replace("\\", "/"))

    # With項目
    cmake_args.append("-DWITH_1394=OFF")
    cmake_args.append("-DWITH_MATLAB=OFF")
    cmake_args.append("-DWITH_MFX=ON")
    cmake_args.append(
        "-DWITH_MSMF={:s}".format("ON" if enable_msmf else "OFF"))
    cmake_args.append("-DWITH_OPENCL_SVM=ON")
    cmake_args.append("-DWITH_OPENGL=ON")
    cmake_args.append("-DWITH_VTK=OFF")

    # CUDA項目
    cmake_args.append(
        "-DWITH_CUBLAS={:s}".format("ON" if enable_cuda else "OFF"))
    cmake_args.append(
        "-DWITH_CUDA={:s}".format("ON" if enable_cuda else "OFF"))
    cmake_args.append(
        "-DWITH_CUFFT={:s}".format("ON" if enable_cuda else "OFF"))
    cmake_args.append(
        "-DWITH_NVCUVID={:s}".format("ON" if enable_cuda else "OFF"))
    if enable_cuda:
        cmake_args.append("-DCUDA_ARCH_BIN=5.2 6.1")
        cmake_args.append("-DCUDA_ARCH_PTX=3.0")
        cmake_args.append(
            "-DCUDA_FAST_MATH={:s}".format("OFF" if enable_debug else "ON"))
        cmake_args.append('-DCUDA_NVCC_FLAGS=-Xcompiler "/W0 /FS"')
        if not enable_shared:
            cmake_args.append("-DCUDA_USE_STATIC_CUDA_RUNTIME=OFF")

    # Eigen
    cmake_args.append("-DWITH_EIGEN=ON")
    cmake_args.append("-DEIGEN_INCLUDE_PATH={:s}".format(
        str(source_path / "eigen")).replace("\\", "/"))

    # gflags
    cmake_args.append("-Dgflags_DIR={:s}".format(
        str(gflags_path / "lib" / "cmake" / "gflags")).replace("\\", "/"))
    cmake_args.append("-DGFLAGS_SHARED=OFF")

    # glog
    cmake_args.append("-DGLOG_INCLUDE_DIR={:s}".format(
        str(glog_path / "include")).replace("\\", "/"))
    cmake_args.append("-DGLOG_LIBRARY={:s}".format(
        str(glog_path / "lib" /
            ("glogd.lib" if enable_debug else "glog.lib"))).replace("\\", "/"))
    cmake_args.append("-DGlog_LIBS={:s}".format(
        str(glog_path / "lib" /
            ("glogd.lib" if enable_debug else "glog.lib"))).replace("\\", "/"))

    # Gstreamer
    cmake_args.append(
        "-DWITH_GSTREAMER={:s}".format("ON" if enable_gstreamer else "OFF"))
    if enable_gstreamer:
        cmake_args.append("-DGSTREAMER_DIR={:s}".format(
            str(source_path.parent / "Gstreamer" / "1.0" /
                ("x86_64" if platform_name == "x64" else "x86"))).replace(
                    "\\", "/"))

    # Halide
    cmake_args.append(
        "-DWITH_HALIDE={:s}".format("ON" if enable_halide else "OFF"))
    if enable_halide:
        cmake_args.append("-DHALIDE_INCLUDE_DIR={:s}".format(
            str(halide_path / "include")).replace("\\", "/"))
        cmake_args.append("-DHALIDE_INCLUDE_DIRS={:s}".format(
            str(halide_path / "include")).replace("\\", "/"))
        cmake_args.append("-DHALIDE_LIBRARIES={:s}".format(
            str(halide_path / "lib" /
                ("Halided.lib" if enable_debug else "Halide.lib"))).replace(
                    "\\", "/"))
        cmake_args.append("-DHALIDE_LIBRARY={:s}".format(
            str(halide_path / "lib" /
                ("Halided.lib" if enable_debug else "Halide.lib"))).replace(
                    "\\", "/"))
        cmake_args.append("-DHALIDE_ROOT_DIR={:s}".format(
            str(halide_path)).replace("\\", "/"))
        cmake_args.append("-DHalide_DIR={:s}".format(str(halide_path)).replace(
            "\\", "/"))

    # HDF5
    cmake_args.append("-DHDF5_C_LIBRARY={:s}".format(
        str(hdf5_path / "lib" /
            ("libhdf5_D.lib" if enable_debug else "libhdf5.lib"))).replace(
                "\\", "/"))
    cmake_args.append("-DHDF5_INCLUDE_DIRS={:s}".format(
        str(hdf5_path / "include")).replace("\\", "/"))
    cmake_args.append("-DHDF5_USE_DLL=OFF")

    # Jpeg
    cmake_args.append("-DBUILD_JPEG=OFF")
    cmake_args.append("-DJPEG_INCLUDE_DIR={:s}".format(
        str(libjpeg_path / "include")).replace("\\", "/"))
    cmake_args.append("-DJPEG_LIBRARY={:s}".format(
        str(libjpeg_path / "lib" / ("jpeg-staticd.lib" if enable_debug else
                                    "jpeg-static.lib"))).replace("\\", "/"))

    # MKL
    cmake_args.append("-DMKL_ROOT_DIR={}".format(str(mkl_path)).replace(
        "\\", "/"))
    cmake_args.append("-DMKL_USE_DLL=OFF")
    cmake_args.append(
        "-DMKL_USE_MULTITHREAD={:s}".format("OFF" if enable_debug else "ON"))
    cmake_args.append(
        "-DMKL_WITH_TBB={:s}".format("OFF" if enable_debug else "ON"))
    cmake_args.append("-DMKL_USE_TBB_PREVIEW=OFF")
    cmake_args.append("-DMKL_WITH_OPENMP=OFF")

    # ProtoBuf
    cmake_args.append(
        "-DBUILD_PROTOBUF={:s}".format("OFF" if enable_protobuf else "ON"))
    cmake_args.append("-DPROTOBUF_UPDATE_FILES={:s}".format(
        "ON" if enable_protobuf else "OFF"))
    if enable_protobuf:
        cmake_args.append("-DProtobuf_INCLUDE_DIR={:s}".format(
            str(protobuf_path / "include")).replace("\\", "/"))
        cmake_args.append("-DProtobuf_PROTOC_EXECUTABLE={:s}".format(
            str(protoc_path)).replace("\\", "/"))
        if enable_debug:
            cmake_args.append("-DProtobuf_LIBRARY_DEBUG={:s}".format(
                str(protobuf_path / "lib" / "protobufd.lib")).replace(
                    "\\", "/"))
            cmake_args.append("-DProtobuf_LITE_LIBRARY_DEBUG={:s}".format(
                str(protobuf_path / "lib" / "protobuf-lited.lib")).replace(
                    "\\", "/"))
            cmake_args.append("-DProtobuf_PROTOC_LIBRARY_DEBUG={:s}".format(
                str(protobuf_path / "lib" / "protocd.lib")).replace("\\", "/"))
        else:
            cmake_args.append("-DProtobuf_LIBRARY_RELEASE={:s}".format(
                str(protobuf_path / "lib" / "protobuf.lib")).replace(
                    "\\", "/"))
            cmake_args.append("-DProtobuf_LITE_LIBRARY_RELEASE={:s}".format(
                str(protobuf_path / "lib" / "protobuf-lite.lib")).replace(
                    "\\", "/"))
            cmake_args.append("-DProtobuf_PROTOC_LIBRARY_RELEASE={:s}".format(
                str(protobuf_path / "lib" / "protoc.lib")).replace("\\", "/"))

    # Python
    cmake_args.append(
        "-DBUILD_opencv_python3={:s}".format("ON" if enable_python else "OFF"))
    cmake_args.append("-DBUILD_opencv_python_bindings_generator={:s}".format(
        "ON" if enable_python else "OFF"))
    if enable_python:
        cmake_args.append("-DPYTHON3_EXECUTABLE={:s}".format(
            str(source_path.parent / "Python" / "python")).replace("\\", "/"))

    # TBB
    cmake_args.append("-DWITH_TBB=ON")
    cmake_args.append("-DTBB_ENV_INCLUDE={:s}".format(
        str(tbb_path / "include")).replace("\\", "/"))
    if enable_debug:
        cmake_args.append("-DTBB_ENV_LIB_DEBUG={:s}".format(
            str(tbb_lib_path / "tbb_debug.lib")).replace("\\", "/"))
    else:
        cmake_args.append("-DTBB_ENV_LIB={:s}".format(
            str(tbb_lib_path / "tbb.lib")).replace("\\", "/"))

    # Zlib
    cmake_args.append("-DBUILD_ZLIB=OFF")
    cmake_args.append("-DZLIB_INCLUDE_DIR={:s}".format(
        str(zlib_path / "include")).replace("\\", "/"))
    if enable_debug:
        cmake_args.append("-DZLIB_LIBRARY_DEBUG={:s}".format(
            str(zlib_path / "lib" / "zlibstaticd.lib")).replace("\\", "/"))
    else:
        cmake_args.append("-DZLIB_LIBRARY_RELEASE={:s}".format(
            str(zlib_path / "lib" / "zlibstatic.lib")).replace("\\", "/"))

    return True


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    lib_name = "OpenCV"
    # バージョン設定
    lib_ver = "4.0.1"

    # ビルド実行
    success = com.build(
        lib_name,
        lib_ver,
        args,
        create_cmake_args,
        result_copy,
        enable_shared=True)
    if success:
        success = com.build(
            lib_name,
            lib_ver,
            args,
            create_cmake_args,
            result_copy,
            enable_shared=True,
            enable_debug=True)

    # VS2015はPythonもビルド
    _, vc_ver = com.get_vs_env()
    if success and vc_ver == 140:
        success = com.build(lib_name, lib_ver, args, create_cmake_args,
                            python_copy)

    sys.exit(0 if success else -1)
