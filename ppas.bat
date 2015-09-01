@echo off
SET THEFILE=saveme.exe
echo Linking %THEFILE%
Z:\mnt\bambini\Public\apps\lazarus\fpc\2.6.4\bin\i386-win32\ld.exe -b pei-i386 -m i386pe  --gc-sections   --subsystem windows --entry=_WinMainCRTStartup    -o saveme.exe link.res
if errorlevel 1 goto linkend
Z:\mnt\bambini\Public\apps\lazarus\fpc\2.6.4\bin\i386-win32\postw32.exe --subsystem gui --input saveme.exe --stack 16777216
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
