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
cp -r "$SCRIPT_DIR/workspace/skills/"* "$WORKSPACE_DIR/skills/"
SKILL_LIST=$(ls "$SCRIPT_DIR/workspace/skills/" | tr '\n' ', ' | sed 's/,$//')
echo "   ✅ $SKILL_LIST"

# ── Step 4: Append extra fields to USER.md if not already present ─────────
if [ -f "$WORKSPACE_DIR/USER.md" ] && ! grep -q "## Google" "$WORKSPACE_DIR/USER.md" 2>/dev/null; then
    echo ""
    echo "👤 Adding Google/service config to USER.md..."
    read -p "   Google account email: " GOOGLE_ACCOUNT
    read -p "   GOG keyring password: " GOG_KEYRING_PASSWORD
    read -p "   Location (e.g. Seoul Gangseo-gu): " LOCATION
    read -p "   Latitude (e.g. 37.55): " LATITUDE
    read -p "   Longitude (e.g. 126.85): " LONGITUDE
    read -p "   Google Tasks list ID (Enter to skip): " TASKS_LIST_ID

    cat >> "$WORKSPACE_DIR/USER.md" << EOF

## Google

- **Account:** ${GOOGLE_ACCOUNT}
- **GOG_KEYRING_PASSWORD:** ${GOG_KEYRING_PASSWORD}

## Location

- **Location:** ${LOCATION}
- **Latitude:** ${LATITUDE}
- **Longitude:** ${LONGITUDE}

## Calendars

Add your calendar IDs here:

| Name | ID | Notes |
|------|----|-------|
| Primary | ${GOOGLE_ACCOUNT} | Personal |

## Google Tasks

- **List ID:** ${TASKS_LIST_ID}
EOF
    echo "   ✅ USER.md updated"
else
    echo "✅ USER.md already has Google config (skipped)"
fi

# ── Step 5: Append extra config.toml sections if not present ──────────────
if ! grep -q "\[a2ui\]" "$ZEROCLAW_DIR/config.toml" 2>/dev/null; then
    echo "⚙️  Adding extra config sections..."
    cat >> "$ZEROCLAW_DIR/config.toml" << 'EOF'

[a2ui]
enabled = true

[web_fetch]
enabled = true
provider = "nanohtml2text"
allowed_domains = ["*"]

[web_search]
enabled = true
provider = "duckduckgo"
EOF
    echo "   ✅ a2ui, web_fetch, web_search added to config.toml"
fi

echo ""
echo "🎉 Done! To start Lisa:"
echo ""
echo "   GEMINI_API_KEY=\"your-api-key\" zeroclaw daemon"
echo ""
