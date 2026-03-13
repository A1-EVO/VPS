#!/bin/bash

# Цвета (необязательно, но красиво)
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

# --- ФУНКЦИИ ---

update_repos() {
    echo -e "${GREEN}Обновляю пакеты...${NC}"
    apt update && apt upgrade -y
}

performance_status() {
    echo -e "${GREEN}Запускаю диспечер...${NC}"
    /usr/local/vps-menu/sys-panel.sh
}

install_proxy() {
    echo -e "${GREEN}Устанавливаю proxy...${NC}"
    bash <(curl -Ls "https://raw.githubusercontent.com/A1-EVO/VPS/main/Proxy.sh?$(date +%s)-$RANDOM")
}

install_3xui() {
    echo -e "${GREEN}Устанавливаю 3x-ui...${NC}"
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
}

open_3xui() {
    echo -e "${GREEN}Открываю 3x-ui...${NC}"
    x-ui
}

update_script() {
    echo -e "${GREEN}Обновляю скрипт с GitHub...${NC}"

    TS=$(date +%s)
    RAND=$RANDOM

    curl -L "https://raw.githubusercontent.com/A1-EVO/VPS/main/vps-menu.sh?$TS-$RAND" \
        -o /usr/local/vps-menu/vps-menu.sh

    chmod +x /usr/local/vps-menu/vps-menu.sh

    # Качаем панель ретро
    curl -L "https://raw.githubusercontent.com/A1-EVO/VPS/main/sys-panel.sh?$(date +%s)-$RANDOM" \
    -o "$INSTALL_DIR/sys-panel.sh"
    # Делаем исполняемым
    chmod +x "$INSTALL_DIR/sys-panel.sh"

    echo -e "${GREEN}Скрипт обновлён!${NC}"
    echo
    read -p "Нажмите Enter для перезапуска меню..."

    exec /usr/local/vps-menu/vps-menu.sh
}


remove_script() {
    echo -e "${RED}Удаляю скрипт...${NC}"
    rm -f /usr/local/bin/start
    rm -rf /usr/local/vps-menu
    echo -e "${GREEN}Скрипт полностью удалён.${NC}"
    exit 0
}

# --- МЕНЮ ---

while true; do
    clear
    echo -e "${GREEN}=== VPS A1 MENU ===${NC}"
    echo "1) Обновить все репозитории"
    echo "2) Диспечер нагрузки"
    echo "3) Установить Proxy Telegram"
    echo "12) Установить 3x-ui"
    echo "13) Открыть меню 3x-ui"
    echo "14) Удалить 3x-ui"
    echo "98) Обновить скрипт с GitHub"
    echo "99) Удалить скрипт"
    echo "0) Выход"
    echo
    read -p "Выберите действие: " choice

    case "$choice" in
        1) update_repos ;;
        2) performance_status ;;
        3) install_proxy ;;
        12) install_3xui ;;
        13) open_3xui ;;
        98) update_script ;;
        99) remove_script ;;
        0) exit 0 ;;
        *) echo -e "${RED}Неизвестная команда${NC}" ;;
    esac

    echo
    read -p "Нажмите Enter чтобы продолжить..."
done
