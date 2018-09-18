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


def tbb_copy(final_dir, lib_dir, platform_name, enable_shared, enable_debug,
             args):
    """ビルド結果コピー処理"""
    intel_lib_dir = Path(
        r"C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows")

    # ライブラリ名
    lib_name_intel = lib_dir.name

    # プラットフォーム名
    platform_intel = "intel64" if platform_name == "x64" else "ia32"

    # VCバージョン
    vc_ver_intel = "vc{:s}".format(str(final_dir.parent.name)[1:3])

    # FastCopyの引数作成
    include_dir = final_dir / "include"
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        "/exclude=*.html",
        str(intel_lib_dir / lib_name_intel / "include"), "/to={:s}".format(
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
        str(files_path / "tbbset.h"), "/to={:s}".format(str(include_dir))
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
        str(files_path / "TbbCopy.bat"), "/to={:s}".format(str(final_dir))
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
        str(intel_lib_dir / "redist" / platform_intel / lib_name_intel /
            vc_ver_intel), "/to={:s}".format(
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
        "/exclude=*.def;*.pdb",
        str(intel_lib_dir / lib_name_intel / "lib" / platform_intel /
            vc_ver_intel), "/to={:s}".format(
                str(final_dir / "lib" / platform_name))
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
    lib_name = "TBB"
    # バージョン設定
    lib_ver = "2018Update4"
    # ビルド実行
    success = com.build(lib_name, lib_ver, args, None, tbb_copy)

    sys.exit(0 if success else -1)
