#!/usr/bin/env bash
# setup-claude-code.sh — Export Copilot Orchestrator to Claude Code format
#
# Usage:
#   ./scripts/setup-claude-code.sh [OPTIONS]
#
# Options:
#   --mode <project|user|plugin>   Output mode (default: project)
#   --target <path>                Target directory (auto-detected if omitted)
#   --repo <path>                  Path to copilot_orchestrator repo (auto-detected)
#   --no-instructions              Skip converting instruction files
#   --no-mcp                       Skip MCP config conversion
#   --force                        Overwrite existing files
#   --help                         Show this help
#
# Examples:
#   ./scripts/setup-claude-code.sh --mode project --target ~/my-project
#   ./scripts/setup-claude-code.sh --mode user
#   ./scripts/setup-claude-code.sh --mode plugin --target ./dist/copilot-orchestrator-plugin
#
# Requires: bash 4+, sed, grep

set -euo pipefail

# ============================================================
# Defaults
# ============================================================
MODE="project"
TARGET_PATH=""
REPO_ROOT=""
INCLUDE_INSTRUCTIONS=true
INCLUDE_MCP=true
FORCE=false

# ============================================================
# Parse arguments
# ============================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)           MODE="$2"; shift 2 ;;
        --target)         TARGET_PATH="$2"; shift 2 ;;
        --repo)           REPO_ROOT="$2"; shift 2 ;;
        --no-instructions) INCLUDE_INSTRUCTIONS=false; shift ;;
        --no-mcp)         INCLUDE_MCP=false; shift ;;
        --force)          FORCE=true; shift ;;
        --help)
            head -20 "$0" | grep "^#" | sed 's/^# \?//'
            exit 0
            ;;
        *) echo "[ERROR] Unknown option: $1"; exit 1 ;;
    esac
done

# ============================================================
# Resolve paths
# ============================================================
if [[ -z "$REPO_ROOT" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
fi

if [[ -z "$TARGET_PATH" ]]; then
    case "$MODE" in
        project) TARGET_PATH="$(pwd)" ;;
        user)    TARGET_PATH="$HOME" ;;
        plugin)  TARGET_PATH="$(pwd)/copilot-orchestrator-plugin" ;;
    esac
fi

case "$MODE" in
    project) OUTPUT_BASE="$TARGET_PATH/.claude" ;;
    user)    OUTPUT_BASE="$TARGET_PATH/.claude" ;;
    plugin)  OUTPUT_BASE="$TARGET_PATH" ;;
    *)       echo "[ERROR] Invalid mode: $MODE (use project, user, or plugin)"; exit 1 ;;
esac

AGENTS_SOURCE="$REPO_ROOT/.github/agents"
SKILLS_SOURCE="$REPO_ROOT/.github/skills"
INSTRUCTIONS_ROOT="$REPO_ROOT/instructions"
COPILOT_INSTR="$REPO_ROOT/.github/copilot-instructions.md"

# ============================================================
# Helpers
# ============================================================
map_model() {
    local model="$1"
    if echo "$model" | grep -qi "opus"; then echo "opus"; return; fi
    if echo "$model" | grep -qi "sonnet"; then echo "sonnet"; return; fi
    if echo "$model" | grep -qi "haiku"; then echo "haiku"; return; fi
    echo "sonnet"  # fallback for non-Anthropic models
}

# Extract first model from YAML array like ['GPT-5.3-Codex (copilot)', 'GPT-5.3-Codex (copilot)']
extract_first_model() {
    local raw="$1"
    echo "$raw" \
        | sed "s/^\[//;s/\]$//" \
        | tr ',\n' '\n' \
        | sed -e "s/^[[:space:]]*-[[:space:]]*//" -e "s/^[[:space:]'\"]*//" -e "s/[[:space:]'\"]*$//" \
        | sed '/^$/d' \
        | head -n 1
}

