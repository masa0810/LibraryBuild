@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ライブラリパス
set tbbDir=tbb-2017_U7

rem デフォルトバージョン
set tbbDefaultVsVersion=vs2012

rem バージョン設定
set tbbVersion=2017Update7

rem 引数解析
if /%1==/install (
	set buildType=install
) else (
	set buildType=build
)

rem ビルド条件表示
echo build type : %buildType%

rem 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

rem バッチファイルの場所
set batchPath=%~dp0

rem ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

rem FastCopyパス作成
set fastcopyExe="%sourceDir%\Build\Tools\%fastcopyPath%"
rem FastCopyパス表示
echo FastCopy : %fastcopyExe%

rem TBBパス
set tbbPath=%sourceDir%\%tbbDir%
rem TBBパス表示
echo TBB : %tbbPath%

rem アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
)

rem Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set vcVersion=110
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set vcVersion=120
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set vcVersion=140
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set vcVersion=141
) else (
	set vsVersion=vs2010
	set vcVersion=100
)

rem インストールディレクトリ(※ビルドより前にやらないと変数が作れない。。。)
set finalDir=%sourceDir%\Final\v%vcVersion%\TBB

rem ビルド出力フォルダ(※ビルドより前にやらないと変数が作れない。。。)
set buildOutputDir=%tbbPath%\build\%vsVersion%\%platformName%

rem プロジェクトディレクトリ確認
if not exist "%tbbPath%\build\%vsVersion%" (
	xcopy /y /s /q "%tbbPath%\build\%tbbDefaultVsVersion%" "%tbbPath%\build\%vsVersion%\"
	for /f "delims=" %%f in ( 'dir "%tbbPath%\build\%vsVersion%" /a-D /B /S ^| findstr ".*sln$"' ) do devenv "%%f" /upgrade
)

rem ビルド
for /f "delims=" %%f in ( 'dir "%tbbPath%\build\%vsVersion%" /a-D /B ^| findstr ".*sln$"' ) do set slnFile=%tbbPath%\build\%vsVersion%\%%f
for /f "delims=" %%f in ( 'dir "%tbbPath%\build\%vsVersion%" /a-D /B ^| findstr ".*vcxproj$"' ) do (
	devenv "%slnFile%" /Build "Release|%platformName%" /Project %%~nf
	call :ErrorCheck
	devenv "%slnFile%" /Build "Debug|%platformName%" /Project %%~nf
	call :ErrorCheck
)

rem インストール
if /%buildType%==/install (
	rem インストールディレクトリ表示
	echo install : %finalDir%

	rem インストールディレクトリ削除
	if exist "%finalDir%" (
		rd /S /Q "%finalDir%"
	)

	rem includeディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.html" "%tbbPath%\include" /to="%finalDir%\"

	rem libファイルコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%buildOutputDir%\Release" /to="%finalDir%\lib\%platformName%"
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%buildOutputDir%\Debug" /to="%finalDir%\lib\%platformName%"

	rem dll・pdbファイルコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll;*.pdb" "%buildOutputDir%\Release" /to="%finalDir%\bin\%platformName%"
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll;*.pdb" "%buildOutputDir%\Debug" /to="%finalDir%\bin\%platformName%"

	rem セットヘッダのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\tbbset.h" /to="%finalDir%\include\"

	rem Copyバッチのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\TbbCopy.bat" /to="%finalDir%\"

	rem バージョン番号ファイル追加
	type nul > %finalDir%\TBB_%tbbVersion%
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
