#!/bin/bash

# ========================================
# Linux Server Monitor
# ========================================

CPU_LIMIT=80
MEMORY_LIMIT=80
DISK_LIMIT=80

LOG_DIR="logs"
MONITOR_LOG="$LOG_DIR/monitoring.log"
ALERT_LOG="$LOG_DIR/alerts.log"

mkdir -p "$LOG_DIR"
touch "$MONITOR_LOG"
touch "$ALERT_LOG"

show_header() {
    echo "========================================"
    echo "        LINUX SERVER MONITOR"
    echo "========================================"
    echo ""
}

show_system_info() {
    echo "Hostname       : $(hostname)"
    echo "Current User   : $(whoami)"
    echo "Uptime         : $(uptime -p)"
    echo "Date           : $(date)"
    echo ""
}

get_cpu_usage() {
    CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')
    CPU_USAGE=${CPU_USAGE%.*}
}

get_memory_usage() {
    MEMORY_USAGE=$(free | awk '/Mem:/ {
        printf "%.0f", ($3/$2) * 100
    }')
}

get_disk_usage() {
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
}

send_alert() {
    local message="$1"
    local timestamp

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] ALERT: $message" | tee -a "$ALERT_LOG"
}

check_cpu() {
    if [ "$CPU_USAGE" -ge "$CPU_LIMIT" ]; then
        send_alert "CPU usage is ${CPU_USAGE}% (limit: ${CPU_LIMIT}%)"
        CPU_STATUS="WARNING"
    else
        CPU_STATUS="OK"
    fi
}

check_memory() {
    if [ "$MEMORY_USAGE" -ge "$MEMORY_LIMIT" ]; then
        send_alert "Memory usage is ${MEMORY_USAGE}% (limit: ${MEMORY_LIMIT}%)"
        MEMORY_STATUS="WARNING"
    else
        MEMORY_STATUS="OK"
    fi
}

check_disk() {
    if [ "$DISK_USAGE" -ge "$DISK_LIMIT" ]; then
        send_alert "Disk usage is ${DISK_USAGE}% (limit: ${DISK_LIMIT}%)"
        DISK_STATUS="WARNING"
    else
        DISK_STATUS="OK"
    fi
}

show_header
show_system_info

get_cpu_usage
get_memory_usage
get_disk_usage

check_cpu
check_memory
check_disk

echo "CPU Usage      : ${CPU_USAGE}% [$CPU_STATUS]"
echo "Memory Usage   : ${MEMORY_USAGE}% [$MEMORY_STATUS]"
echo "Disk Usage     : ${DISK_USAGE}% [$DISK_STATUS]"
echo ""

if [ "$CPU_STATUS" = "WARNING" ] || \
   [ "$MEMORY_STATUS" = "WARNING" ] || \
   [ "$DISK_STATUS" = "WARNING" ]; then

    echo "Overall Status : WARNING"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Overall Status: WARNING" >> "$MONITOR_LOG"
    exit 1
else

    echo "Overall Status : HEALTHY"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Overall Status: HEALTHY" >> "$MONITOR_LOG"
    exit 0
fi
