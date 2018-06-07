@echo off
setlocal

REM CMake
set cmakePath=CMake\bin\cmake.exe

REM ninja
set ninjaPath=Ninja\ninja.exe

REM ライブラリパス
set openBlasDir=OpenBLAS
set openCv3rdpartyDir=opencv_3rdparty
set openCvContribDir=opencv_contrib
set openCvDir=opencv
set tbbDir=tbb
set gstreamerDir=C:\Library\Gstreamer
set intelLibraryDirOrig="C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows"
set intelLibraryDir=%intelLibraryDirOrig:"=%

REM Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set flagShared=ON
	set linkType=Shared

	set postfixR=
	set postfixD=d

	REM set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES"
) else (
	set flagShared=OFF
	set linkType=Static

	set postfixR=_static
	set postfixD=_staticd

	REM set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL= /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS="
)
set glogFlagOrig="/DGLOG_NO_ABBREVIATED_SEVERITIES /DGOOGLE_GLOG_DLL_DECL= /DGOOGLE_GLOG_DLL_DECL_FOR_UNITTESTS="
set glogFlag=%glogFlagOrig:"=%

REM Release/Debug切り替え
if /%2==/debug (
	set flagDebug=ON
	set flagRelease=OFF
	set configType=Debug

	set postfix=%postfixD%
) else (
	set flagRelease=ON
	set flagDebug=OFF
	set configType=Release
	
	set postfix=%postfixR%
)

REM avx判定
if /%3==/avx (
	set cpuBaseLineOrig="-DCPU_BASELINE=""AVX2"""
	set avxType=Enable
	echo Enable AVX
) else (
	set cpuBaseLineOrig="-DCPU_BASELINE=""SSE4_2"""
	set avxType=Disable
)
set cpuBaseLine=%cpuBaseLineOrig:"=%

REM Python切り替え
REM if /%linkType%==/Shared (
REM 	set flagPython=OFF
REM ) else (
REM 	if /%configType%==/Debug (
REM 		set flagPython=OFF
REM 	) else (
REM 		if /%VisualStudioVersion%==/14.0 (
REM 			set flagPython=ON
REM 		) else (
REM 			set flagPython=OFF
REM 		)
REM 	)
REM )
set flagPython=OFF

REM ビルド条件表示
echo link type : %linkType%
echo config type : %configType%
echo avx type : %avxType%
echo python build : %flagPython%

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

REM MKLパス
set mklPath=%intelLibraryDir%\mkl
REM MKLパス表示
echo MKL : %mklPath%

REM OpenCV 3rd Partyパス
set openCv3rdpartyPath=%sourceDir%\%openCv3rdpartyDir%
REM OpenCV 3rd Partyパス表示
echo OpenCV 3rd Party : %openCv3rdpartyPath%

REM OpenCV Contribパス
set openCvContribPath=%sourceDir%\%openCvContribDir%
REM OpenCV Contribパス表示
echo OpenCV Contrib : %openCvContribPath%

REM OpenCV
set openCvPath=%sourceDir%\%openCvDir%
REM OpenCVパス表示
echo OpenCV : %openCvPath%

REM TBBパス
REM set tbbPath=%sourceDir%\%tbbDir%
set tbbPath=%intelLibraryDir%\tbb
REM TBBパス表示
echo TBB : %tbbPath%

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
	set platformNameGst=x86
) else (
	set platformName=x64
	set platformNameShort=x64
	set platformNameIntel=intel64
	set platformNameGst=x86_64
)

REM Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set flagCuda=ON
	set flagMsmf=ON
	set flagHalide=OFF
	set flagSfm=ON
	set vcVersion=vc11
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set flagCuda=ON
	set flagMsmf=ON
	set flagHalide=OFF
	set flagSfm=ON
	set vcVersion=vc12
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set flagCuda=ON
	set flagMsmf=ON
	set flagHalide=ON
	set flagSfm=ON
	set vcVersion=vc14
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set flagCuda=ON
	set flagMsmf=ON
	set flagHalide=ON
	set flagSfm=ON
	REM set vcVersion=vc141
	set vcVersion=vc14
) else (
	set vsVersion=vs2010
	set flagCuda=ON
	set flagMsmf=OFF
	set flagHalide=OFF
	set flagSfm=ON
	set vcVersion=vc10
)

REM Gstreamerパス作成
set gstPath=%gstreamerDir%\1.0\%platformNameGst%
REM Gstreamerパス表示
echo Gstreamer : %gstPath%

