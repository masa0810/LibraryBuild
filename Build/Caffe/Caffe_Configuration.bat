@echo off
setlocal

REM CMake
set cmakePath=CMake\bin\cmake.exe

REM ninja
set ninjaPath=Ninja\ninja.exe

REM ライブラリパス
set caffeDir=caffe
set cudnnDir=cudnn
set boostDir=boost
set intelLibraryDirOrig="C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows"
set intelLibraryDir=%intelLibraryDirOrig:"=%

REM Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set flagShared=ON
	set flagStatic=OFF
	set linkType=Shared

	set postfixR=
	set postfixD=d

	REM set boostPreProcesserOrig="/DBOOST_ALL_DYN_LINK"
	REM set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES"
) else (
	set flagShared=OFF
	set flagStatic=ON
	set linkType=Static

	set postfixR=_static
	set postfixD=_staticd

	REM set boostPreProcesserOrig=""
	REM set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL= /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS="
)
set boostPreProcesserOrig=""
set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL= /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS="
set boostPreProcesse=%boostPreProcesserOrig:"=%
set glogFlag=%glogFlagOrig:"=%

REM Release/Debug切り替え
if /%2==/debug (
	set configType=Debug
	set flagRelease=OFF
	
	set postfix=%postfixD%
) else (
	set configType=Release
	set flagRelease=ON
	
	set postfix=%postfixR%
)

REM ビルド条件表示
echo link type : %linkType%
echo config type : %configType%

REM 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

REM バッチファイルの場所
set batchPath=%~dp0

REM ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

REM CMakeパス作成
set cmakeExe="%sourceDir%\Build\Tools\%cmakePath%"
REM CMakeパス表示
echo CMake : %cmakeExe%

REM Ninja
set ninjaExe="%sourceDir%\Build\Tools\%ninjaPath%"
REM Ninjaパス表示
echo Ninja : %ninjaExe%

REM Ninjaファイルチェック
call "%sourceDir%\Build\Ninja\Ninja_Build.bat"

REM boostパス
set boostPath=%sourceDir%\%boostDir%
REM boostパス表示
echo Boost : %boostPath%

REM Caffeパス
set caffePath=%sourceDir%\%caffeDir%
REM Caffeパス表示
echo Caffe : %caffePath%

REM TBBパス
REM set tbbPath=%sourceDir%\%tbbDir%
set tbbPath=%intelLibraryDir%\tbb
REM TBBパス表示
echo TBB : %tbbPath%

REM cuDNNパス
set cudnnPath=%sourceDir%\%cudnnDir%
REM cuDNNパス表示
echo cuDNN : %cudnnPath%

REM CUDAパス
set cudaPath=%sourceDir%\CUDA
REM CUDAパス表示
echo CUDA : %cudaPath%

REM CUDAパス確認
if not exist %cudaPath% (
	powershell -Command Start-Process -Wait -FilePath cmd.exe -Verb runas -ArgumentList '/c','"mklink /D ""%cudaPath%""" """%CUDA_PATH%"""'
)

REM CUDAパス再設定
if not /"%cudaPath%"==/"%CUDA_PATH%" (
	set CUDA_PATH=%cudaPath%
)

REM アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
	set platformNameShort=x86
	set platformNameIntel=ia32
) else (
	set platformName=x64
	set platformNameShort=x64
	set platformNameIntel=intel64
)

REM Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set flagCpuOnly=OFF
	set vcVersion=vc11
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set flagCpuOnly=OFF
	set vcVersion=vc12
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set flagCpuOnly=OFF
	set vcVersion=vc14
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set flagCpuOnly=ON
	REM set vcVersion=vc141
	set vcVersion=vc14
) else (
	set vsVersion=vs2010
	set flagCpuOnly=OFF
	set vcVersion=vc10
)

REM Boostステージディレクトリ
set boostStageDir=%buildBuf%\%vsVersion%\%platformName%\Boost\Stage
REM Boostステージディレクトリ表示
echo Boost Stage Dir : %boostStageDir%

REM gflags
set gflagPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Gflags\install
REM gflagsパス表示
echo gflags path : %gflagPath%

REM glog
REM set glogPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\Glog\install
set glogPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Static\Glog\install
REM glogパス表示
echo glog path : %glogPath%

REM HDF5
REM set hdf5Path=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\HDF5\install
set hdf5Path=%buildBuf%\%vsVersion%\%platformName%\%configType%\Static\HDF5\install
REM set hdf5PathD=%buildBuf%\%vsVersion%\%platformName%\Debug\%linkType%\HDF5\install
set hdf5PathD=%buildBuf%\%vsVersion%\%platformName%\Debug\Static\HDF5\install
REM set hdf5PathR=%buildBuf%\%vsVersion%\%platformName%\Release\%linkType%\HDF5\install
set hdf5PathR=%buildBuf%\%vsVersion%\%platformName%\Release\Static\HDF5\install
REM HDF5ライブラリ
REM if /%linkType%==/Shared (
REM 	set hdf5prefix=
REM ) else (
	set hdf5prefix=lib
REM )
REM HDF5パス表示
echo hdf5 path : %hdf5Path%
echo hdf5 debug lib path : %hdf5PathD%\lib\%hdf5prefix%hdf5_D.lib
echo hdf5 release lib path : %hdf5PathR%\lib\%hdf5prefix%hdf5.lib
echo hdf5 hl debug lib path : %hdf5PathD%\lib\%hdf5prefix%hdf5_hl_D.lib
echo hdf5 hl release lib path : %hdf5PathR%\lib\%hdf5prefix%hdf5_hl.lib

