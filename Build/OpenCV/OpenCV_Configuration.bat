@echo off
setlocal

rem CMake
set cmakePath=cmake-3.7.2-win64-x64\bin\cmake.exe

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem ライブラリパス
set eigenDir=eigen-eigen-5a0156e40feb
set openBlasDir=OpenBLAS-v0.2.19-Win64-int32
set openCvContribDir=opencv_contrib-3.2.0
set openCvDir=opencv-3.2.0
set protoBufDir=protobuf-3.3.2
set tbbDir=tbb-2017_U7

rem Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set flagShared=ON
    set linkType=Shared
) else (
	set flagShared=OFF
    set linkType=Static
)

rem Release/Debug切り替え
if /%2==/debug (
	set flagDebug=ON
    set configType=Debug
	set flagCudaFastMath=OFF
) else (
	set flagDebug=OFF
    set configType=Release
	set flagCudaFastMath=ON
)

rem avx判定
if /%3==/avx (
	set flagAvx=ON
	set avxType=Enable
) else (
	set flagAvx=OFF
	set avxType=Disable
)

rem Python切り替え
if /%linkType%==/Shared (
    set flagPython=OFF
) else (
    if /%configType%==/Debug (
	    set flagPython=OFF
    ) else (
	    set flagPython=ON
    )
)

rem ビルド条件表示
echo link type : %linkType%
echo config type : %configType%
echo avx type : %avxType%
echo python build : %flagPython%

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

rem Eigenパス
set eigenPath=%sourceDir%\%eigenDir%
rem Eigenパス表示
echo Eigen : %eigenPath%

rem OpenBLASパス
set openBlasPath=%sourceDir%\%openBlasDir%
rem OpenBLASパス表示
echo OpenBLAS : %openBlasPath%

rem OpenCV Contribパス
set openCvContribPath=%sourceDir%\%openCvContribDir%
rem OpenCV Contribパス表示
echo OpenCV Contrib : %openCvContribPath%

rem OpenCV
set openCvPath=%sourceDir%\%openCvDir%
rem OpenCVパス表示
echo OpenCV : %openCvPath%

rem TBBパス
set tbbPath=%sourceDir%\%tbbDir%
rem TBBパス表示
echo TBB : %tbbPath%

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
	set flagCuda=ON
	set flagMsmf=ON
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set flagCuda=ON
	set flagMsmf=ON
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set flagCuda=ON
	set flagMsmf=ON
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set flagCuda=OFF
	set flagMsmf=ON
) else (
	set vsVersion=vs2010
	set flagCuda=ON
	set flagMsmf=OFF
)

rem HDF5
set hdf5Path=%sourceDir%\Build\HDF5\Build_%vsVersion%_%platformName%_%linkType%_%configType%\install
rem HDF5インクルード
set hdf5IncludePath=%hdf5Path%\include
rem HDF5ライブラリ
if /%linkType%==/Shared (
    if /%configType%==/Debug (
		set hdf5LibPath=%hdf5Path%\lib\hdf5_D.lib
	) else (
		set hdf5LibPath=%hdf5Path%\lib\hdf5.lib
	)
) else (
    if /%configType%==/Debug (
		set hdf5LibPath=%hdf5Path%\lib\libhdf5_D.lib
	) else (
		set hdf5LibPath=%hdf5Path%\lib\libhdf5.lib
	)
)
rem HDF5パス表示
echo HDF5 Path : %hdf5Path%
echo HDF5 include Path : %hdf5IncludePath%
echo HDF5 lib Path : %hdf5LibPath%

rem ProtoBuf
set protoBufPath=%sourceDir%\Build\ProtoBuf\Build_%vsVersion%_%platformName%_%linkType%_%configType%\install
set protoBufDebugPath=%sourceDir%\Build\ProtoBuf\Build_%vsVersion%_%platformName%_%linkType%_Debug\install
set protoBufReleasePath=%sourceDir%\Build\ProtoBuf\Build_%vsVersion%_%platformName%_%linkType%_Release\install
rem ProtoBufインクルード
set protoBufIncludePath=%sourceDir%\%protoBufDir%\src
rem ProtoBufライブラリ
set protoBufDebugLibPath=%protoBufDebugPath%\lib
set protoBufReleaseLibPath=%protoBufReleasePath%\lib
rem Protocパス
set protocExe="%sourceDir%\Build\ProtoBuf\Build_%vsVersion%_%platformName%_Static_Release\install\bin\protoc.exe"

rem ProtoBufパス表示
echo ProtoBuf Path : %protoBufPath%
echo ProtoBuf include Path : %protoBufIncludePath%
echo ProtoBuf debug lib Path : %protoBufDebugLibPath%
echo ProtoBuf release lib Path : %protoBufReleaseLibPath%
echo ProtoBuf Compiler Path : %protocExe%

rem jpeg
set jpegPath=%sourceDir%\Build\libJpeg-turbo\Build_%vsVersion%_%platformName%_%configType%\install
rem jpegインクルード
set jpegIncludePath=%jpegPath%\include
rem jpegライブラリ
if /%linkType%==/Shared (
    if /%configType%==/Debug (
		set jpegLibPath=%jpegPath%\lib\jpegd.lib
	) else (
		set jpegLibPath=%jpegPath%\lib\jpeg.lib
	)
) else (
    if /%configType%==/Debug (
		set jpegLibPath=%jpegPath%\lib\jpeg-staticd.lib
	) else (
		set jpegLibPath=%jpegPath%\lib\jpeg-static.lib
	)
)

