#pragma once

// glog
#define GLOG_NO_ABBREVIATED_SEVERITIES

#ifdef CAFFE_DYN_LINK
    // glog
    #define GOOGLE_GLOG_DLL_DECL __declspec(dllimport)
    #define GOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS __declspec(dllimport)

    // ProtoBuf
    #define PROTOBUF_USE_DLLS
#else
    // glog
    #define GOOGLE_GLOG_DLL_DECL
    #define GOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS
#endif

// 各種スイッチ
#define USE_LMDB
#define USE_LEVELDB
#define USE_CUDNN
#define USE_OPENCV

// cuda対応
#ifndef __CAFFE_NO_INCLUDE__

    // MSVCの場合
    #ifdef _MSC_VER
        #define CAFFE_MSVC_ALL_WARNING_PUSH __pragma(warning(push, 0))
        #define CAFFE_MSVC_WARNING_POP __pragma(warning(pop))
    #else
        #define CAFFE_MSVC_ALL_WARNING_PUSH
        #define CAFFE_MSVC_WARNING_POP
    #endif

    // 全ての警告を抑制
    CAFFE_MSVC_ALL_WARNING_PUSH

    // C4996警告対策
    #ifndef _CRT_SECURE_NO_WARNINGS
        #define _CRT_SECURE_NO_WARNINGS
        #if defined(_DEBUG) && !defined(_SCL_SECURE_NO_WARNINGS)
            #define _SCL_SECURE_NO_WARNINGS
        #endif
        #include <cstdio>
        #ifdef _SCL_SECURE_NO_WARNINGS
            #undef _SCL_SECURE_NO_WARNINGS
        #endif
        #undef _CRT_SECURE_NO_WARNINGS
    #endif

    // STRICT対策
    #ifdef STRICT
        #pragma push_macro("STRICT")
        #undef STRICT
        #define __FLAG_PUSH__
    #endif
    #include <caffe/proto/caffe.pb.h>
    #ifdef __FLAG_PUSH__
        #pragma pop_macro("STRICT")
        #undef __FLAG_PUSH__
    #endif

    // 警告抑制解除
    CAFFE_MSVC_WARNING_POP

#endif

#ifndef _LIB
    // サフィックス設定
    #ifdef CAFFE_USE_DEBUG
        #define __CAFFESET_DBG_SUFFIX__ "-d"
        #define __CAFFESET_DBG_SUFFIX_2__ "d"
        #define __CAFFESET_DBG_HDF5_SUFFIX__ "_D"
    #else
        #define __CAFFESET_DBG_SUFFIX__
        #define __CAFFESET_DBG_SUFFIX_2__
        #define __CAFFESET_DBG_HDF5_SUFFIX__
    #endif

    // サフィックス設定2
    #ifdef CAFFE_DYN_LINK
        #define __CAFFESET_LINK_PATH__
        #define __CAFFESET_STATIC_SUFFIX__
        #define __CAFFESET_STATIC_HDF5_PREFIX__
    #else
        #define __CAFFESET_LINK_PATH__ "static/"
        #define __CAFFESET_STATIC_SUFFIX__ "_static"
        #define __CAFFESET_STATIC_HDF5_PREFIX__ "lib"

        #define CMAKE_WINDOWS_BUILD
    #endif

    // Caffe
    #pragma comment(lib, __CAFFESET_LINK_PATH__ "caffe" __CAFFESET_DBG_SUFFIX__ ".lib")

    // gflags
    #pragma comment(lib, "gflags" __CAFFESET_STATIC_SUFFIX__ __CAFFESET_DBG_SUFFIX_2__ ".lib")

    // glog
    #pragma comment(lib, __CAFFESET_LINK_PATH__ "glog" __CAFFESET_DBG_SUFFIX_2__ ".lib")

    // LevelDB
    #pragma comment(lib, __CAFFESET_LINK_PATH__ "leveldb" __CAFFESET_DBG_SUFFIX_2__ ".lib")

    // lmdb
    #pragma comment(lib, __CAFFESET_LINK_PATH__ "lmdb" __CAFFESET_DBG_SUFFIX_2__ ".lib")

    // Snappy
    #pragma comment(lib, "snappy" __CAFFESET_STATIC_SUFFIX__ __CAFFESET_DBG_SUFFIX_2__ ".lib")

    // HDF5
    #pragma comment(lib, __CAFFESET_STATIC_HDF5_PREFIX__ "hdf5" __CAFFESET_DBG_HDF5_SUFFIX__ ".lib")
    #pragma comment(lib, __CAFFESET_STATIC_HDF5_PREFIX__ "hdf5_hl" __CAFFESET_DBG_HDF5_SUFFIX__ ".lib")

    // CUDA
    #pragma comment(lib, "cudart.lib")

    // cuBLAS
    #pragma comment(lib, "cublas.lib")

    // cuRAND
    #pragma comment(lib, "curand.lib")

    // cuDNN
    #pragma comment(lib, "cudnn.lib")

    #if !defined(CAFFE_DYN_LINK) && !defined(__CAFFE_NO_INCLUDE__)
        // Caffeの追加ライブラリ
        #pragma comment(lib, __CAFFESET_LINK_PATH__ "caffeproto" __CAFFESET_DBG_SUFFIX__ ".lib")
        // Boost.Pythonライブラリ
        CAFFE_MSVC_ALL_WARNING_PUSH
        #define BOOST_LIB_NAME boost_python3
        #include <boost/config/auto_link.hpp>
        #define BOOST_LIB_NAME boost_thread
        #include <boost/config/auto_link.hpp>
        CAFFE_MSVC_WARNING_POP
        // gflags依存
        #pragma comment(lib, "Shlwapi.lib")
        // lmdb依存
        #pragma comment(lib, "ntdll.lib")
    #endif
#endif

#define _HAVE_CAFFE
