#!/bin/bash
set -e

ZEROCLAW_DIR="$HOME/.zeroclaw"
WORKSPACE_DIR="$ZEROCLAW_DIR/workspace"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🎀 Lisa Config Installer"
echo "========================"
echo ""

# ── Parse flags ────────────────────────────────────────────────────────────
SOURCE_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --source) SOURCE_DIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ── Step 0: Ensure zeroclaw binary ────────────────────────────────────────
if [ -n "$SOURCE_DIR" ]; then
    BINARY="$SOURCE_DIR/target/release/zeroclaw"
    if [ ! -f "$BINARY" ]; then
        echo "❌ Binary not found at $BINARY"
        echo "   Run 'cargo build --release' in $SOURCE_DIR first."
        exit 1
    fi
    echo "📦 Copying binary from $BINARY"
    mkdir -p "$HOME/.cargo/bin"
    cp "$BINARY" "$HOME/.cargo/bin/zeroclaw"
else
    if ! command -v zeroclaw &>/dev/null; then
        echo "❌ zeroclaw binary not found."
        echo "   Either:"
        echo "   1. Install zeroclaw (cargo install zeroclaw)"
        echo "   2. Use --source <path-to-lisa-repo> to copy from local build"
        exit 1
    fi
    echo "✅ zeroclaw binary found: $(which zeroclaw)"
fi

# ── Step 1: Run onboard if no config exists ───────────────────────────────
if [ ! -f "$ZEROCLAW_DIR/config.toml" ]; then
    echo ""
    echo "🔧 Running zeroclaw onboard..."
    echo "   (Follow the prompts to set up API key, provider, and channel)"
    echo ""
    zeroclaw onboard
    echo ""
fi

# ── Step 2: Overwrite managed workspace files ─────────────────────────────
echo "📁 Installing Lisa personality..."
cp "$SCRIPT_DIR/workspace/SOUL.md" "$WORKSPACE_DIR/SOUL.md"
cp "$SCRIPT_DIR/workspace/IDENTITY.md" "$WORKSPACE_DIR/IDENTITY.md"
cp "$SCRIPT_DIR/workspace/AGENTS.md" "$WORKSPACE_DIR/AGENTS.md"
echo "   ✅ SOUL.md, IDENTITY.md, AGENTS.md"

# ── Step 3: Copy skills ──────────────────────────────────────────────────
echo "📁 Installing skills..."
mkdir -p "$WORKSPACE_DIR/skills"
if [ -d "$SCRIPT_DIR/workspace/skills" ] && [ "$(ls -A "$SCRIPT_DIR/workspace/skills")" ]; then
    cp -r "$SCRIPT_DIR/workspace/skills/"* "$WORKSPACE_DIR/skills/"
    SKILL_LIST=$(ls "$SCRIPT_DIR/workspace/skills/" | tr '\n' ', ' | sed 's/,$//')
    echo "   ✅ $SKILL_LIST"
else
    echo "   (no skills to install)"
fi

# ── Helper: parse template, prompt for variables, append ──────────────────
apply_template() {
    local TEMPLATE="$1"
    local TARGET="$2"
    local MARKER="$3"  # grep marker to check if already appended

    if [ ! -f "$TEMPLATE" ]; then
        return
    fi

    # Skip if already applied
    if [ -n "$MARKER" ] && grep -q "$MARKER" "$TARGET" 2>/dev/null; then
        echo "   ✅ $(basename "$TEMPLATE") already applied (skipped)"
        return
    fi

    # Extract unique {{VARIABLE}} names from template
    local VARS
    VARS=$(grep -oE '\{\{[A-Z_]+\}\}' "$TEMPLATE" | sort -u | sed 's/[{}]//g')

    if [ -z "$VARS" ]; then
        # No variables — just append as-is
        cat "$TEMPLATE" >> "$TARGET"
        echo "   ✅ $(basename "$TEMPLATE") appended"
        return
    fi

    # Prompt for each variable
    local CONTENT
    CONTENT=$(cat "$TEMPLATE")
    echo ""
    for VAR in $VARS; do
        local PROMPT_NAME
        PROMPT_NAME=$(echo "$VAR" | tr '_' ' ' | tr '[:upper:]' '[:lower:]')
        read -p "   $PROMPT_NAME ($VAR): " VALUE
        CONTENT=$(echo "$CONTENT" | sed "s|{{${VAR}}}|${VALUE}|g")
    done

    echo "$CONTENT" >> "$TARGET"
    echo "   ✅ $(basename "$TEMPLATE") appended"
}

# ── Step 4: Append to USER.md ─────────────────────────────────────────────
if [ -f "$WORKSPACE_DIR/USER.md" ]; then
    echo "📝 Checking USER.md extras..."
    apply_template "$SCRIPT_DIR/templates/USER.md.append" "$WORKSPACE_DIR/USER.md" "## Google"
fi

# ── Step 5: Append to config.toml ─────────────────────────────────────────
echo "⚙️  Checking config.toml extras..."
apply_template "$SCRIPT_DIR/templates/config.toml.append" "$ZEROCLAW_DIR/config.toml" "[a2ui]"

echo ""
echo "🎉 Done! To start Lisa:"
echo ""
echo "   GEMINI_API_KEY=\"your-api-key\" zeroclaw daemon"
echo ""
