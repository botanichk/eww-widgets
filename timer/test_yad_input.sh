#!/bin/bash
# Тестовый скрипт для проверки ввода через Yad

echo "Запуск теста ввода через Yad..."
echo "Пожалуйста, введите число в диалоговое окно Yad"

# Вызываем скрипт ввода через Yad
/home/ig_ro/Документы/eww/timer/yad_input.sh

# Ждем немного, чтобы дать возможность вводу завершиться
sleep 2

# Проверяем, что было записано в файл
if [ -f /tmp/timer_input_value ]; then
    input_value=$(cat /tmp/timer_input_value)
    echo "Значение из /tmp/timer_input_value: $input_value"
    
    # Тестируем обработку этого значения
    echo "Тестируем обработку значения через countdown_timer.sh..."
    /home/ig_ro/Документы/eww/timer/countdown_timer.sh start_custom "$input_value"
else
    echo "Файл /tmp/timer_input_value не найден"
fi

echo "Проверьте файл /tmp/timer_debug.log для подробного лога операций"