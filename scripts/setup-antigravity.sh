#!/usr/bin/env bash
# ============================================================
# Export Copilot Orchestrator agents/skills/instructions
# to Antigravity IDE format.
#
# Usage:
#   ./scripts/setup-antigravity.sh --mode project --target ~/projects/my-app
#   ./scripts/setup-antigravity.sh --mode user
#   ./scripts/setup-antigravity.sh --mode project --target . --force
#
# Antigravity directory structure:
#   .agent/agents/      -- agent definitions
#   .agent/skills/      -- skills (SKILL.md format)
#   .agent/workflows/   -- slash-command workflows
#   .agent/rules/       -- project rules/instructions
#   .agent/mcp_config.json -- MCP server config
#   .agent/ARCHITECTURE.md -- project context
# ============================================================
set -euo pipefail

# Defaults
MODE="project"
TARGET=""
REPO_ROOT=""
INCLUDE_INSTRUCTIONS=true
INCLUDE_MCP=true
INCLUDE_WORKFLOWS=true
FORCE=false

usage() {
    cat <<EOF
Usage: $0 [options]
  --mode <project|user>     Output mode (default: project)
  --target <path>           Target directory
  --repo <path>             Repository root (default: auto-detect)
  --no-instructions         Skip instruction/rules conversion
  --no-mcp                  Skip MCP config conversion
  --no-workflows            Skip workflow generation
  --force                   Overwrite existing files
  -h, --help                Show this help
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)           MODE="$2"; shift 2 ;;
        --target)         TARGET="$2"; shift 2 ;;
        --repo)           REPO_ROOT="$2"; shift 2 ;;
        --no-instructions) INCLUDE_INSTRUCTIONS=false; shift ;;
        --no-mcp)         INCLUDE_MCP=false; shift ;;
        --no-workflows)   INCLUDE_WORKFLOWS=false; shift ;;
        --force)          FORCE=true; shift ;;
        -h|--help)        usage ;;
        *) echo "[ERROR] Unknown option: $1"; usage ;;
    esac
done

# Resolve repo root
if [[ -z "$REPO_ROOT" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Resolve target
if [[ -z "$TARGET" ]]; then
    case "$MODE" in
        project) TARGET="$(pwd)" ;;
        user)    TARGET="$HOME/.gemini/antigravity/skills" ;;
    esac
fi

# Output base
case "$MODE" in
    project) OUTPUT_BASE="$TARGET/.agent" ;;
    user)    OUTPUT_BASE="$TARGET" ;;
esac

# Source paths
AGENTS_SRC="$REPO_ROOT/.github/agents"
SKILLS_SRC="$REPO_ROOT/.github/skills"
PROMPTS_SRC="$REPO_ROOT/.github/prompts"
INSTRUCTIONS_SRC="$REPO_ROOT/instructions"
COPILOT_INSTR="$REPO_ROOT/.github/copilot-instructions.md"
VSCODE_MCP="$REPO_ROOT/.vscode/mcp.json"

echo ""
echo "============================================"
echo " Copilot Orchestrator -> Antigravity Setup"
echo "============================================"
echo ""
echo "Mode:           $MODE"
echo "Source:         $REPO_ROOT"
echo "Target:         $TARGET"
echo "Output Base:    $OUTPUT_BASE"
echo "Instructions:   $INCLUDE_INSTRUCTIONS"
echo "MCP Config:     $INCLUDE_MCP"
echo "Workflows:      $INCLUDE_WORKFLOWS"
echo ""

# Check source
if [[ ! -d "$AGENTS_SRC" ]]; then
    echo "[ERROR] Agents source not found: $AGENTS_SRC"
    echo "[HINT]  Ensure --repo points to the copilot_orchestrator repo."
    exit 1
fi

# Check existing output
if [[ -d "$OUTPUT_BASE" && "$FORCE" != "true" ]]; then
    echo "[WARN] Output directory exists: $OUTPUT_BASE"
    read -rp "Continue and overwrite? (y/N) " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "[ABORT] Setup cancelled."
        exit 0
    fi
fi

# Create output structure
mkdir -p "$OUTPUT_BASE/agents" "$OUTPUT_BASE/skills"

# ============================================================
# Helper: Map VS Code model names to Antigravity
# ============================================================
map_model() {
    local model="$1"
    case "$model" in
        *Opus*)   echo "opus" ;;
        *Sonnet*) echo "sonnet" ;;
        *Haiku*)  echo "haiku" ;;
        *Gemini*) echo "gemini-pro" ;;
        *)        echo "inherit" ;;
    esac
}

