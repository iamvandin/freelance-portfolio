#!/bin/bash


# ========================================
# Linux Server Monitor
# ========================================

CPU_LIMIT=80
MEMORY_LIMIT=80
DISK_LIMIT=80

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

check_status() {
    local usage=$1
    local limit=$2

    if [ "$usage" -ge "$limit" ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

show_header
show_system_info

get_cpu_usage
get_memory_usage
get_disk_usage

CPU_STATUS=$(check_status "$CPU_USAGE" "$CPU_LIMIT")
MEMORY_STATUS=$(check_status "$MEMORY_USAGE" "$MEMORY_LIMIT")
DISK_STATUS=$(check_status "$DISK_USAGE" "$DISK_LIMIT")

echo "CPU Usage      : ${CPU_USAGE}% [$CPU_STATUS]"
echo "Memory Usage   : ${MEMORY_USAGE}% [$MEMORY_STATUS]"
echo "Disk Usage     : ${DISK_USAGE}% [$DISK_STATUS]"
echo ""

if [ "$CPU_STATUS" = "WARNING" ] || \
   [ "$MEMORY_STATUS" = "WARNING" ] || \
   [ "$DISK_STATUS" = "WARNING" ]; then
    echo "Overall Status : WARNING"
else
    echo "Overall Status : HEALTHY"
fi

echo ""
echo "========================================"


