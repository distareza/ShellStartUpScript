#!/bin/zsh

neofetch() {
    # Define colors
    RED="\033[1;31m"
    GREEN="\033[1;32m"
    CYAN="\033[1;36m"
    MAGENTA="\033[1;35m"
    RESET="\033[0m"
    ORANGE="\033[38;5;214m"  # Orange color
    YELLOW="\033[1;33m"
    BLUE="\033[1;34m"
    
    # System info
    USER_NAME="$USER"
    HOST_NAME="$(hostname)"
    OS_NAME="$(uname -s)"
    KERNEL="$(uname -r)"
    ARCH="$(uname -m)"
    UPTIME="$(uptime | sed 's/.*up \([^,]*\), .*/\1/')"
    SHELL_NAME="$SHELL"
    TERM_NAME="$TERM"
    
    # CPU & Memory (macOS + Linux friendly)
    CPU="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || lscpu | grep 'Model name' | sed 's/Model name:[ \t]*//')"
    
    if [[ "$OS_NAME" == "Darwin" ]]; then
      MEM_TOTAL=$(sysctl -n hw.memsize)
      MEM_TOTAL=$((MEM_TOTAL / 1024 / 1024 / 1024))
      MEM_USED=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/\.//' )
      MEM_USED=$((MEM_USED * 4096 / 1024 / 1024))
    else
      MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
      MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    fi
    
    draw_bar() {
      local percent=$1
      local width=20
      local filled=$(( percent * width / 100 ))
      local empty=$(( width - filled ))
    
      local bar=""
      local color
    
      if (( percent < 50 )); then
        color=$GREEN
      elif (( percent < 80 )); then
        color=$YELLOW
      else
        color=$RED
      fi
    
      bar+="${color}"
      repeat $filled; bar+="█"
      bar+="${RESET}"
      repeat $empty; bar+="░"
    
      print -n "$bar ${percent}%"
    }
    
    # CPU Usage
    if [[ "$OS_NAME" == "Darwin" ]]; then
      CPU_IDLE=$(top -l 1 | awk '/CPU usage/ {print $7}' | tr -d '%')
      CPU_USAGE=$(( 100 - ${CPU_IDLE%.*} ))
    else
      CPU_USAGE=$(top -bn1 | awk '/Cpu/ {print int(100 - $8)}')
    fi
    CPU_BAR="$(draw_bar $CPU_USAGE)%"
    
    # Memory Usage
    if [[ "$OS_NAME" == "Darwin" ]]; then
      MEM_TOTAL_MB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
      MEM_USED_MB=$(vm_stat | awk '
        /Pages active/ {a=$3}
        /Pages wired/  {w=$4}
        END {print (a+w)*4096/1024/1024}' | sed 's/\..*//')
    else
      MEM_TOTAL_MB=$(free -m | awk '/Mem:/ {print $2}')
      MEM_USED_MB=$(free -m | awk '/Mem:/ {print $3}')
    fi
    MEM_PERCENT=$(( MEM_USED_MB * 100 / MEM_TOTAL_MB ))
    MEM_BAR="$(draw_bar $MEM_PERCENT)%"
    
     if [[ "$(uname)" == "Darwin" ]]; then
      OS_NAME="$(sw_vers -productName)"
      OS_VERSION="$(sw_vers -productVersion)"
      OS_FULL="${OS_NAME} ${OS_VERSION}"
    else
      OS_FULL="$(uname -s) $(uname -r)"
    fi   
    
    info=(
    "${CYAN}User:${RESET}      $USER_NAME@$HOST_NAME"
    "${CYAN}OS:${RESET}        $OS_FULL $ARCH"
    "${CYAN}Kernel:${RESET}    $KERNEL"
    "${CYAN}Uptime:${RESET}    $UPTIME"
    "${CYAN}Shell:${RESET}     $SHELL_NAME"
    "${CYAN}Terminal:${RESET}  $TERM_NAME"
    "${CYAN}CPU:${RESET}       $CPU"
    "           $CPU_BAR"
    "${CYAN}Memory:${RESET}    ${MEM_USED}MB / ${MEM_TOTAL}GB"
    "           $MEM_BAR"
)
    
    # https://www.reddit.com/r/WidescreenWallpaper/comments/15xoqxl/apple_logo_ascii_art_3440x1440/#lightbox
    logo=(
    "${GREEN}                   'c.             "
    "${GREEN}                ,xNMM.             "
    "${GREEN}              .OMMMMo              "
    "${GREEN}              OMMM0,               "
    "${GREEN}    .;loddo:' loolloddol;.         "
    "${YELLOW}  cKMMMMMMMMMMNWMMMMMMMMMMM0:       "
    "${RED} .KMMMMMMMMMMMMMMMMMMMMMMMWd.      "
    "${RED} XMMMMMMMMMMMMMMMMMMMMMMMX.        "
    "${RED};MMMMMMMMMMMMMMMMMMMMMMMM:         "
    "${RED}:MMMMMMMMMMMMMMMMMMMMMMMM:         "
    "${RED}.MMMMMMMMMMMMMMMMMMMMMMMMX.        "
    "${RED} kMMMMMMMMMMMMMMMMMMMMMMMMWd.      "
    "${MAGENTA} .XMMMMMMMMMMMMMMMMMMMMMMMMMMk     "
    "${MAGENTA}  .XMMMMMMMMMMMMMMMMMMMMMMMMK.     "
    "${BLUE}   kMMMMMMMMMMMMMMMMMMMMMMd        "
    "${BLUE}    KMMMMMMMWXXWMMMMMMMMk.         "
    "${BLUE}      .cooc,.  .,coo:.             ${RESET}"
    )
    
    # Print side-by-side
    logo_lines=${#logo[@]}
    info_lines=${#info[@]}
    
    start_line=$(( (logo_lines - info_lines) / 2 + 1 ))
    info_index=1
    
    for i in {1..$logo_lines}; do
      if (( i >= start_line && info_index <= info_lines )); then
        print -P "${logo[$i]}   ${info[$info_index]}"
        ((info_index++))
      else
        print -P "${logo[$i]}"
      fi
    done
}

neofetch

