@echo off
setlocal ENABLEDELAYEDEXPANSION

for %%f in ( tbb tbbmalloc tbbmalloc_proxy ) do (
	call :FileCopy %1 %2 %3 %%f dll
	call :FileCopy %1 %2 %3 %%f pdb
)
goto :EOF

rem ファイルコピー
:FileCopy

if /%1==/Release (
	set suffix=
) else (
	set suffix=_debug
)

if %2==x64 (
	set path=%~dp0bin\x64\
) else (
	echo "Win32非対応"
	goto :EOF
)

set filename=%4%suffix%.%5
set filename1=%~f3%filename%
set filename2=%path%%filename%

if exist "%filename2%" (
	if not exist "%filename1%" (
		copy "%filename2%" "%~3" /y
		echo %filename2% Copy
	) else (
		for %%a in ( "%filename1%" ) do set oldtime=%%~ta
		for %%b in ( "%filename2%" ) do set newtime=%%~tb
		if "!newtime!" GTR "!oldtime!" (
			copy "%filename2%" "%~3" /y
			echo %filename2% Update
		)
	)
)

exit /b

endlocal
