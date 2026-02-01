#!/bin/bash
# Скрипт для переключения окна таймера

EWW_CONFIG="/home/ig_ro/Документы/eww/timer"

# Проверяем реальное состояние окна через eww
is_window_open() {
    eww -c "$EWW_CONFIG" active-windows 2>/dev/null | grep -q "timer"
}

if is_window_open; then
    # Окно открыто - закрываем
    eww -c "$EWW_CONFIG" close timer 2>/dev/null
else
    # Окно закрыто - открываем
    eww -c "$EWW_CONFIG" open timer
fi
