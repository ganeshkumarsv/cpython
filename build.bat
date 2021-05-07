if not exist c:\mnt\ goto nomntdir
@echo c:\mnt found, continuing
cd c:\mnt

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
goto :EOF

:nomntdir
@echo directory not mounted, parameters incorrect
exit /b 1
goto :EOF