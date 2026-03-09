#!/bin/bash

# Очистка экрана
tput clear

# Цвета
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
NC="\e[0m"

draw_box() {
    local title="$1"
    echo -e "${MAGENTA}┌──────────────────────────────────────────────┐${NC}"
    printf "${MAGENTA}│${NC} %-44s ${MAGENTA}│${NC}\n" "$title"
    echo -e "${MAGENTA}└──────────────────────────────────────────────┘${NC}"
}

while true; do
    tput cup 0 0

    # CPU
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
    CPU_NUM=$(echo "$CPU" | tr -d '%')

    if (( $(echo "$CPU_NUM > 80" | bc -l) )); then CPU_COLOR=$RED
    elif (( $(echo "$CPU_NUM > 50" | bc -l) )); then CPU_COLOR=$YELLOW
    else CPU_COLOR=$GREEN
    fi

    # RAM
    RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
    RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    RAM_PERC=$((100 * RAM_USED / RAM_TOTAL))

    if (( RAM_PERC > 80 )); then RAM_COLOR=$RED
    elif (( RAM_PERC > 50 )); then RAM_COLOR=$YELLOW
    else RAM_COLOR=$GREEN
    fi

    # Disk
    DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
    DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
    DISK_PERC=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

    if (( DISK_PERC > 80 )); then DISK_COLOR=$RED
    elif (( DISK_PERC > 50 )); then DISK_COLOR=$YELLOW
    else DISK_COLOR=$GREEN
    fi

    # Рисуем панель
    draw_box "A1 RETRO SYSTEM PANEL"

    echo -e "${BLUE}CPU Load:${NC}      ${CPU_COLOR}${CPU}${NC}"
    echo -e "${BLUE}RAM Usage:${NC}     ${RAM_COLOR}${RAM_USED}MB / ${RAM_TOTAL}MB (${RAM_PERC}%)${NC}"
    echo -e "${BLUE}Disk Usage:${NC}    ${DISK_COLOR}${DISK_USED} / ${DISK_TOTAL} (${DISK_PERC}%)${NC}"

    echo
    echo -e "${CYAN}Нажмите CTRL+C для выхода.${NC}"

    sleep 1
done