# Convert VS Code tool names to Claude Code equivalents
map_tools() {
    local tools_raw="$1"
    local agents_raw="${2:-}"
    local result=""

    # Parse tool list
    local tools
    tools=$(echo "$tools_raw" | sed "s/^\[//;s/\]$//" | tr ',\n' '\n' | sed -e "s/^[[:space:]]*-[[:space:]]*//" -e "s/^[[:space:]'\"]*//" -e "s/[[:space:]'\"]*$//")

    local has_task=false
    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        case "$tool" in
            runSubagent|agent) has_task=true ;;
            edit)        result="${result:+$result, }Edit" ;;
            readFile)    result="${result:+$result, }Read" ;;
            runCommands) result="${result:+$result, }Bash" ;;
            search)      result="${result:+$result, }Grep" ;;
            fileSearch)  result="${result:+$result, }Glob" ;;
            fetch)       result="${result:+$result, }Bash(curl *)" ;;
            githubRepo)  result="${result:+$result, }Bash(gh *)" ;;
            changes)     result="${result:+$result, }Bash(git diff*)" ;;
            todos)       result="${result:+$result, }TodoWrite" ;;
            problems|usages) ;; # No direct mapping needed
        esac
    done <<< "$tools"

    # Add Task with agents allowlist
    if [[ -n "$agents_raw" ]]; then
        local agents_list
        agents_list=$(echo "$agents_raw" | sed "s/^\[//;s/\]$//" | tr ',\n' '\n' | sed -e "s/^[[:space:]]*-[[:space:]]*//" -e "s/^[[:space:]'\"]*//" -e "s/[[:space:]'\"]*$//" | sed '/^$/d' | awk 'BEGIN { sep="" } { printf "%s%s", sep, $0; sep=", " } END { printf "" }')
        result="${result:+$result, }Task($agents_list)"
    elif [[ "$has_task" == true ]]; then
        result="${result:+$result, }Task"
    fi

    echo "$result"
}

language_paths_frontmatter() {
    local base_name="$1"
    local lang_key
    lang_key=$(echo "$base_name" | sed 's/\.instructions$//' | sed 's/^[0-9]\+_//' | tr '[:upper:]' '[:lower:]')

    case "$lang_key" in
        *powershell*) echo $'---\npaths:\n  - "**/*.ps1"\n  - "**/*.psm1"\n  - "**/*.psd1"\n---'; return 0 ;;
        *python*)     echo $'---\npaths:\n  - "**/*.py"\n---'; return 0 ;;
        *typescript*) echo $'---\npaths:\n  - "**/*.ts"\n  - "**/*.tsx"\n---'; return 0 ;;
        *javascript*) echo $'---\npaths:\n  - "**/*.js"\n  - "**/*.jsx"\n---'; return 0 ;;
        *csharp*)     echo $'---\npaths:\n  - "**/*.cs"\n---'; return 0 ;;
        *go*)         echo $'---\npaths:\n  - "**/*.go"\n---'; return 0 ;;
        *rust*)       echo $'---\npaths:\n  - "**/*.rs"\n---'; return 0 ;;
        *java*)       echo $'---\npaths:\n  - "**/*.java"\n---'; return 0 ;;
        *)            return 1 ;;
    esac
}

# ============================================================
# Convert an agent file
# ============================================================
convert_agent() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    # Read the file
    local content
    content=$(cat "$src")

    # Extract and parse frontmatter
    local fm_name="" fm_desc="" fm_model="" fm_tools="" fm_agents=""
    local frontmatter=""
    local body=""
    local fm_start=false
    local fm_end=false

    while IFS= read -r raw_line; do
        local line
        line="${raw_line%$'\r'}"
        if [[ "$line" == "---" ]]; then
            if [[ "$fm_start" == false ]]; then
                fm_start=true
                continue
            elif [[ "$fm_end" == false ]]; then
                fm_end=true
                continue
            fi
        fi

        if [[ "$fm_start" == true && "$fm_end" == false ]]; then
            frontmatter="${frontmatter}${line}
"
        elif [[ "$fm_end" == true ]]; then
            body="${body}${line}
