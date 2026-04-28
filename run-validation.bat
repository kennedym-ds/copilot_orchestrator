@echo off
setlocal enabledelayedexpansion

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set TS=%%i
if not exist logs mkdir logs
set LOG=logs\validation-%TS%.log

echo Logging to %LOG%
echo Validation run started at %DATE% %TIME%> "%LOG%"

echo Running validate-copilot-assets...
echo Running validate-copilot-assets...>> "%LOG%"
powershell -NoProfile -File scripts\validate-copilot-assets.ps1 -RepositoryRoot . >> "%LOG%" 2>&1
if errorlevel 1 goto :fail

echo Running lint...
echo Running lint...>> "%LOG%"
powershell -NoProfile -File scripts\run-lint.ps1 -RepositoryRoot . >> "%LOG%" 2>&1
if errorlevel 1 goto :fail

echo Running smoke tests...
echo Running smoke tests...>> "%LOG%"
powershell -NoProfile -File scripts\run-smoke-tests.ps1 -RepositoryRoot . >> "%LOG%" 2>&1
if errorlevel 1 goto :fail

echo Running Pester (fast)...
echo Running Pester (fast)...>> "%LOG%"
powershell -NoProfile -Command "Invoke-Pester -Path tests -ExcludeTag Slow -Output Detailed" >> "%LOG%" 2>&1
if errorlevel 1 goto :fail

echo Running pytest...
echo Running pytest...>> "%LOG%"
python -m pytest tests/mcp/ -v >> "%LOG%" 2>&1
if errorlevel 1 goto :fail

echo Running token report...
echo Running token report...>> "%LOG%"
powershell -NoProfile -File scripts\token-report.ps1 -Path . >> "%LOG%" 2>&1
if errorlevel 1 goto :fail

echo All checks completed.
echo All checks completed.>> "%LOG%"
exit /b 0

:fail
echo Validation failed with exit code %ERRORLEVEL%.
echo Validation failed with exit code %ERRORLEVEL%.>> "%LOG%"
exit /b %ERRORLEVEL%
