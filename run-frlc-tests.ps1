# run-frlc-tests.ps1
# Usage: Run this script from PowerShell. Requires SBCL in PATH.

$sbcl = Get-Command sbcl -ErrorAction SilentlyContinue
if (-not $sbcl) {
    Write-Error "sbcl not found in PATH. Install SBCL (https://www.sbcl.org/) or add sbcl.exe to PATH."
    exit 1
}

# Ensure script runs from project root
if ($PSScriptRoot) { Set-Location $PSScriptRoot }

Write-Host "Running FRLC tests with sbcl..."
& sbcl --noinform --load "frlc-system/frlc.lisp" --eval "(in-package :frlc)" --eval "(initialize-frlc)" --eval "(load \"frlc-system/tests.lisp\")" --eval "(run-tests)" --quit

if ($LASTEXITCODE -ne 0) { Write-Error "SBCL exited with code $LASTEXITCODE" }
else { Write-Host "FRLC tests finished." }