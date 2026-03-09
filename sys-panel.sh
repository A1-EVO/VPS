#!/bin/bash

# Очистка экрана один раз
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
    echo -ne "\e[K${MAGENTA}┌──────────────────────────────────────────────┐${NC}\n"
    printf "\e[K${MAGENTA}│${NC} %-44s ${MAGENTA}│${NC}\n" "$title"
    echo -ne "\e[K${MAGENTA}└──────────────────────────────────────────────┘${NC}\n"
}

# История CPU для сглаживания
CPU_HISTORY=()

while true; do
    # Перемещаем курсор в начало экрана
    tput cup 0 0

    # CPU (моментальное значение)
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
    CPU_NUM=$(echo "$CPU" | tr -d '%')

    # --- Сглаживание CPU по последним 10 значениям ---
    CPU_HISTORY+=("$CPU_NUM")

    # Ограничиваем длину массива до 10
    if [ ${#CPU_HISTORY[@]} -gt 10 ]; then
        CPU_HISTORY=("${CPU_HISTORY[@]:1}")
    fi

    # Считаем среднее
    CPU_SUM=0
    for v in "${CPU_HISTORY[@]}"; do
        CPU_SUM=$(echo "$CPU_SUM + $v" | bc)
    done
    CPU_AVG=$(echo "scale=1; $CPU_SUM / ${#CPU_HISTORY[@]}" | bc)

    # Цвет CPU по среднему значению
    if (( $(echo "$CPU_AVG > 80" | bc -l) )); then CPU_COLOR=$RED
    elif (( $(echo "$CPU_AVG > 50" | bc -l) )); then CPU_COLOR=$YELLOW
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

    # Панель
    draw_box "A1 RETRO SYSTEM PANEL среднее"

    echo -ne "\e[K${BLUE}CPU Load:${NC}      ${CPU_COLOR}${CPU_AVG}%${NC}\n"
    echo -ne "\e[K${BLUE}RAM Usage:${NC}     ${RAM_COLOR}${RAM_USED}MB / ${RAM_TOTAL}MB (${RAM_PERC}%)${NC}\n"
    echo -ne "\e[K${BLUE}Disk Usage:${NC}    ${DISK_COLOR}${DISK_USED} / ${DISK_TOTAL} (${DISK_PERC}%)${NC}\n"

    echo -ne "\n\e[K${CYAN}Нажмите CTRL+C для выхода.${NC}\n"

    sleep 1
done
