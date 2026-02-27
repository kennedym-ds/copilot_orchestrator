#!/usr/bin/env bash
# setup-vs-cli.sh — Configure Copilot Orchestrator for VS / Copilot CLI on macOS/Linux
#
# Usage:
#   ./scripts/setup-vs-cli.sh [OPTIONS]
#
# Options:
#   --target <path>       Target project directory (default: current dir)
#   --repo <path>         Path to copilot_orchestrator repo (auto-detected)
#   --strategy <link|copy|reference>  How to set up (default: link)
#   --force               Overwrite existing files
#   --validate            Only validate without making changes
#   --help                Show this help
#
# Requires: bash 4+, ln, cp

set -euo pipefail

# ============================================================
# Defaults
# ============================================================
TARGET_PATH=""
REPO_ROOT=""
STRATEGY="link"
FORCE=false
VALIDATE_ONLY=false

# ============================================================
# Parse arguments
# ============================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)     TARGET_PATH="$2"; shift 2 ;;
        --repo)       REPO_ROOT="$2"; shift 2 ;;
        --strategy)   STRATEGY="$2"; shift 2 ;;
        --force)      FORCE=true; shift ;;
        --validate)   VALIDATE_ONLY=true; shift ;;
        --help)
            head -16 "$0" | grep "^#" | sed 's/^# \?//'
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
    TARGET_PATH="$(pwd)"
fi

AGENTS_SRC="$REPO_ROOT/.github/agents"
PROMPTS_SRC="$REPO_ROOT/.github/prompts"
SKILLS_SRC="$REPO_ROOT/.github/skills"
INSTR_SRC="$REPO_ROOT/instructions"
COPILOT_INSTR="$REPO_ROOT/.github/copilot-instructions.md"

TARGET_GITHUB="$TARGET_PATH/.github"
TARGET_AGENTS="$TARGET_GITHUB/agents"
TARGET_PROMPTS="$TARGET_GITHUB/prompts"
TARGET_SKILLS="$TARGET_GITHUB/skills"
TARGET_INSTR="$TARGET_PATH/instructions"
TARGET_CI="$TARGET_GITHUB/copilot-instructions.md"

# ============================================================
# Helpers
# ============================================================
link_or_skip() {
    local link="$1" target="$2"
    mkdir -p "$(dirname "$link")"

    if [[ -e "$link" ]]; then
        if [[ "$FORCE" == true ]]; then
            rm -rf "$link"
        else
            echo "  [SKIP] Already exists: $link"
            return
        fi
    fi

    ln -s "$target" "$link"
    echo "  [OK] Linked: $link -> $target"
}

copy_or_skip() {
    local src="$1" dst="$2"
    [[ ! -e "$src" ]] && return

    if [[ -e "$dst" ]]; then
        if [[ "$FORCE" == true ]]; then
            rm -rf "$dst"
        else
            echo "  [SKIP] Already exists: $dst"
            return
        fi
    fi

    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
    echo "  [OK] Copied: $dst"
}