REM Eigenパス
set eigenPath=%buildBuf%\%vsVersion%\%platformName%\Eigen\install\include\eigen3
REM Eigenパス表示
echo Eigen : %eigenPath%

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
REM HDF5ライブラリ
REM if /%linkType%==/Shared (
REM 	set hdf5prefix=
REM ) else (
	set hdf5prefix=lib
REM )
if /%configType%==/Debug (
	set hdf5postfix=_D
) else (
	set hdf5postfix=
)
REM HDF5パス表示
echo hdf5 path : %hdf5Path%
echo hdf5 lib path : %hdf5Path%\lib\%hdf5prefix%hdf5%hdf5postfix%.lib

REM Halide
set halidePath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Halide
REM Halideライブラリ
if /%configType%==/Debug (
	set halidePostfix=d
) else (
	set halidePostfix=
)
REM Halideパス表示
echo halide Path : %halidePath%
echo halide lib Path : %halidePath%\lib\Halide%postfix%.lib

REM Halideの定数定義オプション
set halideDefineString=-DHALIDE_INCLUDE_DIR="%halidePath:\=/%/include" ^
-DHALIDE_INCLUDE_DIRS="%halidePath:\=/%/include" ^
-DHALIDE_LIBRARIES="%halidePath:\=/%/lib/Halide%halidePostfix%.lib" ^
-DHALIDE_LIBRARY="%halidePath:\=/%/lib/Halide%halidePostfix%.lib%" ^
-DHALIDE_ROOT_DIR="%halidePath:\=/%" ^
-DHalide_DIR="%halidePath:\=/%"

REM Visual StudioがHalideをサポートしない場合は、Halideの定数定義オプションを空文字列にする。
if /%flagHalide%==/OFF (
	set halideDefineString=
	echo Halideなしでビルド %vsVersion%
)

REM jpeg
set jpegPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\libJpeg-turbo\install
REM HDF5ライブラリ
REM if /%linkType%==/Shared (
REM 	set jpegPostfixTmp=
REM ) else (
	set jpegPostfixTmp=-static
REM )
if /%configType%==/Debug (
	set jpegPostfix=%jpegPostfixTmp%d
) else (
	set jpegPostfix=%jpegPostfixTmp%
)
REM jpegパス表示
echo jpeg Path : %jpegPath%
echo jpeg lib Path : %jpegPath%\lib\jpeg%jpegPostfix%.lib

REM ProtoBuf
REM set protoBufPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\ProtoBuf\install
set protoBufPath=%buildBuf%\%vsVersion%\%platformName%\%configType%\Static\ProtoBuf\install
REM set protoBufPathD=%buildBuf%\%vsVersion%\%platformName%\Debug\%linkType%\ProtoBuf\install
set protoBufPathD=%buildBuf%\%vsVersion%\%platformName%\Debug\Static\ProtoBuf\install
REM set protoBufPathR=%buildBuf%\%vsVersion%\%platformName%\Release\%linkType%\ProtoBuf\install
set protoBufPathR=%buildBuf%\%vsVersion%\%platformName%\Release\Static\ProtoBuf\install
set protobufCompiler=%buildBuf%\%vsVersion%\%platformName%\Release\Static\ProtoBuf\install\bin\protoc.exe

REM ProtoBufパス表示
echo ProtoBuf Path : %protoBufPath%
echo ProtoBuf Compiler Path : %protobufCompiler%

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
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\OpenCV

REM ビルドディレクトリ表示
echo build directory : %buildDir%
REM ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM ビルドディレクトリへ移動
cd /d "%buildDir%"

