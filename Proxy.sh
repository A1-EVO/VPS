#!/usr/bin/env bash
# Автоматическая установка и настройка SOCKS5-прокси Dante
# Пользователь: A1
# Пароль: 23
# Порт: 587

set -e

### 1. Проверка root
if [[ "$EUID" -ne 0 ]]; then
  echo "Этот скрипт нужно запускать от root (например: sudo bash $0)"
  exit 1
fi

echo "=== Установка SOCKS5-прокси Dante ==="

### 2. Установка Dante
echo "[1/6] Обновление пакетов и установка dante-server..."
apt update -y
apt upgrade -y
apt install -y dante-server

### 3. Определение сетевого интерфейса
echo "[2/6] Определение внешнего сетевого интерфейса..."
IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}')

if [[ -z "$IFACE" ]]; then
  echo "Не удалось определить интерфейс. Проверьте 'ip a'."
  exit 1
fi

echo "Обнаружен интерфейс: $IFACE"

### 4. Создание конфига Dante
echo "[3/6] Создание /etc/danted.conf..."

cat > /etc/danted.conf <<EOF
logoutput: /var/log/sockd.log
internal: ${IFACE} port = 587
external: ${IFACE}
method: username
user.privileged: root
user.notprivileged: A1

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

echo "Конфигурация создана."

### 5. Создание пользователя A1
echo "[4/6] Создание пользователя A1..."

if id "A1" &>/dev/null; then
  echo "Пользователь A1 уже существует, обновляю пароль..."
else
  useradd -m A1
  echo "Пользователь A1 создан."
fi

echo "A1:23" | chpasswd
echo "Пароль установлен."

### 6. Открытие порта 587 в UFW
echo "[5/6] Настройка firewall..."

if command -v ufw &>/dev/null; then
  if [[ "$(ufw status | head -n1 | awk '{print $2}')" == "active" ]]; then
    ufw allow 587/tcp
    ufw reload
    echo "Порт 587 открыт."
  else
    echo "UFW не активен — пропускаю."
  fi
else
  echo "UFW не установлен."
fi

### 7. Перезапуск Dante
echo "[6/6] Перезапуск danted..."
systemctl restart danted
sleep 2

if systemctl is-active --quiet danted; then
  echo "Dante успешно запущен."
else
  echo "Ошибка запуска! Проверьте:"
  echo "  systemctl status danted"
  echo "  cat /var/log/sockd.log"
  exit 1
fi

### 8. Итог
SERVER_IP=$(hostname -I | awk '{print $1}')

echo
echo "=== Готово! SOCKS5-прокси работает. ==="
echo "Параметры подключения:"
echo "  Тип:      SOCKS5"
echo "  Server:   ${SERVER_IP}:587"
echo "  Username: A1"
echo "  Password: 23"
echo
echo "Telegram → Settings → Data and Storage → Connection Type → Use Proxy → SOCKS5"