"
        fi
    done <<< "$content"

    # Fallback for files without valid frontmatter delimiters
    if [[ "$fm_start" == false || "$fm_end" == false ]]; then
        frontmatter=""
        body="$content"
    fi

    # Parse frontmatter keys, including multiline YAML lists for model/tools/agents
    local current_list_key=""
    while IFS= read -r raw_line; do
        local line
        line="${raw_line%$'\r'}"
        if [[ "$line" =~ ^([a-zA-Z_-]+):[[:space:]]*(.*)$ ]]; then
            local key val
            key="${BASH_REMATCH[1]}"
            val="${BASH_REMATCH[2]}"
            current_list_key=""

            if [[ -z "$val" ]]; then
                case "$key" in
                    model|tools|agents) current_list_key="$key" ;;
                esac
                continue
            fi

            val=$(echo "$val" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")
            case "$key" in
                name)        fm_name="$val" ;;
                description) fm_desc="$val" ;;
                model)       fm_model="$val" ;;
                tools)       fm_tools="$val" ;;
                agents)      fm_agents="$val" ;;
            esac
            continue
        fi

        if [[ -n "$current_list_key" && "$line" =~ ^[[:space:]]*-[[:space:]]+(.+)$ ]]; then
            local item
            item="${BASH_REMATCH[1]}"
            item=$(echo "$item" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")

            case "$current_list_key" in
                model)  fm_model="${fm_model}${fm_model:+$'\n'}${item}" ;;
                tools)  fm_tools="${fm_tools}${fm_tools:+$'\n'}${item}" ;;
                agents) fm_agents="${fm_agents}${fm_agents:+$'\n'}${item}" ;;
            esac
            continue
        fi

        # Stop list capture on unrelated lines
        if [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
            current_list_key=""
        fi
    done <<< "$frontmatter"

    # Fallback name from filename
    if [[ -z "$fm_name" ]]; then
        fm_name=$(basename "$src" | sed 's/\.agent\.md$//')
    fi

    # Map model
    local claude_model="sonnet"
    if [[ -n "$fm_model" ]]; then
        local first_model
        first_model=$(extract_first_model "$fm_model")
        claude_model=$(map_model "$first_model")
    fi

    # Map tools
    local claude_tools=""
    if [[ -n "$fm_tools" ]]; then
        claude_tools=$(map_tools "$fm_tools" "$fm_agents")
    elif [[ -n "$fm_agents" ]]; then
        claude_tools=$(map_tools "" "$fm_agents")
    fi

    # Write output
    {
        echo "---"
        echo "name: $fm_name"
        [[ -n "$fm_desc" ]] && echo "description: \"$fm_desc\""
        echo "model: $claude_model"
        [[ -n "$claude_tools" ]] && echo "tools: $claude_tools"
        echo "---"
        echo ""
        echo "$body"
    } > "$dst"
}

# ============================================================
# Main execution
# ============================================================
echo ""
echo "============================================"
echo " Copilot Orchestrator → Claude Code Setup"
echo "============================================"
echo ""
echo "Mode:           $MODE"
echo "Source:         $REPO_ROOT"
echo "Target:         $TARGET_PATH"
echo "Output Base:    $OUTPUT_BASE"
echo ""

# Validate source
if [[ ! -d "$AGENTS_SOURCE" ]]; then
    echo "[ERROR] Agents source not found: $AGENTS_SOURCE"
    echo "[HINT]  Use --repo to point to the copilot_orchestrator repo."
    exit 1
fi

# Check existing output
if [[ -d "$OUTPUT_BASE" && "$FORCE" != true ]]; then
    echo "[WARN] Output directory exists: $OUTPUT_BASE"
    read -rp "Continue and overwrite? (y/N) " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        echo "[ABORT] Setup cancelled."
        exit 0
    fi
fi

# Create directories
AGENTS_OUT="$OUTPUT_BASE/agents"
SKILLS_OUT="$OUTPUT_BASE/skills"
mkdir -p "$AGENTS_OUT" "$SKILLS_OUT"

# ---- Step 1: Convert agents ----
echo "--- Converting Agents ---"
agent_count=0
for agent_file in "$AGENTS_SOURCE"/*.agent.md; do
    [[ ! -f "$agent_file" ]] && continue
    dest_name=$(basename "$agent_file" | sed 's/\.agent\.md$/.md/')
    convert_agent "$agent_file" "$AGENTS_OUT/$dest_name"
    echo "  [OK] $(basename "$agent_file") -> $dest_name"
    agent_count=$((agent_count + 1))
done
echo "[DONE] Converted $agent_count agents"
echo ""

# ---- Step 2: Copy skills ----
echo "--- Copying Skills ---"
skill_count=0
for skill_dir in "$SKILLS_SOURCE"/*/; do
    [[ ! -d "$skill_dir" ]] && continue
    skill_name=$(basename "$skill_dir")
    cp -r "$skill_dir" "$SKILLS_OUT/$skill_name"
    echo "  [OK] $skill_name"
    skill_count=$((skill_count + 1))
done
echo "[DONE] Copied $skill_count skills"
echo ""

