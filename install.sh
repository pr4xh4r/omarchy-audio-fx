#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  omarchy-audio-fx — Installer
#  Supports: Arch, Ubuntu/Debian, Fedora, openSUSE, any distro with EasyEffects
#  Keybindings: Omarchy/Hyprland, KDE Plasma, GNOME, i3, Sway, manual
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

BOLD="\033[1m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"
RED="\033[1;31m"; CYAN="\033[1;36m"; DIM="\033[2m"; RESET="\033[0m"

info()  { echo -e " ${GREEN}✓${RESET} $*"; }
warn()  { echo -e " ${YELLOW}⚠${RESET}  $*"; }
die()   { echo -e " ${RED}✗${RESET} $*" >&2; exit 1; }
step()  { echo -e "\n ${BOLD}$*${RESET}"; }
tip()   { echo -e "   ${DIM}$*${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESETS_DIR="${HOME}/.local/share/easyeffects/output"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/audiofx"

# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e " ${BOLD}🎛️  omarchy-audio-fx${RESET}"
echo -e " ${DIM}Audio modes for Linux — Marshall, Dolby, Harman and more${RESET}"
echo ""

# ── Detect distro ─────────────────────────────────────────────────────────────
step "Detecting system..."
DISTRO="unknown"
PKG_MANAGER="unknown"

if command -v pacman &>/dev/null; then
    DISTRO="arch"; PKG_MANAGER="pacman"
    info "Arch Linux / Manjaro detected"
elif command -v apt &>/dev/null; then
    DISTRO="debian"; PKG_MANAGER="apt"
    . /etc/os-release 2>/dev/null || true
    info "${NAME:-Ubuntu/Debian} detected"
elif command -v dnf &>/dev/null; then
    DISTRO="fedora"; PKG_MANAGER="dnf"
    info "Fedora / RHEL detected"
elif command -v zypper &>/dev/null; then
    DISTRO="opensuse"; PKG_MANAGER="zypper"
    info "openSUSE detected"
else
    warn "Unknown distro — skipping dependency check"
fi

# ── Check / install EasyEffects ───────────────────────────────────────────────
step "Checking EasyEffects..."
if ! command -v easyeffects &>/dev/null; then
    warn "EasyEffects not found. Installing..."
    case "$PKG_MANAGER" in
        pacman)  sudo pacman -S --noconfirm easyeffects calf lsp-plugins-ladspa zam-plugins mda.lv2 libbs2b ;;
        apt)     sudo apt install -y easyeffects ;;
        dnf)     sudo dnf install -y easyeffects ;;
        zypper)  sudo zypper install -y easyeffects ;;
        *)       die "Please install EasyEffects manually: https://github.com/wwmm/easyeffects" ;;
    esac
fi
EE_VER=$(easyeffects --version 2>/dev/null | head -1 || echo "found")
info "EasyEffects ${EE_VER}"

# ── Check PipeWire ────────────────────────────────────────────────────────────
if ! command -v pactl &>/dev/null; then
    warn "pactl not found — auto device detection may not work"
    tip "Install: pipewire-pulse (Arch) or pipewire (Ubuntu/Fedora)"
else
    info "PipeWire/pactl found"
fi

# ── Check Python 3 ───────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    warn "Python 3 not found — smart device detection won't work"
    tip "Install: python (Arch) or python3 (Ubuntu/Fedora)"
else
    info "Python $(python3 --version | cut -d' ' -f2) found"
fi

# ── Install presets ───────────────────────────────────────────────────────────
step "Installing presets..."
mkdir -p "$PRESETS_DIR"
COUNT=0
for f in "${SCRIPT_DIR}"/presets/**/*.json; do
    [[ -f "$f" ]] || continue
    cp "$f" "${PRESETS_DIR}/$(basename "$f")"
    ((COUNT++))
done
info "${COUNT} presets installed → ${PRESETS_DIR}"

# ── Set up EasyEffects as a persistent background service ─────────────────────
step "Setting up EasyEffects as a background service..."
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"

# Use distro's unit file if it exists, else install ours
if ! systemctl --user cat easyeffects &>/dev/null; then
    cp "${SCRIPT_DIR}/systemd/easyeffects.service" "${SYSTEMD_USER_DIR}/easyeffects.service"
    systemctl --user daemon-reload
    info "EasyEffects systemd unit installed"
fi

if systemctl --user enable --now easyeffects 2>/dev/null; then
    info "EasyEffects service enabled — starts automatically on login"
    info "Audio effects persist even after closing the terminal"
else
    warn "Could not enable systemd service — using fallback startup"
    # Fallback: add to autostart for DEs that support XDG autostart
    AUTOSTART_DIR="${HOME}/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    cat > "${AUTOSTART_DIR}/easyeffects-service.desktop" <<EOF
