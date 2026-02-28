#!/bin/bash
set -e

ZEROCLAW_DIR="$HOME/.zeroclaw"
WORKSPACE_DIR="$ZEROCLAW_DIR/workspace"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🎀 Lisa Onboard"
echo "================"
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

# ── Step 1: Run zeroclaw onboard if no config exists ──────────────────────
if [ ! -f "$ZEROCLAW_DIR/config.toml" ]; then
    echo ""
    echo "🔧 Running zeroclaw onboard..."
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

# ── Step 4: Append extra config from templates ────────────────────────────
for TEMPLATE in "$SCRIPT_DIR"/templates/*.append; do
    [ -f "$TEMPLATE" ] || continue
    BASENAME=$(basename "$TEMPLATE" .append)
    TARGET="$ZEROCLAW_DIR/$BASENAME"

    MARKER=$(grep -m1 '^\[' "$TEMPLATE" 2>/dev/null || true)
    if [ -n "$MARKER" ] && grep -qF "$MARKER" "$TARGET" 2>/dev/null; then
        echo "⚙️  $BASENAME: already has $MARKER (skipped)"
        continue
    fi

    cat "$TEMPLATE" >> "$TARGET"
    echo "⚙️  $BASENAME: appended from $(basename "$TEMPLATE")"
done

# ── Step 5: Lisa personal config ─────────────────────────────────────────
echo ""
if grep -q "## Google" "$WORKSPACE_DIR/USER.md" 2>/dev/null; then
    echo "✅ Lisa personal config already set."
    read -p "   Overwrite? (y/N): " OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        echo "   Skipped."
        echo ""
        echo "🎉 Done! GEMINI_API_KEY=\"your-key\" zeroclaw daemon"
        exit 0
    fi
    sed -i '' '/^## Google$/,$d' "$WORKSPACE_DIR/USER.md"
fi

echo "📍 Location"
read -p "   도시/구 (e.g. Seoul Gangseo-gu): " LOCATION
read -p "   위도 latitude (e.g. 37.55): " LATITUDE
read -p "   경도 longitude (e.g. 126.85): " LONGITUDE

echo ""
echo "🔑 Google (gog CLI)"
read -p "   Google account email: " GOOGLE_ACCOUNT
read -p "   GOG keyring password: " GOG_KEYRING_PASSWORD

echo ""
echo "📅 Calendars"
echo "   Primary calendar = Google account."
CALENDARS="| Primary | ${GOOGLE_ACCOUNT} | Personal |"

while true; do
    read -p "   Add another calendar? (y/N): " ADD_CAL
    if [ "$ADD_CAL" != "y" ] && [ "$ADD_CAL" != "Y" ]; then
        break
    fi
    read -p "   Calendar name: " CAL_NAME
    read -p "   Calendar ID: " CAL_ID
    read -p "   Notes (optional): " CAL_NOTES
    CALENDARS="${CALENDARS}
| ${CAL_NAME} | ${CAL_ID} | ${CAL_NOTES} |"
done

echo ""
read -p "📋 Google Tasks list ID (Enter to skip): " TASKS_LIST_ID

cat >> "$WORKSPACE_DIR/USER.md" << EOF

## Google

- **Account:** ${GOOGLE_ACCOUNT}
- **GOG_KEYRING_PASSWORD:** ${GOG_KEYRING_PASSWORD}

## Location

- **Location:** ${LOCATION}
- **Latitude:** ${LATITUDE}
- **Longitude:** ${LONGITUDE}

## Calendars

| Name | ID | Notes |
|------|----|-------|
${CALENDARS}

## Google Tasks

- **List ID:** ${TASKS_LIST_ID}
EOF

echo ""
echo "🎉 Lisa onboard complete!"
echo ""
echo "   GEMINI_API_KEY=\"your-key\" zeroclaw daemon"
echo ""
