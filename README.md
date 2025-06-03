# Docker-SlimVNC

## Overview
A Dockerized desktop environment featuring Openbox, LXPanel, and Conky for a lightweight, efficient setup. It includes Google Chrome with adjusted flags, a VNC server for remote access, and noVNC for web-based control, offering a functional virtual workspace optimized for performance and usability.

## Features
- **Minimal Debian-based desktop environment**
- **Integrated Google Chrome with sandboxing adjustments**
- **VNC server for remote access**
- **Web-based VNC via noVNC**
- **System monitoring with Conky**
- **Optimized usability within containerized setups**

## Run
```
docker volume create docker-slimvnc-google-chrome

docker run -d --name docker-slimvnc \
  -p 5901:5901 -p 6080:6080 \
  --shm-size=2gb \
  -v docker-slimvnc-google-chrome:/root/.config/google-chrome \
  ghcr.io/techroy23/docker-slimvnc:latest
```

## Access
- VNC Client: localhost:5901
- Web Interface (noVNC): http://localhost:6080
