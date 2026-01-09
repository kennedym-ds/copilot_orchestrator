[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location).Path,

    [string]$OutputPath,
    [switch]$FailOnThreshold,
    [int]$Threshold = 150000,
    [string]$ConfigPath,
    [hashtable]$CategoryThresholds
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path '$Path' was not found."
}

$TargetPath = (Resolve-Path -LiteralPath $Path).ProviderPath
$config = $null

if ($ConfigPath) {
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Config path '$ConfigPath' was not found."
    }

    try {
        $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "Failed to parse JSON config from '$ConfigPath': $($_.Exception.Message)"
    }
}

$effectiveThreshold = $Threshold
$effectiveFailOnThreshold = $FailOnThreshold.IsPresent
$effectiveCategoryThresholds = @{}

if ($config) {
    if ($config.totalThreshold) {
        $effectiveThreshold = [int]$config.totalThreshold
    }

    if ($null -ne $config.failOnThreshold) {
        $effectiveFailOnThreshold = [bool]$config.failOnThreshold
    }

    if ($config.categoryThresholds) {
        foreach ($entry in $config.categoryThresholds.PSObject.Properties) {
            $effectiveCategoryThresholds[$entry.Name] = [int]$entry.Value
        }
    }
}

if ($CategoryThresholds) {
    foreach ($key in $CategoryThresholds.Keys) {
        $effectiveCategoryThresholds[$key] = [int]$CategoryThresholds[$key]
    }
}

if ($FailOnThreshold.IsPresent) {
    $effectiveFailOnThreshold = $true
}

function Get-TokenEstimate {
    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return 0
    }

    $length = $Text.Length
    return [math]::Ceiling($length / 4.0)
}

function New-TokenRecord {
    param(
        [string]$FilePath,
        [string]$Category,
        [string]$Content
    )

    $tokens = Get-TokenEstimate -Text $Content
    $words = if ($Content) { ($Content -split '\s+' | Where-Object { $_.Length -gt 0 }).Count } else { 0 }
    $chars = if ($Content) { $Content.Length } else { 0 }

    return [PSCustomObject]@{
        File     = $FilePath
        Category = $Category
        Tokens   = $tokens
        Words    = $words
        Chars    = $chars
    }
}

$records = New-Object System.Collections.Generic.List[object]

$instructionFiles = Get-ChildItem -Path $TargetPath -Recurse -Filter '*.instructions.md' -File -ErrorAction SilentlyContinue
foreach ($file in $instructionFiles) {
    $relative = $file.FullName.Replace($TargetPath + [IO.Path]::DirectorySeparatorChar, '')
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $records.Add((New-TokenRecord -FilePath $relative -Category 'instructions' -Content $content)) | Out-Null
}

$agentFiles = @()
$agentFiles += Get-ChildItem -Path (Join-Path $TargetPath '.github/agents') -Filter '*.agent.md' -File -ErrorAction SilentlyContinue
$agentFiles += Get-ChildItem -Path (Join-Path $TargetPath '.github/chatmodes') -Filter '*.chatmode.md' -File -ErrorAction SilentlyContinue
foreach ($file in $agentFiles) {
    $relative = $file.FullName.Replace($TargetPath + [IO.Path]::DirectorySeparatorChar, '')
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $records.Add((New-TokenRecord -FilePath $relative -Category 'agents' -Content $content)) | Out-Null
}

$promptFiles = Get-ChildItem -Path (Join-Path $TargetPath '.github/prompts') -Filter '*.prompt.md' -Recurse -File -ErrorAction SilentlyContinue
foreach ($file in $promptFiles) {
    $relative = $file.FullName.Replace($TargetPath + [IO.Path]::DirectorySeparatorChar, '')
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $records.Add((New-TokenRecord -FilePath $relative -Category 'prompts' -Content $content)) | Out-Null
}

$docFiles = Get-ChildItem -Path (Join-Path $TargetPath 'docs') -Filter '*.md' -Recurse -File -ErrorAction SilentlyContinue
foreach ($file in $docFiles) {
    $relative = $file.FullName.Replace($TargetPath + [IO.Path]::DirectorySeparatorChar, '')
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $records.Add((New-TokenRecord -FilePath $relative -Category 'docs' -Content $content)) | Out-Null
}