REM LevelDB
REM set leveldbPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\LevelDB\install
set leveldbPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Static\LevelDB\install
REM LevelDBパス表示
echo leveldb path : %leveldbPath%

REM LMDB
REM set lmdbPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\Lmdb\install
set lmdbPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Static\Lmdb\install
REM LMDBパス表示
echo lmdb path : %lmdbPath%

REM OpenCV
set opencvPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\OpenCV\install
REM OpenCVパス表示
echo opencv path : %opencvPath%

REM ProtoBuf
REM set protobufPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\ProtoBuf\install
set protobufPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Static\ProtoBuf\install
REM set protobufPathD=%buildBuf%\%vsVersion%\%platformName%\Debug\%linkType%\ProtoBuf\install
set protobufPathD=%buildBuf%\%vsVersion%\%platformName%\Debug\Static\ProtoBuf\install
set protobufCompiler=%buildBuf%\%vsVersion%\%platformName%\Release\Static\ProtoBuf\install\bin\protoc.exe
REM ProtoBufパス表示
echo protobuf path : %protobufPath%
echo protobuf compiler path : %protobufCompiler%

REM Snappy
REM set snappyPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\Snappy\install
set snappyPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Static\Snappy\install
REM Snappyパス表示
echo snappy path : %snappyPath%

REM TBB
if /%configType%==/Debug (
	set tbbLibPathOrig="%tbbPath%\lib\%platformNameIntel%\%vcVersion%\tbb_debug.lib"
) else (
	set tbbLibPathOrig="%tbbPath%\lib\%platformNameIntel%\%vcVersion%\tbb.lib"
)
set tbbLibPath=%tbbLibPathOrig:"=%
REM TBBパス表示
echo TBB Library Dir : %tbbLibPath%

REM zlib
set zlibPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Zlib\install
REM zlibライブラリ
REM if /%linkType%==/Shared (
REM 	set zlibPostfix=
REM ) else (
	set zlibPostfix=static
REM )
set zlibLibD=%buildBuf%\%vsVersion%\%platformName%\Debug\Zlib\install\lib\zlib%zlibPostfix%d.lib
set zlibLibR=%buildBuf%\%vsVersion%\%platformName%\Release\Zlib\install\lib\zlib%zlibPostfix%.lib

REM zlibパス表示
echo zlib Path : %zlibPath%
echo zlib include Path : %zlibPath%\include
echo zlib debug lib Path : %zlibLibD%
echo zlib release lib Path : %zlibLibR%

REM ビルドディレクトリ
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\Caffe