rem jpegパス表示
echo jpeg Path : %jpegPath%
echo jpeg include Path : %jpegIncludePath%
echo jpeg debug lib Path : %jpegLibPath%

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

rem -G "Visual Studio 14 2015 Win64"^
rem -DCUDA_ARCH_BIN="3.0 3.5 3.7 5.0 5.2 6.0 6.1" ^
%cmakeExe% "%openCvPath%" ^
-G "Ninja"  ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DEIGEN_INCLUDE_PATH="%eigenPath:\=/%" ^
-DUPDATE_PROTO_FILES=ON ^
-DBUILD_DOCS=OFF ^
-DBUILD_JPEG=OFF ^
-DBUILD_PACKAGE=OFF ^
-DBUILD_PERF_TESTS=OFF ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DBUILD_TESTS=OFF ^
-DBUILD_WITH_STATIC_CRT=OFF ^
-DBUILD_ZLIB=OFF ^
-DBUILD_opencv_apps=OFF ^
-DBUILD_opencv_python3=%flagPython% ^
-DBUILD_opencv_ts=OFF ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /W3 /GR /EHa /DHAVE_LAPACK_CONFIG_H /DLAPACK_COMPLEX_CPP /wd4505 /wd4819" ^
-DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 /DHAVE_LAPACK_CONFIG_H /DLAPACK_COMPLEX_STRUCTURE /wd4505 /wd4819" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DCUDA_ARCH_BIN="3.0 3.5 3.7 5.0 5.2 6.0 6.1" ^
-DCUDA_FAST_MATH=%flagCudaFastMath% ^
-DCUDA_NVCC_FLAGS="-Xcompiler """/wd4505 /wd4819 /FS"""" ^
-DENABLE_AVX=%flagAvx% ^
-DENABLE_AVX2=%flagAvx% ^
-DENABLE_FMA3=%flagAvx% ^
-DENABLE_POPCNT=ON ^
-DENABLE_SSE41=ON ^
-DENABLE_SSE42=ON ^
-DENABLE_SSSE3=ON ^
-DHDF5_C_LIBRARY="%hdf5LibPath:\=/%" ^
-DHDF5_INCLUDE_DIRS="%hdf5IncludePath:\=/%" ^
-DJPEG_INCLUDE_DIR="%jpegIncludePath:\=/%" ^
-DJPEG_LIBRARY="%jpegLibPath:\=/%" ^
-DOPENCV_ENABLE_NONFREE=ON ^
-DOPENCV_EXTRA_MODULES_PATH="%openCvContribPath:\=/%/modules" ^
-DOpenBLAS_INCLUDE_DIR="%openBlasPath:\=/%/include" ^
-DOpenBLAS_LIB="%openBlasPath:\=/%/lib/libopenblas.dll.a" ^
-DProtobuf_INCLUDE_DIR="%protoBufIncludePath:\=/%" ^
-DProtobuf_LIBRARY_DEBUG="%protoBufDebugLibPath:\=/%/libprotobufd.lib" ^
-DProtobuf_LIBRARY_RELEASE="%protoBufReleaseLibPath:\=/%/libprotobuf.lib" ^
-DProtobuf_LITE_LIBRARY_DEBUG="%protoBufDebugLibPath:\=/%/libprotobuf-lited.lib" ^
-DProtobuf_LITE_LIBRARY_RELEASE="%protoBufReleaseLibPath:\=/%/libprotobuf-lite.lib" ^
-DProtobuf_PROTOC_EXECUTABLE=%protocExe:\=/% ^
-DProtobuf_PROTOC_LIBRARY_DEBUG="%protoBufDebugLibPath:\=/%/libprotocd.lib" ^
-DProtobuf_PROTOC_LIBRARY_RELEASE="%protoBufReleaseLibPath:\=/%/libprotoc.lib" ^
-DTBB_ENV_INCLUDE="%tbbPath:\=/%/include" ^
-DTBB_ENV_LIB="%tbbPath:\=/%/build/%vsVersion%/%platformName%/Release/tbb.lib" ^
-DTBB_ENV_LIB_DEBUG="%tbbPath:\=/%/build/%vsVersion%/%platformName%/Debug/tbb_debug.lib" ^
-DWITH_1394=OFF ^
-DWITH_CUBLAS=%flagCuda% ^
-DWITH_CUDA=%flagCuda% ^
-DWITH_CUFFT=%flagCuda% ^
-DWITH_GSTREAMER=OFF ^
-DWITH_MATLAB=OFF ^
-DWITH_MSMF=%flagMsmf% ^
-DWITH_NVCUVID=%flagCuda% ^
-DWITH_OPENCL=%flagCuda% ^
-DWITH_OPENCL_SVM=%flagCuda% ^
-DWITH_OPENGL=ON ^
-DWITH_TBB=ON ^
-DWITH_VTK=OFF ^
-DZLIB_INCLUDE_DIR="%zlibIncludePath:\=/%" ^
-DZLIB_LIBRARY_DEBUG="%zlibDebugLibPath:\=/%" ^
-DZLIB_LIBRARY_RELEASE="%zlibReleaseLibPath:\=/%"

endlocal
