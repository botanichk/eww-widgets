#!/bin/bash

CACHE_FILE="/tmp/weather_gomel_full.txt"
CACHE_TIME=600  # 10 минут

fetch_weather() {
    # Запрашиваем текущую погоду + почасовые данные (влажность, давление)
    json=$(curl -s --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=52.4380&longitude=30.9900&current_weather=true&hourly=relative_humidity_2m,pressure_msl&timezone=Europe/Minsk")

    if [ $? -ne 0 ] || [[ -z "$json" ]] || [[ "$json" == *"error"* ]]; then
        echo "🌤️ ? | 💧 ?% | 📉 ?hPa"
        return 1
    fi

    # Температура и код погоды — из current_weather
    temp=$(echo "$json" | jq -r '.current_weather.temperature // empty')
    code=$(echo "$json" | jq -r '.current_weather.weathercode // empty')
    wind_speed=$(echo "$json" | jq -r '.current_weather.windspeed // empty')
    wind_dir=$(echo "$json" | jq -r '.current_weather.winddirection // empty')

    # Влажность и давление — из hourly (берём первое значение — текущий час)
    humidity=$(echo "$json" | jq -r '.hourly.relative_humidity_2m[0] // empty')
    pressure=$(echo "$json" | jq -r '.hourly.pressure_msl[0] // empty')

    # Проверка на ошибки
    if [[ -z "$temp" ]] || [[ -z "$humidity" ]] || [[ -z "$pressure" ]]; then
        echo "🌤️ ? | 💧 ?% | 📉 ?hPa"
        return 1
    fi

    # Иконка по погоде
    case $code in
        0) icon="☀️" ;;
        1|2|3) icon="⛅" ;;
        45|48) icon="🌫️" ;;
        51|53|55|56|57) icon="🌧️" ;;
        61|63|65|66|67) icon="🌧️" ;;
        71|73|75|77) icon="❄️" ;;
        80|81|82) icon="🌦️" ;;
        85|86) icon="🌨️" ;;
        95|96|99) icon="⛈️" ;;
        *) icon="🌤️" ;;
    esac

    # Округляем давление до целого
    pressure_rounded=$(LC_NUMERIC=C printf "%.0f" "$pressure")

    # Сохраняем полную строку
    full_output="${icon} ${temp}°C | 💧 ${humidity}% | 📉 ${pressure_rounded}hPa | 💨 ${wind_speed}km/h ${wind_dir}°"
    
    # Если передан аргумент, возвращаем только нужное значение
    case "$1" in
        "temp")
            if [[ -n "$temp" ]]; then
                echo "${temp}°C"
            else
                echo "?°C"
            fi
            ;;
        "feels_like")
            if [[ -n "$temp" ]]; then
                echo "${temp}°C"
            else
                echo "?°C"
            fi
            ;;
        "description")
            case $code in
                0) echo "Ясно" ;;
                1|2|3) echo "Малооблачно" ;;
                45|48) echo "Туман" ;;
                51|53|55|56|57) echo "Морось" ;;
                61|63|65|66|67) echo "Дождь" ;;
                71|73|75|77) echo "Снег" ;;
                80|81|82) echo "Ливень" ;;
                85|86) echo "Снегопад" ;;
                95|96|99) echo "Гроза" ;;
                *) echo "Неизвестно" ;;
            esac
            ;;
        "icon")
            if [[ -n "$icon" ]]; then
                echo "$icon"
            else
                echo "🌤️"
            fi
            ;;
        "wind_speed")
            if [[ -n "$wind_speed" ]]; then
                echo "${wind_speed}"
            else
                echo "?"
            fi
            ;;
        "wind_dir")
            if [[ -n "$wind_dir" ]]; then
                echo "${wind_dir}°"
            else
                echo "?"
            fi
            ;;
        "humidity")
            if [[ -n "$humidity" ]]; then
                echo "${humidity}%"
            else
                echo "?%"
            fi
            ;;
        "pressure")
            if [[ -n "$pressure_rounded" ]]; then
                echo "${pressure_rounded}hPa"
            else
                echo "?hPa"
            fi
            ;;
        "city")
            echo "Гомель"
            ;;
        "country")
            echo "BY"
            ;;
        "last_update")
            date '+%H:%M'
            ;;
        *)
            # Если нет аргумента, возвращаем полную строку
            echo "$full_output"
            ;;
    esac
}

# Кэш-логика
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
else
    CACHE_AGE=$CACHE_TIME
fi

# Обновляем кэш только если истекло время
if [ $CACHE_AGE -ge $CACHE_TIME ]; then
    fetch_weather > "$CACHE_FILE"
fi

if [ $# -gt 0 ]; then
    # Если передан аргумент, парсим кэш и извлекаем нужное значение
    cached_data=$(cat "$CACHE_FILE" 2>/dev/null)
    if [ -n "$cached_data" ]; then
        # Получаем данные из кэша и парсим их
        icon=$(echo "$cached_data" | grep -o '^[^ ]* ')
        temp=$(echo "$cached_data" | grep -o '[+-]\?[0-9]\+\.[0-9]\+°C' | head -1)
        humidity=$(echo "$cached_data" | grep -o '[0-9]\+%' | head -1)
        pressure=$(echo "$cached_data" | grep -o '[0-9]\+hPa' | head -1)
        wind_speed=$(echo "$cached_data" | grep -o '[0-9]\+\.[0-9]\+km/h' | head -1 | sed 's/km\/h//')
        wind_dir=$(echo "$cached_data" | grep -o '[0-9]\+°[[:space:]]*$' | head -1 | tr -d ' ')
        
        case "$1" in
            "temp")
                if [ -n "$temp" ]; then
                    echo "$temp"
                else
                    echo "?°C"
                fi
                ;;
            "icon")
                if [ -n "$icon" ]; then
                    echo "$icon"
                else
                    echo "🌤️"
                fi
                ;;
            "humidity")
                if [ -n "$humidity" ]; then
                    echo "$humidity"
                else
                    echo "?%"
                fi
                ;;
            "pressure")
                if [ -n "$pressure" ]; then
                    echo "$pressure"
                else
                    echo "?hPa"
                fi
                ;;
            "wind_speed")
                if [ -n "$wind_speed" ]; then
                    echo "$wind_speed"
                else
                    echo "?км/ч"
                fi
                ;;
            "wind_dir")
                if [ -n "$wind_dir" ]; then
                    echo "$wind_dir"
                else
                    echo "?"
                fi
                ;;
            "city")
                echo "Гомель"
                ;;
            "country")
                echo "BY"
                ;;
            "last_update")
                date '+%H:%M'
                ;;
            "feels_like")
                if [ -n "$temp" ]; then
                    echo "$temp"
                else
                    echo "?°C"
                fi
                ;;
            "description")
                echo "Неизвестно"
                ;;
            *)
                echo "$cached_data"
                ;;
        esac
    else
        # Если кэш пустой, делаем полный запрос
        fetch_weather "$1"
    fi
else
    # Иначе возвращаем закэшированное значение
    cat "$CACHE_FILE" 2>/dev/null || fetch_weather
fi
