#!/bin/bash
set -e

ZEROCLAW_DIR="$HOME/.zeroclaw"
WORKSPACE_DIR="$ZEROCLAW_DIR/workspace"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🎀 Lisa Config Installer"
echo "========================"
echo ""

# ── Parse flags ────────────────────────────────────────────────────────────
UPDATE_MODE=false
SOURCE_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --update) UPDATE_MODE=true; shift ;;
        --source) SOURCE_DIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ── Ensure zeroclaw binary ────────────────────────────────────────────────
if [ -n "$SOURCE_DIR" ]; then
    BINARY="$SOURCE_DIR/target/release/zeroclaw"
    if [ ! -f "$BINARY" ]; then
        echo "❌ Binary not found at $BINARY"
        echo "   Run 'cargo build --release' in $SOURCE_DIR first."
        exit 1
    fi
    echo "📦 Copying binary from $BINARY"
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

# ── Create directories ────────────────────────────────────────────────────
mkdir -p "$WORKSPACE_DIR/skills"
mkdir -p "$WORKSPACE_DIR/memory"
mkdir -p "$WORKSPACE_DIR/state"

# ── Copy workspace files (always overwrite managed files) ─────────────────
echo ""
echo "📁 Installing workspace files..."
cp "$SCRIPT_DIR/workspace/SOUL.md" "$WORKSPACE_DIR/SOUL.md"
cp "$SCRIPT_DIR/workspace/IDENTITY.md" "$WORKSPACE_DIR/IDENTITY.md"
cp "$SCRIPT_DIR/workspace/AGENTS.md" "$WORKSPACE_DIR/AGENTS.md"
echo "   ✅ SOUL.md, IDENTITY.md, AGENTS.md"

# ── Copy skills (always overwrite) ────────────────────────────────────────
echo "📁 Installing skills..."
cp -r "$SCRIPT_DIR/workspace/skills/"* "$WORKSPACE_DIR/skills/"
echo "   ✅ $(ls "$SCRIPT_DIR/workspace/skills/" | tr '\n' ', ')"

# ── USER.md (create only if missing) ──────────────────────────────────────
if [ ! -f "$WORKSPACE_DIR/USER.md" ]; then
    echo ""
    echo "👤 Setting up USER.md..."
    read -p "   Your name: " USER_NAME
    read -p "   Timezone (e.g. Asia/Seoul): " TIMEZONE
    read -p "   Location (e.g. Seoul Gangseo-gu): " LOCATION
    read -p "   Latitude (e.g. 37.55): " LATITUDE
    read -p "   Longitude (e.g. 126.85): " LONGITUDE
    read -p "   Google account email: " GOOGLE_ACCOUNT
    read -p "   GOG keyring password: " GOG_KEYRING_PASSWORD
    read -p "   Google Tasks list ID (or press Enter to skip): " TASKS_LIST_ID

    sed -e "s|{{USER_NAME}}|$USER_NAME|g" \
        -e "s|{{TIMEZONE}}|$TIMEZONE|g" \
        -e "s|{{LOCATION}}|$LOCATION|g" \
        -e "s|{{LATITUDE}}|$LATITUDE|g" \
        -e "s|{{LONGITUDE}}|$LONGITUDE|g" \
        -e "s|{{GOOGLE_ACCOUNT}}|$GOOGLE_ACCOUNT|g" \
        -e "s|{{GOG_KEYRING_PASSWORD}}|$GOG_KEYRING_PASSWORD|g" \
        -e "s|{{TASKS_LIST_ID}}|$TASKS_LIST_ID|g" \
        "$SCRIPT_DIR/templates/USER.md.template" > "$WORKSPACE_DIR/USER.md"
    echo "   ✅ USER.md created"
else
    echo "✅ USER.md already exists (skipped)"
fi

# ── config.toml (create only if missing) ──────────────────────────────────
if [ ! -f "$ZEROCLAW_DIR/config.toml" ]; then
    echo ""
    echo "⚙️  Setting up config.toml..."
    read -p "   Telegram bot token: " TELEGRAM_BOT_TOKEN
    read -p "   Telegram user ID: " TELEGRAM_USER_ID

    sed -e "s|{{TELEGRAM_BOT_TOKEN}}|$TELEGRAM_BOT_TOKEN|g" \
        -e "s|{{TELEGRAM_USER_ID}}|$TELEGRAM_USER_ID|g" \
        "$SCRIPT_DIR/templates/config.toml.template" > "$ZEROCLAW_DIR/config.toml"
    echo "   ✅ config.toml created"
else
    echo "✅ config.toml already exists (skipped)"
fi

echo ""
echo "🎉 Done! To start Lisa:"
echo ""
echo "   GEMINI_API_KEY=\"your-api-key\" zeroclaw daemon"
echo ""
