#!/bin/bash
set -e

ZEROCLAW_DIR="${ZEROCLAW_DIR:-$HOME/.zeroclaw}"
WORKSPACE_DIR="$ZEROCLAW_DIR/workspace"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/workspace/skills"

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

# ── Step 1.5: Symlink config.override.toml ────────────────────────────────
OVERRIDE_SRC="$SCRIPT_DIR/config.override.toml"
OVERRIDE_DST="$ZEROCLAW_DIR/config.override.toml"
if [ -f "$OVERRIDE_SRC" ]; then
    echo "⚙️  Linking config.override.toml..."
    ln -sf "$OVERRIDE_SRC" "$OVERRIDE_DST"
    echo "   ✅ $OVERRIDE_DST → $OVERRIDE_SRC"
fi

# ── Step 2: Symlink managed workspace files ───────────────────────────────
echo "📁 Linking Lisa personality..."
for FILE in SOUL.md IDENTITY.md AGENTS.md; do
    rm -f "$WORKSPACE_DIR/$FILE"
    ln -sf "$SCRIPT_DIR/workspace/$FILE" "$WORKSPACE_DIR/$FILE"
done
echo "   ✅ SOUL.md, IDENTITY.md, AGENTS.md (symlinked)"

# ── Step 3: Skill selection ───────────────────────────────────────────────
echo ""
echo "📦 Available skills:"
echo ""

AVAILABLE_SKILLS=()
IDX=1
for SKILL_DIR in "$SKILLS_DIR"/*/; do
    [ -f "$SKILL_DIR/SKILL.md" ] || continue
    SKILL_NAME=$(basename "$SKILL_DIR")
    # Extract description from front matter
    DESC=$(sed -n '/^---$/,/^---$/{ /^description:/{ s/^description: *"\{0,1\}//; s/"\{0,1\} *$//; p; } }' "$SKILL_DIR/SKILL.md")
    [ -z "$DESC" ] && DESC="(no description)"
    printf "   %d) %-16s %s\n" "$IDX" "$SKILL_NAME" "$DESC"
    AVAILABLE_SKILLS+=("$SKILL_NAME")
    IDX=$((IDX + 1))
done

echo ""
echo "   a) All skills"
echo ""
read -p "   Select skills (e.g. 1,2,3 or a for all): " SELECTION

SELECTED_SKILLS=()
if [ "$SELECTION" = "a" ] || [ "$SELECTION" = "A" ]; then
    SELECTED_SKILLS=("${AVAILABLE_SKILLS[@]}")
else
    IFS=',' read -ra INDICES <<< "$SELECTION"
    for I in "${INDICES[@]}"; do
        I=$(echo "$I" | tr -d ' ')
        if [ "$I" -ge 1 ] && [ "$I" -le "${#AVAILABLE_SKILLS[@]}" ] 2>/dev/null; then
            SELECTED_SKILLS+=("${AVAILABLE_SKILLS[$((I-1))]}")
        fi
    done
fi

if [ ${#SELECTED_SKILLS[@]} -eq 0 ]; then
    echo "   No skills selected."
else
    echo "   Selected: ${SELECTED_SKILLS[*]}"
fi

# ── Step 4: Install selected skills + process onboard.conf ────────────────
mkdir -p "$WORKSPACE_DIR/skills"

# Collect all user variables (deduplicate across skills)
declare -A USER_VARS      # key -> prompt
declare -A USER_VALUES    # key -> value
declare -A INSTALLED_BINS # bin -> 1

for SKILL_NAME in "${SELECTED_SKILLS[@]}"; do
    SKILL_SRC="$SKILLS_DIR/$SKILL_NAME"
    CONF="$SKILL_SRC/onboard.conf"

    # Symlink skill directory
    rm -rf "$WORKSPACE_DIR/skills/$SKILL_NAME"
    ln -sf "$SKILL_SRC" "$WORKSPACE_DIR/skills/$SKILL_NAME"
    echo "   📦 $SKILL_NAME linked"

    # Parse onboard.conf if exists
    [ -f "$CONF" ] || continue

    SECTION=""
    while IFS= read -r LINE || [ -n "$LINE" ]; do
        LINE=$(echo "$LINE" | sed 's/#.*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        [ -z "$LINE" ] && continue

        # Section header
        if [[ "$LINE" =~ ^\[(.+)\]$ ]]; then
            SECTION="${BASH_REMATCH[1]}"
            continue
        fi

        KEY=$(echo "$LINE" | cut -d'=' -f1 | sed 's/[[:space:]]*$//')
        VAL=$(echo "$LINE" | cut -d'=' -f2- | sed 's/^[[:space:]]*//')

        case "$SECTION" in
            requires)
                # Parse OS-specific keys: bin.darwin, bin.linux, or plain bin
                BIN="$KEY"
                OS_SUFFIX=""
                if [[ "$KEY" == *.* ]]; then
                    BIN="${KEY%%.*}"
                    OS_SUFFIX="${KEY#*.}"
                fi

                # Skip if wrong OS
                CURRENT_OS=$(uname -s | tr '[:upper:]' '[:lower:]')  # darwin or linux
                if [ -n "$OS_SUFFIX" ] && [ "$OS_SUFFIX" != "$CURRENT_OS" ]; then
                    continue
                fi

                if ! command -v "$BIN" &>/dev/null && [ -z "${INSTALLED_BINS[$BIN]}" ]; then
                    echo ""
                    echo "   ⚠️  $SKILL_NAME requires '$BIN' but it's not installed."
                    echo "   Install command: $VAL"
                    read -p "   Install now? (Y/n): " DO_INSTALL
                    if [ "$DO_INSTALL" != "n" ] && [ "$DO_INSTALL" != "N" ]; then
                        eval "$VAL"
                        INSTALLED_BINS[$BIN]=1
                    fi
                fi
                ;;
            user)
                if [ -z "${USER_VARS[$KEY]}" ]; then
                    USER_VARS[$KEY]="$VAL"
                fi
                ;;
            config)
                # Lines under [config] are appended as-is to config.toml
                # Use first [section] line as duplicate marker
                if ! grep -qF "$LINE" "$ZEROCLAW_DIR/config.toml" 2>/dev/null; then
                    echo "$LINE" >> "$ZEROCLAW_DIR/config.toml"
                fi
                ;;
        esac
    done < "$CONF"
