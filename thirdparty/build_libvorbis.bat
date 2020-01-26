@echo off

:: setup build tools
where /Q cmake.exe
IF ERRORLEVEL 1 set "PATH=%PATH%;C:\Program Files\CMake\bin"
if not defined VCINSTALLDIR call "..\tools\vcvarsall.bat" x64

SET "DEPS_ROOT=%~dp0"
SET "INCLUDE_PATH=%DEPS_ROOT%include"
SET "LIB64_PATH=%DEPS_ROOT%lib64"

if not exist %INCLUDE_PATH% mkdir %INCLUDE_PATH%
if not exist %LIB64_PATH% mkdir %LIB64_PATH%

::build
cd /D %DEPS_ROOT%libvorbis
cd win32

:: upgrade solution files
rmdir /S /Q VS2019 > nul
xcopy VS2010 VS2019 /E /H /K /I
cd VS2019

:: we have to manually wait for the upgrade process to finish because devenv is a GUI process
devenv.exe vorbis_dynamic.sln /Upgrade
devenv.exe vorbis_static.sln /Upgrade

echo Upgrading solution files...
goto check

:wait
ping -n 2 127.0.0.1 > nul

:check
:: we upgrade two solution files so we wait for the second log to appear
if not exist UpgradeLog2.htm GOTO wait

:build
echo Upgrade done?

rmdir /S /Q libvorbis\x64 > nul
rmdir /S /Q libvorbisfile\x64 > nul

::msbuild libvorbis\libvorbis_static.vcxproj /p:Configuration=Debug /p:Platform=x64
::msbuild libvorbis\libvorbis_static.vcxproj /p:Configuration=Release /p:Platform=x64
::msbuild libvorbisfile\libvorbisfile_static.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild libvorbisfile\libvorbisfile_static.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

mkdir include\vorbis > nul

copy /Y libvorbis\include\vorbis\*.h include\vorbis\

::copy /Y libvorbis\win32\VS2019\libvorbis\x64\Release\*.lib lib64\
::copy /Y libvorbis\win32\VS2019\libvorbis\x64\Release\*.pdb lib64\
copy /Y libvorbis\win32\VS2019\libvorbisfile\x64\Release\*.lib lib64\
copy /Y libvorbis\win32\VS2019\libvorbisfile\x64\Release\*.pdb lib64\
