#!/bin/bash

echo "=== HarinOS Auto Installer ==="

# List of packages you want
PKGS=(
    openbox
    obconf
    tint2
    picom
    lxappearance
    lxterminal
    pcmanfm
    feh
    breeze-icons
    ttf-jetbrains-mono-nerd
    lightdm
    lightdm-gtk-greeter
    xorg-server
    xorg-xinit
    firefox
    network-manager-applet
)

echo "[1] Updating pacman database..."
sudo rm -f /var/lib/pacman/sync/*.db
sudo pacman -Syy

echo ""
echo "=== Installing main packages ==="

for pkg in "${PKGS[@]}"; do
    echo ""
    echo "➡ Installing: $pkg"
    sudo pacman -S --noconfirm "$pkg"

    if [[ $? -ne 0 ]]; then
        echo "❗ Pacman failed to install $pkg"

        # Try fallback repo refresh
        echo "➡ Trying fallback mirror..."
        echo "Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch" | sudo tee /etc/pacman.d/mirrorlist
        sudo pacman -Syy

        echo "➡ Trying reinstall: $pkg"
        sudo pacman -S --noconfirm "$pkg"
        
        # If still not installed → try AUR (yay)
        if [[ $? -ne 0 ]]; then
            echo "⚠ $pkg still failed — checking if AUR package..."

            if command -v yay >/dev/null 2>&1; then
                echo "➡ Trying AUR install using yay..."
                yay -S --noconfirm "$pkg"
            else
                echo "❌ AUR helper not found. Installing yay first..."

                sudo pacman -S --needed --noconfirm git base-devel
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                cd /tmp/yay && makepkg -si --noconfirm
                
                echo "➡ Retrying AUR install: $pkg"
                yay -S --noconfirm "$pkg"
            fi
        fi
    fi
done

echo ""
echo "=== Enabling services ==="
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager

echo ""
echo "=== DONE! HarinOS components installed ==="
echo "Reboot and login with LightDM."