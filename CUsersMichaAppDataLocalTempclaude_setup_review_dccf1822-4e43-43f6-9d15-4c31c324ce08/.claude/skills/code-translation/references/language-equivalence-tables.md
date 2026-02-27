# Language Equivalence Tables

Quick-reference mapping tables for cross-language translation patterns.

## Python ↔ TypeScript

### Data Types

| Python | TypeScript | Notes |
|--------|-----------|-------|
| `str` | `string` | |
| `int` | `number` | TS has no int/float distinction |
| `float` | `number` | |
| `bool` | `boolean` | |
| `None` | `null \| undefined` | Use `null` for explicit absence |
| `list[T]` | `T[]` or `Array<T>` | |
| `dict[K, V]` | `Record<K, V>` or `Map<K, V>` | `Record` for plain objects |
| `tuple[A, B]` | `[A, B]` | TS tuple syntax |
| `set[T]` | `Set<T>` | |
| `Optional[T]` | `T \| null` | Or `T \| undefined` |
| `Union[A, B]` | `A \| B` | |
| `Any` | `any` or `unknown` | Prefer `unknown` in TS |
| `TypedDict` | `interface` | |
| `dataclass` | `class` or `interface` | |
| `Enum` | `enum` | |

### Control Flow

| Python | TypeScript |
|--------|-----------|
| `if x:` | `if (x) {` |
| `elif:` | `} else if () {` |
| `for x in items:` | `for (const x of items) {` |
| `for i, x in enumerate(items):` | `items.forEach((x, i) => {` |
| `while True:` | `while (true) {` |
| `try: ... except E as e:` | `try { } catch (e: E) {` |
| `with open(f) as fh:` | `using` or try/finally |
| `match x:` (3.10+) | `switch (x) {` |

### Common Patterns

| Python | TypeScript |
|--------|-----------|
| `[x for x in items if cond]` | `items.filter(x => cond).map(x => ...)` |
| `{k: v for k, v in ...}` | `Object.fromEntries(...)` |
| `lambda x: x + 1` | `(x: number) => x + 1` |
| `async def fn():` | `async function fn(): Promise<T>` |
| `await asyncio.gather(*tasks)` | `await Promise.all(tasks)` |
| `@decorator` | No native equivalent — use HOF or class decorator |
| `__init__(self, ...)` | `constructor(...)` |
| `@property` | `get propName()` |
| `raise ValueError(...)` | `throw new Error(...)` |
| `isinstance(x, T)` | Type guards: `x is T` |

### Module System

| Python | TypeScript |
|--------|-----------|
| `import module` | `import * as module from './module'` |
| `from module import func` | `import { func } from './module'` |
| `from module import *` | Avoid; use named imports |
| `__init__.py` | `index.ts` barrel exports |
| `if __name__ == '__main__':` | Top-level execution or `main()` |

---

## PowerShell ↔ Bash

### Variables and Types

| PowerShell | Bash | Notes |
|------------|------|-------|
| `$var = "value"` | `var="value"` | No spaces around `=` in Bash |
| `[string]$var` | N/A | Bash is untyped |
| `$null` | `""` or unset | |
| `$true` / `$false` | `true` / `false` | Bash uses command exit codes |
| `@("a", "b")` | `("a" "b")` | Bash arrays |
| `@{key="val"}` | `declare -A map; map[key]="val"` | Bash associative arrays |
| `$env:VAR` | `$VAR` | Environment variables |
| `$PSScriptRoot` | `$(dirname "$0")` | Script directory |
| `$args` | `$@` | All arguments |
| `$_` (pipeline) | N/A | Use `xargs` or `while read` |

### Control Flow

| PowerShell | Bash |
|------------|------|
| `if ($x -eq 5) { }` | `if [ "$x" -eq 5 ]; then ... fi` |
| `-eq`, `-ne`, `-gt`, `-lt` | `-eq`, `-ne`, `-gt`, `-lt` |
| `-and`, `-or`, `-not` | `&&`, `\|\|`, `!` |
| `foreach ($x in $items) { }` | `for x in "${items[@]}"; do ... done` |
| `switch ($x) { }` | `case "$x" in ... esac` |
| `try { } catch { }` | `trap` or `set -e` |
| `1..10` (range) | `{1..10}` or `seq 1 10` |

### Common Patterns

| PowerShell | Bash |
|------------|------|
| `Get-Content file.txt` | `cat file.txt` |
| `Set-Content -Path f -Value v` | `echo "v" > f` |
| `Test-Path $path` | `[ -e "$path" ]` |
| `Get-ChildItem -Recurse` | `find . -type f` |
| `Select-String -Pattern "x"` | `grep "x"` |
| `ForEach-Object { $_ }` | `while read -r line; do ... done` |
| `Where-Object { $_.Name }` | `grep` / `awk` |
| `Sort-Object` | `sort` |
| `Measure-Object -Line` | `wc -l` |
| `Join-Path $a $b` | `"$a/$b"` |
| `Write-Host "msg"` | `echo "msg"` |
| `Write-Error "msg"` | `echo "msg" >&2` |
| `Exit 1` | `exit 1` |

### Functions

| PowerShell | Bash |
|------------|------|
| `function Get-Data { param($x) ... }` | `get_data() { local x=$1; ... }` |
| `return $value` | `echo "$value"` (capture via `$(...)`) |
| `[CmdletBinding()] param(...)` | `getopts` or manual parsing |
| `[Parameter(Mandatory)]` | `${1:?'arg required'}` |

### Error Handling

| PowerShell | Bash |
|------------|------|
| `$ErrorActionPreference = 'Stop'` | `set -euo pipefail` |
| `try { } catch { $_.Exception }` | `trap 'handler' ERR` |
| `-ErrorAction SilentlyContinue` | `command 2>/dev/null` |
| `$LASTEXITCODE` | `$?` |
