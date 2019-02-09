@echo off

SET "DEPS_ROOT=%~dp0"

cd /D %DEPS_ROOT%libvorbis
cd win32

:: upgrade solution files
rmdir /S /Q VS2017 > nul
xcopy VS2010 VS2017 /E /H /K /I
cd VS2017

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

::copy /Y libvorbis\win32\VS2017\libvorbis\x64\Release\*.lib lib64\
::copy /Y libvorbis\win32\VS2017\libvorbis\x64\Release\*.pdb lib64\
copy /Y libvorbis\win32\VS2017\libvorbisfile\x64\Release\*.lib lib64\
copy /Y libvorbis\win32\VS2017\libvorbisfile\x64\Release\*.pdb lib64\