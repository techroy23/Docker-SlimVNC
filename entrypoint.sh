#!/bin/bash

echo "Starting up ..."
set -e
export DISPLAY=:0
mkdir -p ~/Templates
echo " "

echo "Setting up variables ..."
if [ -z "$VNC_PASS" ]; then
    echo "WARNING: VNC_PASS was not set! Using default password: 'password'"
    echo "Consider redeploying the Docker container with -e VNC_PASS='your_secure_password'"
    export VNC_PASS="password"  # Default fallback
else
    export VNC_PASS
fi

VNC_DISPLAY=":0"
VNC_PORT=5901
NOVNC_PORT=6080
SCREEN_RESOLUTION="1600x900x24"
echo " "

echo "Setting default terminal emulator..."
update-alternatives --set x-terminal-emulator /usr/bin/lxterminal
echo " "

echo "Setting default web browser..."
mkdir -p ~/.config/google-chrome
tee /usr/local/bin/google-chrome-no-sandbox <<EOF
#!/bin/bash
/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus "\$@"
EOF
chmod +x /usr/local/bin/google-chrome-no-sandbox
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/google-chrome-no-sandbox 100
update-alternatives --set x-www-browser /usr/local/bin/google-chrome-no-sandbox
echo " "

echo "Storing the VNC password ..."
mkdir -p ~/.vnc
x11vnc -storepasswd "$VNC_PASS" ~/.vnc/passwd
echo " "

echo "Starting D-Bus..."
mkdir -p /run/dbus
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
dbus-uuidgen > /etc/machine-id
dbus-daemon --system --fork
echo " "

echo "Starting virtual framebuffer ..."
Xvfb $VNC_DISPLAY -screen 0 $SCREEN_RESOLUTION &

echo "Starting Openbox ..."
sleep 5
openbox &
echo " "

echo "Starting LXPanel ..."
sleep 5
lxpanel &
echo " "

echo "Starting Conky ..."
sleep 5
conky -d
echo " "

echo "Starting the VNC server ..."
x11vnc -quiet -display $VNC_DISPLAY -rfbauth ~/.vnc/passwd -forever -rfbport $VNC_PORT -localhost &
echo " "

echo "Starting WebSockify to bridge VNC to the web ..."
cd /opt/noVNC/utils/websockify
./run --web /opt/noVNC/ $NOVNC_PORT localhost:$VNC_PORT &> /opt/websockify.log &
echo " "

echo "##### Running Indefinitely #####"
tail -f /dev/null
wait
echo " "
