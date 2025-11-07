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

Write-Host "Token budget summary for $TargetPath" -ForegroundColor Cyan
$totals | Sort-Object -Property Category | ForEach-Object {
    Write-Host ("  {0,-15} {1,8}" -f $_.Category, $_.Tokens)
}
Write-Host ("  {0,-15} {1,8}" -f 'total', $totalTokens)

if ($totalTokens -gt $effectiveThreshold) {
    Write-Warning ("Total token count {0} exceeds threshold {1}." -f $totalTokens, $effectiveThreshold)
}

foreach ($breach in $categoryBreaches) {
    Write-Warning ("Category '{0}' exceeds threshold {1} with {2} tokens." -f $breach.Category, $breach.Limit, $breach.Tokens)
}

if ($effectiveFailOnThreshold -and $categoryBreaches.Count -gt 0) {
    Write-Host "Category token counts exceeded configured thresholds." -ForegroundColor Red
}

if ($OutputPath) {
    $output = [PSCustomObject]@{
        root        = $TargetPath
        summary     = $totals
        totalTokens = $totalTokens
        files       = $records
        generatedAt = (Get-Date).ToString('o')
        thresholds  = [PSCustomObject]@{
            total      = $effectiveThreshold
            categories = $effectiveCategoryThresholds
        }
    }

    $json = $output | ConvertTo-Json -Depth 6
    Set-Content -LiteralPath $OutputPath -Value $json
    Write-Host "Wrote token report to $OutputPath" -ForegroundColor Green
}

if ($effectiveFailOnThreshold -and $totalTokens -gt $effectiveThreshold) {
    Write-Host "Token count $totalTokens exceeds threshold $effectiveThreshold." -ForegroundColor Red
    exit 1
}

if ($effectiveFailOnThreshold -and $categoryBreaches.Count -gt 0) {
    exit 1
}

exit 0
