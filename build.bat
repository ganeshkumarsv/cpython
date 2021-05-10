if not exist c:\mnt\ goto nomntdir
@echo c:\mnt found, continuing
cd c:\mnt  || exit /b 2
mkdir build-out
if not exist build-out exit /b 3

set platf=Win32

if "%TARGET_ARCH%" == "x64" (
    @echo IN x64 BRANCH
    call %VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvars64.bat
    set platf=x64
)

if "%TARGET_ARCH%" == "x86" (
    @echo IN x86 BRANCH
    call %VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvars32.bat
)

msbuild .\PCbuild\python.vcxproj /p:Configuration=Release /p:Platform=%platf%
copy .\PCbuild\*.dll build-out || exit /b 4
copy .\PCbuild\*.exe build-out || exit /b 5
copy .\PCbuild\*.exp build-out || exit /b 6
copy .\PCbuild\*.lib build-out || exit /b 7
copy .\PCbuild\*.pdb build-out || exit /b 8
copy .\PCbuild\*.pyd build-out || exit /b 9
goto :EOF

:nomntdir
@echo directory not mounted, parameters incorrect
exit /b 1
goto :EOF