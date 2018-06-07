@echo off
setlocal

REM Python
set pythonExe="C:\Library\Python\python.exe"

REM ライブラリパス
set ninjaDir=ninja

REM 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

REM バッチファイルの場所
set batchPath=%~dp0

REM ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

REM Ninjaパス
set ninjaPath=%sourceDir%\%ninjaDir%

REM Ninjaパス
set ninjaInstallPath=%sourceDir%\Build\Tools\Ninja

REM ファイルチェック
if not exist "%ninjaInstallPath%\ninja.exe" (
	REM ビルド
	if not exist "%ninjaPath%\ninja.exe" (
		cd /d "%ninjaPath%"
		echo Create Ninja : "%ninjaPath%\ninja.exe"
		%pythonExe% bootstrap.py --platform msvc
		cd /d "%currentPath%"
	)
	REM フォルダ作成
	if not exist "%ninjaInstallPath%" (
		md "%ninjaInstallPath%"
	)
	REM コピー
	copy "%ninjaPath%\ninja.exe" "%ninjaInstallPath%"
)

endlocal
