#pragma once

#ifndef _SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING
  #define _SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING
#endif

#ifndef _LIB
    // サフィックス設定
    #ifdef GTEST_USE_DEBUG
        #define __GTEST_SUFFIX__ "d"
    #else
        #define __GTEST_SUFFIX__
    #endif

    #pragma comment(lib, "gtest" __GTEST_SUFFIX__ ".lib")
    #pragma comment(lib, "gmock" __GTEST_SUFFIX__ ".lib")

    #ifdef GTEST_USE_MAIN
        #pragma comment(lib, "gtest_main" __GTEST_SUFFIX__ ".lib")
        #pragma comment(lib, "gmock_main" __GTEST_SUFFIX__ ".lib")
    #endif
#endif

#define _HAVE_GTEST
