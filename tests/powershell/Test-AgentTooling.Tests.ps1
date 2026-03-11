# Pester v5 tests to enforce required tooling and structural requirements on all agents.

BeforeDiscovery {
    $repoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    $agentsPath = Join-Path $repoRoot ".github/agents"
    $agentFiles = @()
    if (Test-Path -LiteralPath $agentsPath) {
        $agentFiles = @(Get-ChildItem -Path $agentsPath -Filter '*.agent.md' -File -ErrorAction SilentlyContinue)
    }

    # Read-only / analysis agents are excluded from edit and execute requirements.
    # See: artifacts/specs/agent-skill-quality-review/spec.md — REQ-F-006 least-privilege scoping.
    $readOnlyAgentNames = @(
        'planner',
        'reviewer',
        'researcher',
        'security',
        'performance',
        'accessibility',
        'observability',
        'red-team',
        'rubber-duck',
        'visualizer',
        'design'
    )

    # Agents with ## Workflow normalized in Phase 2-4.
    $workflowNormalizedAgents = @(
        'conductor',
        'planner',
        'implementer',
        'reviewer',
        'researcher',
        'spec',
        'security',
        'performance',
        'accessibility',
        'docs',
        'observability',
        'deployment',
        'red-team',
        'test',
        'lint',
        'maintainer',
        'github-ops',
        'design',
        'beast-mode',
        'gui-tester',
        'rubber-duck',
        'visualizer',
        'terraform',
        'bicep',
        'translation-conductor',
        'translator',
        'translation-analyzer',
        'translation-validator',
        'translation-styler'
    )

    # Agents with ## Output Contract normalized in Phase 2-4.
    $outputContractAgents = @(
        'conductor',
        'planner',
        'implementer',
        'reviewer',
        'researcher',
        'spec',
        'security',
        'performance',
        'accessibility',
        'docs',
        'observability',
        'deployment',
        'red-team',
        'test',
        'lint',
        'maintainer',
        'github-ops',
        'design',
        'beast-mode',
        'gui-tester',
        'rubber-duck',
        'visualizer',
        'terraform',
        'bicep',
        'translation-conductor',
        'translator',
        'translation-analyzer',
        'translation-validator',
        'translation-styler'
    )
}

Describe "Agent Tooling Requirements" -Tag 'tooling' {
    BeforeAll {
        $repoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        $agentsPath = Join-Path $repoRoot ".github/agents"
        $agentFileCount = @(Get-ChildItem -Path $agentsPath -Filter '*.agent.md' -File -ErrorAction SilentlyContinue).Count
    }

    It "Agents directory exists" {
        Test-Path -LiteralPath $agentsPath | Should -BeTrue
    }

    It "Found at least one agent file" {
        $agentFileCount | Should -BeGreaterThan 0
    }

    Context "<_>" -ForEach $agentFiles {
        BeforeAll {
            $content = Get-Content -LiteralPath $_.FullName -Raw
            $toolsLine = ''
            if ($content -match '(?m)^tools:\s*\[([^\]]+)\]') {
                $toolsLine = $Matches[1]
            }
        }

        It "has a tools declaration" {
            $toolsLine | Should -Not -BeNullOrEmpty
        }

        It "includes agent tool" {
            $toolsLine | Should -Match '\bagent\b'
        }

        It "includes read tool" {
            $toolsLine | Should -Match '\bread\b'
        }

        It "includes edit tool (role-appropriate)" -Skip:($readOnlyAgentNames -contains ($_.BaseName -replace '\.agent$')) {
            $toolsLine | Should -Match '\bedit\b'
        }

        It "includes execute tool (role-appropriate)" -Skip:($readOnlyAgentNames -contains ($_.BaseName -replace '\.agent$')) {
            $toolsLine | Should -Match '\bexecute\b'
        }
    }
}

Describe "Agent Structural Requirements" -Tag 'structure' {
    BeforeAll {
        $repoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        $agentsPath = Join-Path $repoRoot ".github/agents"
    }

    Context "<_>" -ForEach $agentFiles {
        BeforeAll {
            $content = Get-Content -LiteralPath $_.FullName -Raw
        }

        It "has a Boundaries section" {
            $content | Should -Match '(?m)^## Boundaries'
        }

        It "has a Delegation section" {
            $content | Should -Match '(?m)^## Delegation'
        }

        It "has a Workflow section" -Skip:($workflowNormalizedAgents -notcontains ($_.BaseName -replace '\.agent$')) {
            $content | Should -Match '(?m)^## Workflow'
        }

        It "has an Output Contract section" -Skip:($outputContractAgents -notcontains ($_.BaseName -replace '\.agent$')) {
            $content | Should -Match '(?m)^## Output Contract'
        }
    }
}
