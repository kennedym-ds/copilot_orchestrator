$settingsPath = Join-Path $env:APPDATA 'Code\User\settings.json'
if (-not (Test-Path $settingsPath)) {
    Write-Error "Settings file not found: $settingsPath"
    exit 2
}

$json = Get-Content $settingsPath -Raw | ConvertFrom-Json

Describe 'Planner Visibility - Phase 1' {
    Context 'User settings' {
        It 'settings file exists' {
            if (-not (Test-Path $settingsPath)) { throw "Settings file not found: $settingsPath" }
        }

        It 'chat.agentFilesLocations contains at least one tilde path' {
            $locations = $json.'chat.agentFilesLocations'
            if ($null -eq $locations) { throw "chat.agentFilesLocations missing in settings" }
            $prop = ($locations | Get-Member -MemberType NoteProperty | Select-Object -First 1 -ExpandProperty Name)
            if ($prop -notmatch '^~') { throw "Agent path is not a tilde path: $prop" }
        }
    }

    Context 'Agent discovery' {
        It 'tilde path resolves to an existing directory' {
            # Resolve a canonical tilde path used for global agent discovery
            $tilde = "~\copilot_orchestrator\.github\agents"
            $resolved = Resolve-Path $tilde -ErrorAction SilentlyContinue
            if (-not $resolved) { throw "Tilde path did not resolve: $tilde" }
        }

        It 'planner.agent.md exists in the agents folder' {
            $tilde = "~\copilot_orchestrator\.github\agents"
            $resolved = (Resolve-Path $tilde -ErrorAction Stop).Path
            if (-not (Test-Path (Join-Path $resolved 'planner.agent.md'))) { throw "planner.agent.md not found in $resolved" }
        }
    }
}
