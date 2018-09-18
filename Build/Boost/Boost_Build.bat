@echo off
setlocal

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopy���[�h
set fastcopyMode=/force_close

REM �r���h�o�b�t�@
set buildBuf=C:\Library\Temp

REM ���C�u�����p�X
set boostDir=boost
set pythonDir=C:\Library\Python

REM �o�[�W�����ݒ�
set boostVersion=1.68
set pythonVersion=3.6

REM ����r���h��
set numOfParallel=%NUMBER_OF_PROCESSORS%

REM �������
if /%1==/install (
	set buildType=install
	if /%2==/avx (
		set avxType=Enable
	) else (
		set avxType=Disable
	)
) else if /%1==/avx (
	set avxType=Enable
	if /%2==/install (
		set buildType=install
	) else (
		set buildType=stage
	)
) else (
	set buildType=stage
	set avxType=Disable
)

REM �r���h�����\��
echo build type : %buildType%
echo avx type : %avxType%

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

REM boost�p�X
set boostPath=%sourceDir%\%boostDir%
REM boost�p�X�\��
echo Boost : %boostPath%

REM �A�h���X���f���؂�ւ�
if /%Platform%==/ (
	set addmodel=86
	set platformName=Win32
) else (
	set addmodel=64
	set platformName=x64
)

REM Visual Studio�o�[�W�����؂�ւ�
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set vcVersion=110
	set toolsetName=msvc-11.0
	set cppver=
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set vcVersion=120
	set toolsetName=msvc-12.0
	set cppver=
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set vcVersion=140
	set toolsetName=msvc-14.0
	set cppver="/std:c++14"
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set vcVersion=141
	set toolsetName=msvc-14.1
	set cppver="/std:c++17"
) else (
	set vsVersion=vs2010
	set vcVersion=100
	set toolsetName=msvc-10.0
	set cppver
)

REM �r���h�f�B���N�g��
set buildPath=%buildBuf%\%vsVersion%\%platformName%\Boost
set buildDir=%buildPath%\Tmp
set stageDir=%buildPath%\Stage

REM Boost�f�B���N�g���Ɉړ�
cd /d "%boostPath%"

REM b2�t�@�C���쐬
set pythonPath=%pythonDir:\=\\%
if not exist b2.exe (
	REM �o�b�`���s
	call bootstrap.bat
	REM python�ݒ�
	echo using python : %pythonVersion% : %pythonPath% : %pythonPath%\\include : %pythonPath%\\libs ; >> project-config.jam
)

REM �����쐬
if /%avxType%==/Enable (
	REM set instructionOptionOrig="instruction-set=sandy-bridge"
	set instructionOptionOrig=""
	echo Enable AVX
) else (
	set instructionOptionOrig="instruction-set=nehalem"
)
set instructionOption=%instructionOptionOrig:"=%

REM �r���h
b2.exe ^
%buildType% ^
toolset=%toolsetName% ^
address-model=%addmodel% ^
link=static,shared ^
runtime-link=shared ^
threading=multi ^
variant=release,debug ^
embed-manifest=off ^
debug-symbols=on ^
cxxflags=%cppver% ^
-j%numOfParallel% ^
--build-dir="%buildDir%" ^
--prefix="%stageDir%" ^
--stagedir="%stageDir%" ^
--build-type=complete ^
--without-mpi %instructionOption%
call :ErrorCheck

REM �C���X�g�[���f�B���N�g��
set finalDir=%buildBuf%\Final\v%vcVersion%\Boost

REM �C���X�g�[��
if /%buildType%==/install (
	REM �C���X�g�[���f�B���N�g���\��
	echo install : %finalDir%

	REM include�f�B���N�g���R�s�[
	for /f %%d in ( 'dir /a:D /B "%stageDir%\include"' ) do (
		%fastcopyExe% %fastcopyMode% /cmd=diff "%stageDir%\include\%%d" /to="%finalDir%\include"
	)

	REM dll�R�s�[
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "%stageDir%\lib" /to="%finalDir%\bin\%platformName%"

	REM lib�R�s�[
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%stageDir%\lib" /to="%finalDir%\lib\%platformName%"

	REM pdb�R�s�[
	for /f "delims=" %%f in ( 'dir "%buildDir%" /a-D /B /S ^| findstr "boost[^\\]*%vcVersion%[^\\]*pdb$"' ) do (
		copy "%%f" "%finalDir%\bin\%platformName%"
	)

	REM �o�[�W�����ԍ��t�@�C���ǉ�
	type nul > %finalDir%\Boost_%boostVersion%
)

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