# Map VS Code tools to Antigravity tools and merge core toolset.
map_tools() {
    local tools_raw="${1:-}"
    local mapped=()
    local has=()
    local core=("Read" "Grep" "Glob" "Bash" "Edit" "Write")
    local token

    add_tool() {
        local t="$1"
        [[ -z "$t" ]] && return
        if [[ " ${has[*]} " != *" $t "* ]]; then
            mapped+=("$t")
            has+=("$t")
        fi
    }

    if [[ -n "$tools_raw" ]]; then
        local normalized
        normalized=$(echo "$tools_raw" | sed "s/^\[//;s/\]$//" | tr ',' '\n' | sed "s/^[' ]*//" | sed "s/[' ]*$//")
        while IFS= read -r token; do
            [[ -z "$token" ]] && continue
            case "$token" in
                search|usages)      add_tool "Grep" ;;
                fileSearch)         add_tool "Glob" ;;
                runCommands|fetch|githubRepo|changes|problems|todos) add_tool "Bash" ;;
                edit)               add_tool "Edit" ;;
                readFile)           add_tool "Read" ;;
                runSubagent|agent)  ;; # no direct Antigravity equivalent
            esac
        done <<< "$normalized"
    fi

    for token in "${core[@]}"; do
        add_tool "$token"
    done

    local out=""
    for token in "${mapped[@]}"; do
        out="${out:+$out, }$token"
    done
    echo "$out"
}

# ============================================================
# Step 1: Convert agents
# ============================================================
echo "--- Converting Agents ---"
agent_count=0

for src_file in "$AGENTS_SRC"/*.agent.md; do
    [[ -f "$src_file" ]] || continue
    filename="$(basename "$src_file")"
    dest_name="${filename%.agent.md}.md"

    # Extract frontmatter
    content="$(cat "$src_file")"

    # Parse name from frontmatter
    name=""
    description=""
    model_raw=""
    tools_raw=""
    body="$content"
    if echo "$content" | head -1 | grep -q '^---'; then
        fm_block="$(echo "$content" | sed -n '1,/^---$/p' | sed '1d;$d')"
        body="$(echo "$content" | sed '1,/^---$/d' | sed '1,/^$/!d; 1d')"
        # Actually get body after second ---
        body="$(echo "$content" | awk 'BEGIN{c=0} /^---$/{c++; if(c==2){found=1; next}} found{print}')"

        name="$(echo "$fm_block" | grep '^name:' | sed 's/^name:\s*//' | tr -d "\"'" || true)"
        description="$(echo "$fm_block" | grep '^description:' | sed 's/^description:\s*//' | tr -d "\"'" || true)"
        model_raw="$(echo "$fm_block" | grep '^model:' | head -1 | sed 's/^model:\s*//' | tr -d "\"'[]" | cut -d',' -f1 | xargs || true)"
        tools_raw="$(echo "$fm_block" | grep '^tools:' | sed 's/^tools:\s*//' || true)"
    else
        body="$content"
    fi

    if [[ -z "$name" ]]; then
        name="${dest_name%.md}"
    fi

    # Map model
    ag_model="inherit"
    if [[ -n "$model_raw" ]]; then
        ag_model="$(map_model "$model_raw")"
    fi

    ag_tools="$(map_tools "$tools_raw")"

    # Build output with Antigravity frontmatter
    {
        echo "---"
        echo "name: $name"
        if [[ -n "$description" ]]; then
            echo "description: $description"
        fi
        echo "tools: $ag_tools"
        echo "model: $ag_model"
        echo "---"
        echo ""
        echo "$body"
    } > "$OUTPUT_BASE/agents/$dest_name"

    agent_count=$((agent_count + 1))
    echo "  [OK] $filename -> $dest_name"
done

echo "[DONE] Converted $agent_count agents"
echo ""

# ============================================================
# Step 2: Copy skills
# ============================================================
echo "--- Copying Skills ---"
skill_count=0

for skill_dir in "$SKILLS_SRC"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    dest_dir="$OUTPUT_BASE/skills/$skill_name"
    cp -r "$skill_dir" "$dest_dir"
    skill_count=$((skill_count + 1))
    echo "  [OK] $skill_name"
done

echo "[DONE] Copied $skill_count skills"
echo ""

