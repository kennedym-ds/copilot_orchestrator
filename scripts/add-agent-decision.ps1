<#
.SYNOPSIS
  Create a durable memory entry under .agent-memory with consistent metadata.

.DESCRIPTION
  Writes a timestamped markdown file into `.agent-memory/` with a small YAML
  frontmatter block and the provided fact text. The script is idempotent and
  intended to be used by agents (or humans) to add short durable facts.
#>

param(
    [Parameter(Mandatory=$true)][string]$Subject,
    [Parameter(Mandatory=$true)][string]$Fact,
    [string]$Citations = "",
    [string]$Reason = "",
    [ValidateSet('architecture','process','security','ops','other')][string]$Category = 'other'
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$memDir = Join-Path $root "..\.agent-memory"
if (-not (Test-Path $memDir)) { New-Item -ItemType Directory -Path $memDir | Out-Null }

$ts = Get-Date -Format "yyyy-MM-dd-HHmmss"
$slug = ($Subject -replace '[^a-zA-Z0-9\-]','-').ToLower()
$file = Join-Path $memDir ("DEC-{0}-{1}.md" -f $ts, $slug)

$front = @()
$front += "---"
$front += "subject: $Subject"
$front += "fact: |"
$front += "  $Fact"
if ($Citations) { $front += "citations: $Citations" }
if ($Reason) { $front += "reason: |"; $front += "  $Reason" }
$front += "category: $Category"
$front += "created: $(Get-Date -Format o)"
$front += "---`n"

Set-Content -Path $file -Value ($front -join "`n") -Encoding UTF8
Add-Content -Path $file -Value "`n" -Encoding UTF8
Write-Output "Created durable memory entry: $file"
Write-Output $file