validate_setup() {
    local project="$1"
    local has_errors=false
    echo ""
    echo "--- Validation Report ---"

    local agents_dir="$project/.github/agents"
    if [[ -d "$agents_dir" ]]; then
        local count=0
        local agent_file
        for agent_file in "$agents_dir"/*.agent.md; do
            [[ -f "$agent_file" ]] || continue
            count=$((count + 1))
        done
        if [[ "$count" -gt 0 ]]; then
            echo "  [OK] Agents: $count found"
        else
            echo "  [!!] Agents: 0 found"
            has_errors=true
        fi
    else
        echo "  [!!] No .github/agents/ directory"
        has_errors=true
    fi

    local skills_dir="$project/.github/skills"
    if [[ -d "$skills_dir" ]]; then
        local count=0
        local skill_dir
        for skill_dir in "$skills_dir"/*; do
            [[ -d "$skill_dir" ]] || continue
            count=$((count + 1))
        done
        echo "  [OK] Skills: $count found"
    else
        echo "  [--] No .github/skills/"
    fi

    local prompts_dir="$project/.github/prompts"
    if [[ -d "$prompts_dir" ]]; then
        local count
        count=$(find "$prompts_dir" -name "*.prompt.md" | wc -l | tr -d ' ')
        echo "  [OK] Prompts: $count found"
    else
        echo "  [--] No .github/prompts/"
    fi

    [[ -f "$project/.github/copilot-instructions.md" ]] && echo "  [OK] copilot-instructions.md" || echo "  [--] No copilot-instructions.md"
    [[ -d "$project/instructions" ]] && echo "  [OK] instructions/" || echo "  [--] No instructions/"
    echo ""

    if [[ "$has_errors" == true ]]; then
        return 1
    fi
    return 0
}

check_cli() {
    echo "--- Checking Copilot CLI ---"

    if command -v gh &>/dev/null; then
        echo "  [OK] gh CLI found: $(which gh)"
    else
        echo "  [!!] gh CLI not found — install from https://cli.github.com"
        return 1
    fi

    if gh extension list 2>/dev/null | grep -q copilot; then
        echo "  [OK] gh copilot extension installed"
    else
        echo "  [!!] gh copilot extension not found"
        echo "       Install: gh extension install github/gh-copilot"
    fi

    if gh auth status &>/dev/null; then
        echo "  [OK] gh authenticated"
    else
        echo "  [!!] gh not authenticated — run: gh auth login"
    fi
    echo ""
}

# ============================================================
# Main
# ============================================================
echo ""
echo "================================================"
echo " Copilot Orchestrator → VS / CLI Setup"
echo "================================================"
echo ""
echo "Strategy:       $STRATEGY"
echo "Source:         $REPO_ROOT"
echo "Target:         $TARGET_PATH"
echo ""

# Validate source
if [[ ! -d "$AGENTS_SRC" ]]; then
    echo "[ERROR] Agents not found: $AGENTS_SRC"
    echo "[HINT]  Use --repo to point to copilot_orchestrator."
    exit 1
fi

# Pre-checks
check_cli || true

# Validate-only mode
if [[ "$VALIDATE_ONLY" == true ]]; then
    if validate_setup "$TARGET_PATH"; then
        exit 0
    fi
    exit 1
fi

# Apply strategy
case "$STRATEGY" in
    link)
        echo "--- Creating Symlinks ---"
        mkdir -p "$TARGET_GITHUB"
        link_or_skip "$TARGET_AGENTS" "$AGENTS_SRC"
        [[ -d "$PROMPTS_SRC" ]] && link_or_skip "$TARGET_PROMPTS" "$PROMPTS_SRC"
        [[ -d "$SKILLS_SRC" ]] && link_or_skip "$TARGET_SKILLS" "$SKILLS_SRC"
        [[ -d "$INSTR_SRC" ]] && link_or_skip "$TARGET_INSTR" "$INSTR_SRC"
        [[ -f "$COPILOT_INSTR" ]] && link_or_skip "$TARGET_CI" "$COPILOT_INSTR"
        ;;

    copy)
        echo "--- Copying Files ---"
        copy_or_skip "$AGENTS_SRC" "$TARGET_AGENTS"
        [[ -d "$PROMPTS_SRC" ]] && copy_or_skip "$PROMPTS_SRC" "$TARGET_PROMPTS"
        [[ -d "$SKILLS_SRC" ]] && copy_or_skip "$SKILLS_SRC" "$TARGET_SKILLS"
        [[ -d "$INSTR_SRC" ]] && copy_or_skip "$INSTR_SRC" "$TARGET_INSTR"
        [[ -f "$COPILOT_INSTR" ]] && copy_or_skip "$COPILOT_INSTR" "$TARGET_CI"
        ;;

    reference)
        echo "--- Reference Configuration ---"
        echo ""
        REPO_TILDE="${REPO_ROOT/#$HOME/\~}"
        echo "Add to VS Code / Visual Studio settings.json:"
        echo ""
        echo "  \"chat.agentFilesLocations\": { \"$REPO_TILDE/.github/agents\": true },"
        echo "  \"chat.agentSkillsLocations\": { \"$REPO_TILDE/.github/skills\": true },"
        echo "  \"chat.promptFilesLocations\": [\"$REPO_TILDE/.github/prompts\"],"
        echo "  \"chat.instructionsFilesLocations\": [\"$REPO_TILDE/instructions\"]"
        echo ""
        echo "For Copilot CLI, cd to the orchestrator repo or use symlinks."
        echo ""
        ;;

    *)
        echo "[ERROR] Unknown strategy: $STRATEGY (use link, copy, or reference)"
        exit 1
        ;;
esac

# Post-setup validation
if ! validate_setup "$TARGET_PATH"; then
    echo "[ERROR] Setup validation failed. Missing required agent setup."
    exit 1
fi

echo "================================================"
echo " Setup Complete!"
echo "================================================"
echo ""
echo "Visual Studio:"
echo "  1. Open $TARGET_PATH in VS 2022+"
echo "  2. Copilot Chat auto-discovers .github/agents/"
echo "  3. Use @conductor etc. in chat"
echo ""
echo "Copilot CLI:"
echo "  1. cd $TARGET_PATH"
echo "  2. gh copilot"
echo "  3. Use @conductor etc."
echo ""
