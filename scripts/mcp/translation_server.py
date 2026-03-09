"""
Translation MCP Server — Model Context Protocol server for code translation workflows.

Provides tools, resources, and prompts for orchestrating repository-level code translation
between programming languages. Exposes dependency graph analysis, translation state management,
validation orchestration, and confidence scoring via the MCP protocol.

Usage:
    python scripts/mcp/translation_server.py

Requires:
    pip install mcp duckduckgo-search
"""

from mcp.server.fastmcp import FastMCP, Context
from mcp.types import ToolAnnotations
import json
import os
import re
from pathlib import Path
from typing import Optional

mcp = FastMCP("translation-server")

# ---------------------------------------------------------------------------
# In-memory state (persisted to artifacts/plans/translation/ on disk)
# ---------------------------------------------------------------------------
translation_state = {
    "source": {"language": None, "path": None, "total_files": 0, "total_loc": 0},
    "target": {"language": None, "path": None},
    "modules": [],
    "dependency_graph": {"layers": []},
    "framework_mappings": {},
    "package_mappings": {},
    "confidence_scores": {},
    "phase": "idle",  # idle | discovery | foundation | business_logic | integration | qa | documentation | complete
    "progress": {"translated": 0, "validated": 0, "total": 0},
}


# ---------------------------------------------------------------------------
# TOOLS — 8 tools for translation workflow
# ---------------------------------------------------------------------------

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def analyze_imports(file_path: str, language: str) -> str:
    """
    Parse import/require/use/include statements from a source file.
    Returns a JSON array of imported module names.
    Supports Python, TypeScript/JavaScript, Rust, Go, Java, C#.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        imports = []
        patterns = {
            "python": [
                r"^import\s+([\w.]+)",
                r"^from\s+([\w.]+)\s+import",
            ],
            "typescript": [
                r"import\s+.*?\s+from\s+['\"](.+?)['\"]",
                r"require\(['\"](.+?)['\"]\)",
            ],
            "javascript": [
                r"import\s+.*?\s+from\s+['\"](.+?)['\"]",
                r"require\(['\"](.+?)['\"]\)",
            ],
            "rust": [
                r"use\s+([\w:]+)",
                r"extern\s+crate\s+(\w+)",
            ],
            "go": [
                r"import\s+\"(.+?)\"",
                r"import\s+\(\s*([^)]+)\s*\)",
            ],
            "java": [
                r"import\s+([\w.]+)",
            ],
            "csharp": [
                r"using\s+([\w.]+)",
            ],
        }

        lang_key = language.lower().replace("#", "sharp")
        lang_patterns = patterns.get(lang_key, [])

        for pattern in lang_patterns:
            matches = re.findall(pattern, content, re.MULTILINE)
            imports.extend(matches)

        return json.dumps({
            "file": file_path,
            "language": language,
            "imports": list(set(imports)),
            "count": len(set(imports)),
        }, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
async def build_dependency_graph(source_dir: str, language: str, ctx: Context = None) -> str:
    """
    Build a dependency DAG for all source files in a directory.
    Returns JSON with adjacency list, topological layers, and cycle detection.
    """
    try:
        source_path = Path(source_dir)
        extensions = {
            "python": [".py"],
            "typescript": [".ts", ".tsx"],
            "javascript": [".js", ".jsx"],
            "rust": [".rs"],
            "go": [".go"],
            "java": [".java"],
            "csharp": [".cs"],
        }

        lang_key = language.lower().replace("#", "sharp")
        exts = extensions.get(lang_key, [])

        # Collect all source files
        files = []
        for ext in exts:
            files.extend(source_path.rglob(f"*{ext}"))

        # Build adjacency list with progress reporting
        adjacency = {}
        for i, file in enumerate(files):
            if ctx:
                await ctx.report_progress(
                    progress=i, total=len(files),
                    message=f"Analyzing {file.name}",
                )
            rel_path = str(file.relative_to(source_path))
            import_result = json.loads(analyze_imports(str(file), language))
            adjacency[rel_path] = import_result.get("imports", [])

        # Simple topological sort with cycle detection
        layers = _topological_sort(adjacency)

        if ctx:
            await ctx.report_progress(
                progress=len(files), total=len(files),
                message=f"Dependency graph complete — {len(files)} files, {len(layers)} layers",
            )

        return json.dumps({
            "source_dir": source_dir,
            "language": language,
            "total_files": len(files),
            "adjacency": adjacency,
            "layers": layers,
            "has_cycles": any("CYCLE" in str(l) for l in layers),
        }, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


def _topological_sort(adjacency: dict) -> list:
    """Layer-based topological sort with cycle detection."""
    in_degree = {node: 0 for node in adjacency}
    for node, deps in adjacency.items():
        for dep in deps:
            if dep in in_degree:
                in_degree[dep] += 1

    # Simplified: group by depth
    visited = set()
    layers = []
    remaining = set(adjacency.keys())

    layer_num = 0
    while remaining:
        # Find nodes whose deps are all satisfied
        current_layer = []
        for node in list(remaining):
            deps = adjacency.get(node, [])
            internal_deps = [d for d in deps if d in adjacency]
            if all(d in visited for d in internal_deps):
                current_layer.append(node)

        if not current_layer:
            # Cycle detected — add remaining as cycle layer
            layers.append({
                "layer": layer_num,
                "modules": list(remaining),
                "note": "CYCLE — circular dependency detected",
            })
            break

        layers.append({
            "layer": layer_num,
            "modules": current_layer,
        })

        for node in current_layer:
            visited.add(node)
            remaining.remove(node)

        layer_num += 1

    return layers


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def translate_file(
    source_path: str,
    target_path: str,
    source_language: str,
    target_language: str,
    framework_mappings: str = "{}",
    package_mappings: str = "{}",
) -> str:
    """
    Read a source file and prepare a translation context package.
    Returns the source content with metadata for translation by the LLM.
    The actual translation is performed by the translator agent using this context.
    """
    try:
        with open(source_path, "r", encoding="utf-8") as f:
            source_content = f.read()

        loc = source_content.count("\n") + 1
        fw_maps = json.loads(framework_mappings) if isinstance(framework_mappings, str) else framework_mappings
        pkg_maps = json.loads(package_mappings) if isinstance(package_mappings, str) else package_mappings

        import_result = json.loads(analyze_imports(source_path, source_language))

        return json.dumps({
            "source_path": source_path,
            "target_path": target_path,
            "source_language": source_language,
            "target_language": target_language,
            "source_content": source_content,
            "loc": loc,
            "imports": import_result.get("imports", []),
            "framework_mappings": fw_maps,
            "package_mappings": pkg_maps,
            "instructions": f"Translate this {source_language} code to idiomatic {target_language}. "
                          f"Use the framework and package mappings provided. "
                          f"Maintain functional equivalence.",
        }, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def validate_translation(
    translated_path: str,
    target_language: str,
    validation_layers: str = "syntax,types,lint",
) -> str:
    """
    Run validation checks on a translated file.
    Returns layer-by-layer validation results with scores.
    Layers: syntax, types, lint, unit_tests, integration, equivalence.
    """
    try:
        layers_to_run = [l.strip() for l in validation_layers.split(",")]
        results = {}

        validation_commands = {
            "typescript": {
                "syntax": "npx tsc --noEmit {file}",
                "types": "npx tsc --noEmit --strict {file}",
                "lint": "npx eslint {file}",
                "unit_tests": "npx jest --passWithNoTests",
            },
            "python": {
                "syntax": "python -m py_compile {file}",
                "types": "mypy {file}",
                "lint": "ruff check {file}",
                "unit_tests": "pytest -x",
            },
            "rust": {
                "syntax": "cargo check",
                "types": "cargo check",
                "lint": "cargo clippy",
                "unit_tests": "cargo test",
            },
            "go": {
                "syntax": "go build ./...",
                "types": "go vet ./...",
                "lint": "golangci-lint run",
                "unit_tests": "go test ./...",
            },
            "java": {
                "syntax": "javac {file}",
                "types": "javac -Xlint:all {file}",
                "lint": "checkstyle {file}",
                "unit_tests": "mvn test",
            },
            "csharp": {
                "syntax": "dotnet build --no-restore",
                "types": "dotnet build --no-restore",
                "lint": "dotnet format --verify-no-changes",
                "unit_tests": "dotnet test",
            },
        }

        lang_key = target_language.lower().replace("#", "sharp")
        commands = validation_commands.get(lang_key, {})

        for layer in layers_to_run:
            cmd = commands.get(layer)
            if cmd:
                results[layer] = {
                    "command": cmd.replace("{file}", translated_path),
                    "status": "ready",
                    "note": "Execute this command to validate. Report exit code and output.",
                }
            else:
                results[layer] = {
                    "status": "unsupported",
                    "note": f"No built-in command for {layer} in {target_language}",
                }

        return json.dumps({
            "file": translated_path,
            "language": target_language,
            "layers": results,
            "scoring": {
                "syntax": {"weight": 0.15, "description": "Binary pass/fail"},
                "types": {"weight": 0.15, "description": "Error count ratio"},
                "lint": {"weight": 0.10, "description": "Warning count ratio"},
                "unit_tests": {"weight": 0.25, "description": "Test pass ratio"},
                "integration": {"weight": 0.15, "description": "Integration pass ratio"},
                "equivalence": {"weight": 0.20, "description": "Behavioral equivalence"},
            },
        }, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def calculate_confidence(
    syntax_score: float = 0.0,
    type_score: float = 0.0,
    lint_score: float = 0.0,
    unit_test_score: float = 0.0,
    integration_score: float = 0.0,
    equivalence_score: float = 0.0,
    file_path: str = "",
    loc: int = 0,
) -> str:
    """
    Calculate the confidence score for a translated file using the 6-layer weighted formula.
    Returns the overall score, band label, and per-layer breakdown.
    """
    weights = {
        "syntax": 0.15,
        "types": 0.15,
        "lint": 0.10,
        "unit_tests": 0.25,
        "integration": 0.15,
        "equivalence": 0.20,
    }

    scores = {
        "syntax": min(max(syntax_score, 0.0), 1.0),
        "types": min(max(type_score, 0.0), 1.0),
        "lint": min(max(lint_score, 0.0), 1.0),
        "unit_tests": min(max(unit_test_score, 0.0), 1.0),
        "integration": min(max(integration_score, 0.0), 1.0),
        "equivalence": min(max(equivalence_score, 0.0), 1.0),
    }

    weighted_score = sum(weights[k] * scores[k] for k in weights)

    if weighted_score >= 0.9:
        band = "High"
        action = "Auto-approve, no human review needed"
    elif weighted_score >= 0.7:
        band = "Medium"
        action = "Quick human review of flagged areas"
    elif weighted_score >= 0.5:
        band = "Low"
        action = "Full human review required"
    else:
        band = "Critical"
        action = "Re-translate or flag for manual rewrite"

    return json.dumps({
        "file": file_path,
        "loc": loc,
        "overall_score": round(weighted_score, 4),
        "band": band,
        "recommended_action": action,
        "breakdown": {k: {"weight": weights[k], "score": scores[k], "weighted": round(weights[k] * scores[k], 4)} for k in weights},
    }, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def calculate_repo_confidence(scores_json: str) -> str:
    """
    Calculate the LOC-weighted repo-level confidence score.
    Input: JSON string of array [{file, loc, score}, ...]
    Returns aggregate score and distribution by confidence band.
    """
    try:
        file_scores = json.loads(scores_json) if isinstance(scores_json, str) else scores_json

        total_weighted = sum(f["loc"] * f["score"] for f in file_scores)
        total_loc = sum(f["loc"] for f in file_scores)

        repo_score = total_weighted / total_loc if total_loc > 0 else 0.0

        bands = {"High": [], "Medium": [], "Low": [], "Critical": []}
        for f in file_scores:
            s = f["score"]
            if s >= 0.9:
                bands["High"].append(f)
            elif s >= 0.7:
                bands["Medium"].append(f)
            elif s >= 0.5:
                bands["Low"].append(f)
            else:
                bands["Critical"].append(f)

        distribution = {}
        for band, files in bands.items():
            band_loc = sum(f["loc"] for f in files)
            distribution[band] = {
                "file_count": len(files),
                "total_loc": band_loc,
                "loc_percentage": round(band_loc / total_loc * 100, 1) if total_loc > 0 else 0,
            }

        return json.dumps({
            "repo_score": round(repo_score, 4),
            "total_files": len(file_scores),
            "total_loc": total_loc,
            "distribution": distribution,
        }, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def get_translation_status() -> str:
    """
    Get the current translation workflow status.
    Returns phase, progress, and module-level status.
    """
    return json.dumps(translation_state, indent=2, default=str)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=False,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def update_module_status(
    module_id: str,
    status: str,
    confidence: float = -1.0,
    notes: str = "",
) -> str:
    """
    Update the status and confidence of a specific module in the translation manifest.
    Status: pending, translating, translated, validating, validated, failed, escalated.
    """
    valid_statuses = {'pending', 'translating', 'translated', 'validating', 'validated', 'failed', 'escalated'}
    if status not in valid_statuses:
        return json.dumps({"error": f"Invalid status: {status}. Must be one of: {', '.join(sorted(valid_statuses))}"})

    for module in translation_state["modules"]:
        if module.get("id") == module_id:
            module["status"] = status
            if confidence >= 0:
                module["confidence"] = confidence
            if notes:
                module["notes"] = notes
            translation_state["progress"]["translated"] = sum(
                1 for m in translation_state["modules"] if m.get("status") in ("translated", "validated")
            )
            translation_state["progress"]["validated"] = sum(
                1 for m in translation_state["modules"] if m.get("status") == "validated"
            )
            return json.dumps({"success": True, "module": module}, indent=2)

    return json.dumps({"error": f"Module {module_id} not found"})


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def suggest_target_dependencies(
    source_packages: str,
    source_language: str,
    target_language: str,
) -> str:
    """
    Suggest target language package equivalents for source language dependencies.
    Input: comma-separated source package names.
    Returns a JSON mapping of source → suggested target packages.
    """
    # Common cross-language package mappings
    known_mappings = {
        ("python", "typescript"): {
            "requests": "axios",
            "httpx": "axios",
            "flask": "express",
            "fastapi": "@nestjs/core",
            "django": "@nestjs/core",
            "sqlalchemy": "typeorm",
            "pydantic": "class-validator",
            "pytest": "jest",
            "unittest": "jest",
            "click": "commander",
            "typer": "commander",
            "celery": "bull",
            "redis": "ioredis",
            "boto3": "@aws-sdk/client-s3",
            "structlog": "pino",
            "logging": "winston",
            "aiohttp": "axios",
            "beautifulsoup4": "cheerio",
            "numpy": "mathjs",
            "pandas": "danfojs-node",
        },
        ("python", "rust"): {
            "requests": "reqwest",
            "flask": "actix-web",
            "fastapi": "axum",
            "sqlalchemy": "diesel",
            "pydantic": "serde",
            "pytest": "cargo test (built-in)",
            "click": "clap",
            "redis": "redis-rs",
            "structlog": "tracing",
            "aiohttp": "reqwest",
        },
        ("python", "go"): {
            "requests": "net/http",
            "flask": "gin",
            "fastapi": "fiber",
            "sqlalchemy": "gorm",
            "pydantic": "go-playground/validator",
            "pytest": "testing + testify",
            "click": "cobra",
            "redis": "go-redis",
            "structlog": "zap",
            "celery": "machinery",
        },
        ("typescript", "python"): {
            "express": "flask",
            "nestjs": "fastapi",
            "axios": "requests",
            "typeorm": "sqlalchemy",
            "jest": "pytest",
            "commander": "click",
            "winston": "structlog",
            "ioredis": "redis",
            "bull": "celery",
            "zod": "pydantic",
        },
        ("java", "python"): {
            "spring-boot": "fastapi",
            "hibernate": "sqlalchemy",
            "junit": "pytest",
            "mockito": "unittest.mock",
            "jackson": "pydantic",
            "slf4j": "structlog",
            "okhttp": "requests",
            "lombok": "dataclasses",
        },
        ("java", "typescript"): {
            "spring-boot": "@nestjs/core",
            "hibernate": "typeorm",
            "junit": "jest",
            "mockito": "jest.fn",
            "jackson": "class-transformer",
            "slf4j": "winston",
            "okhttp": "axios",
        },
        ("csharp", "typescript"): {
            "asp.net-core": "@nestjs/core",
            "entity-framework": "typeorm",
            "xunit": "jest",
            "nunit": "jest",
            "moq": "jest.fn",
            "serilog": "winston",
            "newtonsoft.json": "class-transformer",
            "httpclient": "axios",
            "fluentvalidation": "class-validator",
        },
    }

    src_lang = source_language.lower().replace("#", "sharp")
    tgt_lang = target_language.lower().replace("#", "sharp")
    packages = [p.strip() for p in source_packages.split(",")]

    mapping_key = (src_lang, tgt_lang)
    mappings = known_mappings.get(mapping_key, {})

    result = {}
    for pkg in packages:
        pkg_lower = pkg.lower()
        if pkg_lower in mappings:
            result[pkg] = {
                "target": mappings[pkg_lower],
                "confidence": "high",
                "note": "Known mapping",
            }
        else:
            result[pkg] = {
                "target": None,
                "confidence": "unknown",
                "note": f"No known mapping for {pkg} from {source_language} to {target_language}. Research required.",
            }

    return json.dumps({
        "source_language": source_language,
        "target_language": target_language,
        "mappings": result,
        "unmapped_count": sum(1 for v in result.values() if v["target"] is None),
    }, indent=2)


# ---------------------------------------------------------------------------
# RESOURCES — Translation state and mappings
# ---------------------------------------------------------------------------

@mcp.resource("translation://status")
def get_status_resource() -> str:
    """Current translation workflow status including phase, progress, and per-module state."""
    return json.dumps(translation_state, indent=2, default=str)


@mcp.resource("translation://confidence-matrix")
def get_confidence_matrix() -> str:
    """Per-file confidence scores matrix."""
    matrix = []
    for module in translation_state.get("modules", []):
        matrix.append({
            "id": module.get("id"),
            "source": module.get("sourcePath"),
            "target": module.get("targetPath"),
            "confidence": module.get("confidence"),
            "status": module.get("status"),
        })
    return json.dumps(matrix, indent=2)


@mcp.resource("translation://dependency-graph")
def get_dependency_graph() -> str:
    """Dependency graph with topological layers."""
    return json.dumps(translation_state.get("dependency_graph", {}), indent=2)


@mcp.resource("translation://framework-mappings")
def get_framework_mappings() -> str:
    """Source to target framework and package mappings."""
    return json.dumps({
        "frameworks": translation_state.get("framework_mappings", {}),
        "packages": translation_state.get("package_mappings", {}),
    }, indent=2)


# ---------------------------------------------------------------------------
# PROMPTS — Reusable translation prompts
# ---------------------------------------------------------------------------

@mcp.prompt()
def translate_file_prompt(
    source_path: str,
    target_path: str,
    source_language: str,
    target_language: str,
) -> str:
    """Generate a prompt for translating a specific file."""
    return f"""Translate the following {source_language} file to idiomatic {target_language}.

