# Pester v5 tests to enforce required tooling on all agents

BeforeDiscovery {
    $repoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    $agentsPath = Join-Path $repoRoot ".github/agents"
    $agentFiles = @()
    if (Test-Path -LiteralPath $agentsPath) {
        $agentFiles = @(Get-ChildItem -Path $agentsPath -Filter '*.agent.md' -File -ErrorAction SilentlyContinue)
    }
}

Describe "Agent Tooling Requirements" -Tag 'tooling' {
    BeforeAll {
        $repoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        $agentsPath = Join-Path $repoRoot ".github/agents"
    }

    It "Agents directory exists" {
        Test-Path -LiteralPath $agentsPath | Should -BeTrue
    }

    It "Found at least one agent file" {
        $agentFiles = Get-ChildItem -Path $agentsPath -Filter '*.agent.md' -File -ErrorAction SilentlyContinue
        $agentFiles.Count | Should -BeGreaterThan 0
    }

    Context "<_>" -ForEach $agentFiles {
        BeforeAll {
            $content = Get-Content -LiteralPath $_.FullName -Raw
        }

        It "includes agent tool" {
            $content | Should -Match '(?s)tools:\s*\[.*\bagent\b'
        }

        It "includes edit tool" {
            $content | Should -Match '(?s)tools:[\s\S]*edit'
        }

        It "includes execute tool" {
            $content | Should -Match '(?s)tools:[\s\S]*execute'
        }
    }
}
