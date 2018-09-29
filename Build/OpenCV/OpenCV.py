"""
ライブラリビルド
"""

# -*- coding: utf-8 -*-

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.append(str((Path(__file__).parent.parent / "Common").resolve()))
import Common as com


def result_copy(final_dir, build_dir, platform_name, enable_shared,
                enable_debug, args):
    """ビルド結果コピー処理"""
    # FastCopyの引数作成
    include_dir = final_dir / "include"
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        str(build_dir / "install" / "include"), "/to={:s}".format(
            str(include_dir))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    files_path = Path(__file__).resolve().parent / "files"
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        str(files_path / "opencvset.h"), "/to={:s}".format(str(include_dir))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        str(files_path / "OpenCvCopy.bat"), "/to={:s}".format(str(final_dir))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        "/include=*.dll;*.pdb",
        str(build_dir / "bin"), "/to={:s}".format(
            str(final_dir / "bin" / platform_name))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        "/include=*.lib",
        str(build_dir / "lib"), "/to={:s}".format(
            str(final_dir / "lib" / platform_name))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    return result_state


def create_cmake_args(cmake_args, source_path, build_base_dir, platform_name,
                      vc_ver, args, enable_shared, enable_debug):
    """CMakeの引数作成"""
    if platform_name == "Win32":
        platform_name_short = "x86"
        platform_name_gst = "x86"
        platform_name_intel = "ia32"
    else:
        platform_name_short = "x64"
        platform_name_gst = "x86_64"
        platform_name_intel = "intel64"
    if vc_ver == 110:
        vc_name = "vc11"
    elif vc_ver == 120:
        vc_name = "vc12"
    elif vc_ver == 140:
        vc_name = "vc14"
    elif vc_ver == 141:
        vc_name = "vc14"
    elif vc_ver == 100:
        vc_name = "vc10"
    glog_flag = "/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL= /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS="
    intel_lib_path = Path(
        r"C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows")
    mkl_path = intel_lib_path / "mkl"
    mkl_lib_path = mkl_path / "lib" / platform_name_intel
    tbb_path = intel_lib_path / "tbb"
    tbb_lib_path = tbb_path / "lib" / platform_name_intel / vc_name

    cmake_args.append("-DBUILD_DOCS=OFF")
    cmake_args.append("-DBUILD_PACKAGE=OFF")
    cmake_args.append("-DBUILD_PERF_TESTS=OFF")
    cmake_args.append(
        "-DBUILD_SHARED_LIBS={}".format("ON" if enable_shared else "OFF"))
    cmake_args.append("-DBUILD_TESTS=OFF")
    cmake_args.append("-DBUILD_WITH_STATIC_CRT=OFF")
    cmake_args.append("-DBUILD_opencv_apps=OFF")
    cmake_args.append("-DBUILD_opencv_java_bindings_generator=OFF")
    cmake_args.append("-DBUILD_opencv_js=OFF")
    cmake_args.append("-DBUILD_opencv_sfm=OFF")
    cmake_args.append("-DBUILD_opencv_ts=OFF")
    cmake_args.append("-DBUILD_opencv_world=ON")
    cmake_args.append(
        "-DCMAKE_CXX_FLAGS=/DWIN32 /D_WINDOWS /W0 /GR /EHsc /bigobj /std:c++14 /DCV_CXX_STD_ARRAY=1 {}"
        .format(glog_flag if enable_shared else ""))
    cmake_args.append("-DCMAKE_C_FLAGS=/DWIN32 /D_WINDOWS /W0 /bigobj {}".
                      format(glog_flag if enable_shared else ""))
    cmake_args.append("-DCMAKE_EXE_LINKER_FLAGS=/machine:{} /MANIFEST:NO".
                      format(platform_name_short))
    cmake_args.append("-DCMAKE_MODULE_LINKER_FLAGS=/machine:{} /MANIFEST:NO".
                      format(platform_name_short))
    cmake_args.append("-DCMAKE_SHARED_LINKER_FLAGS=/machine:{} /MANIFEST:NO".
                      format(platform_name_short))
    cmake_args.append("-DCPU_BASELINE={}".format(
        "SSE4_2" if args.disable_auto_simd else "AVX2"))
    cmake_args.append("-DCUDA_ARCH_BIN=5.0")
    cmake_args.append('-DCUDA_NVCC_FLAGS=-Xcompiler "/W0 /FS"')
    cmake_args.append(
        "-DCUDA_FAST_MATH={}".format("OFF" if enable_debug else "ON"))
    cmake_args.append("-DEIGEN_INCLUDE_PATH={}".format(
        str(source_path / "eigen")).replace("\\", "/"))
    cmake_args.append("-DENABLE_CXX11=ON")
    cmake_args.append("-DENABLE_LTO=ON")
    cmake_args.append("-DGSTREAMER_DIR={}".format(
        str(source_path.parent / "Gstreamer" / "1.0" /
            platform_name_gst)).replace("\\", "/"))
    cmake_args.append("-DMKL_INCLUDE_DIRS={}".format(
        str(mkl_path / "include")))
    cmake_args.append("-DMKL_ROOT_DIR={}".format(str(mkl_path)).replace(
        "\\", "/"))
    cmake_args.append("-DMKL_LIBRARIES={};{};{}".format(
        str(mkl_lib_path / "mkl_intel_lp64.lib"),
        str(mkl_lib_path /
            ("mkl_sequential.lib" if enable_debug else "mkl_tbb_thread.lib")),
        str(mkl_lib_path / "mkl_core.lib")).replace("\\", "/"))
    cmake_args.append("-DMKL_USE_DLL=OFF")
    cmake_args.append("-DMKL_USE_MULTITHREAD=OFF")
    cmake_args.append(
        "-DMKL_WITH_TBB={}".format("OFF" if enable_debug else "ON"))
    cmake_args.append("-DMKL_USE_TBB_PREVIEW=OFF")
    cmake_args.append("-DOPENCV_DOWNLOAD_PATH={}".format(
        str(source_path / "opencv_3rdparty")).replace("\\", "/"))
    cmake_args.append("-DOPENCV_ENABLE_NONFREE=ON")
    cmake_args.append("-DTBB_ENV_INCLUDE={}".format(str(
        tbb_path / "include")).replace("\\", "/"))
    cmake_args.append("-DWITH_1394=OFF")
    cmake_args.append("-DWITH_CUBLAS=ON")
    cmake_args.append("-DWITH_CUDA=ON")
    cmake_args.append("-DWITH_CUFFT=ON")
    cmake_args.append("-DWITH_GSTREAMER=ON")
    cmake_args.append("-DWITH_MATLAB=OFF")
    cmake_args.append("-DWITH_MSMF=ON")
    cmake_args.append("-DWITH_NVCUVID=ON")
    cmake_args.append("-DWITH_OPENCL=ON")
    cmake_args.append("-DWITH_OPENCL_SVM=ON")
    cmake_args.append("-DWITH_OPENGL=ON")
    cmake_args.append("-DWITH_TBB=ON")
    cmake_args.append("-DWITH_VTK=OFF")

    if enable_debug:
        cmake_args.append("-DCMAKE_DEBUG_POSTFIX=d")
        cmake_args.append("-DTBB_ENV_LIB_DEBUG={}".format(
            str(tbb_lib_path / "tbb_debug.lib")).replace("\\", "/"))
    else:
        cmake_args.append("-DTBB_ENV_LIB={}".format(
            str(tbb_lib_path / "tbb.lib")).replace("\\", "/"))

    return True


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    lib_name = "OpenCV"
    # バージョン設定
    lib_ver = "3.4.3"

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

    sys.exit(0 if success else -1)