REM ビルドディレクトリ表示
echo build directory : %buildDir%
REM ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%caffePath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DCMAKE_DEBUG_POSTFIX="%postfixD%" ^
-DCMAKE_RELEASE_POSTFIX="%postfixR%" ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DUSE_PREBUILT_DEPENDENCIES=OFF ^
-DBLAS="MKL" ^
-Dpython_version="3" ^
-DCPU_ONLY=%flagCpuOnly% ^
-DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /W0 /GR /EHsc /bigobj /std:c++14 %boostPreProcesser% %glogFlag%" ^
-DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W0 /bigobj %boostPreProcesser% %glogFlag%" ^
-DCMAKE_EXE_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DCMAKE_MODULE_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DCMAKE_SHARED_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DCUDA_ARCH_NAME="Manual" ^
-DCUDA_ARCH_BIN="5.2 6.1" ^
-DCUDA_ARCH_PTX="3.0" ^
-DCUDA_NVCC_FLAGS="-Xcompiler """/W0 /FS"""" ^
-DCUDA_NVCC_FLAGS_RELEASE="-use_fast_math" ^
-DCUDNN_INCLUDE="%cudnnPath:\=/%/include" ^
-DCUDNN_LIBRARY="%cudnnPath:\=/%/lib/%platformName%/cudnn.lib" ^
-DCUDNN_ROOT="%cudnnPath:\=/%/cuda" ^
-DBOOST_ROOT="%boostPath:\=/%" ^
-DBOOST_INCLUDEDIR="%boostPath:\=/%" ^
-DBOOST_LIBRARYDIR="%boostStageDir:\=/%/lib" ^
-DBoost_USE_MULTITHREADED=ON ^
-DBoost_USE_STATIC_LIBS=ON ^
-DBoost_USE_STATIC_RUNTIME=OFF ^
-Dgflags_DIR="%gflagPath:\=/%/lib/cmake/gflags" ^
-DGFLAGS_ROOT_DIR="%gflagPath:\=/%" ^
-Dgflags_INCLUDE_DIRS="%gflagPath:\=/%/include" ^
-DGFLAGS_SHARED=OFF ^
-Dglog_DIR="%glogPath:\=/%/lib/cmake/glog" ^
-Dglog_INCLUDE_DIRS="%glogPath:\=/%/include" ^
-Dglog_LIBRARIES="%glogPath:\=/%/lib/glog%postfix%.lib" ^
-DHDF5_DIR="%hdf5Path:\=/%/cmake" ^
-DHDF5_ROOT_DIR="%hdf5Path:\=/%" ^
-DHDF5_C_INCLUDE_DIR="%hdf5Path:\=/%/include" ^
-DHDF5_hdf5_LIBRARY_DEBUG="%hdf5PathD%/lib/%hdf5prefix%hdf5_D.lib" ^
-DHDF5_hdf5_LIBRARY_RELEASE="%hdf5PathR%/lib/%hdf5prefix%hdf5.lib" ^
-DHDF5_hdf5_hl_LIBRARY_DEBUG="%hdf5PathD%/lib/%hdf5prefix%hdf5_hl_D.lib" ^
-DHDF5_hdf5_hl_LIBRARY_RELEASE="%hdf5PathR%/lib/%hdf5prefix%hdf5_hl.lib" ^
-DHDF5_USE_DLL=OFF ^
-DINTEL_ROOT="%intelLibraryDir:\=/%" ^
-DLevelDB_INCLUDE="%leveldbPath:\=/%/include" ^
-DLevelDB_LIBRARY="%leveldbPath:\=/%/lib/leveldb%postfix%.lib" ^
-DLMDB_DIR="%lmdbPath:\=/%/cmake" ^
-DMKL_MULTI_THREADED=%flagRelease% ^
-DMKL_RT_LIBRARY="%intelLibraryDir:\=/%/mkl/lib/%platformNameIntel%/mkl_rt.lib" ^
-DMKL_RTL_LIBRARY="%tbbLibPath:\=/%" ^
-DMKL_USE_SINGLE_DYNAMIC_LIBRARY=OFF ^
-DMKL_USE_STATIC_LIBS=OFF ^
-DMKL_WITH_TBB=ON ^
-DOpenCV_DIR="%opencvPath:\=/%" ^
-DOpenCV_STATIC=%flagStatic% ^
-DProtobuf_DIR="%protobufPath:\=/%/cmake" ^
-DPROTOBUF_INCLUDE_DIRS="%protobufPath:\=/%/include" ^
-DPROTOBUF_INCLUDE_DIR="%protobufPath:\=/%/include" ^
-DPROTOBUF_LIBRARIES="%protobufPath:\=/%/lib/protobuf%postfix%.lib" ^
-DPROTOBUF_LIBRARY="%protobufPath:\=/%/lib/protobuf%postfix%.lib" ^
-DPROTOBUF_LIBRARY_DEBUG="%protobufPathD:\=/%/lib/protobuf%postfixD%.lib" ^
-DPROTOBUF_LITE_LIBRARIES="%protobufPath:\=/%/lib/protobuf-lite%postfix%.lib" ^
-DPROTOBUF_LITE_LIBRARY="%protobufPath:\=/%/lib/protobuf-lite%postfix%.lib" ^
-DPROTOBUF_LITE_LIBRARY_DEBUG="%protobufPathD:\=/%/lib/protobuf-lite%postfixD%.lib" ^
-DPROTOBUF_PROTOC_LIBRARIES="%protobufPath:\=/%/lib/protoc%postfix%.lib" ^
-DPROTOBUF_PROTOC_LIBRARY="%protobufPath:\=/%/lib/protoc%postfix%.lib" ^
-DPROTOBUF_PROTOC_LIBRARY_DEBUG="%protobufPathD:\=/%/lib/protoc%postfixD.lib" ^
-DPROTOBUF_PROTOC_EXECUTABLE="%protobufCompiler:\=/%" ^
-DSnappy_DIR="%snappyPath:\=/%/lib/cmake/Snappy" ^
-DSnappy_INCLUDE_DIR="%snappyPath:\=/%/include" ^
-DSnappy_LIBRARIES="%snappyPath:\=/%/lib/snappy%postfix%.lib" ^
-DZLIB_INCLUDE_DIR="%zlibPath:\=/%/include" ^
-DZLIB_LIBRARY_DEBUG="%zlibLibD:\=/%" ^
-DZLIB_LIBRARY_RELEASE="%zlibLibR:\=/%" ^
-DCOPY_PREREQUISITES=OFF ^
-DINSTALL_PREREQUISITES=OFF ^
-DOpenCV_TBB_DIR="%tbbLibPath:\=/%" ^
-DCUSTOM_PROTOC_EXECUTABLE="%protobufCompiler:\=/%"

REM -DCUDA_ARCH_BIN="3.0 3.5 3.7 5.0 5.2 6.0 6.1 7.0" ^

endlocal