# ============================================================
# Step 3: Generate workflows from prompts
# ============================================================
workflow_count=0
if [[ "$INCLUDE_WORKFLOWS" == "true" && -d "$PROMPTS_SRC" ]]; then
    echo "--- Generating Workflows ---"
    mkdir -p "$OUTPUT_BASE/workflows"

    while IFS= read -r -d '' prompt_file; do
        pname="$(basename "$prompt_file" .prompt.md)"

        # Extract description from frontmatter if present
        desc=""
        pcontent="$(cat "$prompt_file")"
        if echo "$pcontent" | head -1 | grep -q '^---'; then
            desc="$(echo "$pcontent" | sed -n '1,/^---$/p' | grep '^description:' | sed 's/^description:\s*//' | tr -d "\"'" || true)"
            pbody="$(echo "$pcontent" | awk 'BEGIN{c=0} /^---$/{c++; if(c==2){found=1; next}} found{print}')"
        else
            pbody="$pcontent"
        fi

        if [[ -z "$desc" ]]; then
            desc="Workflow generated from prompt $pname"
        fi

        {
            echo "---"
            echo "description: $desc"
            echo "---"
            echo ""
            echo "# /$pname"
            echo ""
            echo "\$ARGUMENTS"
            echo ""
            echo "$pbody"
        } > "$OUTPUT_BASE/workflows/$pname.md"

        workflow_count=$((workflow_count + 1))
    done < <(find "$PROMPTS_SRC" -type f -name "*.prompt.md" -print0)

    echo "[DONE] Generated $workflow_count workflows"
    echo ""
fi

# ============================================================
# Step 4: Convert instructions to rules
# ============================================================
if [[ "$INCLUDE_INSTRUCTIONS" == "true" ]]; then
    echo "--- Converting Instructions ---"

    # ARCHITECTURE.md from copilot-instructions
    if [[ -f "$COPILOT_INSTR" ]]; then
        {
            echo "# Copilot Orchestrator - Project Architecture"
            echo ""
            echo "<!-- Auto-generated from .github/copilot-instructions.md -->"
            echo "<!-- Run setup-antigravity to regenerate -->"
            echo ""
            cat "$COPILOT_INSTR"
        } > "$OUTPUT_BASE/ARCHITECTURE.md"
        echo "[OK] Created: ARCHITECTURE.md"
    fi

    # Instruction rules
    if [[ -d "$INSTRUCTIONS_SRC" ]]; then
        for folder in global workflows compliance languages; do
            folder_path="$INSTRUCTIONS_SRC/$folder"
            [[ -d "$folder_path" ]] || continue
            mkdir -p "$OUTPUT_BASE/rules/$folder"

            for md_file in "$folder_path"/*.md; do
                [[ -f "$md_file" ]] || continue
                bname="$(basename "$md_file")"
                cp "$md_file" "$OUTPUT_BASE/rules/$folder/$bname"
            done
        done
        echo "[OK] Converted instruction files to rules"
    fi
    echo ""
fi

# ============================================================
# Step 5: MCP config
# ============================================================
if [[ "$INCLUDE_MCP" == "true" ]]; then
    echo "--- Converting MCP Configuration ---"
    if [[ -f "$VSCODE_MCP" ]]; then
        cat > "$OUTPUT_BASE/mcp_config.json" <<MCPEOF
{
    "mcpServers": {
        "validation": {
            "command": "python",
            "args": ["$REPO_ROOT/scripts/mcp/validation_server.py"]
        },
        "analytics": {
            "command": "python",
            "args": ["$REPO_ROOT/scripts/mcp/analytics_server.py"]
        },
        "research": {
            "command": "python",
            "args": ["$REPO_ROOT/scripts/mcp/research_server.py"]
        }
    }
}
MCPEOF
        echo "[OK] Created: mcp_config.json"
    else
        echo "[SKIP] No .vscode/mcp.json found"
    fi
    echo ""
fi

# ============================================================
# Summary
# ============================================================
echo "============================================"
echo " Setup Complete!"
echo "============================================"
echo ""
echo "  Agents:       $agent_count"
echo "  Skills:       $skill_count"
echo "  Workflows:    $workflow_count"
echo "  Output:       $OUTPUT_BASE"
echo ""

case "$MODE" in
    project)
        echo "Next steps:"
        echo "  1. Open project in Antigravity IDE"
        echo "  2. Agents auto-detected from .agent/agents/"
        echo "  3. Use slash commands like /plan, /review"
        echo "  4. Skills load automatically by context"
        ;;
    user)
        echo "Next steps:"
        echo "  1. Open Antigravity IDE in any project"
        echo "  2. Skills load globally from ~/.gemini/antigravity/skills/"
        echo "  3. For agents/workflows, also run with --mode project"
        ;;
esac
echo ""
