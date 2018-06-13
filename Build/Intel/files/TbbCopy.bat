@echo off
REM ファイルコピー(引数1:ビルドタイプ、引数2:アーキテクチャ、引数3:出力ディレクトリ)

setlocal ENABLEDELAYEDEXPANSION

set debugSuffix=_debug

set libDir=%~dp0bin\
set platform=%~2

set srcDir="%libDir%%platform%\"

for %%f in ( tbb tbb_preview tbbmalloc tbbmalloc_proxy ) do (
	call :CheckConfig %1 %3 %srcDir% %%f dll %debugSuffix%
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
