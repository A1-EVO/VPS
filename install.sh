#!/bin/bash

set -e

# Куда ставим меню
INSTALL_DIR="/usr/local/vps-menu"

# Создаём папку если нет
mkdir -p "$INSTALL_DIR"

# Качаем последнюю версию из GitHub
curl -L "https://raw.githubusercontent.com/A1-EVO/VPS/main/vps-menu.sh?$(date +%s)-$RANDOM" \
    -o "$INSTALL_DIR/vps-menu.sh"


# Делаем исполняемым
chmod +x "$INSTALL_DIR/vps-menu.sh"

# Создаём команду start
ln -sf "$INSTALL_DIR/vps-menu.sh" /usr/local/bin/start

start
