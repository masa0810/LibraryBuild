#pragma once

// configファイル読み込み
#include "opencv2/opencv_modules.hpp"
#ifdef OPENCV_DYN_LINK
    #ifdef OPENCV_USE_DEBUG
        #ifdef _WIN64
            #include "cvconfig_x64_Shared_Debug.h"
        #else
            #include "cvconfig_Win32_Shared_Debug.h"
        #endif
    #else
        #ifdef _WIN64
            #include "cvconfig_x64_Shared_Release.h"
        #else
            #include "cvconfig_Win32_Shared_Release.h"
        #endif
    #endif
#else
    #ifdef OPENCV_USE_DEBUG
        #ifdef _WIN64
            #include "cvconfig_x64_Static_Debug.h"
        #else
            #include "cvconfig_Win32_Static_Debug.h"
        #endif
    #else
        #ifdef _WIN64
            #include "cvconfig_x64_Static_Release.h"
        #else
            #include "cvconfig_Win32_Static_Release.h"
        #endif
    #endif
#endif

#ifndef _LIB
    // サフィックス設定
    #ifdef OPENCV_USE_DEBUG
        #define __OPENCVSET_SUFFIX__ "d"
    #else
        #define __OPENCVSET_SUFFIX__
    #endif

    // フォルダ設定
    #if defined(BUILD_SHARED_LIBS) || (_MSC_VER <= 1600)
        #define __OPENCVSET_LINK_TYPE__
    #else
        #define __OPENCVSET_LINK_TYPE__ "static/"
    #endif

    // バージョン文字列
    #define __OPENCV_VER__ "320"

    // 通常ライブラリ
    #ifdef HAVE_OPENCV_CALIB3D
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_calib3d" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CORE
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_core" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDAARITHM
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudaarithm" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDABGSEGM
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudabgsegm" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDACODEC
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudacodec" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDAFEATURES2D
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudafeatures2d" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDAFILTERS
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudafilters" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDAIMGPROC
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudaimgproc" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDALEGACY
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudalegacy" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDAOBJDETECT
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudaobjdetect" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDAOPTFLOW
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudaoptflow" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDASTEREO
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudastereo" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDAWARPING
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudawarping" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CUDEV
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cudev" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_FEATURES2D
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_features2d" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_FLANN
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_flann" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_HIGHGUI
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_highgui" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_IMGCODECS
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_imgcodecs" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_IMGPROC
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_imgproc" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_ML
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_ml" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_OBJDETECT
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_objdetect" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_PHOTO
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_photo" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_SHAPE
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_shape" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_STITCHING
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_stitching" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_SUPERRES
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_superres" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_VIDEO
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_video" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_VIDEOIO
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_videoio" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_VIDEOSTAB
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_videostab" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif

    // contribライブラリ
    #ifdef HAVE_OPENCV_ARUCO
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_aruco" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_BGSEGM
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_bgsegm" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_BIOINSPIRED
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_bioinspired" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CCALIB
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_ccalib" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_CVV
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_cvv" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_DATASETS
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_datasets" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_DNN
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_dnn" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_DPM
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_dpm" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_FACE
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_face" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_FREETYPE
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_freetype" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_FUZZY
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_fuzzy" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_HDF
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_hdf" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_LINE_DESCRIPTOR
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_line_descriptor" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_OPTFLOW
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_optflow" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_PHASE_UNWRAPPING
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_phase_unwrapping" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_PLOT
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_plot" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_REG
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_reg" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_RGBD
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_rgbd" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_SALIENCY
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_saliency" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_SFM
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_sfm" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_STEREO
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_stereo" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_STRUCTURED_LIGHT
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_structured_light" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_SURFACE_MATCHING
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_surface_matching" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_TEXT
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_text" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_TRACKING
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_tracking" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_VIZ
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_viz" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_XFEATURES2D
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_xfeatures2d" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_XIMGPROC
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_ximgproc" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_XOBJDETECT
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_xobjdetect" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_XPHOTO
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "opencv_xphoto" __OPENCV_VER__ __OPENCVSET_SUFFIX__ ".lib")
    #endif

    // OpenBLAS
    #ifdef HAVE_LAPACK
        #ifndef HAVE_LAPACK_CONFIG_H
            #define HAVE_LAPACK_CONFIG_H
        #endif
        #ifndef LAPACK_COMPLEX_CPP
            #define LAPACK_COMPLEX_CPP
        #endif
        #pragma comment(lib, "libopenblas.lib")
        // Eigen
        #ifdef HAVE_EIGEN
            #define EIGEN_USE_BLAS
            #define EIGEN_USE_LAPACKE
            #if !defined(__WIN64__) && defined(_WIN64)
                #define __WIN64__
            #endif
        #endif
    #endif

    #ifndef BUILD_SHARED_LIBS
        // CUBLAS
        #ifdef HAVE_CUBLAS
            #pragma comment(lib, "cublas.lib")
        #endif

        // CUDA
        #ifdef HAVE_CUDA
            #pragma comment(lib, "cudart.lib")
            #pragma comment(lib, "cuda.lib")
        #endif

        // CUFFT
        #ifdef HAVE_CUFFT
            #pragma comment(lib, "cufft.lib")
        #endif

        // DirectShow
        #ifdef HAVE_DSHOW
            #pragma comment(lib, "ole32.lib")
            #pragma comment(lib, "oleaut32.lib")
        #endif

        // NVidia Video Decoding
        #ifdef HAVE_NVCUVID
            #pragma comment(lib, "nvcuvid.lib")
        #endif

        // OpenGL
        #ifdef HAVE_OPENGL
            #pragma comment(lib, "OpenGL32.lib")
        #endif

        // TBB
        #if defined(HAVE_TBB) && !defined(TBB_DYN_LINK) && !defined(__TBB_NO_IMPLICIT_LINKAGE)
            #define __TBB_NO_IMPLICIT_LINKAGE 1
            #ifdef TBB_USE_DEBUG
                #define __TBBSET_SUFFIX__ "_debug"
            #else
                #define __TBBSET_SUFFIX__
            #endif
            #pragma comment(lib, "tbb" __TBBSET_SUFFIX__ ".lib")
            #pragma comment(lib, "tbbmalloc" __TBBSET_SUFFIX__ ".lib")
            #ifdef TBB_ENABLE_PROXY
                #pragma comment(lib, "tbbmalloc_proxy" __TBBSET_PREFIX__ ".lib")
                #ifdef _WIN64
                    #pragma comment(linker, "/include:__TBB_malloc_proxy")
                #else
                    #pragma comment(linker, "/include:___TBB_malloc_proxy")
                #endif
            #endif
        #endif

        // Video for Windows
        #ifdef HAVE_VFW
            #pragma comment(lib, "vfw32.lib")
        #endif

        // Win32 UI
        #ifdef HAVE_WIN32UI
            #pragma comment(lib, "comctl32.lib")
            #pragma comment(lib, "user32.lib")
        #endif

        // HDF5
        #ifdef HAVE_OPENCV_HDF
            #ifdef OPENCV_USE_DEBUG
                #pragma comment(lib, "libhdf5_D.lib")
            #else
                #pragma comment(lib, "libhdf5.lib")
            #endif
        #endif

        // zlib
        #pragma comment(lib, "zlibstatic" __OPENCVSET_SUFFIX__ ".lib")
        // JPEG
        #ifdef HAVE_JPEG
            #pragma comment(lib, "jpeg-static" __OPENCVSET_SUFFIX__ ".lib")
        #endif

        // protobuf
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "libprotobuf" __OPENCVSET_SUFFIX__ ".lib")

        // webp
        #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "libwebp" __OPENCVSET_SUFFIX__ ".lib")

        // IPP
        #ifdef HAVE_IPP
            #ifdef HAVE_IPP_ICV_ONLY
                #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "ippicvmt.lib")
            #endif
        #endif

        // JPEG-2000
        #ifdef HAVE_JASPER
            #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "libjasper" __OPENCVSET_SUFFIX__ ".lib")
        #endif

        // OpenEXR
        #ifdef HAVE_OPENEXR
            #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "IlmImf" __OPENCVSET_SUFFIX__ ".lib")
        #endif

        // PNG
        #ifdef HAVE_PNG
            #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "libpng" __OPENCVSET_SUFFIX__ ".lib")
        #endif

        // TIFF
        #ifdef HAVE_TIFF
            #pragma comment(lib, __OPENCVSET_LINK_TYPE__ "libtiff" __OPENCVSET_SUFFIX__ ".lib")
        #endif
    #endif
#endif

#define _HAVE_OPENCV
