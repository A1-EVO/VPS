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

install_3xui() {
    echo -e "${GREEN}Устанавливаю 3x-ui...${NC}"
    bash <(curl -Ls https://raw.githubusercontent.com/MHSanaei/3x-ui/master/install.sh)
}

update_script() {
    echo -e "${GREEN}Обновляю скрипт с GitHub...${NC}"
    curl -L https://raw.githubusercontent.com/A1-EVO/VPS/main/vps-menu.sh -o /usr/local/vps-menu/vps-menu.sh
    chmod +x /usr/local/vps-menu/vps-menu.sh
    echo -e "${GREEN}Скрипт обновлён! Перезапустите меню командой: start${NC}"
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
    echo "12) Установить 3x-ui"
    echo "98) Обновить скрипт с GitHub"
    echo "99) Удалить скрипт"
    echo "0) Выход"
    echo
    read -p "Выберите действие: " choice

    case "$choice" in
        1) update_repos ;;
        12) install_3xui ;;
        98) update_script ;;
        99) remove_script ;;
        0) exit 0 ;;
        *) echo -e "${RED}Неизвестная команда${NC}" ;;
    esac

    echo
    read -p "Нажмите Enter чтобы продолжить..."
done
