"""
CUDA Build
"""

# -*- coding: utf-8 -*-

import os
import subprocess
import sys
from pathlib import Path

sys.path.append(str((Path(__file__).parent.parent / "Common").resolve()))
import Common as com


def cuda_copy(final_dir, lib_dir, platform_name, enable_shared, enable_debug,
              args):
    """ビルド結果コピー処理"""
    # シンボリックリンク作成
    if not lib_dir.exists():
        cuda_path = os.getenv(
            "CUDA_PATH_V10_0",
            r"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.0")
        subprocess.check_call([
            "powershell", "-Command", "Start-Process", "-Wait", "-FilePath",
            "cmd", "-Verb", "runas", "-ArgumentList",
            '/c, "mklink /D ""{:s}"" ""{:s}"" "'.format(
                str(lib_dir), cuda_path)
        ])

    # include
    result_state = com.copy_command(
        args, str(lib_dir / "include"), "/to={:s}".format(
            str(final_dir / "include")))

    # bin
    result_state &= com.copy_command(args, "/include=*.dll", "/exclude=*32*",
                                     str(lib_dir / "bin"), "/to={:s}".format(
                                         str(final_dir / "bin")))

    # lib
    result_state &= com.copy_command(
        args, "/include=*.lib", str(lib_dir / "lib" / platform_name),
        "/to={:s}".format(str(final_dir / "lib" / platform_name)))

    # 依存DLL
    driver_path = Path(__file__).resolve().parent / "NvidiaDriver"
    result_state &= com.copy_command(
        args, str(driver_path / "nvcuda.dll"),
        str(driver_path / "nvcuvid.dll"),
        str(driver_path / "nvfatbinaryLoader.dll"), "/to={:s}".format(
            str(final_dir / "bin")))

    return result_state


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    cuda_name = "CUDA"
    # バージョン設定
    cuda_ver = "10.0.130"
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
    cudnn_ver = "7.4.2.24"
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
