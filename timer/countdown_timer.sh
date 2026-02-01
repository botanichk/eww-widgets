#!/bin/bash

# Скрипт для управления таймером обратного отсчета
# Использует файл состояния для хранения оставшегося времени

STATE_DIR="$HOME/.local/share/eww/timer"
STATE_FILE="$STATE_DIR/state"
LOCK_FILE="$STATE_DIR/lock"

mkdir -p "$STATE_DIR"

# Функция для форматирования времени в MM:SS
format_time() {
    local total_seconds=$1
    local minutes=$((total_seconds / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d" $minutes $seconds
}

# Функция для преобразования строки времени в секунды
parse_time() {
    local input="$1"
    local total_seconds=0
    
    # Проверяем формат HH:MM или MM:SS
    if [[ $input =~ ^([0-9]+):([0-9]+)$ ]]; then
        local minutes=${BASH_REMATCH[1]}
        local seconds=${BASH_REMATCH[2]}
        total_seconds=$((minutes * 60 + seconds))
    # Проверяем формат XhYm (например, 1h30m)
    elif [[ $input =~ ^([0-9]+)h([0-9]+)m$ ]]; then
        local hours=${BASH_REMATCH[1]}
        local minutes=${BASH_REMATCH[2]}
        total_seconds=$((hours * 3600 + minutes * 60))
    # Проверяем формат Xh (например, 1h)
    elif [[ $input =~ ^([0-9]+)h$ ]]; then
        local hours=${BASH_REMATCH[1]}
        total_seconds=$((hours * 3600))
    # Проверяем формат Xm (например, 30m)
    elif [[ $input =~ ^([0-9]+)m$ ]]; then
        local minutes=${BASH_REMATCH[1]}
        total_seconds=$((minutes * 60))
    # Если просто число - считаем за минуты
    elif [[ $input =~ ^[0-9]+$ ]]; then
        local minutes=$input
        total_seconds=$((minutes * 60))
    else
        # Если формат не распознан, возвращаем 0
        echo 0
        return
    fi
    
    echo $total_seconds
}

# Функция для запуска таймера
start_timer() {
    local duration_input=$1
    local total_seconds=$(parse_time "$duration_input")
    
    # Если не удалось распознать время, выходим
    if [ $total_seconds -le 0 ]; then
        echo "Неверный формат времени. Используйте: 5, 5m, 1h30m, 1:30"
        exit 1
    fi
    
    # Блокировка для предотвращения одновременного запуска
    if [ -f "$LOCK_FILE" ]; then
        # Проверяем, активен ли процесс
        PID=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ ! -z "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            # Таймер уже запущен, обновляем время
            echo $total_seconds > "$STATE_FILE"
            exit 0
        else
            # Старый файл блокировки, удаляем
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # Записываем время в файл состояния
    echo $total_seconds > "$STATE_FILE"
    
    # Запускаем фоновый процесс для отсчета
    # Используем команду 'exec' чтобы получить правильный PID subshell
    (
        # Получаем PID этого subshell (не родительского!)
        TIMER_PID=$BASHPID
        echo $TIMER_PID > "$LOCK_FILE"
        
        local remaining=$total_seconds
        while [ $remaining -gt 0 ]; do
            sleep 1
            remaining=$((remaining - 1))
            echo $remaining > "$STATE_FILE"
        done
        
        # Удаляем файл состояния и блокировку
        rm -f "$STATE_FILE" "$LOCK_FILE"
        
        # Показываем уведомление и воспроизводим звук
        notify-send "Таймер" "Время вышло!" --urgency=critical --icon=dialog-information
        # Попытка воспроизвести звук несколькими способами
        if command -v paplay &> /dev/null; then
            paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || \
            paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || \
            paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || \
            echo -e "\a"
        elif command -v aplay &> /dev/null; then
            aplay /usr/share/sounds/complete.wav 2>/dev/null || \
            aplay /usr/share/sounds/applause-01.wav 2>/dev/null || \
            echo -e "\a"
        elif command -v play &> /dev/null; then
            play -n -t alsa synth 0.5 sin 880 2>/dev/null || \
            echo -e "\a"
        else
            echo -e "\a"
        fi
        
    ) &
}

# Функция для получения текущего состояния
get_status() {
    if [ -f "$STATE_FILE" ]; then
        remaining=$(cat "$STATE_FILE")
        if [ $remaining -gt 0 ]; then
            format_time $remaining
        else
            echo "Время вышло!"
        fi
    else
        echo "Остановлен"
    fi
}

# Функция для сброса таймера
reset_timer() {
    # Убиваем процесс таймера если он запущен
    if [ -f "$LOCK_FILE" ]; then
        PID=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ ! -z "$PID" ]; then
            # Убиваем весь процесс группы, чтобы остановить sleep и весь subshell
            kill -- -$PID 2>/dev/null || kill $PID 2>/dev/null
        fi
    fi
    # Удаляем файлы состояния
    rm -f "$STATE_FILE" "$LOCK_FILE"
}

# Обработка аргументов
case "$1" in
    "start_5")
        start_timer 5
        ;;
    "start_10")
        start_timer 10
        ;;
    "start_30")
        start_timer 30
        ;;
    "start_custom")
        if [ -n "$2" ]; then
            start_timer "$2"
        else
            echo "Укажите время для таймера. Используйте: 5, 5m, 1h30m, 1:30"
            exit 1
        fi
        ;;
    "status")
        get_status
        ;;
    "reset")
        reset_timer
        ;;
    *)
        echo "Использование: $0 {start_5|start_10|start_30|start_custom <время>|status|reset}"
        exit 1
        ;;
esac
