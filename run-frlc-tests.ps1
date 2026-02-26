# run-frlc-tests.ps1
# Usage: Run this script from PowerShell. Requires SBCL installed.

$sbcl = Get-Command sbcl -ErrorAction SilentlyContinue
$sbclPath = $null
if ($sbcl) {
    $sbclPath = $sbcl.Source
} else {
    $defaultSbcl = "C:\Program Files\Steel Bank Common Lisp\sbcl.exe"
    if (Test-Path $defaultSbcl) {
        $sbclPath = $defaultSbcl
    }
}

if (-not $sbclPath) {
    Write-Error "sbcl not found in PATH and default install was not found. Install SBCL (https://www.sbcl.org/) or add sbcl.exe to PATH."
    exit 1
}

# Ensure script runs from project root
if ($PSScriptRoot) { Set-Location $PSScriptRoot }

Write-Host "Running FRLC tests with sbcl..."

# Build argument string properly
$args = @(
    "--noinform",
    "--load", "frlc-system/frlc.lisp",
    "--eval", '(in-package :frlc)',
    "--eval", '(initialize-frlc)',
    "--eval", '(load "frlc-system/tests.lisp")',
    "--eval", '(run-tests)',
    "--quit"
)

& $sbclPath @args

if ($LASTEXITCODE -ne 0) { Write-Error "SBCL exited with code $LASTEXITCODE" }
else { Write-Host "FRLC tests finished." }