REM -G "Visual Studio 14 2015 Win64"^
%cmakeExe% "%openCvPath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DEIGEN_INCLUDE_PATH="%eigenPath:\=/%" ^
-DCMAKE_DEBUG_POSTFIX="%postfixD%" ^
-DCMAKE_RELEASE_POSTFIX="%postfixR%" ^
-DCMAKE_EXE_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DCMAKE_MODULE_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DCMAKE_SHARED_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DPROTOBUF_UPDATE_FILES=ON ^
-DBUILD_DOCS=OFF ^
-DBUILD_JPEG=OFF ^
-DBUILD_PACKAGE=OFF ^
-DBUILD_PERF_TESTS=OFF ^
-DBUILD_PROTOBUF=OFF ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DBUILD_TESTS=OFF ^
-DBUILD_WITH_STATIC_CRT=OFF ^
-DBUILD_ZLIB=OFF ^
-DBUILD_opencv_apps=OFF ^
-DBUILD_opencv_java_bindings_generator=OFF ^
-DBUILD_opencv_js=OFF ^
-DBUILD_opencv_sfm=%flagSfm% ^
-DBUILD_opencv_python3=%flagPython% ^
-DBUILD_opencv_ts=OFF ^
-DBUILD_opencv_world=ON ^
-DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /W0 /GR /EHsc /bigobj /std:c++14 /DCV_CXX_STD_ARRAY=1 %glogFlag%" ^
-DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W0 /bigobj %glogFlag%" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" %cpuBaseLine% ^
-DCUDA_ARCH_BIN="5.2 6.1" ^
-DCUDA_ARCH_PTX="3.0" ^
-DCUDA_FAST_MATH=%flagRelease% ^
-DCUDA_NVCC_FLAGS="-Xcompiler """/W0 /FS"""" ^
-DENABLE_CXX11=ON ^
-DENABLE_LTO=ON ^
-Dgflags_DIR="%gflagPath:\=/%/lib/cmake/gflags" ^
-DGFLAGS_SHARED=%flagShared% ^
-DGLOG_INCLUDE_DIR="%glogPath:\=/%/include" ^
-DGLOG_LIBRARY="%glogPath:\=/%/lib/glog%postfix%.lib" ^
-DGlog_LIBS="%glogPath:\=/%/lib/glog%postfix%.lib" ^
-DGSTREAMER_DIR="%gstPath:\=/%" ^
%halideDefineString% ^
-DHDF5_C_LIBRARY="%hdf5Path:\=/%/lib/%hdf5prefix%hdf5%hdf5postfix%.lib" ^
-DHDF5_INCLUDE_DIRS="%hdf5Path:\=/%/include" ^
-DHDF5_USE_DLL=OFF ^
-DJPEG_INCLUDE_DIR="%jpegPath:\=/%/include" ^
-DJPEG_LIBRARY="%jpegPath:\=/%/lib/jpeg%jpegPostfix%.lib" ^
-DMKL_ROOT_DIR="%mklPath:\=/%" ^
-DMKL_USE_DLL=OFF ^
-DMKL_USE_MULTITHREAD=ON ^
-DMKL_WITH_TBB=%flagRelease% ^
-DMKL_USE_TBB_PREVIEW=OFF ^
-DOPENCV_DOWNLOAD_PATH="%openCv3rdpartyPath:\=/%" ^
-DOPENCV_ENABLE_NONFREE=ON ^
-DOPENCV_EXTRA_MODULES_PATH="%openCvContribPath:\=/%/modules" ^
-DProtobuf_INCLUDE_DIR="%protoBufPath:\=/%/include" ^
-DProtobuf_LIBRARY_DEBUG="%protoBufPathD:\=/%/lib/protobuf%postfixD%.lib" ^
-DProtobuf_LIBRARY_RELEASE="%protoBufPathR:\=/%/lib/protobuf%postfixR%.lib" ^
-DProtobuf_LITE_LIBRARY_DEBUG="%protoBufPathD:\=/%/lib/protobuf-lite%postfixD%.lib" ^
-DProtobuf_LITE_LIBRARY_RELEASE="%protoBufPathR:\=/%/lib/protobuf-lite%postfixR%.lib" ^
-DProtobuf_PROTOC_EXECUTABLE="%protobufCompiler:\=/%" ^
-DProtobuf_PROTOC_LIBRARY_DEBUG="%protoBufPathD:\=/%/lib/protoc%postfixD%.lib" ^
-DProtobuf_PROTOC_LIBRARY_RELEASE="%protoBufPathR:\=/%/lib/protoc%postfixR%.lib" ^
-DProtobuf_USE_DLL=OFF ^
-DTBB_ENV_INCLUDE="%tbbPath:\=/%/include" ^
-DTBB_ENV_LIB="%tbbPath:\=/%/lib/%platformNameIntel%/%vcVersion%/tbb.lib" ^
-DTBB_ENV_LIB_DEBUG="%tbbPath:\=/%/lib/%platformNameIntel%/%vcVersion%/tbb_debug.lib" ^
-DTINYDNN_USE_TBB=ON ^
-DWITH_1394=OFF ^
-DWITH_CUBLAS=%flagCuda% ^
-DWITH_CUDA=%flagCuda% ^
-DWITH_CUFFT=%flagCuda% ^
-DWITH_GSTREAMER=ON ^
-DWITH_HALIDE=%flagHalide% ^
-DWITH_MATLAB=OFF ^
-DWITH_MSMF=%flagMsmf% ^
-DWITH_NVCUVID=%flagCuda% ^
-DWITH_OPENCL=%flagCuda% ^
-DWITH_OPENCL_SVM=%flagCuda% ^
-DWITH_OPENGL=ON ^
-DWITH_TBB=ON ^
-DWITH_VTK=OFF ^
-DZLIB_INCLUDE_DIR="%zlibPath:\=/%/include" ^
-DZLIB_LIBRARY_DEBUG="%zlibLibD:\=/%" ^
-DZLIB_LIBRARY_RELEASE="%zlibLibR:\=/%"

REM -DCUDA_ARCH_BIN="3.0 3.5 3.7 5.0 5.2 6.0 6.1 7.0" ^

REM pause

endlocal
