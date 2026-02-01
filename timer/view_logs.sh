#!/bin/bash
# Скрипт для просмотра логов таймера

echo "=== Логи таймера ==="
echo ""

if [ -f /tmp/timer_debug.log ]; then
    echo "--- /tmp/timer_debug.log ---"
    tail -n 20 /tmp/timer_debug.log
    echo ""
else
    echo "Файл /tmp/timer_debug.log не найден"
    echo ""
fi

if [ -f /tmp/timer_rofi_debug.log ]; then
    echo "--- /tmp/timer_rofi_debug.log ---"
    tail -n 20 /tmp/timer_rofi_debug.log
    echo ""
else
    echo "Файл /tmp/timer_rofi_debug.log не найден"
    echo ""
fi

if [ -f /tmp/yad_input_debug.log ]; then
    echo "--- /tmp/yad_input_debug.log ---"
    tail -n 20 /tmp/yad_input_debug.log
    echo ""
else
    echo "Файл /tmp/yad_input_debug.log не найден"
    echo ""
fi

if [ -f /tmp/test_rofi_debug.log ]; then
    echo "--- /tmp/test_rofi_debug.log ---"
    tail -n 20 /tmp/test_rofi_debug.log
    echo ""
else
    echo "Файл /tmp/test_rofi_debug.log не найден"
    echo ""
fi

echo "==================="