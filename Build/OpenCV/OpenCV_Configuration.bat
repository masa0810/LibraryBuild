@echo off
setlocal

REM CMake
set cmakePath="C:\Program Files\CMake\bin\cmake.exe"

REM ninja
set ninjaPath="E:\Shared\Software\Ninja\ninja.exe"

REM ���C�u�����p�X
set openCv3rdpartyDir=opencv_3rdparty
set openCvDir=opencv
set tbbDir=tbb
set gstreamerDir=C:\Library\Gstreamer
set intelLibraryDirOrig="C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows"
set intelLibraryDir=%intelLibraryDirOrig:"=%

REM Static�r���h/Dynamic�r���h�؂�ւ�
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

REM Release/Debug�؂�ւ�
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

REM avx����
if /%3==/avx (
	set cpuBaseLineOrig="-DCPU_BASELINE=""AVX2"""
	set avxType=Enable
	echo Enable AVX
) else (
	set cpuBaseLineOrig="-DCPU_BASELINE=""SSE4_2"""
	set avxType=Disable
)
set cpuBaseLine=%cpuBaseLineOrig:"=%

REM Python�؂�ւ�
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

REM �r���h�����\��
echo link type : %linkType%
echo config type : %configType%
echo avx type : %avxType%
echo python build : %flagPython%

REM ���݂̃p�X�̕ێ�
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

REM �o�b�`�t�@�C���̏ꏊ
set batchPath=%~dp0

REM �\�[�X�u����
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

REM CMake�p�X�쐬
set cmakeExe=%cmakePath%
REM CMake�p�X�\��
echo CMake : %cmakeExe%

REM Ninja
set ninjaExe=%ninjaPath%
REM Ninja�p�X�\��
echo Ninja : %ninjaExe%

REM Eigen�p�X
set eigenPath=%sourceDir%\eigen
REM Eigen�p�X�\��
echo Eigen : %eigenPath%

REM MKL�p�X
set mklPath=%intelLibraryDir%\mkl
REM MKL�p�X�\��
echo MKL : %mklPath%

REM OpenCV 3rd Party�p�X
set openCv3rdpartyPath=%sourceDir%\%openCv3rdpartyDir%
REM OpenCV 3rd Party�p�X�\��
echo OpenCV 3rd Party : %openCv3rdpartyPath%

REM OpenCV
set openCvPath=%sourceDir%\%openCvDir%
REM OpenCV�p�X�\��
echo OpenCV : %openCvPath%

REM TBB�p�X
REM set tbbPath=%sourceDir%\%tbbDir%
set tbbPath=%intelLibraryDir%\tbb
REM TBB�p�X�\��
echo TBB : %tbbPath%

REM CUDA�p�X
set cudaPath=%sourceDir%\CUDA
REM CUDA�p�X�\��
echo CUDA : %cudaPath%

REM CUDA�p�X�m�F
if not exist %cudaPath% (
	powershell -Command Start-Process -Wait -FilePath cmd.exe -Verb runas -ArgumentList '/c','"mklink /D ""%cudaPath%""" """%CUDA_PATH%"""'
)

REM CUDA�p�X�Đݒ�
if not /"%cudaPath%"==/"%CUDA_PATH%" (
	set CUDA_PATH=%cudaPath%
)

REM �A�h���X���f���؂�ւ�
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

REM Visual Studio�o�[�W�����؂�ւ�
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set flagCuda=ON
	set flagMsmf=ON
	set vcVersion=vc11
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set flagCuda=ON
	set flagMsmf=ON
	set vcVersion=vc12
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set flagCuda=ON
	set flagMsmf=ON
	set vcVersion=vc14
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set flagCuda=ON
	set flagMsmf=ON
	REM set vcVersion=vc141
	set vcVersion=vc14
) else (
	set vsVersion=vs2010
	set flagCuda=ON
	set flagMsmf=OFF
	set vcVersion=vc10
)

REM Gstreamer�p�X�쐬
set gstPath=%gstreamerDir%\1.0\%platformNameGst%
REM Gstreamer�p�X�\��
echo Gstreamer : %gstPath%

REM �r���h�f�B���N�g��
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\OpenCV

REM �r���h�f�B���N�g���\��
echo build directory : %buildDir%
REM �r���h�f�B���N�g���m�F
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM �r���h�f�B���N�g���ֈړ�
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
-DBUILD_DOCS=OFF ^
-DBUILD_PACKAGE=OFF ^
-DBUILD_PERF_TESTS=OFF ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DBUILD_TESTS=OFF ^
-DBUILD_WITH_STATIC_CRT=OFF ^
-DBUILD_opencv_apps=OFF ^
-DBUILD_opencv_java_bindings_generator=OFF ^
-DBUILD_opencv_js=OFF ^
-DBUILD_opencv_sfm=OFF ^
-DBUILD_opencv_python3=%flagPython% ^
-DBUILD_opencv_ts=OFF ^
-DBUILD_opencv_world=ON ^
-DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /W0 /GR /EHsc /bigobj /std:c++14 /DCV_CXX_STD_ARRAY=1 %glogFlag%" ^
-DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W0 /bigobj %glogFlag%" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" %cpuBaseLine% ^
-DCUDA_ARCH_BIN="5.0" ^
-DCUDA_FAST_MATH=%flagRelease% ^
-DCUDA_NVCC_FLAGS="-Xcompiler """/W0 /FS"""" ^
-DENABLE_CXX11=ON ^
-DENABLE_LTO=ON ^
-DGSTREAMER_DIR="%gstPath:\=/%" ^
-DMKL_ROOT_DIR="%mklPath:\=/%" ^
-DMKL_LIBRARIES="%mklPath:\=/%/lib/intel64/mkl_intel_lp64.lib;%mklPath:\=/%/lib/intel64/mkl_sequential.lib;%mklPath:\=/%/lib/intel64/mkl_core.lib" ^
-DMKL_USE_DLL=OFF ^
-DMKL_USE_MULTITHREAD=ON ^
-DMKL_WITH_TBB=%flagRelease% ^
-DMKL_USE_TBB_PREVIEW=OFF ^
-DOPENCV_DOWNLOAD_PATH="%openCv3rdpartyPath:\=/%" ^
-DOPENCV_ENABLE_NONFREE=ON ^
-DTBB_ENV_INCLUDE="%tbbPath:\=/%/include" ^
-DTBB_ENV_LIB="%tbbPath:\=/%/lib/%platformNameIntel%/%vcVersion%/tbb.lib" ^
-DTBB_ENV_LIB_DEBUG="%tbbPath:\=/%/lib/%platformNameIntel%/%vcVersion%/tbb_debug.lib" ^
-DWITH_1394=OFF ^
-DWITH_CUBLAS=%flagCuda% ^
-DWITH_CUDA=%flagCuda% ^
-DWITH_CUFFT=%flagCuda% ^
-DWITH_GSTREAMER=ON ^
-DWITH_MATLAB=OFF ^
-DWITH_MSMF=%flagMsmf% ^
-DWITH_NVCUVID=%flagCuda% ^
-DWITH_OPENCL=%flagCuda% ^
-DWITH_OPENCL_SVM=%flagCuda% ^
-DWITH_OPENGL=ON ^
-DWITH_TBB=ON ^
-DWITH_VTK=OFF

REM pause

endlocal
