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


def intel_copy(final_dir, lib_dir, platform_name, enable_shared, enable_debug,
               args):
    """ビルド結果コピー処理"""
    intel_lib_dir = Path(r"C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows")

    # ライブラリ名
    lib_name_intel = lib_dir.name

    # プラットフォーム名
    platform_intel = "intel64" if platform_name == "x64" else "ia32"

    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        str(intel_lib_dir / lib_name_intel / "include"), "/to={:s}".format(
            str(final_dir / "include"))
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
        "/include=*.dll", "/exclude=*32*",
        str(intel_lib_dir / "redist" / platform_intel / lib_name_intel / "*"),
        "/to={:s}".format(str(final_dir / "bin" / platform_name))
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
        str(intel_lib_dir / lib_name_intel / "lib" / platform_intel / "*"),
        "/to={:s}".format(str(final_dir / "lib" / platform_name))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    return result_state


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    mkl_name = "MKL"
    # バージョン設定
    intel_ver = "2018Update3"
    # ビルド実行
    success = com.build(
        mkl_name, intel_ver, args, None, intel_copy, enable_vs_share=True)

    # ライブラリ名
    ipp_name = "IPP"
    # ビルド実行
    success = com.build(
        ipp_name, intel_ver, args, None, intel_copy, enable_vs_share=True)

    sys.exit(0 if success else -1)
