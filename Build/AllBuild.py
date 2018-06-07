"""
全てのライブラリをビルドするスクリプト
"""

# -*- coding: utf-8 -*-

import os
import subprocess
import sys

LOOP_MIN = 2
LOOP_MAX = 10

def get_line(proc):
    """コマンドライン出力取得"""
    while True:
        line = proc.stdout.readline()
        if line:
            yield line
        if not line and proc.poll() is not None:
            break

def safe_run(batch_file, *args, min_loop=1, max_loop=1):
    """セーフ実行"""

    # 表示文字列作成
    show_string = os.path.basename(os.path.dirname(batch_file))

    # 引数リストを作成
    arg_list = [batch_file]
    for arg in args:
        if arg is not None:
            arg_list.append(arg)
            show_string += ' ' + arg

    # 開始
    print("[{:s}] Start".format(show_string))

    # 最大繰り返し回数分ループ
    for i in range(max_loop):
        # プロセスを生成してバッチファイルを実行
        proc = subprocess.Popen(arg_list, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        # バッチファイルの出力をコンソールに出力
        for line in get_line(proc):
            sys.stdout.write(line.decode("sjis", "ignore"))

        # 最低ループ数以上の場合終了判定
        if i >= min_loop - 1:
            # 戻り値が正常な場合は終了
            if proc.returncode == 0:
                break
            elif i > 0:
                print("[{:s}] Error Retry={:d}".format(show_string, i))
    # 終了しなかった場合
    else:
        print("[{:s}] Failed".format(show_string))
        return False

    # 正常終了
    print("[{:s}] Success".format(show_string))
    return True

def build_run(build_name, flag_avx=False):
    """ビルド実行"""

    if flag_avx:
        print("Enable AVX")

    switcher = {
        "boost": (os.path.join(SCRIPT_PATH, r"Boost\Boost_Build.bat"), flag_avx),
        "caffe": (os.path.join(SCRIPT_PATH, r"Caffe\Caffe_Build.bat"), False),
        "gflags": (os.path.join(SCRIPT_PATH, r"Gflags\gflags_Build.bat"), False),
        "glog": (os.path.join(SCRIPT_PATH, r"Glog\glog_Build.bat"), False),
        "halide": (os.path.join(SCRIPT_PATH, r"Halide\Halide_Build.bat"), False),
        "hdf5": (os.path.join(SCRIPT_PATH, r"HDF5\HDF5_Build.bat"), False),
        "icu": (os.path.join(SCRIPT_PATH, r"ICU\ICU_Build.bat"), False),
        "leveldb": (os.path.join(SCRIPT_PATH, r"LevelDB\LevelDB_Build.bat"), False),
        "libcapture": (os.path.join(SCRIPT_PATH, r"libCapture\libCapture_Build.bat"), False),
        "libjpeg-turbo":
            (os.path.join(SCRIPT_PATH, r"libJpeg-turbo\libJpeg-turbo_Build.bat"), False),
        "lmdb": (os.path.join(SCRIPT_PATH, r"Lmdb\lmdb_Build.bat"), False),
        "mxnet": (os.path.join(SCRIPT_PATH, r"MXNet\MXNet_Build.bat"), False),
        "opencv": (os.path.join(SCRIPT_PATH, r"OpenCV\OpenCV_Build.bat"), flag_avx),
        "protobuf": (os.path.join(SCRIPT_PATH, r"ProtoBuf\ProtoBuf_Build.bat"), False),
        "snappy": (os.path.join(SCRIPT_PATH, r"Snappy\Snappy_Build.bat"), False),
        "zlib": (os.path.join(SCRIPT_PATH, r"Zlib\zlib_Build.bat"), False)
    }

    batch_path, avx_status = switcher.get(build_name.lower(), (None, False))
    if batch_path is not None and safe_run(batch_path, "avx" if avx_status else None, min_loop=LOOP_MIN, max_loop=LOOP_MAX):
        return safe_run(batch_path, "install", "avx" if avx_status else None)
    else:
        return False

if __name__ == "__main__":

    # スクリプトの場所
    SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))

    # 引数取得
    ARGV = sys.argv

    # avx確認
    enable_avx = "avx" in ARGV
    if enable_avx:
        ARGV.remove("avx")

    # 引数の数
    ARGC = len(ARGV)

    # ビルド実行
    if ARGC > 1:
        for n in range(1, ARGC):
            build_run(ARGV[n], enable_avx)
    else:
        for name in ["zlib",
                     "HDF5",
                     "libJpeg-turbo",
                     "gflags",
                     "glog",
                     "ProtoBuf",
                     "Halide",
                     "OpenCV",
                     "MXNet",
                     "ICU",
                     "Boost",
                     "lmdb",
                     "Snappy",
                     "LevelDB",
                     "Caffe"]:
            if not build_run(name, enable_avx):
                break
