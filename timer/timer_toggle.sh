#!/bin/bash
# Скрипт для переключения видимости таймера

# Проверяем, запущен ли уже eww daemon
if ! pgrep -x "eww" > /dev/null; then
    # Запускаем eww daemon
    eww -c /home/ig_ro/Документы/eww/timer daemon
    sleep 2  # Ждем немного, пока daemon запускается
fi

# Проверяем, открыто ли окно таймера
if eww -c /home/ig_ro/Документы/eww/timer active-windows | grep -q "timer"; then
    # Если открыто - закрываем
    eww -c /home/ig_ro/Документы/eww/timer close timer
else
    # Если закрыто - открываем
    eww -c /home/ig_ro/Документы/eww/timer open timer
fi