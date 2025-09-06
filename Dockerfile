FROM debian:bullseye-slim
 
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y \
    git x11vnc xvfb dbus dbus-x11 \
    && apt-get autoclean -y && apt-get autoremove -y && apt-get autopurge -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update -y && apt-get install -y \
    openbox lxpanel lxterminal conky-all \
    && apt-get autoclean -y && apt-get autoremove -y && apt-get autopurge -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update -y && apt-get install -y \
    scrot gdebi curl wget nano htop net-tools jq iproute2 iputils-ping procps \
    && apt-get autoclean -y && apt-get autoremove -y && apt-get autopurge -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update -y && wget -O /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    gdebi --n /tmp/google-chrome-stable.deb && \
    rm /tmp/google-chrome-stable.deb \
    && apt-get autoclean -y && apt-get autoremove -y && apt-get autopurge -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/novnc/noVNC /opt/noVNC && \
    chmod +x /opt/noVNC/utils/novnc_proxy && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html

RUN git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

RUN sed -i 's|Exec=/usr/bin/google-chrome-stable %U|Exec=/usr/bin/google-chrome-stable --disable-gpu --disable-dbus --no-sandbox --no-process-singleton-dialog --no-default-browser-check --no-first-run --no-managed-user-acknowledgment --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds %U |' /usr/share/applications/com.google.Chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable|Exec=/usr/bin/google-chrome-stable --disable-gpu --disable-dbus --no-sandbox --no-process-singleton-dialog --no-default-browser-check --no-first-run --no-managed-user-acknowledgment --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds |' /usr/share/applications/com.google.Chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable --incognito|Exec=/usr/bin/google-chrome-stable --disable-gpu --disable-dbus --no-sandbox --no-process-singleton-dialog --no-default-browser-check --no-first-run --no-managed-user-acknowledgment --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds --incognito |' /usr/share/applications/com.google.Chrome.desktop

RUN sed -i 's|Exec=/usr/bin/google-chrome-stable %U|Exec=/usr/bin/google-chrome-stable --disable-gpu --disable-dbus --no-sandbox --no-process-singleton-dialog --no-default-browser-check --no-first-run --no-managed-user-acknowledgment --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds %U |' /usr/share/applications/google-chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable|Exec=/usr/bin/google-chrome-stable --disable-gpu --disable-dbus --no-sandbox --no-process-singleton-dialog --no-default-browser-check --no-first-run --no-managed-user-acknowledgment --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds |' /usr/share/applications/google-chrome.desktop
RUN sed -i 's|Exec=/usr/bin/google-chrome-stable --incognito|Exec=/usr/bin/google-chrome-stable --disable-gpu --disable-dbus --no-sandbox --no-process-singleton-dialog --no-default-browser-check --no-first-run --no-managed-user-acknowledgment --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds --incognito |' /usr/share/applications/google-chrome.desktop

RUN echo '#!/bin/bash' > /usr/local/bin/google-chrome-no-sandbox && \
    echo '/usr/bin/google-chrome-stable --disable-gpu --disable-dbus --no-sandbox --no-process-singleton-dialog --no-default-browser-check --no-first-run --no-managed-user-acknowledgment --enable-unsafe-swiftshader --use-gl=swiftshader --ignore-gpu-blocklist --disable-gpu-driver-bug-workarounds "$@"' >> /usr/local/bin/google-chrome-no-sandbox && \
    chmod +x /usr/local/bin/google-chrome-no-sandbox && \
    update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/google-chrome-no-sandbox 100 && \
    update-alternatives --set x-www-browser /usr/local/bin/google-chrome-no-sandbox && \
    update-alternatives --set x-terminal-emulator /usr/bin/lxterminal

COPY conf/conky.conf /etc/conky/conky.conf

EXPOSE 5901 6080

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
