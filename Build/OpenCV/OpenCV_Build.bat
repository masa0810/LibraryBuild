@echo off
setlocal enabledelayedexpansion

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopy���[�h
set fastcopyMode=/force_close

REM ninja
set ninjaPath="E:\Shared\Software\Ninja\ninja.exe"

REM �r���h�o�b�t�@
set buildBuf=C:\Library\Temp

REM �o�[�W�����ݒ�
set openCvVersion=3.4.2

REM ����r���h��
set numOfParallel=%NUMBER_OF_PROCESSORS%

REM �������
if /%1==/install (
	set buildType=install
	if /%2==/avx (
		set flagAvx=avx
	) else (
		set flagAvx=
	)
) else if /%1==/avx (
	set flagAvx=avx
	if /%2==/install (
		set buildType=install
	) else (
		set buildType=
	)
) else (
	set buildType=
	set flagAvx=
)

REM �r���h�����\��
echo build type : %buildType%

REM ���݂̃p�X�̕ێ�
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

REM �o�b�`�t�@�C���̏ꏊ
set batchPath=%~dp0

REM �\�[�X�u����
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

REM FastCopy�p�X�쐬
set fastcopyExe=%fastcopyPath%
REM FastCopy�p�X�\��
echo FastCopy : %fastcopyExe%

REM Ninja
set ninjaExe=%ninjaPath%
REM Ninja�p�X�\��
echo Ninja : %ninjaExe%

REM CUDA�p�X
set cudaPath=%sourceDir%\CUDA
REM CUDA�p�X�\��
echo CUDA : %cudaPath%

REM �A�h���X���f���؂�ւ�
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
)

REM Visual Studio�o�[�W�����؂�ւ�
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set vcVersion=110
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set vcVersion=120
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set vcVersion=140
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set vcVersion=141
) else (
	set vsVersion=vs2010
	set vcVersion=100
)

REM echo Static Release
REM cd /d %batchPath%
REM call :Main static release
echo Shared Release
cd /d %batchPath%
call :Main shared release
REM echo Static Debug
REM cd /d %batchPath%
REM call :Main static debug
echo Shared Debug
cd /d %batchPath%
call :Main shared debug

goto :EOF

:Main

REM Static�r���h/Dynamic�r���h�؂�ւ�
if /%1==/shared (
	set linkType=Shared
) else (
	set linkType=Static
)

REM Release/Debug�؂�ւ�
if /%2==/debug (
	set configType=Debug
) else (
	set configType=Release
)

REM Configuration���s
call %batchPath%OpenCV_Configuration.bat %1 %2 %flagAvx%

REM �r���h�f�B���N�g��
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\OpenCV

REM �r���h�f�B���N�g���\��
echo build directory : %buildDir%

REM CUDA�p�X�Đݒ�(�� Configuration������ł��)
if not /"%cudaPath%"==/"%CUDA_PATH%" (
	set CUDA_PATH=%cudaPath%
)

REM �r���h�f�B���N�g���ֈړ�
cd /d "%buildDir%"
%ninjaExe% %buildType% -j %numOfParallel%
call :ErrorCheck

REM �C���X�g�[���f�B���N�g��
set finalDir=%buildBuf%\Final\v%vcVersion%\OpenCV

REM �C���X�g�[��
if /%buildType%==/install (
	REM �C���X�g�[���f�B���N�g���\��
	echo install : %finalDir%

	REM include�f�B���N�g���R�s�[
	%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="cvconfig.h" "install\include" /to="%finalDir%\"

	REM �ʃt�@�C���R�s�[
	%fastcopyExe% %fastcopyMode% /cmd=diff "install\include\opencv2\cvconfig.h" /to="%finalDir%\include"

	REM �ʃt�@�C�����l�[��
	if exist "%finalDir%\include\cvconfig_%platformName%_%linkType%_%configType%.h" (
		del "%finalDir%\include\cvconfig_%platformName%_%linkType%_%configType%.h"
	)
	ren "%finalDir%\include\cvconfig.h" cvconfig_%platformName%_%linkType%_%configType%.h

	REM bin&lib�t�@�C���R�s�[
	if /%linkType%==/Shared (
		call :Shared
	) else (
		call :Static
	)

	REM �Z�b�g�w�b�_�̃R�s�[
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\opencvset.h" /to="%finalDir%\include\"

	REM Copy�o�b�`�̃R�s�[
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\OpenCvCopy.bat" /to="%finalDir%\"

	REM �o�[�W�����ԍ��t�@�C���ǉ�
	type nul > %finalDir%\OpenCV_%openCvVersion%
)

exit /b

goto :EOF

:Shared

REM bin�f�B���N�g���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll;*.pdb" /exclude="opencv_waldboost_detector*" "bin" /to="%finalDir%\bin\%platformName%"

REM lib�f�B���N�g���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /include="opencv_*.lib" "lib" /to="%finalDir%\lib\%platformName%"

exit /b

goto :EOF

:Static

REM bin�f�B���N�g���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "bin" /to="%finalDir%\bin\%platformName%"

REM lib�f�B���N�g���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /include="opencv_*.lib;opencv_*.pdb" /exclude="opencv_python3*" "lib" /to="%finalDir%\lib\%platformName%"

REM 3rdparty���C�u�����R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib;*.pdb" "3rdparty\lib" /to="%finalDir%\lib\%platformName%"
%fastcopyExe% %fastcopyMode% /cmd=diff "3rdparty\ippicv\ippicv_win\lib\intel64\ippicvmt.lib" /to="%finalDir%\lib\%platformName%\"

exit /b

goto :EOF

:ErrorCheck
if not %errorlevel% == 0 (
	echo ERROR
	cd /d "%currentPath%"
	exit 1
) else (
	exit /b
)

goto :EOF

endlocal
