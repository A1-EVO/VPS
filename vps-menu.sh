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

# --- МЕНЮ ---

while true; do
    clear
    echo -e "${GREEN}=== VPS MENU ===${NC}"
    echo "1) Обновить все репозитории"
    echo "12) Установить 3x-ui"
    echo "0) Выход"
    echo
    read -p "Выберите действие: " choice

    case "$choice" in
        1) update_repos ;;
        12) install_3xui ;;
        0) exit 0 ;;
        *) echo -e "${RED}Неизвестная команда${NC}" ;;
    esac

    echo
    read -p "Нажмите Enter чтобы продолжить..."
done
