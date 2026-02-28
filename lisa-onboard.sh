#!/bin/bash
set -e

ZEROCLAW_DIR="$HOME/.zeroclaw"
WORKSPACE_DIR="$ZEROCLAW_DIR/workspace"

echo "🎀 Lisa Onboard"
echo "================"
echo ""

# ── Check prerequisites ───────────────────────────────────────────────────
if [ ! -f "$WORKSPACE_DIR/USER.md" ]; then
    echo "❌ USER.md not found. Run 'zeroclaw onboard' first."
    exit 1
fi

if grep -q "## Google" "$WORKSPACE_DIR/USER.md" 2>/dev/null; then
    echo "✅ Lisa onboard already completed."
    read -p "   Overwrite? (y/N): " OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        echo "   Skipped."
        exit 0
    fi
    # Remove existing Lisa sections for re-onboard
    sed -i '' '/^## Google$/,$d' "$WORKSPACE_DIR/USER.md"
fi

# ── Location ──────────────────────────────────────────────────────────────
echo ""
echo "📍 Location"
read -p "   도시/구 (e.g. Seoul Gangseo-gu): " LOCATION
read -p "   위도 latitude (e.g. 37.55): " LATITUDE
read -p "   경도 longitude (e.g. 126.85): " LONGITUDE

# ── Google ────────────────────────────────────────────────────────────────
echo ""
echo "🔑 Google (gog CLI)"
read -p "   Google account email: " GOOGLE_ACCOUNT
read -p "   GOG keyring password: " GOG_KEYRING_PASSWORD

# ── Calendars ─────────────────────────────────────────────────────────────
echo ""
echo "📅 Calendars"
echo "   Primary calendar ID defaults to your Google account."
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

# ── Google Tasks ──────────────────────────────────────────────────────────
echo ""
read -p "📋 Google Tasks list ID (Enter to skip): " TASKS_LIST_ID

# ── Write to USER.md ─────────────────────────────────────────────────────
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
echo "✅ USER.md updated!"
echo ""
echo "🎉 Lisa onboard complete. Start with:"
echo ""
echo "   GEMINI_API_KEY=\"your-key\" zeroclaw daemon"
echo ""
