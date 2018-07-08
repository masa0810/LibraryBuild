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
set tbbVersion=2018Update4

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

REM Visual Studio�o�[�W�����؂�ւ�
if /%VisualStudioVersion%==/11.0 (
	set vcVersion=110
	set vcVersionIntel=vc11
) else if /%VisualStudioVersion%==/12.0 (
	set vcVersion=120
	set vcVersionIntel=vc12
) else if /%VisualStudioVersion%==/14.0 (
	set vcVersion=140
	set vcVersionIntel=vc14
) else if /%VisualStudioVersion%==/15.0 (
	set vcVersion=141
	REM set vcVersionIntel=vc141
	set vcVersionIntel=vc14
) else (
	set vcVersion=100
	set vcVersionIntel=vc10
)

REM �C���X�g�[���f�B���N�g��
set tbbFinalDir=%buildBuf%\Final\v%vcVersion%\TBB
REM �C���X�g�[���f�B���N�g���\��
echo install : %tbbFinalDir%

REM �C���X�g�[���f�B���N�g���폜
if exist "%tbbFinalDir%" (
	rd /S /Q "%tbbFinalDir%"
)

REM include�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.html" "%intelLibraryDir%\tbb\include" /to="%tbbFinalDir%\"

REM lib�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.def;*.pdb" "%intelLibraryDir%\tbb\lib\%platformNameIntel%\%vcVersionIntel%" /to="%tbbFinalDir%\lib\%platformName%"

REM bin�R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\redist\%platformNameIntel%\tbb\%vcVersionIntel%" /to="%tbbFinalDir%\bin\%platformName%"

REM �Z�b�g�w�b�_�̃R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\tbbset.h" /to="%tbbFinalDir%\include\"

REM Copy�o�b�`�̃R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\TbbCopy.bat" /to="%tbbFinalDir%\"

REM �o�[�W�����ԍ��t�@�C���ǉ�
type nul > %tbbFinalDir%\TBB_%tbbVersion%

endlocal