[Desktop Entry]
Name=EasyEffects Service
Comment=Audio effects service
Exec=easyeffects --service-mode
Type=Application
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false
EOF
    info "Added EasyEffects to XDG autostart (${AUTOSTART_DIR})"
fi

# ── Install CLI tools ─────────────────────────────────────────────────────────
step "Installing CLI tools..."
mkdir -p "$BIN_DIR"

cp "${SCRIPT_DIR}/audiofx"         "${BIN_DIR}/audiofx"
cp "${SCRIPT_DIR}/bin/audiofx-smart" "${BIN_DIR}/audiofx-smart"
cp "${SCRIPT_DIR}/bin/audio-mode"  "${BIN_DIR}/audio-mode"
chmod +x "${BIN_DIR}/audiofx" "${BIN_DIR}/audiofx-smart" "${BIN_DIR}/audio-mode"

info "audiofx CLI installed"
info "audiofx-smart (device detector) installed"
info "audio-mode (keybinding script) installed"

# Check PATH
if ! echo "$PATH" | grep -q "${BIN_DIR}"; then
    warn "${BIN_DIR} is not in PATH"
    SHELL_RC=""
    [[ -f "${HOME}/.zshrc" ]]  && SHELL_RC="${HOME}/.zshrc"
    [[ -f "${HOME}/.bashrc" ]] && SHELL_RC="${HOME}/.bashrc"
    if [[ -n "$SHELL_RC" ]]; then
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        info "Added to ${SHELL_RC} — run: source ${SHELL_RC}"
    else
        tip "Add to your shell rc: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

mkdir -p "$CONFIG_DIR"

# ── Detect desktop environment / WM and register keybinding ──────────────────
step "Setting up Super+M keybinding..."

WM="unknown"

# Detect WM/DE
[[ -n "${XDG_CURRENT_DESKTOP:-}" ]] && DESKTOP="${XDG_CURRENT_DESKTOP,,}" || DESKTOP=""
[[ -n "${DESKTOP_SESSION:-}" ]]     && SESSION="${DESKTOP_SESSION,,}"      || SESSION=""
command -v hyprctl &>/dev/null      && WM="hyprland"
[[ "$DESKTOP" == *"gnome"* ]]       && WM="gnome"
[[ "$DESKTOP" == *"kde"* ]]         && WM="kde"
[[ "$SESSION" == *"i3"* ]]          && WM="i3"
[[ "$SESSION" == *"sway"* ]]        && WM="sway"

case "$WM" in

    hyprland)
        # Check if Omarchy bindings.lua exists
        if [[ -f "${HOME}/.config/hypr/bindings.lua" ]]; then
            if grep -q "audio-mode" "${HOME}/.config/hypr/bindings.lua"; then
                info "Super+M already registered in Omarchy bindings.lua"
            else
                printf '\n-- Audio FX: cycle all presets (Super+M)\no.bind("SUPER + M", "Audio Mode", "audio-mode")\n' \
                    >> "${HOME}/.config/hypr/bindings.lua"
                info "Added Super+M to ~/.config/hypr/bindings.lua"
                warn "Reload Hyprland: Super+Shift+R"
            fi
        else
            # Raw Hyprland — find hyprland.conf
            HYPR_CONF="${HOME}/.config/hypr/hyprland.conf"
            if [[ -f "$HYPR_CONF" ]]; then
                if grep -q "audio-mode" "$HYPR_CONF"; then
                    info "Super+M already in hyprland.conf"
                else
                    echo "" >> "$HYPR_CONF"
                    echo "# Audio FX: cycle all presets" >> "$HYPR_CONF"
                    echo "bind = SUPER, M, exec, audio-mode" >> "$HYPR_CONF"
                    info "Added Super+M to hyprland.conf"
                    warn "Reload Hyprland: hyprctl reload"
                fi
            else
                warn "Hyprland detected but no config found. Add manually:"
                tip "bind = SUPER, M, exec, audio-mode"
            fi
        fi
        ;;

    gnome)
        info "GNOME detected — adding Super+M custom shortcut"
        # Check if gsettings is available
        if command -v gsettings &>/dev/null; then
            BINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/audiofx/"
            gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${BINDING_PATH}" name    "Audio FX" 2>/dev/null || true
            gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${BINDING_PATH}" command "${BIN_DIR}/audio-mode" 2>/dev/null || true
            gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${BINDING_PATH}" binding "<Super>m" 2>/dev/null || true
            # Register in list
            CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "@as []")
            if ! echo "$CURRENT" | grep -q "audiofx"; then
                NEW=$(echo "$CURRENT" | sed "s|]|, '${BINDING_PATH}']|" | sed "s|\[@as \[\], |['|")
                gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['${BINDING_PATH}']" 2>/dev/null || true
            fi
            info "Super+M bound in GNOME"
        else
            warn "Could not auto-bind. In GNOME Settings → Keyboard → Custom Shortcuts:"
            tip "Name: Audio FX  |  Command: ${BIN_DIR}/audio-mode  |  Key: Super+M"
        fi
        ;;

    kde)
        info "KDE Plasma detected"
        if command -v kwriteconfig5 &>/dev/null || command -v kwriteconfig6 &>/dev/null; then
            KWRITE=$(command -v kwriteconfig6 2>/dev/null || command -v kwriteconfig5)
            $KWRITE --file kglobalshortcutsrc --group "audiofx.desktop" --key "cycle-audio-mode" "Meta+M,none,Cycle Audio FX" 2>/dev/null || true
            # Write .desktop file for KDE
            mkdir -p "${HOME}/.local/share/applications"
            cat > "${HOME}/.local/share/applications/audiofx.desktop" <<EOF
