@echo off
setlocal

rem CMake
set cmakePath=cmake-3.7.2-win64-x64\bin\cmake.exe

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem ライブラリパス
set caffeDir=caffe-windows
set cudnnDir=cudnn-8.0-windows10-x64-v6.0

rem サードパーティーライブラリパス
set libraryDir=Final

rem Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set flagShared=ON
	set flagStatic=OFF
    set linkType=Shared
	set hdf5prefix=
	set prefixdir=
	set boostPreProcesserOrig="/DBOOST_ALL_DYN_LINK"
	set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES"
	rem set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL=__declspec(dllimport) /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS=__declspec(dllimport)"
	set protoBufFlagOrig="/DPROTOBUF_USE_DLLS"
) else (
	set flagShared=OFF
	set flagStatic=ON
    set linkType=Static
	set hdf5prefix=lib
	set prefixdir=static/
	set boostPreProcesserOrig=""
	set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL=  /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS="
	set protoBufFlagOrig=""
)
set boostPreProcesse=%boostPreProcesserOrig:"=%
set glogFlag=%glogFlagOrig:"=%
set protoBufFlag=%protoBufFlagOrig:"=%

rem Release/Debug切り替え
if /%2==/debug (
    set configType=Debug
	set hdf5postfix=_D
	set postfix=d
) else (
    set configType=Release
	set hdf5postfix=
	set postfix=
)

rem ビルド条件表示
echo link type : %linkType%
echo config type : %configType%

rem 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

rem バッチファイルの場所
set batchPath=%~dp0

rem ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

rem CMakeパス作成
set cmakeExe="%sourceDir%\Build\Tools\%cmakePath%"
rem CMakeパス表示
echo CMake : %cmakeExe%

rem Ninja
set ninjaExe="%sourceDir%\%ninjaPath%"
rem Ninjaパス表示
echo Ninja : %ninjaExe%

rem Ninjaファイルチェック
call "%sourceDir%\Build\Ninja\Ninja_Build.bat"

rem Caffe
set caffePath=%sourceDir%\%caffeDir%
rem Caffeパス表示
echo Caffe : %caffePath%

rem ライブラリパス
set libraryPath=%sourceDir%\%libraryDir%
rem ライブラリパス表示
echo Library : %libraryPath%

rem cuDNNパス
set cudnnPath=%sourceDir%\%cudnnDir%
rem cuDNNパス表示
echo cuDNN : %cudnnPath%

rem CUDAパス
set cudaPath=%sourceDir%\CUDA
rem CUDAパス表示
echo CUDA : %cudaPath%

rem CUDAパス確認
if not exist %cudaPath% (
	powershell -Command Start-Process -Wait -FilePath cmd.exe -Verb runas -ArgumentList '/c','"mklink /D ""%cudaPath%""" """%CUDA_PATH%"""'
)

rem CUDAパス再設定
if not /"%cudaPath%"==/"%CUDA_PATH%" (
	set CUDA_PATH=%cudaPath%
)

rem アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
)

rem Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set vcVersion=110
	set flagCpuOnly=OFF
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set vcVersion=120
	set flagCpuOnly=OFF
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set vcVersion=140
	set flagCpuOnly=OFF
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set vcVersion=141
	set flagCpuOnly=ON
) else (
	set vsVersion=vs2010
	set vcVersion=100
	set flagCpuOnly=OFF
)

rem zlib
set zlibPath=%sourceDir%\Build\Zlib\Build_%vsVersion%_%platformName%_%configType%\install
set zlibDebugPath=%sourceDir%\Build\Zlib\Build_%vsVersion%_%platformName%_Debug\install
set zlibReleasePath=%sourceDir%\Build\Zlib\Build_%vsVersion%_%platformName%_Release\install
rem zlibインクルード
set zlibIncludePath=%zlibPath%\include
rem zlibライブラリ
if /%linkType%==/Shared (
	set zlibDebugLibPath=%zlibDebugPath%\lib\zlibd.lib
	set zlibReleaseLibPath=%zlibReleasePath%\lib\zlib.lib
) else (
	set zlibDebugLibPath=%zlibDebugPath%\lib\zlibstaticd.lib
	set zlibReleaseLibPath=%zlibReleasePath%\lib\zlibstatic.lib
)

rem zlibパス表示
echo zlib Path : %zlibPath%
echo zlib include Path : %zlibIncludePath%
echo zlib debug lib Path : %zlibDebugLibPath%
echo zlib release lib Path : %zlibReleaseLibPath%

rem ライブラリパス
set libraryPath2=%libraryPath%\v%vcVersion%
rem ライブラリパス表示
echo Library : %libraryPath2%

rem ビルドディレクトリ
set buildDir=%batchPath%Build_%vsVersion%_%platformName%_%linkType%_%configType%

