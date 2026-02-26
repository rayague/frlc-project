@echo off
echo Running FRLC tests with sbcl...
"C:\Program Files\Steel Bank Common Lisp\sbcl.exe" --noinform --load frlc-system/frlc.lisp --eval "(in-package :frlc)" --eval "(initialize-frlc)" --eval "(load \"frlc-system/tests.lisp\")" --eval "(run-tests)" --eval "(format t \"Tests completed.~%\")" --quit
if %ERRORLEVEL% neq 0 (
    echo ERROR: SBCL exited with code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
echo FRLC tests finished.
