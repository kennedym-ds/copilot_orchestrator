# PreToolUse semantic firewall — evaluates tool arguments against deny rules before execution.
# Returns {"decision":"deny","reason":"..."} to stdout to block the call; exits 0 silently to allow.
# VS Code stdin: {sessionId, hookEventName, tool_name, tool_input, cwd, ...}
#
# Rules are defined in instructions/compliance/semantic-firewall-rules.md.
# Deny events are appended to artifacts/sessions/hooks/semantic-firewall.jsonl.
#
# Closes gap G63 from artifacts/decisions/ADR-sota-2026-04-22-remaining-gaps.md.
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")

$h         = Read-HookInput
$ToolName  = if ($h.tool_name)  { [string]$h.tool_name }  else { '' }
$ToolInput = $h.tool_input   # PSCustomObject or null

# Flatten tool_input to a single string for pattern matching
function Get-ToolField {
    param([object]$Input, [string]$Field)
    if ($null -eq $Input) { return '' }
    if ($Field -eq '*') {
        # Serialize entire input as JSON for catch-all checks
        try { return ($Input | ConvertTo-Json -Compress -Depth 4) } catch { return [string]$Input }
    }
    $val = $Input.$Field
    if ($null -eq $val) { return '' }
    return [string]$val
}

function Write-Deny {
    param([string]$Rule, [string]$Reason)
    $log = [ordered]@{
        event    = 'PreToolUse.denied'
        rule     = $Rule
        tool     = $ToolName
        reason   = $Reason
        ts       = (Get-Date).ToString('o')
    }
    Write-HookEvent -Event 'semantic-firewall' -Payload $log
    [Console]::Out.WriteLine(($([ordered]@{ decision = 'deny'; reason = $Reason } | ConvertTo-Json -Compress)))
    exit 0
}

function Write-AllowOverride {
    param([string]$Pattern)
    $log = [ordered]@{
        event    = 'PreToolUse.allow-override'
        pattern  = $Pattern
        tool     = $ToolName
        ts       = (Get-Date).ToString('o')
    }
    Write-HookEvent -Event 'semantic-firewall' -Payload $log
}

# ---------------------------------------------------------------------------
# ALLOW list — check these first; if matched, skip deny rules and exit clean
# ---------------------------------------------------------------------------
$AllowPatterns = @(
    'Remove-Item.*artifacts/'
    'Remove-Item.*\.cache'
    'Remove-Item.*__pycache__'
)
$cmdField = Get-ToolField -Input $ToolInput -Field 'command'
foreach ($pat in $AllowPatterns) {
    if ($cmdField -imatch $pat) {
        Write-AllowOverride -Pattern $pat
        exit 0
    }
}

# ---------------------------------------------------------------------------
# DENY rules — each entry: [rule-id, tool-match, field, pattern, reason]
# ---------------------------------------------------------------------------
$DenyRules = @(
    # Category 1 — Destructive shell commands
    @('D01','execute','command', 'rm\s+-[rf]{1,2}\s+/',
      'Recursive delete of root-relative paths is blocked. Use explicit, scoped deletes.')
    @('D02','execute','command', 'Remove-Item.*-Recurse.*-Force\s+[/\\]',
      'Recursive forced remove of root-relative paths is blocked.')
    @('D03','execute','command', 'del\s+/[sfq]*\s+[a-z]:\\',
      'del /s /f on drive root is blocked.')
    @('D04','execute','command', 'format\s+[a-z]:',
      'Disk format commands are blocked.')
    @('D05','execute','command', 'rd\s+/[sq]*\s+[a-z]:\\',
      'rd /s on drive root is blocked.')

    # Category 2 — Secret and credential exfiltration
    @('E01','execute','command', '\$env:\w*(key|token|secret|password|pass|pwd|cred|apikey)',
      'Accessing secret-named env vars in a shell command requires explicit user approval.')
    @('E02','execute','command', 'printenv|Get-ChildItem\s+Env:\s*\||Env\s*\|\s*sort',
      'Bulk env dump detected.')
    @('E03','execute','command', 'cat\s+~/.ssh|Get-Content.*\.ssh|type.*id_rsa',
      'Reading SSH key files is blocked.')
    @('E04','execute','command', 'cmdkey\s+/list|credential\s+manager',
      'Reading Windows Credential Manager entries is blocked.')

    # Category 3 — Unsafe network fetch targets
    @('N01','fetch','url', '^file://',
      'Fetching file:// URIs is blocked (local file exfiltration risk).')
    @('N02','fetch','url', '\\\\[a-z0-9]',
      'UNC path fetch blocked (SMB share access).')
    @('N03','fetch','url', 'raw\.githubusercontent\.com.*\.(sh|ps1|py|exe|bat|cmd)',
      'Fetching raw executable scripts from GitHub without review is blocked. Download and review first.')
    @('N04','fetch','url', 'pastebin\.com|gist\.github\.com/[^/]+/[^/]+/raw',
      'Fetching raw content from paste sites or anonymous gists is blocked.')
    @('N05','execute','command', '(curl|wget|Invoke-WebRequest|iwr)\s+.*\.(exe|bat|ps1|sh|cmd)\s*\|\s*(sh|bash|pwsh|powershell)',
      'Curl-pipe-to-shell pattern is blocked. Download, review, then execute.')

    # Category 4 — Path traversal
    @('P01','*','path', '\.\.[/\\]',
      'Path traversal (../) in tool arguments is blocked.')
    @('P02','edit','path', '^\.\./|^/etc/|^/usr/|^C:\\Windows\\',
      'Editing files outside the workspace is blocked.')

    # Category 5 — Eval / code injection
    @('C01','execute','command', 'Invoke-Expression\s+\$|iex\s+\$|Invoke-Expression.*\(.*\)',
      'Invoke-Expression with a variable argument is blocked (code injection risk).')
    @('C02','execute','command', '\beval\b.*\$|\bexec\b.*\$',
      'eval/exec with variable content is blocked.')
)

foreach ($rule in $DenyRules) {
    $ruleId  = $rule[0]
    $toolPat = $rule[1]   # tool name pattern or '*'
    $field   = $rule[2]
    $pattern = $rule[3]
    $reason  = $rule[4]

    # Check tool name match
    $toolMatch = ($toolPat -eq '*') -or ($ToolName -ieq $toolPat)
    if (-not $toolMatch) { continue }

    # Extract relevant field from tool_input
    $value = Get-ToolField -Input $ToolInput -Field $field
    if ([string]::IsNullOrEmpty($value)) { continue }

    # Evaluate pattern
    if ($value -imatch $pattern) {
        Write-Deny -Rule $ruleId -Reason $reason
        # Write-Deny calls exit 0; this line is unreachable but keeps PSScriptAnalyzer happy
        return
    }
}

# No rule matched — allow silently (no stdout output required)
exit 0
