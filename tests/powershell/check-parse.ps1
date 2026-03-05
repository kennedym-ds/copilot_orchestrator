$path = Join-Path $PSScriptRoot 'Test-AgentTooling.Tests.ps1'
$bytes = [System.IO.File]::ReadAllBytes($path)
# Show BOM
Write-Output "BOM: $($bytes[0].ToString('X2')) $($bytes[1].ToString('X2')) $($bytes[2].ToString('X2'))"
Write-Output "File size: $($bytes.Length) bytes"

# Parse check
$tokens = $null
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) {
    foreach ($e in $errors) {
        Write-Output "Parse error: $($e.Message) at line $($e.Extent.StartLineNumber) col $($e.Extent.StartColumnNumber)"
    }
} else {
    Write-Output "No parse errors found."
}

# Dump hex of line 32 area
$text = [System.IO.File]::ReadAllText($path)
$lines = $text -split "`r?`n"
for ($ln = 30; $ln -le 34; $ln++) {
    $l = $lines[$ln]
    $hex = ($l.ToCharArray() | ForEach-Object { ([int]$_).ToString('X2') }) -join ' '
    Write-Output "Line $($ln+1) hex: $hex"
    Write-Output "Line $($ln+1) txt: $l"
}
