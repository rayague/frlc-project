@echo off
cd /d "%~dp0"
echo Lancement de la demonstration FRLC...
echo.
"C:\Program Files\Steel Bank Common Lisp\sbcl.exe" --noinform --load demo.lisp --quit
echo.
pause
