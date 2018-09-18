"""
ヘッダorビルド済みライブラリのコピースクリプト
"""

# -*- coding: utf-8 -*-

import os
import subprocess
import sys


def get_line(proc):
    """コマンドライン出力取得"""
    while True:
        line = proc.stdout.readline()
        if line:
            yield line
        if not line and proc.poll() is not None:
            break


def safe_run(batch_file):
    """セーフ実行"""

    # 表示文字列作成
    show_string = os.path.basename(os.path.dirname(batch_file))

    # プロセスを生成してバッチファイルを実行
    proc = subprocess.Popen(
        batch_file, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    # バッチファイルの出力をコンソールに出力
    for line in get_line(proc):
        sys.stdout.write(line.decode("sjis", "ignore"))

    # 正常終了
    print("[{:s}] Success".format(show_string))


def build_run(build_name):
    """ビルド実行"""

    switcher = {
        "cereal": os.path.join(SCRIPT_PATH, r"Cereal\Cereal_Build.bat"),
        "cuda": os.path.join(SCRIPT_PATH, r"CUDA\CUDA_Build.bat"),
        "eigen": os.path.join(SCRIPT_PATH, r"Eigen\Eigen_Build.bat"),
        "fmt": os.path.join(SCRIPT_PATH, r"Fmt\Fmt_Build.bat"),
        "gstreamer": os.path.join(SCRIPT_PATH,
                                  r"Gstreamer\Gstreamer_Build.bat"),
        "intel": os.path.join(SCRIPT_PATH, r"Intel\Intel_Build.bat"),
        "pybind11": os.path.join(SCRIPT_PATH, r"PyBind11\PyBind11_Build.bat")
    }

    batch_path = switcher.get(build_name.lower())
    if batch_path is not None:
        safe_run(batch_path)


if __name__ == "__main__":

    # スクリプトの場所
    SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))

    # 引数取得
    ARGV = sys.argv

    # 引数の数
    ARGC = len(ARGV)

    # ビルド実行
    if ARGC > 1:
        for n in range(1, ARGC):
            build_run(ARGV[n])
    else:
        # for name in ["Cereal",
        #              "CUDA",
        for name in ["CUDA", "Eigen", "Fmt", "Intel"]:
            build_run(name)
