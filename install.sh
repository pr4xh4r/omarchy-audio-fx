#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  omarchy-audio-fx — Installer
#  https://github.com/pr4xh4r/omarchy-audio-fx
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

BOLD="\033[1m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"
RED="\033[1;31m"; CYAN="\033[1;36m"; RESET="\033[0m"

info()  { echo -e "${GREEN}✓${RESET} $*"; }
warn()  { echo -e "${YELLOW}⚠${RESET} $*"; }
die()   { echo -e "${RED}✗${RESET} $*" >&2; exit 1; }
step()  { echo -e "\n${BOLD}$*${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESETS_DIR="${HOME}/.local/share/easyeffects/output"
BIN_DIR="${HOME}/.local/bin"
PLUGIN_DIR="${HOME}/.config/omarchy/plugins"
CONFIG_DIR="${HOME}/.config/audiofx"

echo ""
echo -e " ${BOLD}🎛️  omarchy-audio-fx Installer${RESET}"
echo -e " ${CYAN}Cinematic audio modes for Linux${RESET}"
echo ""

# ── Check EasyEffects ────────────────────────────────────────────────────────
step "Checking dependencies..."
if ! command -v easyeffects &>/dev/null; then
    warn "EasyEffects not found. Install it first:"
    echo "  sudo pacman -S easyeffects     # Arch"
    echo "  sudo apt install easyeffects   # Ubuntu"
    exit 1
fi
info "EasyEffects $(easyeffects --version 2>/dev/null | head -1 || echo 'found')"

if ! command -v pactl &>/dev/null; then
    warn "PipeWire/PulseAudio (pactl) not found — auto-detection will be limited"
fi

# ── Install Presets ──────────────────────────────────────────────────────────
step "Installing presets..."
mkdir -p "$PRESETS_DIR"

COUNT=0
for preset in "${SCRIPT_DIR}"/presets/**/*.json; do
    [[ -f "$preset" ]] || continue
    name=$(basename "$preset")
    cp "$preset" "${PRESETS_DIR}/${name}"
    info "Installed: ${name%.json}"
    ((COUNT++))
done

echo -e "\n ${GREEN}✓${RESET} ${COUNT} presets installed to ${CYAN}${PRESETS_DIR}${RESET}"

# ── Install CLI ──────────────────────────────────────────────────────────────
step "Installing audiofx CLI..."
mkdir -p "$BIN_DIR"
cp "${SCRIPT_DIR}/audiofx" "${BIN_DIR}/audiofx"
chmod +x "${BIN_DIR}/audiofx"
info "CLI installed to ${BIN_DIR}/audiofx"

# Check if bin dir is in PATH
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    warn "${BIN_DIR} is not in PATH. Add this to your ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# ── Install audio-mode keybinding script ─────────────────────────────────────
step "Installing Super+M keybinding script..."
cp "${SCRIPT_DIR}/bin/audio-mode" "${BIN_DIR}/audio-mode"
chmod +x "${BIN_DIR}/audio-mode"
info "audio-mode script installed → ${BIN_DIR}/audio-mode"

# Register the keybinding for supported WMs
if [[ -f "${HOME}/.config/hypr/bindings.lua" ]]; then
    # Omarchy / Hyprland — check if binding already exists
    if grep -q "audio-mode" "${HOME}/.config/hypr/bindings.lua"; then
        info "Super+M keybinding already present in bindings.lua ✓"
    else
        echo "" >> "${HOME}/.config/hypr/bindings.lua"
        echo "-- Audio Mode: cycle all presets (Super+M)" >> "${HOME}/.config/hypr/bindings.lua"
        echo 'o.bind("SUPER + M", "Audio Mode", "audio-mode")' >> "${HOME}/.config/hypr/bindings.lua"
        info "Added Super+M binding to ~/.config/hypr/bindings.lua"
        warn "Reload Hyprland for the keybinding to take effect: Super+Shift+R"
    fi
elif command -v hyprctl &>/dev/null; then
    # Raw Hyprland (no Omarchy)
    hyprctl keyword bind "SUPER, M, exec, audio-mode" 2>/dev/null && \
        info "Super+M bound via hyprctl (temporary — add to hyprland.conf to persist)" || \
        warn "Could not auto-bind. Add manually to hyprland.conf:"
    echo "    bind = SUPER, M, exec, audio-mode"
else
    warn "Could not detect Hyprland. Add this keybinding manually to your WM config:"
    echo "    Key:     Super + M"
    echo "    Command: audio-mode"
fi

# ── Config Dir ───────────────────────────────────────────────────────────────
mkdir -p "$CONFIG_DIR"

# ── Omarchy Plugin (optional) ────────────────────────────────────────────────
step "Checking for Omarchy..."
if [[ -d "$PLUGIN_DIR" ]]; then
    cp -r "${SCRIPT_DIR}/plugins/pr4xh4r.audiofx" "${PLUGIN_DIR}/"
    info "Omarchy plugin installed: pr4xh4r.audiofx"
    warn "Restart Quickshell to load the new plugin"
else
    warn "Omarchy not detected — skipping plugin install (presets still work)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e " ${BOLD}🎉 Installation complete!${RESET}"
echo ""
echo -e " ${BOLD}Keyboard shortcut:${RESET}"
echo -e "   ${CYAN}Super + M${RESET}  →  cycle through all audio modes"
echo -e "   ${DIM}Off → Marshall → Dolby Atmos → Harman → Sony Clear → ...${RESET}"
echo ""
echo -e " ${BOLD}CLI quick start:${RESET}"
echo -e "   audiofx list              # see all modes"
echo -e "   audiofx set Marshall      # apply Marshall sound"
echo -e "   audiofx set Dolby-Atmos   # apply Dolby Atmos"
echo -e "   audiofx profile Headphones # optimize for headphones"
echo -e "   audiofx auto              # auto-detect your device"
echo ""
echo -e " ${CYAN}Or open EasyEffects and load any preset manually.${RESET}"
echo ""

