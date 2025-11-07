[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [int]$MaxLineLength = 400,

    [Parameter(Mandatory = $false)]
    [switch]$FailOnWarning,

    [Parameter(Mandatory = $false)]
    [string[]]$Exclude = @()
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $RepositoryRoot)) {
    throw "Repository root '$RepositoryRoot' was not found."
}

$resolvedRoot = (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath
$issues = New-Object System.Collections.Generic.List[object]

function Add-Issue {
    param(
        [System.Collections.Generic.List[object]]$Collector,
        [string]$File,
        [int]$LineNumber,
        [string]$Severity,
        [string]$Message
    )

    $Collector.Add([PSCustomObject]@{
            File       = $File
            LineNumber = $LineNumber
            Severity   = $Severity
            Message    = $Message
        }) | Out-Null
}

function Should-ExcludeFile {
    param(
        [string]$FullPath,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ([string]::IsNullOrWhiteSpace($pattern)) {
            continue
        }

        if ($FullPath -like (Join-Path $resolvedRoot $pattern)) {
            return $true
        }
    }

    return $false
}

$markdownFiles = Get-ChildItem -Path $resolvedRoot -Recurse -File -Include *.md, *.instructions.md |
    Where-Object {
        $_.FullName -notmatch "\\\.git\\" -and
        $_.FullName -notmatch "\\node_modules\\" -and
        $_.FullName -notmatch "\\artifacts\\" -and
        -not (Should-ExcludeFile -FullPath $_.FullName -Patterns $Exclude)
    }

foreach ($file in $markdownFiles) {
    $relative = $file.FullName.Replace($resolvedRoot + [IO.Path]::DirectorySeparatorChar, '')
    $lines = Get-Content -LiteralPath $file.FullName

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1

        if ($line.Length -gt $MaxLineLength) {
            Add-Issue -Collector $issues -File $relative -LineNumber $lineNumber -Severity 'Warning' -Message "Line length $($line.Length) exceeds maximum $MaxLineLength characters."
        }

        if ($line -match '\s+$' -and $line.TrimEnd().Length -lt $line.Length) {
            Add-Issue -Collector $issues -File $relative -LineNumber $lineNumber -Severity 'Warning' -Message 'Trailing whitespace detected.'
        }

        if ($line -match "`t") {
            Add-Issue -Collector $issues -File $relative -LineNumber $lineNumber -Severity 'Warning' -Message 'Tab character detected; prefer spaces.'
        }
    }
}

if ($issues.Count -eq 0) {
    Write-Host 'Markdown lint checks passed.' -ForegroundColor Green
    exit 0
}

$errors = @($issues | Where-Object { $_.Severity -eq 'Error' })
$warnings = @($issues | Where-Object { $_.Severity -eq 'Warning' })

Write-Host "Lint findings:" -ForegroundColor Yellow
$issues | Sort-Object File, LineNumber | ForEach-Object {
    Write-Host "  [$($_.Severity)] $($_.File):$($_.LineNumber) - $($_.Message)"
}

if ($FailOnWarning.IsPresent -and $warnings.Count -gt 0) {
    Write-Host "Failing due to $($warnings.Count) warning(s)." -ForegroundColor Red
    exit 1
}

if ($errors.Count -gt 0) {
    Write-Host "Found $($errors.Count) error(s)." -ForegroundColor Red
    exit 1
}

exit 0
