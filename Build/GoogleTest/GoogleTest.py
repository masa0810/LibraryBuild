"""
Google Build
"""

# -*- coding: utf-8 -*-

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
        str(args.fastcopy_path), args.fastcopy_mode,
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
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode,
        str(Path(__file__).resolve().parent / "files" / "gtestset.h"),
        "/to={:s}".format(str(include_dir))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode,
        "/include=*.lib",
        str(build_dir / "install" / "lib"), "/to={:s}".format(
            str(final_dir / "lib" / platform_name))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    return result_state


def create_cmake_args(cmake_args, source_path, platform_name, vc_ver, args,
                      enable_shared, enable_debug):
    """CMakeの引数作成"""
    cmake_args.append(
        "-DBUILD_SHARED_LIBS={}".format("ON" if enable_shared else "OFF"))
    cmake_args.append("-Dgtest_force_shared_crt=ON")
    if enable_debug:
        cmake_args.append("-DCMAKE_DEBUG_POSTFIX=d")

    return True


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    lib_name = "GoogleTest"
    # バージョン設定
    lib_ver = "1.8.1"

    # ビルド実行
    success = com.build(lib_name, lib_ver, args, create_cmake_args,
                        result_copy)
    if success:
        success = com.build(
            lib_name,
            lib_ver,
            args,
            create_cmake_args,
            result_copy,
            enable_debug=True)

    sys.exit(0 if success else -1)
