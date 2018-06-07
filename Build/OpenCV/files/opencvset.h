#pragma once

// C++11 std::array
#if __cplusplus < 201103L && defined(_MSC_VER) && _MSC_VER >= 1600
    #define CV_CXX_STD_ARRAY 1
#endif

// configファイル読み込み
#include "opencv2/opencv_modules.hpp"
//#ifdef OPENCV_DYN_LINK
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
//#else
//    #ifdef OPENCV_USE_DEBUG
//        #ifdef _WIN64
//            #include "cvconfig_x64_Static_Debug.h"
//        #else
//            #include "cvconfig_Win32_Static_Debug.h"
//        #endif
//    #else
//        #ifdef _WIN64
//            #include "cvconfig_x64_Static_Release.h"
//        #else
//            #include "cvconfig_Win32_Static_Release.h"
//        #endif
//    #endif
//#endif

#ifndef _LIB
    // サフィックス設定
    #ifdef OPENCV_USE_DEBUG
        #define __OCV_CONF_SUFFIX__ "d"
    #else
        #define __OCV_CONF_SUFFIX__
    #endif

    // スタティック設定
    #ifdef BUILD_SHARED_LIBS
        #define __OCV_SUFFIX__ __OCV_CONF_SUFFIX__
    #else
        #define __OCV_SUFFIX__ "_static" __OCV_CONF_SUFFIX__
    #endif

    // バージョン文字列
    #define __OCV_VER__ "341"

    #ifdef HAVE_OPENCV_IMG_HASH
        #pragma comment(lib, "opencv_img_hash" __OCV_VER__ __OCV_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_SFM
        #pragma comment(lib, "opencv_sfm" __OCV_VER__ __OCV_SUFFIX__ ".lib")
    #endif
    #ifdef HAVE_OPENCV_WORLD
        #pragma comment(lib, "opencv_world" __OCV_VER__ __OCV_SUFFIX__ ".lib")
    #else
        #ifdef HAVE_OPENCV_CALIB3D
            #pragma comment(lib, "opencv_calib3d" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CORE
            #pragma comment(lib, "opencv_core" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDAARITHM
            #pragma comment(lib, "opencv_cudaarithm" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDABGSEGM
            #pragma comment(lib, "opencv_cudabgsegm" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDACODEC
            #pragma comment(lib, "opencv_cudacodec" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDAFEATURES2D
            #pragma comment(lib, "opencv_cudafeatures2d" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDAFILTERS
            #pragma comment(lib, "opencv_cudafilters" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDAIMGPROC
            #pragma comment(lib, "opencv_cudaimgproc" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDALEGACY
            #pragma comment(lib, "opencv_cudalegacy" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDAOBJDETECT
            #pragma comment(lib, "opencv_cudaobjdetect" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDAOPTFLOW
            #pragma comment(lib, "opencv_cudaoptflow" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDASTEREO
            #pragma comment(lib, "opencv_cudastereo" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDAWARPING
            #pragma comment(lib, "opencv_cudawarping" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CUDEV
            #pragma comment(lib, "opencv_cudev" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_DNN
            #pragma comment(lib, "opencv_dnn" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_FEATURES2D
            #pragma comment(lib, "opencv_features2d" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_FLANN
            #pragma comment(lib, "opencv_flann" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_HIGHGUI
            #pragma comment(lib, "opencv_highgui" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_IMGCODECS
            #pragma comment(lib, "opencv_imgcodecs" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_IMGPROC
            #pragma comment(lib, "opencv_imgproc" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_ML
            #pragma comment(lib, "opencv_ml" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_OBJDETECT
            #pragma comment(lib, "opencv_objdetect" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_PHOTO
            #pragma comment(lib, "opencv_photo" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_SHAPE
            #pragma comment(lib, "opencv_shape" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_STITCHING
            #pragma comment(lib, "opencv_stitching" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_SUPERRES
            #pragma comment(lib, "opencv_superres" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_VIDEO
            #pragma comment(lib, "opencv_video" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_VIDEOIO
            #pragma comment(lib, "opencv_videoio" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_VIDEOSTAB
            #pragma comment(lib, "opencv_videostab" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif

        #ifdef HAVE_OPENCV_ARUCO
            #pragma comment(lib, "opencv_aruco" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_BGSEGM
            #pragma comment(lib, "opencv_bgsegm" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_BIOINSPIRED
            #pragma comment(lib, "opencv_bioinspired" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CCALIB
            #pragma comment(lib, "opencv_ccalib" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_CVV
            #pragma comment(lib, "opencv_cvv" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_DATASETS
            #pragma comment(lib, "opencv_datasets" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_DPM
            #pragma comment(lib, "opencv_dpm" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_FACE
            #pragma comment(lib, "opencv_face" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_FREETYPE
            #pragma comment(lib, "opencv_freetype" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_FUZZY
            #pragma comment(lib, "opencv_fuzzy" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_HDF
            #pragma comment(lib, "opencv_hdf" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_LINE_DESCRIPTOR
            #pragma comment(lib, "opencv_line_descriptor" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_OPTFLOW
            #pragma comment(lib, "opencv_optflow" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_PHASE_UNWRAPPING
            #pragma comment(lib, "opencv_phase_unwrapping" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_PLOT
            #pragma comment(lib, "opencv_plot" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_REG
            #pragma comment(lib, "opencv_reg" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_RGBD
            #pragma comment(lib, "opencv_rgbd" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_SALIENCY
            #pragma comment(lib, "opencv_saliency" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_STEREO
            #pragma comment(lib, "opencv_stereo" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_STRUCTURED_LIGHT
            #pragma comment(lib, "opencv_structured_light" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_SURFACE_MATCHING
            #pragma comment(lib, "opencv_surface_matching" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_TEXT
            #pragma comment(lib, "opencv_text" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_TRACKING
            #pragma comment(lib, "opencv_tracking" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_VIZ
            #pragma comment(lib, "opencv_viz" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_XFEATURES2D
            #pragma comment(lib, "opencv_xfeatures2d" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_XIMGPROC
            #pragma comment(lib, "opencv_ximgproc" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_XOBJDETECT
            #pragma comment(lib, "opencv_xobjdetect" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
        #ifdef HAVE_OPENCV_XPHOTO
            #pragma comment(lib, "opencv_xphoto" __OCV_VER__ __OCV_SUFFIX__ ".lib")
        #endif
    #endif

    // MKL
    #ifdef HAVE_LAPACK
        #pragma comment(lib, "mkl_core.lib")
        #pragma comment(lib, "mkl_intel_lp64.lib")
        #pragma comment(lib, "mkl_sequential.lib")
        #define OPENCV_INCLUDED_MKL
        // Eigen
        #ifdef HAVE_EIGEN
            #ifndef MKL_DIRECT_CALL_SEQ
                #define MKL_DIRECT_CALL_SEQ
            #endif
            #ifndef EIGEN_USE_MKL_ALL
                #define EIGEN_USE_MKL_ALL
            #endif
        #endif
    #endif

    // Halide
    #ifdef HAVE_HALIDE
        #pragma comment(lib, "Halide" __OCV_CONF_SUFFIX__ ".lib")
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

        // GStreamer
        #ifdef HAVE_GSTREAMER
            #pragma comment(lib, "glib-2.0.lib")
            #pragma comment(lib, "gobject-2.0.lib")
            #pragma comment(lib, "gstapp-1.0.lib")
            #pragma comment(lib, "gstaudio-1.0.lib")
            #pragma comment(lib, "gstbase-1.0.lib")
            #pragma comment(lib, "gstbasecamerabinsrc-1.0.lib")
            #pragma comment(lib, "gstcontroller-1.0.lib")
            #pragma comment(lib, "gstnet-1.0.lib")
            #pragma comment(lib, "gstpbutils-1.0.lib")
            #pragma comment(lib, "gstreamer-1.0.lib")
            #pragma comment(lib, "gstriff-1.0.lib")
            #pragma comment(lib, "gstrtp-1.0.lib")
            #pragma comment(lib, "gstrtsp-1.0.lib")
            #pragma comment(lib, "gstrtspserver-1.0.lib")
            #pragma comment(lib, "gstsdp-1.0.lib")
            #pragma comment(lib, "gsttag-1.0.lib")
            #pragma comment(lib, "gstvideo-1.0.lib")
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
        #pragma comment(lib, "zlibstatic" __OCV_CONF_SUFFIX__ ".lib")

        // protobuf
        #pragma comment(lib, "libprotobuf" __OCV_SUFFIX__ ".lib")

        // webp
        #pragma comment(lib, "libwebp" __OCV_SUFFIX__ ".lib")

        // IPP
        #ifdef HAVE_IPP
            #ifdef HAVE_IPP_ICV
                #pragma comment(lib, "ippicvmt.lib")
            #endif
            #ifdef HAVE_IPP_IW
                #pragma comment(lib, "ippiw" __OCV_SUFFIX__ ".lib")
            #endif
        #endif

        // JPEG-2000
        #ifdef HAVE_JASPER
            #pragma comment(lib, "libjasper" __OCV_SUFFIX__ ".lib")
        #endif
        
        // JPEG
        #ifdef HAVE_JPEG
            #pragma comment(lib, "jpeg-static" __OCV_CONF_SUFFIX__ ".lib")
        #endif

        // OpenEXR
        #ifdef HAVE_OPENEXR
            #pragma comment(lib, "IlmImf" __OCV_SUFFIX__ ".lib")
        #endif

        // PNG
        #ifdef HAVE_PNG
            #pragma comment(lib, "libpng" __OCV_SUFFIX__ ".lib")
        #endif

        // TIFF
        #ifdef HAVE_TIFF
            #pragma comment(lib, "libtiff" __OCV_SUFFIX__ ".lib")
        #endif

        // Trace
        #ifdef OPENCV_TRACE
            #pragma comment(lib, "ittnotify" __OCV_SUFFIX__ ".lib")
        #endif
    #endif
#endif

#define _HAVE_OPENCV
