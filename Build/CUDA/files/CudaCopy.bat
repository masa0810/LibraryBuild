@echo off
setlocal ENABLEDELAYEDEXPANSION

for %%f in ( cudart64_80.dll ) do (
	call :FileCopy %1 %2 %%f
)
goto :EOF

rem ファイルコピー
:FileCopy

if /%1==/x64 (
	set path=%~dp0bin\
	set filename=%3
) else (
	echo "Win32非対応"
	goto :EOF
)

set filename1=%~f2%filename%
set filename2=%path%%filename%

if exist "%filename2%" (
	if not exist "%filename1%" (
		copy "%filename2%" "%~2" /y
		echo %filename2% Copy
	) else (
		for %%a in ( "%filename1%" ) do set oldtime=%%~ta
		for %%b in ( "%filename2%" ) do set newtime=%%~tb
		if "!newtime!" GTR "!oldtime!" (
			copy "%filename2%" "%~2" /y
			echo %filename2% Update
		)
	)
)

exit /b

endlocal
