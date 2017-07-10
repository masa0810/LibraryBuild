@echo off
setlocal ENABLEDELAYEDEXPANSION

for %%f in (cudnn64_6.dll cublas64_80.dll curand64_80.dll) do (
	call :FileCopyCUDA %1 %2 %%f
)
call :FileCopyPython %1 %2 python35.dll
goto :EOF

rem ファイルコピー
:FileCopyCUDA

if /%1==/x64 (
	set path=%~dp0..\..\CUDA\bin\
) else (
	echo "Win32非対応"
	goto :EOF
)
call :FileCopy %path% %2 %3

exit /b

rem ファイルコピー
:FileCopyPython

if /%1==/x64 (
	set path=%~dp0bin\x64\
) else (
	echo "Win32非対応"
	goto :EOF
)
call :FileCopy %path% %2 %3

exit /b

:FileCopy

set path=%1
set filename=%3

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
