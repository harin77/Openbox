#!/bin/bash
#
# HarinOS Anime Theme Auto Installer
# Arch Linux + Openbox (2025 Edition)
#
# Installs:
#  - Tokyonight GTK Theme
#  - Tokyonight Icon Pack
#  - Catppuccin Openbox Theme
#  - Anime Cursor (Oreo Cursors)
#  - Tint2 Anime Bar
#  - LXAppearance (for theme control)
#  - Applies all configurations automatically
#

echo "==========================================="
echo "     HarinOS Anime Theme Auto Installer     "
echo "==========================================="

# -------------------------------------------
# 1. Install Dependencies
# -------------------------------------------

echo "[1] Installing Dependencies..."
sudo pacman -S --needed --noconfirm \
    lxappearance \
    git \
    base-devel \
    gtk-engines \
    gtk-engine-murrine \
    tint2

# -------------------------------------------
# 2. Install yay (AUR Helper)
# -------------------------------------------

if ! command -v yay >/dev/null 2>&1; then
    echo "[2] Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
else
    echo "[2] yay already installed."
fi

# -------------------------------------------
# 3. Install Anime Themes (AUR)
# -------------------------------------------

echo "[3] Installing Tokyonight GTK Theme..."
yay -S --noconfirm tokyonight-gtk-theme

echo "[4] Installing Tokyonight Icon Theme..."
yay -S --noconfirm tokyonight-icon-theme

echo "[5] Installing Anime Cursor Theme..."
yay -S --noconfirm oreo-cursors

echo "[6] Installing Catppuccin Openbox Theme..."
yay -S --noconfirm catppuccin-openbox-theme

# -------------------------------------------
# 4. Apply GTK Theme, Icons, Cursor
# -------------------------------------------

echo "[7] Applying GTK / Icon / Cursor Themes..."
mkdir -p ~/.config/gtk-3.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Tokyonight
gtk-font-name=JetBrains Mono 11
gtk-cursor-theme-name=oreo_cursors
gtk-cursor-size=24
EOF

# -------------------------------------------
# 5. Apply Openbox Theme
# -------------------------------------------

echo "[8] Applying Openbox Theme..."

mkdir -p ~/.themes
mkdir -p ~/.config/openbox

# Copy Catppuccin Openbox theme
cp -r /usr/share/themes/Catppuccin-Mocha-Standard-Lavender ~/.themes/ 2>/dev/null

# Create Openbox configuration
cat <<EOF > ~/.config/openbox/rc.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme>
    <name>Catppuccin-Mocha-Standard-Lavender</name>
    <titleLayout>NLIMC</titleLayout>
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

    <keybind key="W-f">
      <action name="Execute">
        <command>pcmanfm</command>
      </action>
    </keybind>
  </keyboard>
</openbox_config>
EOF

# -------------------------------------------
# 6. Install Anime Tint2 Bar
# -------------------------------------------

echo "[9] Installing Anime Tint2 Themes..."
yay -S --noconfirm tint2-theme-collections

mkdir -p ~/.config/tint2
cp /usr/share/tint2/themes/catppuccin-purple.tint2rc ~/.config/tint2/tint2rc 2>/dev/null

# -------------------------------------------
# 7. Reload Openbox
# -------------------------------------------

echo "[10] Reloading Openbox..."
openbox --reconfigure 2>/dev/null

echo ""
echo "===================================================="
echo " Anime Theme Installed Successfully on HarinOS 🎌  "
echo "  - Tokyonight GTK Theme"
echo "  - Tokyonight Icons"
echo "  - Catppuccin Openbox Theme"
echo "  - Oreo Anime Cursor"
echo "  - Anime Tint2 Bar"
echo "Please logout and log back in to see final look."
echo "===================================================="