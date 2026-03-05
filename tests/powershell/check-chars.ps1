$bytes = [System.IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'Test-AgentTooling.Tests.ps1'))
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$lines = $text -split "`r?`n"
$line = $lines[31]
Write-Output "Line 32: $line"
Write-Output "Length: $($line.Length)"
for ($i = 0; $i -lt $line.Length; $i++) {
    $code = [int][char]$line[$i]
    if ($code -gt 127) {
        Write-Output "  NonASCII at pos $i`: U+$($code.ToString('X4'))"
    }
}
# Also check all lines for non-ASCII quotes
for ($ln = 0; $ln -lt $lines.Count; $ln++) {
    $l = $lines[$ln]
    for ($j = 0; $j -lt $l.Length; $j++) {
        $code = [int][char]$l[$j]
        if ($code -eq 0x201C -or $code -eq 0x201D -or $code -eq 0x2018 -or $code -eq 0x2019) {
            Write-Output "Smart quote at line $($ln+1), pos $j`: U+$($code.ToString('X4'))"
        }
    }
}
