FROM debian:latest

RUN apt-get update 

RUN apt-get install -y git x11vnc xvfb dbus dbus-x11 
RUN apt-get install -y openbox lxpanel lxterminal menu
RUN apt-get install -y conky gdebi curl wget nano 

RUN wget -O /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    gdebi --n /tmp/google-chrome-stable.deb && \
    rm /tmp/google-chrome-stable.deb

RUN git clone https://github.com/novnc/noVNC /opt/noVNC && \
    chmod +x /opt/noVNC/utils/novnc_proxy && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html

RUN git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

RUN sed -i 's|Exec=/usr/bin/google-chrome-stable %U|Exec=/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds %U |' /usr/share/applications/com.google.Chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable|Exec=/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds |' /usr/share/applications/com.google.Chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable --incognito|Exec=/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds --incognito |' /usr/share/applications/com.google.Chrome.desktop

RUN sed -i 's|Exec=/usr/bin/google-chrome-stable %U|Exec=/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds %U |' /usr/share/applications/google-chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable|Exec=/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds |' /usr/share/applications/google-chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable --incognito|Exec=/usr/bin/google-chrome-stable --no-sandbox --disable-gpu --disable-dbus --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds --incognito |' /usr/share/applications/google-chrome.desktop

RUN rm -rf /var/lib/apt/lists/*

EXPOSE 5901 6080

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
