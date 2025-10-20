#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create logs folder if it doesn't exist
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Correct variable and date format
LOG_FILE="$LOG_DIR/system_report_$(date '+%Y-%m-%d_%H-%M-%S').log"


#Total CPU usage
get_cpu_usage(){
    echo "CPU usage:"
    top -bn1 | grep "Cpu(s)" | \
    sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
    awk '{print "CPU Load: " 100 - $1"%"}'
}

#Total memory usage (Free vs Used including percentage)
get_total_memory_usage(){
    echo " Total memory usage:"
    free -h | awk '/Mem:/ {printf "Used: %s / Total: %s (%.2f%%)\n", $3, $2, $3/$2 * 100.0}'
}

#Total disk usage (Free vs Used including percentage)
get_total_disk(){
    echo "Total disk usage:"
    df -h --total | awk '/total/ {printf "Used: %s / Total: %s (%.2f%%)\n", $3, $2, $5}'
}
    
#Top 5 processes by CPU usage
get_top_5_process_by_CPU(){
    echo "Top 5 processes by CPU usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
}

#Top 5 processes by memory usage
get_top_5_process_by_mem_usage(){
    echo "Top 5 processes by memory usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -6
}

#Additional stats
get_additional_stats(){
    echo -e "\nOS version: $(cat /etc/os-release)"
    echo -e "\nUptime: $(uptime -p)"
    echo -e "\nLogged in users: $(w)"
}

main(){
    {
    echo "****************************"
    echo "Server Performance Stats"
    echo "****************************"

    get_cpu_usage
    echo ""
    echo "****************************"

    get_total_memory_usage
    echo "" 
    echo "****************************"

    get_total_memory_usage
    echo ""
    echo "****************************"

    get_top_5_process_by_CPU
    echo ""
    echo "****************************"

    get_top_5_process_by_mem_usage
    echo ""
    echo "****************************"

    get_additional_stats
    echo ""
    echo "****************************"
    } | tee -a "$LOG_FILE"

    echo "Log written to: $LOG_FILE"
} 
main