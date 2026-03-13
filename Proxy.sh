#!/usr/bin/env bash
# Автоматическая установка и настройка SOCKS5-прокси Dante для Telegram на Ubuntu 24.04
# Пользователь: socks
# Пароль: 23
# Порт: 1080

set -e

### 1. Проверка, что скрипт запущен от root
if [[ "$EUID" -ne 0 ]]; then
  echo "Этот скрипт нужно запускать от root (например: sudo bash $0)"
  exit 1
fi

echo "=== Установка SOCKS5-прокси Dante для Telegram ==="

### 2. Обновление системы и установка Dante
echo "[1/6] Обновление пакетов и установка dante-server..."
apt update -y
apt upgrade -y
apt install -y dante-server

### 3. Определение внешнего сетевого интерфейса
# Логика:
#   - ip route get 1.1.1.1 показывает маршрут до внешнего адреса
#   - в выводе есть строка вида: "dev ens3" — это и есть нужный интерфейс
echo "[2/6] Определение внешнего сетевого интерфейса..."
IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}')

if [[ -z "$IFACE" ]]; then
  echo "Не удалось автоматически определить сетевой интерфейс."
  echo "Проверьте вывод команды 'ip a' и укажите интерфейс вручную в /etc/danted.conf."
  exit 1
fi

echo "Обнаружен интерфейс: $IFACE"

### 4. Создание конфигурации /etc/danted.conf
# Конфиг основан на инструкции:
#   - internal: интерфейс и порт, на котором слушает Dante
#   - external: интерфейс, через который идёт исходящий трафик
#   - method: username — авторизация по логину/паролю системного пользователя
#   - client pass / pass: правила доступа
echo "[3/6] Настройка /etc/danted.conf..."

cat > /etc/danted.conf <<EOF
logoutput: /var/log/sockd.log
internal: ${IFACE} port = 1080
external: ${IFACE}
method: username
user.privileged: root
user.notprivileged: socks

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error connect disconnect
}

block {
    from: 0.0.0.0/0 to: 127.0.0.0/8
    log: connect error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error connect disconnect
}
EOF

echo "Файл /etc/danted.conf создан."

### 5. Создание пользователя socks с паролем 23
# В инструкции пользователь создаётся так:
#   sudo useradd -m socks
#   sudo passwd socks
# Здесь делаем то же самое, но без участия пользователя.
echo "[4/6] Создание пользователя socks с паролем '23'..."

if id "socks" &>/dev/null; then
  echo "Пользователь 'socks' уже существует, обновляю пароль..."
else
  useradd -m socks
  echo "Пользователь 'socks' создан."
fi

echo "socks:23" | chpasswd
echo "Пароль для пользователя 'socks' установлен."

### 6. Открытие порта 1080 в UFW (если UFW установлен и активен)
echo "[5/6] Настройка firewall (UFW, если используется)..."

if command -v ufw &>/dev/null; then
  UFW_STATUS=$(ufw status | head -n1 | awk '{print $2}')
  if [[ "$UFW_STATUS" == "active" ]]; then
    echo "UFW активен, открываю порт 1080..."
    ufw allow 1080/tcp
    ufw reload
    echo "Порт 1080 открыт в UFW."
  else
    echo "UFW установлен, но не активен — правила не меняю."
  fi
else
  echo "UFW не установлен — пропускаю настройку firewall."
fi

### 7. Перезапуск и проверка сервиса Dante
echo "[6/6] Перезапуск сервиса danted..."
systemctl restart danted

sleep 2

if systemctl is-active --quiet danted; then
  echo "Сервис danted успешно запущен."
else
  echo "Ошибка: сервис danted не запустился. Проверьте 'systemctl status danted' и /var/log/sockd.log."
  exit 1
fi

### 8. Итоговая информация
SERVER_IP=$(hostname -I | awk '{print $1}')

echo
echo "=== Готово! Ваш SOCKS5-прокси для Telegram настроен. ==="
echo "Параметры подключения:"
echo "  Тип:      SOCKS5"
echo "  Server:   ${SERVER_IP}"
echo "  Port:     1080"
echo "  Username: socks"
echo "  Password: 23"
echo
echo "В Telegram: Settings → Data and Storage → Connection Type → Use Proxy → SOCKS5"
echo "Укажите эти параметры, и Telegram будет ходить через ваш прокси."
