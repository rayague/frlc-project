@echo off
cd /d "%~dp0"
echo Lancement de la demonstration Monde Tribal...
echo.
"C:\Program Files\Steel Bank Common Lisp\sbcl.exe" --noinform --load tribal-demo.lisp --quit
echo.
pause
