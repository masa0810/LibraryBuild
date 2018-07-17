#pragma once

#ifndef _LIB
    // サフィックス設定
    #ifdef BENCHMARK_USE_DEBUG
        #define __BENCHMARK_SUFFIX__ "d"
    #else
        #define __BENCHMARK_SUFFIX__
    #endif

    #pragma comment(lib, "benchmark" __BENCHMARK_SUFFIX__ ".lib")

    #ifdef BENCHMARK_USE_MAIN
        #pragma comment(lib, "benchmark_main" __BENCHMARK_SUFFIX__ ".lib")
    #endif
#endif

#define _HAVE_BENCHMARK
