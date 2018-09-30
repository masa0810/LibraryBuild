"""
ヘッダorビルド済みライブラリのコピースクリプト
"""

# -*- coding: utf-8 -*-

import sys
from pathlib import Path

sys.path.append(str((Path(__file__).parent / "Common").resolve()))
import Common as com


def safe_run(batch_file, args, min_loop=1, max_loop=1):
    """セーフ実行"""
    # 開始
    show_lib_name = str(batch_file.stem)
    print("[{}] Start".format(show_lib_name))
    # プロセス生成
    python_args = [
        "python",
        str(batch_file), "--fastcopy_path",
        str(args.fastcopy_path), "--fastcopy_mode",
        str(args.fastcopy_mode), "--cmake_dir",
        str(args.cmake_dir), "--ninja_path",
        str(args.ninja_path), "--build_buf",
        str(args.build_buf)
    ]
    if args.enable_install:
        python_args.append("-i")
    if args.rebuild:
        python_args.append("-r")
    if args.force:
        python_args.append("-f")
    if args.disable_auto_simd:
        python_args.append("-a")
    if args.gui:
        python_args.append("-g")
    if args.verbose:
        python_args.append("-v")
    if args.verbose:
        print("Python Args :")
        for i in python_args:
            print(i)

    # 最大繰り返し回数分ループ
    for i in range(max_loop):
        result_state = com.run_proc(python_args)
        # 最低ループ数以上の場合終了判定
        if i >= min_loop - 1:
            # 戻り値が正常な場合は終了
            if result_state:
                break
            elif i > 0:
                print("[{}] Error Retry={}".format(show_lib_name, i))
    # 結果表示
    print("[{}] {}".format(show_lib_name,
                           "Success" if result_state else "Faild"))
    return result_state


def build_run(build_name, script_dir, args):
    """ビルド実行"""
    copy_only_switcher = {
        "cuda": script_dir / "CUDA" / "CUDA.py",
        "eigen": script_dir / "Eigen" / "Eigen.py",
        "fmt": script_dir / "Fmt" / "Fmt.py",
        "gstreamer": script_dir / "Gstreamer" / "Gstreamer.py",
        "intel": script_dir / "Intel" / "Intel.py",
        "pybind11": script_dir / "PyBind11" / "PyBind11.py"
    }
    build_switcher = {
        "benchmark": script_dir / "Benchmark" / "Benchmark.py",
        "boost": script_dir / "Boost" / "Boost.py",
        "caffe": script_dir / "Caffe" / "Caffe.py",
        "gflags": script_dir / "Gflags" / "Gflags.py",
        "glog": script_dir / "Glog" / "Glog.py",
        "googletest": script_dir / "GoogleTest" / "GoogleTest.py",
        "halide": script_dir / "Halide" / "Halide.py",
        "hdf5": script_dir / "HDF5" / "HDF5.py",
        "leveldb": script_dir / "LevelDB" / "LevelDB.py",
        "libcapture": script_dir / "libCapture" / "libCapture.py",
        "libjpeg-turbo": script_dir / "libJpeg-turbo" / "libJpeg-turbo.py",
        "lmdb": script_dir / "Lmdb" / "Lmdb.py",
        "mxnet": script_dir / "MXNet" / "MXNet.py",
        "opencv": script_dir / "OpenCV" / "OpenCV.py",
        "protobuf": script_dir / "ProtoBuf" / "ProtoBuf.py",
        "snappy": script_dir / "Snappy" / "Snappy.py",
        "tbb": script_dir / "TBB" / "TBB.py",
        "zlib": script_dir / "Zlib" / "Zlib.py"
    }
    build_name_lower = build_name.lower()
    batch_path = copy_only_switcher.get(build_name_lower)
    if batch_path is not None:
        if args.enable_install:
            return safe_run(batch_path, args)
        else:
            print("[{}] Skip".format(str(batch_path.stem)))
            return True
    batch_path = build_switcher.get(build_name_lower)
    if batch_path is not None:
        return safe_run(batch_path, args, 2, 3)

    print("[{}] Nothing build config".format(build_name))
    return False


if __name__ == "__main__":
    """メイン"""
    # スクリプトの場所
    script_dir = Path(__file__).parent
    # 引数取得
    args = com.get_args()
    # ビルドするライブラリリスト
    build_lib_list = args.lib_names if args.lib_names else [
        "CUDA", "Eigen", "Fmt", "Intel", "TBB", "OpenCV", "Boost"
    ]
    # ビルド実行
    for name in build_lib_list:
        if not build_run(name, script_dir, args):
            break
    # ループが回りきった場合
    else:
        sys.exit(0)
    # ループが回りきらなかった場合
    sys.exit(-1)