rem ビルドディレクトリ表示
echo build directory : %buildDir%
rem ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
rem ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%caffePath%" ^
-G "Ninja"  ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DUSE_PREBUILT_DEPENDENCIES=OFF ^
-DBLAS="Open" ^
-Dpython_version="3" ^
-DCPU_ONLY=%flagCpuOnly% ^
-DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /W3 /GR /EHa /DHAVE_LAPACK_CONFIG_H /DLAPACK_COMPLEX_CPP /wd4505 /wd4819 %boostPreProcesser% %glogFlag% %protoBufFlag% /bigobj" ^
-DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 /DHAVE_LAPACK_CONFIG_H /DLAPACK_COMPLEX_STRUCTURE /wd4505 /wd4819 %boostPreProcesser% %glogFlag% %protoBufFlag% /bigobj" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DCUDA_ARCH_NAME="Manual" ^
-DCUDA_ARCH_BIN="3.0 3.5 3.7 5.0 5.2 6.0 6.1" ^
-DCUDA_ARCH_PTX="" ^
-DCUDA_NVCC_FLAGS="-Xcompiler """/wd4505 /wd4819 /FS"""" ^
-DCUDNN_INCLUDE="%cudnnPath:\=/%/cuda/include" ^
-DCUDNN_LIBRARY="%cudnnPath:\=/%/cuda/lib/%platformName%/cudnn.lib" ^
-DCUDNN_ROOT="%cudnnPath:\=/%/cuda" ^
-DBOOST_ROOT="%libraryPath2:\=/%/Boost" ^
-DBOOST_INCLUDEDIR="%libraryPath2:\=/%/Boost/include" ^
-DBOOST_LIBRARYDIR="%libraryPath2:\=/%/Boost/lib/%platformName%" ^
-DBoost_USE_MULTITHREADED=ON ^
-DBoost_USE_STATIC_LIBS=%flagStatic% ^
-DBoost_USE_STATIC_RUNTIME=OFF ^
-Dgflags_DIR="%libraryPath2:\=/%/gflags/cmake" ^
-DGFLAGS_ROOT_DIR="%libraryPath2:\=/%/gflags" ^
-Dgflags_INCLUDE_DIRS="%libraryPath2:\=/%/gflags/include" ^
-DGFLAGS_SHARED=%flagShared% ^
-Dglog_DIR="%libraryPath2:\=/%/glog/cmake" ^
-Dglog_INCLUDE_DIRS="%libraryPath2:\=/%/glog/include" ^
-Dglog_LIBRARIES="%libraryPath2:\=/%/glog/lib/%platformName%/%prefixdir%glog%postfix%.lib" ^
-DHDF5_DIR="%libraryPath2:\=/%/HDF5/cmake" ^
-DHDF5_ROOT_DIR="%libraryPath2:\=/%/HDF5" ^
-DHDF5_INCLUDE_DIRS="%libraryPath2:\=/%/HDF5/include" ^
-DHDF5_LIBRARIES="%libraryPath2:\=/%/HDF5/lib/%platformName%/%hdf5prefix%hdf5%hdf5postfix%.lib" ^
-DHDF5_HL_LIBRARIES="%libraryPath2:\=/%/HDF5/lib/%platformName%/%hdf5prefix%hdf5_hl%hdf5postfix%.lib" ^
-DLevelDB_DIR="%libraryPath2:\=/%/LevelDB/cmake" ^
-DLevelDB_Boost_VcVer=%vcVersion% ^
-DLMDB_DIR="%libraryPath2:\=/%/lmdb/cmake" ^
-DOpenBLAS_INCLUDE_DIR="%libraryPath:\=/%/OpenBLAS/include" ^
-DOpenBLAS_LIB="%libraryPath:\=/%/OpenBLAS/lib/%platformName%/libopenblas.lib" ^
-DOpenCV_DIR="%libraryPath2:\=/%/OpenCV/cmake" ^
-DOpenCV_TBB_DIR="%libraryPath2:\=/%/TBB" ^
-DOpenCV_JPEG_DIR="%libraryPath2:\=/%/libJpeg-turbo" ^
-DOpenCV_STATIC=%flagStatic% ^
-DProtobuf_DIR="%libraryPath2:\=/%/ProtoBuf/cmake" ^
-DPROTOBUF_INCLUDE_DIRS="%libraryPath2:\=/%/ProtoBuf/include" ^
-DPROTOBUF_INCLUDE_DIR="%libraryPath2:\=/%/ProtoBuf/include" ^
-DPROTOBUF_LIBRARIES="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotobuf%postfix%.lib" ^
-DPROTOBUF_LIBRARY="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotobuf%postfix%.lib" ^
-DPROTOBUF_LIBRARY_DEBUG="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotobufd.lib" ^
-DPROTOBUF_LITE_LIBRARIES="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotobuf-lite%postfix%.lib" ^
-DPROTOBUF_LITE_LIBRARY="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotobuf-lite%postfix%.lib" ^
-DPROTOBUF_LITE_LIBRARY_DEBUG="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotobuf-lited.lib" ^
-DPROTOBUF_PROTOC_LIBRARIES="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotoc%postfix%.lib" ^
-DPROTOBUF_PROTOC_LIBRARY="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotoc%postfix%.lib" ^
-DPROTOBUF_PROTOC_LIBRARY_DEBUG="%libraryPath2:\=/%/ProtoBuf/lib/%platformName%/%prefixdir%libprotocd.lib" ^
-DPROTOBUF_PROTOC_EXECUTABLE="%libraryPath2:\=/%/ProtoBuf/bin/%platformName%/protoc.exe" ^
-Dprotobuf_MODULE_COMPATIBLE=ON ^
-DSnappy_DIR="%libraryPath2:\=/%/Snappy/cmake" ^
-DZLIB_INCLUDE_DIR="%zlibIncludePath:\=/%" ^
-DZLIB_LIBRARY_DEBUG="%zlibDebugLibPath:\=/%" ^
-DZLIB_LIBRARY_RELEASE="%zlibReleaseLibPath:\=/%"

endlocal
