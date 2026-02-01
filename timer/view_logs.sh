#!/bin/bash
# Скрипт для просмотра логов таймера

LOG_FILE="/tmp/timer_debug.log"

if [ -f "$LOG_FILE" ]; then
    echo "=== Последние 20 строк лога ==="
    tail -n 20 "$LOG_FILE"
    echo ""
    echo "=== Полный лог ==="
    cat "$LOG_FILE"
else
    echo "Лог-файл $LOG_FILE не найден"
    echo "Логи будут созданы при следующем использовании диалога ввода или таймера"
fi