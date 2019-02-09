@echo off

SET "DEPS_ROOT=%~dp0"

cd /D libogg
cd win32

:: upgrade solution files
rmdir /S /Q VS2017 > nul
xcopy VS2015 VS2017 /E /H /K /I > nul
cd VS2017

:: we have to manually wait for the upgrade process to finish because devenv is a GUI process
devenv.exe libogg_dynamic.sln /Upgrade
devenv.exe libogg_static.sln /Upgrade

echo Upgrading solution files...
goto check

:wait
ping -n 2 127.0.0.1 > nul

:check
:: we upgrade two solution files so we wait for the second log to appear
if not exist UpgradeLog2.htm GOTO wait

:build
echo Upgrade done?

rmdir /S /Q x64 > nul

::msbuild libogg_static.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild libogg_static.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

mkdir include\ogg > nul

copy /Y libogg\include\ogg\*.h include\ogg\

copy /Y libogg\win32\VS2017\x64\Release\*.lib lib64\
copy /Y libogg\win32\VS2017\x64\Release\*.pdb lib64\
