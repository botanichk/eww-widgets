#!/bin/bash
# Тестовый скрипт для проверки функциональности yad_input.sh

echo "Тестирование скрипта yad_input.sh"
echo "--------------------------------"

# Запускаем скрипт
echo "Запуск скрипта yad_input.sh..."
/home/ig_ro/Документы/eww/timer/yad_input.sh

# Ждем немного для возможного ввода
sleep 2

# Проверяем содержимое файла /tmp/timer_input_value
if [ -f /tmp/timer_input_value ]; then
    echo "Файл /tmp/timer_input_value существует"
    input_value=$(cat /tmp/timer_input_value)
    echo "Содержимое файла: $input_value"
else
    echo "Файл /tmp/timer_input_value не существует"
fi

# Проверяем логи
if [ -f /tmp/yad_input_debug.log ]; then
    echo "Логи последних операций:"
    tail -n 10 /tmp/yad_input_debug.log
else
    echo "Файл лога /tmp/yad_input_debug.log не существует"
fi

echo "Тестирование завершено"