Source file: {source_path}
Target file: {target_path}

Translation requirements:
1. Maintain functional equivalence (same inputs → same outputs)
2. Use {target_language} naming conventions and idioms
3. Map imports to target language equivalents
4. Convert doc comments to {target_language} format
5. Add '// Translated from: {source_path}' header comment
6. Preserve all error handling with idiomatic patterns

After translation, produce:
- The translated file content
- A confidence score breakdown (syntax, types, lint, tests, integration, equivalence)
- Any translation decisions that deviate from literal translation
- Areas requiring manual review
"""


@mcp.prompt()
def validate_file_prompt(translated_path: str, target_language: str) -> str:
    """Generate a prompt for validating a translated file."""
    return f"""Validate the translated {target_language} file at: {translated_path}

Run the 6-layer validation stack:
1. Syntax (0.15): Parse check — does the code compile/parse?
2. Types (0.15): Type check — do all types resolve?
3. Lint (0.10): Style check — follows conventions?
4. Unit Tests (0.25): Test pass rate
5. Integration (0.15): Cross-module test pass rate
6. Equivalence (0.20): Same inputs → same outputs?

For each layer, report:
- Command run
- Exit code and output
- Score (0.0–1.0)
- Failures with details

Calculate overall confidence: Σ(weight × score)
"""


@mcp.prompt()
def analyze_repo_prompt(source_dir: str, source_language: str) -> str:
    """Generate a prompt for analyzing a repository before translation."""
    return f"""Analyze the {source_language} repository at: {source_dir}

Produce:
1. File inventory with LOC, role (source/test/config/docs/assets)
2. Dependency graph (import analysis → adjacency list → topological sort)
3. Per-file complexity score (LOC, cyclomatic, deps, language features)
4. Framework identification and suggested target mappings
5. External dependency catalog
6. Risk assessment (high-complexity, untranslatable patterns, platform-specific)

Output as a Translation Manifest JSON following the schema in translation-conductor.agent.md.
"""


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    mcp.run()
