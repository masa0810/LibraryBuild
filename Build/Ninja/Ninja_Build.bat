@echo off
setlocal

rem Python
set pythonExe="D:\Anaconda3\python.exe"

rem ライブラリパス
set ninjaDir=ninja-1.7.2

rem 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

rem バッチファイルの場所
set batchPath=%~dp0

rem ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

rem Ninjaパス
set ninjaPath=%sourceDir%\%ninjaDir%

rem ファイルチェック
if not exist "%ninjaPath%\ninja.exe" (
	cd /d "%ninjaPath%"
	echo Create Ninja : %ninjaPath%\ninja.exe
	%pythonExe% bootstrap.py --platform msvc
	cd /d "%currentPath%"
)

endlocal
