#pragma once

#ifndef HAVE_LAPACK_CONFIG_H
    #define HAVE_LAPACK_CONFIG_H
#endif
#ifndef LAPACK_COMPLEX_CPP
    #define LAPACK_COMPLEX_CPP
#endif

#ifndef _LIB
    #pragma comment(lib, "libopenblas.lib")
#endif

#define _HAVE_OPENBLAS