[Desktop Entry]
Name=Audio FX
Exec=${BIN_DIR}/audio-mode
Type=Application
NoDisplay=true

[Desktop Action cycle-audio-mode]
Name=Cycle Audio FX
Exec=${BIN_DIR}/audio-mode
EOF
            info "KDE shortcut configured — you may need to add it via System Settings → Shortcuts"
        else
            warn "Go to System Settings → Shortcuts → Custom Shortcuts:"
            tip "Command: ${BIN_DIR}/audio-mode  |  Key: Meta+M"
        fi
        ;;

    i3)
        I3_CONF="${HOME}/.config/i3/config"
        [[ ! -f "$I3_CONF" ]] && I3_CONF="${HOME}/.i3/config"
        if [[ -f "$I3_CONF" ]]; then
            if grep -q "audio-mode" "$I3_CONF"; then
                info "Super+M already in i3 config"
            else
                echo "" >> "$I3_CONF"
                echo "# Audio FX: cycle all presets" >> "$I3_CONF"
                echo "bindsym Mod4+m exec --no-startup-id ${BIN_DIR}/audio-mode" >> "$I3_CONF"
                info "Added Super+M to ${I3_CONF}"
                warn "Reload i3: Mod+Shift+R"
            fi
        else
            warn "i3 config not found. Add manually:"
            tip "bindsym Mod4+m exec --no-startup-id ${BIN_DIR}/audio-mode"
        fi
        ;;

    sway)
        SWAY_CONF="${HOME}/.config/sway/config"
        if [[ -f "$SWAY_CONF" ]]; then
            if grep -q "audio-mode" "$SWAY_CONF"; then
                info "Super+M already in Sway config"
            else
                echo "" >> "$SWAY_CONF"
                echo "# Audio FX: cycle all presets" >> "$SWAY_CONF"
                echo "bindsym Mod4+m exec ${BIN_DIR}/audio-mode" >> "$SWAY_CONF"
                info "Added Super+M to ${SWAY_CONF}"
                warn "Reload Sway: Mod+Shift+C"
            fi
        else
            warn "Sway config not found. Add manually:"
            tip "bindsym Mod4+m exec ${BIN_DIR}/audio-mode"
        fi
        ;;

    *)
        warn "Window manager not detected. Add Super+M manually:"
        echo ""
        echo -e "   ${BOLD}Hyprland:${RESET}"
        tip "bind = SUPER, M, exec, audio-mode"
        echo -e "   ${BOLD}i3 / Sway:${RESET}"
        tip "bindsym Mod4+m exec ${BIN_DIR}/audio-mode"
        echo -e "   ${BOLD}GNOME:${RESET}"
        tip "Settings → Keyboard → Custom Shortcuts → Command: audio-mode → Key: Super+M"
        echo -e "   ${BOLD}KDE:${RESET}"
        tip "System Settings → Shortcuts → Custom Shortcuts → Command: audio-mode → Key: Meta+M"
        echo ""
        ;;
esac

# ── Omarchy plugin (optional) ─────────────────────────────────────────────────
OMARCHY_PLUGIN_DIR="${HOME}/.config/omarchy/plugins"
if [[ -d "$OMARCHY_PLUGIN_DIR" ]]; then
    step "Installing Omarchy bar plugin..."
    cp -r "${SCRIPT_DIR}/plugins/pr4xh4r.audiofx" "${OMARCHY_PLUGIN_DIR}/"
    info "pr4xh4r.audiofx bar plugin installed"
    tip "Restart Quickshell to load: omarchy-shell shell restart"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e " ${BOLD}🎉 Done!${RESET}"
echo ""
echo -e " ${BOLD}Try it now:${RESET}"
echo -e "   audiofx list"
echo -e "   audiofx set Marshall"
echo -e "   audiofx set Dolby-Atmos"
echo -e "   audiofx device          ${DIM}# see what was detected${RESET}"
echo ""
echo -e " ${CYAN}Or press Super+M to start cycling.${RESET}"
echo ""
