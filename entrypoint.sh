#!/bin/bash

echo "Starting up ..."
set -e
mkdir -p ~/.vnc
mkdir -p ~/.config/google-chrome
mkdir -p ~/Templates
mkdir -p /run/dbus
mkdir -p /run/user/$(id -u)
chmod 700 /run/user/$(id -u)
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$(id -u)
echo "$DISPLAY"
echo "$XDG_RUNTIME_DIR"
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

echo "Setting defaults ..."
cat <<EOF > /usr/local/bin/google-chrome-no-sandbox
#!/bin/bash
/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds "\$@"
EOF
chmod +x /usr/local/bin/google-chrome-no-sandbox
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/google-chrome-no-sandbox 100
update-alternatives --set x-www-browser /usr/local/bin/google-chrome-no-sandbox
update-alternatives --set x-terminal-emulator /usr/bin/lxterminal
echo " "

echo "Starting virtual framebuffer ..."
Xvfb $VNC_DISPLAY -screen 0 $SCREEN_RESOLUTION &
for i in {1..3}; do
    echo "Waiting for Xvfb to start..."
    sleep 5
    if pgrep -x Xvfb > /dev/null; then
        echo "Xvfb started successfully!"
        break
    elif [ "$i" -eq 3 ]; then
        echo "ERROR: Xvfb failed to start."
        exit 255
    fi
done
echo " "

echo "Starting D-Bus..."
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
dbus-uuidgen > /etc/machine-id
dbus-daemon --system --fork
for i in {1..3}; do
    echo "Waiting for D-Bus to start..."
    sleep 5
    if pgrep -x dbus-daemon > /dev/null; then
        echo "D-Bus started successfully!"
        break
    elif [ "$i" -eq 3 ]; then
        echo "ERROR: D-Bus failed to start."
        exit 255
    fi
done
echo " "

echo "Starting Openbox..."
openbox &
for i in {1..3}; do
    echo "Waiting for Openbox to start..."
    sleep 5
    if pgrep -x openbox > /dev/null; then
        echo "Openbox started successfully!"
        break
    elif [ "$i" -eq 3 ]; then
        echo "ERROR: Openbox failed to start."
        exit 255
    fi
done
echo " "

echo "Starting LXPanel..."
lxpanel &
for i in {1..3}; do
    echo "Waiting for LXPanel to start..."
    sleep 5
    if pgrep -x lxpanel > /dev/null; then
        echo "LXPanel started successfully!"
        break
    elif [ "$i" -eq 3 ]; then
        echo "ERROR: LXPanel failed to start."
        exit 255
    fi
done
echo " "

echo "Starting Conky..."
conky -d
for i in {1..3}; do
    echo "Waiting for Conky to start..."
    sleep 5
    if pgrep -x conky > /dev/null; then
        echo "Conky started successfully!"
        break
    elif [ "$i" -eq 3 ]; then
        echo "ERROR: Conky failed to start."
        exit 255
    fi
done
echo " "

echo "Starting the VNC server ..."
x11vnc -storepasswd "$VNC_PASS" ~/.vnc/passwd
x11vnc -quiet -display $VNC_DISPLAY -rfbauth ~/.vnc/passwd -forever -rfbport $VNC_PORT -localhost &
for i in {1..3}; do
    echo "Waiting for VNC server to start..."
    sleep 5
    if pgrep -x x11vnc > /dev/null; then
        echo "VNC server started successfully!"
        break
    elif [ "$i" -eq 3 ]; then
        echo "ERROR: VNC server failed to start."
        exit 255
    fi
done
echo " "

echo "Starting noVNC on port $NOVNC_PORT..."
/opt/noVNC/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NOVNC_PORT &
for i in {1..3}; do
    echo "Waiting for noVNC to start..."
    sleep 5
    if pgrep -f "novnc_proxy|websockify|run" > /dev/null; then
        echo "noVNC started successfully!"
        break
    elif [ "$i" -eq 3 ]; then
        echo "ERROR: noVNC failed to start."
        exit 255
    fi
done
echo " "

# echo "##### Running Indefinitely #####"
# while true; do sleep 86400; done 
# echo " "

echo " [ NO SLEEP ... ] "
echo " [ NO SLEEP ... ] "
echo " [ NO SLEEP ... ] "
echo " [ NO SLEEP ... ] "
echo " [ NO SLEEP ... ] "
