# Coverage Configuration Examples

## Jest (JavaScript / TypeScript)

```json
// jest.config.js or package.json
{
  "collectCoverage": true,
  "coverageDirectory": "coverage",
  "coverageReporters": ["text", "lcov", "clover"],
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    }
  },
  "collectCoverageFrom": [
    "src/**/*.{ts,tsx}",
    "!src/**/*.d.ts",
    "!src/**/index.ts"
  ]
}
```

## pytest (Python)

```ini
# pytest.ini or pyproject.toml [tool.pytest.ini_options]
[tool.pytest.ini_options]
addopts = "--cov=src --cov-report=term-missing --cov-fail-under=80"

[tool.coverage.run]
branch = true
source = ["src"]
omit = ["tests/*", "**/__init__.py"]

[tool.coverage.report]
show_missing = true
fail_under = 80
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "if __name__ == .__main__.",
]
```

## Pester (PowerShell)

```powershell
# pester.config.ps1
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = @('scripts/*.ps1')
$config.CodeCoverage.OutputFormat = 'JaCoCo'
$config.CodeCoverage.OutputPath = 'coverage/coverage.xml'
$config.CodeCoverage.CoveragePercentTarget = 80
$config.Output.Verbosity = 'Detailed'

Invoke-Pester -Configuration $config
```

## Key Metrics

| Metric | Description |
|--------|-------------|
| Line coverage | Percentage of lines executed during tests |
| Branch coverage | Percentage of conditional branches taken |
| Function coverage | Percentage of functions called |
| Statement coverage | Percentage of statements executed |
