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

## Installation
### **Build the Docker image**
```bash
docker build -t dockerized-lightweight-desktop .
