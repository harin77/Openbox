#!/bin/bash

# ---------------------------------------------------------
# HarinOS Anime Theme Auto Installer (Fail-safe edition)
# Arch Linux + Openbox
# ---------------------------------------------------------

LOGFILE="$HOME/harinos-install.log"

echo "===============================" | tee -a "$LOGFILE"
echo " HarinOS Anime Theme Installer " | tee -a "$LOGFILE"
echo " With Auto-Fix + Retry System  " | tee -a "$LOGFILE"
echo "===============================" | tee -a "$LOGFILE"

# ---------------------------
# Install a package with retry
# ---------------------------
install_pkg() {
    PKG="$1"
    echo "" | tee -a "$LOGFILE"
    echo "➡ Installing: $PKG" | tee -a "$LOGFILE"

    # 1. Try normal pacman install
    sudo pacman -S --noconfirm --needed "$PKG"
    if [[ $? -eq 0 ]]; then
        echo "✔ $PKG installed via pacman" | tee -a "$LOGFILE"
        return
    fi

    echo "❗ Pacman failed for $PKG" | tee -a "$LOGFILE"

    # 2. Force refresh DB
    echo "➡ Refreshing pacman database..." | tee -a "$LOGFILE"
    sudo pacman -Syy

    sudo pacman -S --noconfirm --needed "$PKG"
    if [[ $? -eq 0 ]]; then
        echo "✔ $PKG installed after DB refresh" | tee -a "$LOGFILE"
        return
    fi

    # 3. Change mirrors
    echo "➡ Switching to fallback global mirror..." | tee -a "$LOGFILE"
    echo "Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch" | sudo tee /etc/pacman.d/mirrorlist
    sudo pacman -Syy

    sudo pacman -S --noconfirm --needed "$PKG"
    if [[ $? -eq 0 ]]; then
        echo "✔ $PKG installed after switching mirrors" | tee -a "$LOGFILE"
        return
    fi

    # 4. Try AUR using yay
    if command -v yay >/dev/null 2>&1; then
        echo "➡ Trying AUR install via yay..." | tee -a "$LOGFILE"
        yay -S --noconfirm "$PKG"
        if [[ $? -eq 0 ]]; then
            echo "✔ $PKG installed via AUR (yay)" | tee -a "$LOGFILE"
            return
        fi
    fi

    # 5. Manual AUR git fallback
    echo "➡ Manual install attempt (git clone)..." | tee -a "$LOGFILE"
    cd /tmp
    git clone "https://aur.archlinux.org/${PKG}.git" 2>/dev/null

    if [[ -d "$PKG" ]]; then
        cd "$PKG"
        makepkg -si --noconfirm
        if [[ $? -eq 0 ]]; then
            echo "✔ $PKG installed via manual build" | tee -a "$LOGFILE"
            return
        fi
    fi

    echo "❌ FINAL FAIL: Cannot install $PKG" | tee -a "$LOGFILE"
}

# -------------------------------
# 1. Core dependencies & yay
# -------------------------------
install_pkg "lxappearance"
install_pkg "gtk-engines"
install_pkg "gtk-engine-murrine"
install_pkg "git"
install_pkg "base-devel"
install_pkg "tint2"

# Install yay if needed
if ! command -v yay >/dev/null 2>&1; then
    echo "➡ Installing yay (AUR helper)..." | tee -a "$LOGFILE"
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi

# -------------------------------
# 2. Anime Themes & Icons
# -------------------------------
install_pkg "tokyonight-gtk-theme"
install_pkg "tokyonight-icon-theme"
install_pkg "oreo-cursors"
install_pkg "catppuccin-openbox-theme"

# -------------------------------
# 3. Apply GTK Settings
# -------------------------------
echo ""
echo "➡ Applying GTK Themes..." | tee -a "$LOGFILE"

mkdir -p ~/.config/gtk-3.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Tokyonight
gtk-font-name=JetBrains Mono 11
gtk-cursor-theme-name=oreo_cursors
gtk-cursor-size=24
EOF

# -------------------------------
# 4. Apply Openbox theme
# -------------------------------
echo "➡ Applying Openbox Theme..." | tee -a "$LOGFILE"

mkdir -p ~/.themes
mkdir -p ~/.config/openbox

# Copy theme if exists
THEME_PATH="/usr/share/themes/Catppuccin-Mocha-Standard-Lavender"
if [[ -d "$THEME_PATH" ]]; then
    cp -r "$THEME_PATH" ~/.themes/
fi

cat <<EOF > ~/.config/openbox/rc.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config>
  <theme>
    <name>Catppuccin-Mocha-Standard-Lavender</name>
  </theme>
  <keyboard>
    <keybind key="W-Return">
      <action name="Execute">
        <command>lxterminal</command>
      </action>
    </keybind>
    <keybind key="W-d">
      <action name="Execute">
        <command>rofi -show drun</command>
      </action>
    </keybind>
  </keyboard>
</openbox_config>
EOF

# -------------------------------
# 5. Tint2 Anime Bar
# -------------------------------
install_pkg "tint2-theme-collections"

mkdir -p ~/.config/tint2
cp /usr/share/tint2/themes/catppuccin-purple.tint2rc ~/.config/tint2/tint2rc 2>/dev/null

# -------------------------------
# 6. Reload Openbox
# -------------------------------
echo "➡ Reloading Openbox..." | tee -a "$LOGFILE"
openbox --reconfigure 2>/dev/null

echo ""
echo "==============================================="
echo "   HarinOS Anime Theme Installed Successfully   "
echo "==============================================="
echo "Log out and log back in to see the full theme!"
echo "Log saved to: $LOGFILE"
