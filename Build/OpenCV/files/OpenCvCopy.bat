@echo off
REM �t�@�C���R�s�[(����1:�r���h�^�C�v�A����2:�A�[�L�e�N�`���A����3:�o�̓f�B���N�g��)

setlocal ENABLEDELAYEDEXPANSION

set version=343
set debugSuffix=d

set libDir=%~dp0bin\
set platform=%~2

set srcDir="%libDir%%platform%\"

if /platform==/x64 (
	call :FileCopy %3 %srcDir% opencv_ffmpeg%version%_64.dll
) else (
	call :FileCopy %3 %srcDir% opencv_ffmpeg%version%.dll
)
for %%f in ( opencv_img_hash%version% opencv_sfm%version% opencv_world%version% ) do (
	call :CheckConfig %1 %3 %srcDir% %%f dll %debugSuffix%
)

set cudaVer=92
set cudaDir="%~dp0..\..\CUDA\bin\"

for %%f in ( cublas64_%cudaVer%.dll cudart64_%cudaVer%.dll cufft64_%cudaVer%.dll ) do (
	call :FileCopy %3 %cudaDir% %%f
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
