@echo off
REM �t�@�C���R�s�[(����1:�r���h�^�C�v�A����2:�A�[�L�e�N�`���A����3:�o�̓f�B���N�g��)

setlocal ENABLEDELAYEDEXPANSION

set debugSuffix=_debug

set libDir=%~dp0bin\
set platform=%~2

set srcDir="%libDir%%platform%\"

for %%f in ( tbb tbb_preview tbbmalloc tbbmalloc_proxy ) do (
	call :CheckConfig %1 %3 %srcDir% %%f dll %debugSuffix%
)

goto :EOF

REM �r���h�^�C�v����(����1:�r���h�^�C�v�A����2:�o�̓f�B���N�g���A����3:�R�s�[���f�B���N�g���A����4:�t�@�C�����A����5:�g���q�A����6:�T�t�B�b�N�X������)
:CheckConfig

if /%1==/Debug (
	set suffix=%6
) else (
	set suffix=
)
call :FileCopy %2 %3 %4%suffix%.%5

exit /b
goto :EOF

REM �t�@�C���R�s�[(����1:�o�̓f�B���N�g���A����2:�R�s�[���f�B���N�g���A����3:�t�@�C����)
:FileCopy

set dstPath=%~f1
set srcPath=%~f2
set filename=%3

set filename1=%srcPath%%filename%
set filename2=%dstPath%%filename%

if exist "%filename1%" (
	if not exist "%filename2%" (
		copy "%filename1%" "%dstPath%" /y
		echo %filename1% Copy
	) else (
		for %%a in ( "%filename2%" ) do set oldtime=%%~ta
		for %%b in ( "%filename1%" ) do set newtime=%%~tb
		if "!newtime!" GTR "!oldtime!" (
			copy "%filename1%" "%dstPath%" /y
			echo %filename1% Update
		)
	)
)

exit /b
goto :EOF

endlocal
