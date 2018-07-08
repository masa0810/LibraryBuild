@echo off
setlocal

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopy���[�h
set fastcopyMode=/force_close

REM �r���h�o�b�t�@
set buildBuf=C:\Library\Temp

REM ���C�u�����p�X
set intelLibraryDirOrig="C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows"
set intelLibraryDir=%intelLibraryDirOrig:"=%

REM �o�[�W�����ݒ�
set ippVersion=2018Update3
set mklVersion=2018Update3

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

REM �A�h���X���f���؂�ւ�
if /%Platform%==/ (
	set platformName=Win32
	set platformNameIntel=ia32
) else (
	set platformName=x64
	set platformNameIntel=intel64
)

REM �C���X�g�[���f�B���N�g��
set ippFinalDir=%buildBuf%\Final\IPP
REM �C���X�g�[���f�B���N�g���\��
echo install : %ippFinalDir%

REM �C���X�g�[���f�B���N�g���폜
if exist "%ippFinalDir%" (
	rd /S /Q "%ippFinalDir%"
)

REM include�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\ipp\include" /to="%ippFinalDir%\"

REM lib�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\ipp\lib\%platformNameIntel%\*" /to="%ippFinalDir%\lib\%platformName%\"

REM bin�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\redist\%platformNameIntel%\ipp\*" /to="%ippFinalDir%\bin\%platformName%\"

REM �o�[�W�����ԍ��t�@�C���ǉ�
type nul > %ippFinalDir%\IPP_%ippVersion%

REM �C���X�g�[���f�B���N�g��
set mklFinalDir=%buildBuf%\Final\MKL
REM �C���X�g�[���f�B���N�g���\��
echo install : %mklFinalDir%

REM �C���X�g�[���f�B���N�g���폜
if exist "%mklFinalDir%" (
	rd /S /Q "%mklFinalDir%"
)

REM include�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\mkl\include" /to="%mklFinalDir%\"

REM lib�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\mkl\lib\%platformNameIntel%\*" /to="%mklFinalDir%\lib\%platformName%\"

REM bin�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\redist\%platformNameIntel%\mkl\*" /to="%mklFinalDir%\bin\%platformName%\"

REM �o�[�W�����ԍ��t�@�C���ǉ�
type nul > %mklFinalDir%\MKL_%mklVersion%

endlocal
