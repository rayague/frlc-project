@echo off
cd /d "%~dp0"
echo Starting FRLC Web on http://127.0.0.1:8080/
echo Close this window to stop the server.
"C:\Program Files\Steel Bank Common Lisp\sbcl.exe" --noinform --load web-run.lisp
