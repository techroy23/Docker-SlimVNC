#!/bin/bash
 
echo "### ### ### ### ###"
echo " Starting up ... "
echo "### ### ### ### ###"
set -e
mkdir -p ~/.vnc
mkdir -p ~/.config/google-chrome
mkdir -p ~/Templates
mkdir -p /run/dbus
mkdir -p /run/user/$(id -u)
chmod 700 /run/user/$(id -u)
export XDG_RUNTIME_DIR=/run/user/$(id -u)
echo "$DISPLAY"
echo "$XDG_RUNTIME_DIR"
echo " "

echo "### ### ### ### ### ### ### ###"
echo " Removing temporary files ... "
echo "### ### ### ### ### ### ### ###"
sleep 1
find /tmp -type l -exec unlink {} + &
sleep 1
rm -rf /tmp/* &
sleep 1
rm -f /run/dbus/pid  &
echo " "

echo "### ### ### ### ### ### ### ### ### ### ### ### ###"
echo " Checking Chrome and removing stale chrome files "
echo "### ### ### ### ### ### ### ### ### ### ### ### ###"
if [ -L "/root/.config/google-chrome/SingletonLock" ]; then
	echo " "
    echo "SingletonLock detected, attempting removal..."
    unlink /root/.config/google-chrome/SingletonLock 2>/dev/null && echo "The symlink for SingletonLock has been successfully removed."
    rm -f /root/.config/google-chrome/SingletonLock && echo "The SingletonLock file has been successfully removed."
fi

if [ -L "/root/.config/google-chrome/SingletonSocket" ]; then
	echo " "
    echo "SingletonSocket detected, attempting removal..."
    unlink /root/.config/google-chrome/SingletonSocket 2>/dev/null && echo "The symlink for SingletonSocket has been successfully removed."
    rm -f /root/.config/google-chrome/SingletonSocket && echo "The SingletonSocket file has been successfully removed."
fi

if [ -L "/root/.config/google-chrome/SingletonCookie" ]; then
	echo " "
    echo "SingletonCookie detected, attempting removal..."
    unlink /root/.config/google-chrome/SingletonCookie 2>/dev/null && echo "The symlink for SingletonCookie has been successfully removed."
    rm -f /root/.config/google-chrome/SingletonCookie && echo "The SingletonCookie file has been successfully removed."
fi
echo " "

echo "### ### ### ### ### ### ###"
echo " Setting up variables ... "
echo "### ### ### ### ### ### ###"
if [ -z "$VNC_PASS" ]; then
    echo "WARNING: VNC_PASS was not set! Using default password: 'password'"
    echo "Consider redeploying the Docker container with -e VNC_PASS='your_secure_password'"
    export VNC_PASS="password"  # Default fallback
else
    export VNC_PASS
fi
export DISPLAY=:0
export VNC_DISPLAY=":0"
DISPLAY=:0
VNC_DISPLAY=":0"
VNC_PORT=${VNC_PORT:-5901}
NOVNC_PORT=${NOVNC_PORT:-6080}
SCREEN_RESOLUTION="1600x900x24"
echo " "

echo "### ### ### ### ### ### ### ### ###"
echo " Starting virtual framebuffer ... "
echo "### ### ### ### ### ### ### ### ###"
max_attempts=999
attempt=0

while [ $attempt -lt $max_attempts ]; do
	new_display_num=$(shuf -i 100-10000 -n 1)
	export DISPLAY=":$new_display_num"
    export VNC_DISPLAY=":$new_display_num"
	DISPLAY=":$new_display_num"
    VNC_DISPLAY=":$new_display_num"
	echo "Attempt $((attempt+1)): Starting Xvfb on display $DISPLAY with resolution $SCREEN_RESOLUTION..."
    Xvfb $DISPLAY -screen 0 $SCREEN_RESOLUTION &
    sleep 3
    if pgrep -x Xvfb > /dev/null; then
        echo "Xvfb started successfully on display $DISPLAY!"
        break
    else
        echo "Xvfb failed to start on display $DISPLAY."
        if [ $attempt -lt $((max_attempts - 1)) ]; then
            new_display_num=$(shuf -i 100-1000 -n 1)
            export DISPLAY=":$new_display_num"
            export VNC_DISPLAY=":$new_display_num"
			DISPLAY=":$new_display_num"
            VNC_DISPLAY=":$new_display_num"
            echo "Trying alternative display: $DISPLAY"
        else
            echo "ERROR: Xvfb failed to start after $max_attempts attempts."
            exit 255
        fi
    fi
    attempt=$((attempt+1))
done
echo " "

echo "### ### ### ### ###"
echo " Starting D-Bus... "
echo "### ### ### ### ###"
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

echo "### ### ### ### ###"
echo "Starting Openbox..."
echo "### ### ### ### ###"
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

echo "### ### ### ### ###"
echo "Starting LXPanel..."
echo "### ### ### ### ###"
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

echo "### ### ### ### ###"
echo " Starting Conky... "
echo "### ### ### ### ###"
DISPLAY=$VNC_DISPLAY conky -d -b -X $VNC_DISPLAY
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

echo "### ### ### ### ### ### ###"
echo "Starting the VNC server ..."
echo "### ### ### ### ### ### ###"
x11vnc -storepasswd "$VNC_PASS" ~/.vnc/passwd
echo "Using $VNC_DISPLAY for display and $VNC_PORT for vnc port"
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

echo "### ### ### ### ### ### ### ### ### ###"
echo " Starting noVNC on port $NOVNC_PORT... "
echo "### ### ### ### ### ### ### ### ### ###"
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

echo "### ### ### ### ### ### ### ### ###"
echo " Starting custom-entrypoint.sh ... "
echo "### ### ### ### ### ### ### ### ###"
if [ -f "/custom-entrypoint.sh" ]; then
    echo "Running custom-entrypoint.sh in the background ..."
    /custom-entrypoint.sh &
else
    echo "Skipping custom-entrypoint.sh as it is not present."
fi
echo " "

echo "### ### ### ### ### ### ###"
echo " Running Indefinitely ... "
echo "### ### ### ### ### ### ###"
tail -f /dev/null
echo " "
