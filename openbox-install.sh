#!/bin/sh

echo "=== Updating system ==="
apk update && apk upgrade

echo "=== Installing build tools ==="
apk add build-base autoconf automake libtool pkgconf git wget cmake

echo "=== Installing Xorg ==="
apk add xorg-server xorg-base xinit xf86-input-evdev xf86-video-vesa xf86-video-vmware

echo "=== Installing Mesa (OpenGL) ==="
apk add mesa mesa-dri-gallium mesa-egl mesa-gl mesa-gles mesa-glapi mesa-dri-vmwgfx

echo "=== Installing fonts ==="
apk add font-misc-misc font-cursor-misc font-dejavu font-terminus
apk add mkfontscale mkfontdir
fc-cache -fv

echo "=== Installing libraries for Openbox ==="
apk add pango-dev cairo-dev glib-dev libxml2-dev \
        startup-notification-dev imlib2-dev libev-dev libxcb-dev dbus-dev xorg-server-dev

echo "=== Building Openbox ==="
cd /root
wget https://openbox.org/dist/openbox/openbox-3.6.1.tar.gz
tar xf openbox-3.6.1.tar.gz
cd openbox-3.6.1
./configure --prefix=/usr
make -j$(nproc)
make install

echo "=== Setting up Openbox config ==="
mkdir -p ~/.config/openbox
cp /usr/share/openbox/*.xml ~/.config/openbox/

echo "=== Creating .xinitrc ==="
echo "exec openbox-session" > ~/.xinitrc

echo "=== Installing urxvt terminal ==="
apk add rxvt-unicode rxvt-unicode-terminfo

echo "=== Installing file manager (PCManFM) ==="
apk add pcmanfm gvfs

echo "=== Installing nitrogen wallpaper tool ==="
apk add nitrogen

echo "=== Installing themes & icons ==="
apk add arc-theme papirus-icon-theme adwaita-icon-theme

echo "=== Installing tint2 ==="
apk add tint2 || (
    echo "Tint2 not in repo — compiling..."
    git clone https://gitlab.com/o9000/tint2.git /root/tint2
    cd /root/tint2
    mkdir build && cd build
    cmake ..
    make -j$(nproc)
    make install
)

echo "=== Creating Openbox autostart ==="
cat <<EOF > ~/.config/openbox/autostart
tint2 &
urxvt &
nitrogen --restore &
pcmanfm --desktop &
EOF

echo "=== Adding keybindings (Super+Enter, Super+R, etc.) ==="
sed -i '/<keyboard>/,/<\/keyboard>/d' ~/.config/openbox/rc.xml

cat <<EOF >> ~/.config/openbox/rc.xml
<keyboard>
  <keybind key="W-Return">
    <action name="Execute"><command>urxvt</command></action>
  </keybind>

  <keybind key="W-r">
    <action name="Execute"><command>dmenu_run</command></action>
  </keybind>

  <keybind key="W-d">
    <action name="ToggleShowDesktop"/>
  </keybind>

  <keybind key="W-q">
    <action name="Exit"/>
  </keybind>
</keyboard>
EOF

echo "=== Installing dmenu ==="
apk add dmenu

echo "=== Creating right-click menu ==="
cp /etc/xdg/openbox/menu.xml ~/.config/openbox/
openbox --reconfigure

echo "=== ALL DONE! Run 'startx' to enter your new desktop ==="