#pragma once

#ifndef _LIB
    #ifndef __TBB_NO_IMPLICIT_LINKAGE
        #define __TBB_NO_IMPLICIT_LINKAGE 1
        
        // サフィックス設定
        #ifdef TBB_USE_DEBUG
            #define __TBBSET_PREFIX__ "_debug"
        #else
            #define __TBBSET_PREFIX__
        #endif
        
        // リンク指定
        #pragma comment(lib, "tbb" __TBBSET_PREFIX__ ".lib")
        #pragma comment(lib, "tbbmalloc" __TBBSET_PREFIX__ ".lib")
        
        // アロケータ入れ替え
        #ifdef TBB_ENABLE_PROXY
            #pragma comment(lib, "tbbmalloc_proxy" __TBBSET_PREFIX__ ".lib")
            #ifdef _WIN64
                #pragma comment(linker, "/include:__TBB_malloc_proxy")
            #else
                #pragma comment(linker, "/include:___TBB_malloc_proxy")
            #endif
        #endif
    #endif
#endif
