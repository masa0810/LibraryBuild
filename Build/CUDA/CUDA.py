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


def cuda_copy(final_dir, lib_dir, platform_name, enable_shared, enable_debug,
              args):
    """ビルド結果コピー処理"""
    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        str(lib_dir / "include"), "/to={:s}".format(str(final_dir / "include"))
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
        str(lib_dir / "bin"), "/to={:s}".format(
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
        str(lib_dir / "lib" / platform_name), "/to={:s}".format(
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
    cuda_name = "CUDA"
    # バージョン設定
    cuda_ver = "9.2patch1"
    # ビルド実行
    success = com.build(
        cuda_name,
        cuda_ver,
        args,
        None,
        cuda_copy,
        cuda_name,
        enable_vs_share=True)

    # ライブラリ名
    cudnn_name = "cuDNN"
    # バージョン設定
    cudnn_ver = "7.2.1"
    # ビルド実行
    success = com.build(
        cudnn_name,
        cudnn_ver,
        args,
        None,
        cuda_copy,
        dst_dir_name=cuda_name,
        enable_vs_share=True,
        enable_ver_check=False)

    sys.exit(0 if success else -1)
