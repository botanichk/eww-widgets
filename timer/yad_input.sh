#!/bin/bash
# Скрипт для ввода времени через Yad

# Логируем начало работы
echo "$(date): yad_input.sh started" >> /tmp/yad_input_debug.log

# Показываем диалог ввода через Yad
input=$(yad --entry --title="Введите время" --text="Введите время в формате (5m, 1:30, 90s):" --entry-text="" 2>/dev/null)

# Логируем полученный ввод
echo "$(date): received input: '$input'" >> /tmp/yad_input_debug.log

# Если пользователь что-то ввел
if [ -n "$input" ]; then
    echo "$input" > /tmp/timer_input_value && eww -c /home/ig_ro/Документы/eww/timer update timer_input="$input"
fi
