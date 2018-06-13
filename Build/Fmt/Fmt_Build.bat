@echo off
setlocal

REM CMake
set cmakePath="C:\Program Files\CMake\bin\cmake.exe"

REM ninja
set ninjaPath="E:\Shared\Software\Ninja\ninja.exe"

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopy���[�h
set fastcopyMode=/force_close

REM �r���h�o�b�t�@
set buildBuf=C:\Library\Temp

REM ���C�u�����p�X
set fmtDir=fmt

REM �o�[�W�����ݒ�
set fmtVersion=5.0.0

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

REM FastCopy�p�X�쐬
set fastcopyExe=%fastcopyPath%
REM FastCopy�p�X�\��
echo FastCopy : %fastcopyExe%

REM Fmt�p�X
set fmtPath=%sourceDir%\%fmtDir%
REM Fmt�p�X�\��
echo FMT : %fmtPath%

REM �A�h���X���f���؂�ւ�
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
)

REM Visual Studio�o�[�W�����؂�ւ�
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
) else (
	set vsVersion=vs2010
)

REM �r���h�f�B���N�g��
set buildDir=%buildBuf%\%vsVersion%\%platformName%\Fmt
REM �r���h�f�B���N�g���\��
echo build directory : %buildDir%
REM �r���h�f�B���N�g���m�F
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM �r���h�f�B���N�g���ֈړ�
cd /d "%buildDir%"

%cmakeExe% "%fmtPath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE="Release" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DFMT_DOC=OFF ^
-DFMT_TEST=OFF

%ninjaExe% install
call :ErrorCheck

REM �C���X�g�[���f�B���N�g��
set finalDir=%buildBuf%\Final\Fmt
REM �C���X�g�[���f�B���N�g���\��
echo install : %finalDir%

REM �C���X�g�[���f�B���N�g���폜
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

REM Fmt�f�B���N�g���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "install\include" /to="%finalDir%\"

REM �Z�b�g�w�b�_�̃R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\fmtset.h" /to="%finalDir%\include\"

REM �o�[�W�����ԍ��t�@�C���ǉ�
type nul > %finalDir%\Fmt_%fmtVersion%

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