$totals = $records | Group-Object -Property Category | ForEach-Object {
    [PSCustomObject]@{
        Category = $_.Name
        Tokens   = ($_.Group | Measure-Object -Property Tokens -Sum).Sum
    }
}

$totalTokens = ($records | Measure-Object -Property Tokens -Sum).Sum
$categoryBreaches = @()

foreach ($total in $totals) {
    if ($effectiveCategoryThresholds.ContainsKey($total.Category)) {
        $limit = $effectiveCategoryThresholds[$total.Category]
        if ($total.Tokens -gt $limit) {
            $categoryBreaches += [PSCustomObject]@{
                Category = $total.Category
                Tokens   = $total.Tokens
                Limit    = $limit
            }
        }
    }
}

# Check per-file token limits
$fileBreaches = @()
$maxFileTokens = if ($config -and $config.maxFileTokens) { [int]$config.maxFileTokens } else { 10000 }

foreach ($record in $records) {
    if ($record.Tokens -gt $maxFileTokens) {
        $fileBreaches += [PSCustomObject]@{
            File     = $record.File
            Category = $record.Category
            Tokens   = $record.Tokens
            Limit    = $maxFileTokens
        }
    }
}

Write-Host "Token budget summary for $TargetPath" -ForegroundColor Cyan
$totals | Sort-Object -Property Category | ForEach-Object {
    Write-Host ("  {0,-15} {1,8}" -f $_.Category, $_.Tokens)
}
Write-Host ("  {0,-15} {1,8}" -f 'total', $totalTokens) -ForegroundColor DarkGray
Write-Host "  (Note: Total is informational; per-file limits are enforced)" -ForegroundColor DarkGray
Write-Host ""

if ($fileBreaches.Count -gt 0) {
    Write-Warning ("Found {0} file(s) exceeding per-file token limit of {1}:" -f $fileBreaches.Count, $maxFileTokens)
    foreach ($breach in $fileBreaches | Sort-Object -Property Tokens -Descending) {
        $overage = $breach.Tokens - $breach.Limit
        $pct = [math]::Round(($overage / $breach.Limit) * 100, 1)
        Write-Warning ("  {0} ({1}): {2} tokens (+{3} / +{4}%)" -f $breach.File, $breach.Category, $breach.Tokens, $overage, $pct)
    }
    Write-Host ""
}

# Show top 5 largest files for awareness
Write-Host "Largest files by token count:" -ForegroundColor Cyan
$records | Sort-Object -Property Tokens -Descending | Select-Object -First 5 | ForEach-Object {
    $status = if ($_.Tokens -gt $maxFileTokens) { "WARN" } else { "OK" }
    Write-Host ("  [{0}] {1,-50} {2,6} tokens" -f $status, $_.File, $_.Tokens)
}
Write-Host ""

if ($totalTokens -gt $effectiveThreshold) {
    Write-Host "INFO: Total token count $totalTokens exceeds informational threshold $effectiveThreshold." -ForegroundColor DarkGray
    Write-Host "      (Per-file limits are the primary enforcement mechanism)" -ForegroundColor DarkGray
}

foreach ($breach in $categoryBreaches) {
    Write-Warning ("Category '{0}' total exceeds threshold {1} with {2} tokens (informational only)." -f $breach.Category, $breach.Limit, $breach.Tokens)
}

if ($OutputPath) {
    $output = [PSCustomObject]@{
        root         = $TargetPath
        summary      = $totals
        totalTokens  = $totalTokens
        files        = $records
        fileBreaches = $fileBreaches
        generatedAt  = (Get-Date).ToString('o')
        thresholds   = [PSCustomObject]@{
            total       = $effectiveThreshold
            categories  = $effectiveCategoryThresholds
            maxFileSize = $maxFileTokens
        }
    }

    $json = $output | ConvertTo-Json -Depth 6
    Set-Content -LiteralPath $OutputPath -Value $json
    Write-Host "Wrote token report to $OutputPath" -ForegroundColor Green
}

if ($effectiveFailOnThreshold -and $fileBreaches.Count -gt 0) {
    Write-Host "Per-file token limit exceeded. See warnings above." -ForegroundColor Red
    exit 1
}

if ($effectiveFailOnThreshold -and $categoryBreaches.Count -gt 0) {
    Write-Host "Category token counts exceeded (informational)." -ForegroundColor Yellow
}

exit 0
