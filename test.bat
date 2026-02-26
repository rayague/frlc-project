@echo off
cd /d "%~dp0"
echo Running FRLC tests...
"C:\Program Files\Steel Bank Common Lisp\sbcl.exe" --noinform --load run-all.lisp --quit
echo.
if %ERRORLEVEL% neq 0 (
    echo ERROR: Tests failed with code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
) else (
    echo SUCCESS: All tests passed!
)
