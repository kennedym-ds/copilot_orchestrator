$path = Join-Path $PSScriptRoot 'Test-AgentTooling.Tests.ps1'
$bytes = [System.IO.File]::ReadAllBytes($path)

# Look for em dashes, zero-width chars, or other problematic chars
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
for ($i = 0; $i -lt $text.Length; $i++) {
    $code = [int][char]$text[$i]
    if ($code -gt 127) {
        # Find line number
        $before = $text.Substring(0, $i)
        $lineNum = ($before.Split("`n")).Count
        Write-Output "NonASCII at byte offset ~$i, line $lineNum`: U+$($code.ToString('X4')) = $([char]$code)"
    }
}

# Just dump all bytes in the file as hex, looking around byte 900-1000
Write-Output ""
Write-Output "Raw bytes around 'runCommands' area:"
$searchStr = "runCommands"
$searchBytes = [System.Text.Encoding]::ASCII.GetBytes($searchStr)
for ($i = 0; $i -lt ($bytes.Length - $searchBytes.Length); $i++) {
    $match = $true
    for ($j = 0; $j -lt $searchBytes.Length; $j++) {
        if ($bytes[$i + $j] -ne $searchBytes[$j]) { $match = $false; break }
    }
    if ($match) {
        $start = [Math]::Max(0, $i - 30)
        $end = [Math]::Min($bytes.Length - 1, $i + 50)
        Write-Output "Found '$searchStr' at byte offset $i"
        $hexChunk = ($bytes[$start..$end] | ForEach-Object { $_.ToString('X2') }) -join ' '
        $txtChunk = [System.Text.Encoding]::UTF8.GetString($bytes[$start..$end]) -replace "`r", '<CR>' -replace "`n", '<LF>'
        Write-Output "Hex: $hexChunk"
        Write-Output "Txt: $txtChunk"
    }
}
