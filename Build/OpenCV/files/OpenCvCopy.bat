@echo off
REM ファイルコピー(引数1:ビルドタイプ、引数2:アーキテクチャ、引数3:出力ディレクトリ)

setlocal ENABLEDELAYEDEXPANSION

set version=401
set debugSuffix=d

set libDir=%~dp0bin\
set platform=%~2

set srcDir="%libDir%%platform%\"

if /platform==/x64 (
	call :FileCopy %3 %srcDir% opencv_ffmpeg%version%_64.dll
) else (
	call :FileCopy %3 %srcDir% opencv_ffmpeg%version%.dll
)
for %%f in (
	opencv_img_hash%version%
	opencv_sfm%version%
	opencv_world%version%
) do (
	call :CheckConfig %1 %3 %srcDir% %%f dll %debugSuffix%
)

set cudaVer=100
set cudaDir="%~dp0..\..\CUDA\bin\"

for %%f in (
	cublas64_%cudaVer%.dll
	cudart64_%cudaVer%.dll
	cufft64_%cudaVer%.dll
	nppc64_%cudaVer%.dll
	nppial64_%cudaVer%.dll
	nppicc64_%cudaVer%.dll
	nppidei64_%cudaVer%.dll
	nppif64_%cudaVer%.dll
	nppig64_%cudaVer%.dll
	nppim64_%cudaVer%.dll
	nppist64_%cudaVer%.dll
	nppitc64_%cudaVer%.dll
	npps64_%cudaVer%.dll
) do (
	call :FileCopy %3 %cudaDir% %%f
)

goto :EOF

REM ビルドタイプ判定(引数1:ビルドタイプ、引数2:出力ディレクトリ、引数3:コピー元ディレクトリ、引数4:ファイル名、引数5:拡張子、引数6:サフィックス文字列)
:CheckConfig

if /%1==/Debug (
	set suffix=%6
) else (
	set suffix=
)
call :FileCopy %2 %3 %4%suffix%.%5

exit /b
goto :EOF

REM ファイルコピー(引数1:出力ディレクトリ、引数2:コピー元ディレクトリ、引数3:ファイル名)
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
