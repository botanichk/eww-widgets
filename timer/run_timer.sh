#!/bin/bash
# Скрипт для запуска виджета таймера

# Проверяем, запущен ли уже eww daemon
if ! pgrep -x "eww" > /dev/null; then
    # Запускаем eww daemon
    eww -c /home/ig_ro/Документы/eww/timer daemon
    sleep 2  # Ждем немного, пока daemon запускается
fi

# Закрываем окно таймера, если оно уже открыто
eww -c /home/ig_ro/Документы/eww/timer close timer 2>/dev/null

# Открываем окно таймера
eww -c /home/ig_ro/Документы/eww/timer open timer