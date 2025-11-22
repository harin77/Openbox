#!/bin/bash

echo "=== HarinOS Openbox Auto Setup Script ==="

echo ""
echo "Creating Openbox config directory..."
mkdir -p ~/.config/openbox
cp /etc/xdg/openbox/* ~/.config/openbox/

echo ""
echo "Creating picom config..."
mkdir -p ~/.config
cat <<EOF > ~/.config/picom.conf
backend = "glx";
vsync = true;

shadow = true;
shadow-radius = 16;
shadow-opacity = 0.35;

blur-method = "dual_kawase";
blur-strength = 5;

fade-in-step = 0.02;
fade-out-step = 0.02;
EOF

echo ""
echo "Creating Openbox autostart..."
cat <<EOF > ~/.config/openbox/autostart
nitrogen --restore &
tint2 &
picom --config ~/.config/picom.conf &
nm-applet &
pcmanfm --daemon &
EOF

echo ""
echo "Creating wallpaper folder..."
mkdir -p ~/.wallpapers

echo ""
echo "Creating Openbox menu..."
cat <<EOF > ~/.config/openbox/menu.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu>
    <menu id="root-menu" label="HarinOS Menu">

        <item label="Terminal">
            <action name="Execute">
                <command>lxterminal</command>
            </action>
        </item>

        <item label="File Manager">
            <action name="Execute">
                <command>pcmanfm</command>
            </action>
        </item>

        <item label="Browser">
            <action name="Execute">
                <command>firefox</command>
            </action>
        </item>

        <separator/>

        <item label="Reconfigure">
            <action name="Reconfigure"/>
        </item>

        <item label="Restart Openbox">
            <action name="Restart"/>
        </item>

        <item label="Exit to LightDM">
            <action name="Exit"/>
        </item>

    </menu>
</openbox_menu>
EOF

echo ""
echo "Setting wallpaper via Nitrogen (will apply on next login)..."

# Create nitrogen config
mkdir -p ~/.config/nitrogen
cat <<EOF > ~/.config/nitrogen/bg-saved.cfg
[xin_0]
file=/home/$USER/.wallpapers
mode=4
bgcolor=#000000
EOF

echo ""
echo "Fixing permissions..."
chmod +x ~/.config/openbox/autostart

echo ""
echo "Reloading Openbox config..."
openbox --reconfigure 2>/dev/null

echo ""
echo "Restarting LightDM..."
sudo systemctl restart lightdm

echo ""
echo "=== DONE! Login again to see your full Openbox desktop ==="