# ---- Step 3: Convert instructions ----
if [[ "$INCLUDE_INSTRUCTIONS" == true ]]; then
    echo "--- Converting Instructions ---"

    # CLAUDE.md from copilot-instructions
    if [[ -f "$COPILOT_INSTR" ]]; then
        if [[ "$MODE" == "plugin" ]]; then
            inst_skill_dir="$SKILLS_OUT/project-instructions"
            mkdir -p "$inst_skill_dir"
            {
                echo "---"
                echo "name: project-instructions"
                echo "description: \"Core project instructions and conventions from the Copilot Orchestrator.\""
                echo "user-invocable: false"
                echo "---"
                echo ""
                cat "$COPILOT_INSTR"
            } > "$inst_skill_dir/SKILL.md"
            echo "  [OK] Created plugin skill: project-instructions"
        else
            claude_md="$OUTPUT_BASE/CLAUDE.md"
            {
                echo "# Copilot Orchestrator — Project Memory"
                echo ""
                echo "<!-- Auto-generated from .github/copilot-instructions.md -->"
                echo "<!-- Run setup-claude-code to regenerate -->"
                echo ""
                cat "$COPILOT_INSTR"
            } > "$claude_md"
            echo "  [OK] Created: $claude_md"
        fi
    fi

    # Rules from instruction files
    if [[ -d "$INSTRUCTIONS_ROOT" ]]; then
        for folder in global workflows compliance languages; do
            folder_path="$INSTRUCTIONS_ROOT/$folder"
            [[ ! -d "$folder_path" ]] && continue

            if [[ "$MODE" == "plugin" ]]; then
                for md_file in "$folder_path"/*.md; do
                    [[ ! -f "$md_file" ]] && continue
                    base=$(basename "$md_file" .md)
                    skill_dir="$SKILLS_OUT/instruction-$folder-$base"
                    mkdir -p "$skill_dir"
                    {
                        echo "---"
                        echo "name: instruction-$folder-$base"
                        echo "description: \"$folder instruction: $base\""
                        echo "user-invocable: false"
                        echo "---"
                        echo ""
                        cat "$md_file"
                    } > "$skill_dir/SKILL.md"
                done
            else
                rules_dir="$OUTPUT_BASE/rules/$folder"
                mkdir -p "$rules_dir"
                for md_file in "$folder_path"/*.md; do
                    [[ ! -f "$md_file" ]] && continue
                    base=$(basename "$md_file")
                    if [[ "$folder" == "languages" ]]; then
                        base_no_ext=$(basename "$md_file" .md)
                        paths_frontmatter="$(language_paths_frontmatter "$base_no_ext" || true)"
                        if [[ -n "$paths_frontmatter" ]]; then
                            {
                                echo "$paths_frontmatter"
                                echo ""
                                cat "$md_file"
                            } > "$rules_dir/$base"
                        else
                            cp "$md_file" "$rules_dir/$base"
                        fi
                    else
                        cp "$md_file" "$rules_dir/$base"
                    fi
                done
            fi
        done
        echo "  [OK] Converted instruction files"
    fi
    echo ""
fi

# ---- Step 4: MCP config ----
if [[ "$INCLUDE_MCP" == true ]]; then
    echo "--- Converting MCP Configuration ---"
    if [[ "$MODE" == "plugin" ]]; then
        mcp_path="$OUTPUT_BASE/.mcp.json"
    else
        mcp_path="$(dirname "$OUTPUT_BASE")/.mcp.json"
    fi

    cat > "$mcp_path" << MCPEOF
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
    echo "  [OK] Created: $mcp_path"
    echo ""
fi

# ---- Step 5: Plugin manifest (plugin mode) ----
if [[ "$MODE" == "plugin" ]]; then
    echo "--- Creating Plugin Manifest ---"
    mkdir -p "$OUTPUT_BASE/.claude-plugin"

    cat > "$OUTPUT_BASE/.claude-plugin/plugin.json" << 'PLUGEOF'
{
    "name": "copilot-orchestrator",
    "description": "Multi-agent orchestration system with 28 specialized agents for planning, implementation, review, security, and more.",
    "version": "1.0.0",
    "author": {
        "name": "Copilot Orchestrator"
    }
}
PLUGEOF

    cat > "$OUTPUT_BASE/README.md" << 'READMEEOF'
# Copilot Orchestrator Plugin for Claude Code

Multi-agent orchestration system with 28 specialized agents.

## Installation

```bash
claude --plugin-dir ./copilot-orchestrator-plugin
```

Or install permanently via `/plugin install`.

## Usage

```
Use the conductor agent to plan a new feature
Use the reviewer agent to check my recent changes
```
READMEEOF
    echo "  [OK] Created plugin manifest and README"
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
echo "  Output:       $OUTPUT_BASE"
echo ""

case "$MODE" in
    project)
        echo "Next steps:"
        echo "  1. Navigate to your project: cd $TARGET_PATH"
        echo "  2. Start Claude Code:        claude"
        echo "  3. Test with:                /agents"
        echo "  4. (Optional) Commit .claude/ to version control"
        ;;
    user)
        echo "Next steps:"
        echo "  1. Start Claude Code in any project: claude"
        echo "  2. All agents/skills are now globally available"
        echo "  3. Test with: /agents"
        ;;
    plugin)
        echo "Next steps:"
        echo "  1. Test the plugin:    claude --plugin-dir $OUTPUT_BASE"
        echo "  2. Or install via:     /plugin install (in Claude Code)"
        echo "  3. Distribute to team via Git or plugin marketplace"
        ;;
esac

echo ""