done

# ── Step 5: Prompt for user variables and append to USER.md ───────────────
if [ ${#USER_VARS[@]} -gt 0 ] && [ -f "$WORKSPACE_DIR/USER.md" ]; then
    # Check if already configured
    NEED_INPUT=false
    for KEY in "${!USER_VARS[@]}"; do
        if ! grep -q "$KEY" "$WORKSPACE_DIR/USER.md" 2>/dev/null; then
            NEED_INPUT=true
            break
        fi
    done

    if $NEED_INPUT; then
        echo ""
        echo "👤 Personal config"
        for KEY in $(echo "${!USER_VARS[@]}" | tr ' ' '\n' | sort); do
            PROMPT="${USER_VARS[$KEY]}"
            read -p "   $PROMPT: " VALUE
            USER_VALUES[$KEY]="$VALUE"
        done

        # Append to USER.md
        echo "" >> "$WORKSPACE_DIR/USER.md"
        echo "## Lisa Config" >> "$WORKSPACE_DIR/USER.md"
        echo "" >> "$WORKSPACE_DIR/USER.md"
        for KEY in $(echo "${!USER_VALUES[@]}" | tr ' ' '\n' | sort); do
            echo "- **$KEY:** ${USER_VALUES[$KEY]}" >> "$WORKSPACE_DIR/USER.md"
        done
        echo "   ✅ USER.md updated"
    else
        echo "✅ USER.md already configured (skipped)"
    fi
fi

echo ""
echo "🎉 Lisa onboard complete!"
echo ""
echo "   GEMINI_API_KEY=\"your-key\" zeroclaw daemon"
echo ""
