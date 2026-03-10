# Pester tests to enforce required tooling on all agents

Describe "Agent Tooling Requirements" -Tag 'tooling' {
    $repoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    $agentsPath = Join-Path $repoRoot ".github/agents"
    It "Agents directory exists" {
        Test-Path -LiteralPath $agentsPath | Should Be $true
    }

    if (-not (Test-Path -LiteralPath $agentsPath)) {
        Write-Warning "Agents directory not found at $agentsPath -- skipping remaining tests."
        return
    }

    $agentFiles = Get-ChildItem -Path $agentsPath -Filter '*.agent.md' -File -ErrorAction SilentlyContinue
    It "Found at least one agent file" {
        $agentFiles.Count | Should BeGreaterThan 0
    }

    foreach ($agent in $agentFiles) {
        Context "$($agent.Name)" {
            $content = Get-Content -LiteralPath $agent.FullName -Raw

            It "includes agent tool" {
                $content | Should Match '(?s)tools:\s*\[.*\bagent\b'
            }

            It "includes edit tool" {
                $content | Should Match '(?s)tools:[\s\S]*edit'
            }

            It "includes execute tool" {
                $content | Should Match '(?s)tools:[\s\S]*execute'
            }
        }
    }
}
