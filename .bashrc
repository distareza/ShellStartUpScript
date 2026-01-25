# -----------------------------
# Custom Ubuntu neofetch
# -----------------------------
neofetch() {

  # Colors
  c1='\e[36m' # Cyan
  c2='\e[32m' # Green
  c3='\e[33m' # Yellow
  c4='\e[35m' # Magenta
  c5='\e[34m' # Blue
  c6='\e[31m' # Red
  c7='\e[90m' # Gray
  reset='\e[0m'

  # -------------------------------
  # SYSTEM INFO
  # -------------------------------
  USER_NAME="$USER"
  HOST_NAME="$(hostname)"
  OS_NAME="$(lsb_release -si 2>/dev/null || uname -s)"
  OS_VERSION="$(lsb_release -sr 2>/dev/null || uname -r)"
  OS_FULL="$OS_NAME $OS_VERSION"
  KERNEL="$(uname -r)"
  UPTIME="$(uptime -p | sed 's/up //')"
  SHELL_NAME="$SHELL"
  TERM_NAME="$TERM"

  # CPU model
  CPU_MODEL="$(lscpu | awk -F: '/Model name/ {print $2}' | xargs)"

  # -------------------------------
  # MEMORY
  # -------------------------------
  MEM_TOTAL_MB=$(free -m | awk '/Mem:/ {print $2}' | tr -d ',')
  MEM_USED_MB=$(free -m | awk '/Mem:/ {print $3}' | tr -d ',')
  MEM_PERCENT=$(( MEM_USED_MB * 100 / MEM_TOTAL_MB ))
  if (( MEM_TOTAL_MB >= 1024 )); then
    MEM_TOTAL_HR="$(( MEM_TOTAL_MB / 1024 ))GB"
  else
    MEM_TOTAL_HR="${MEM_TOTAL_MB}MB"
  fi

  # -------------------------------
  # CPU usage
  # -------------------------------
  # Get CPU idle, remove commas and decimals
  CPU_IDLE=$(top -bn1 | awk '/Cpu/ {print $8}' | tr -d ',%' | cut -d. -f1)
  CPU_USAGE=$(( 100 - CPU_IDLE ))

  # -------------------------------
  # OS info
  # -------------------------------
  if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      OS_NAME="$NAME"
      OS_VERSION="$VERSION_ID"
      OS_CODENAME="$VERSION_CODENAME"
      OS_FULL="$OS_NAME $OS_CODENAME $OS_VERSION"
  else
      OS_NAME="$(uname -s)"
      OS_VERSION="$(uname -r)"
      OS_CODENAME=""
      OS_FULL="$OS_NAME $OS_VERSION"
  fi

  # -------------------------------
  # HELPER: draw a colored bar
  # -------------------------------
  draw_bar() {
    local percent=$1
    local width=20
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    local color

    if (( percent < 50 )); then color='\e[32m'
    elif (( percent < 80 )); then color='\e[33m'
    else color='\e[31m'
    fi

    bar=""
    for ((i=0;i<filled;i++)); do bar+="█"; done
    bar="${color}${bar}${reset}"
    for ((i=0;i<empty;i++)); do bar+="░"; done

    echo -n "$bar ${percent}%"
  }

  CPU_BAR=$(draw_bar $CPU_USAGE)
  MEM_BAR=$(draw_bar $MEM_PERCENT)

  # -------------------------------
  # ASCII Ubuntu logo
  # -------------------------------
  logo=(
    "                         ${c6}•/+o+-        "
    "                  ${c7}УУУУ- ${c6}-yyyyyy+.      "
    "               ${c7}://+//////${c6}-yyyyyyo.     "
    "           ${c3}.++ ${c7}.:/++++++/-${c6}.+sss/'      "
    "         ${c3}.:++o:   ${c7}/++++++++/:--:/-     "
    "        ${c3}o:+o+:++. ${c7}'..'''.-/oo+++++/.   "
    "       ${c3}.:+o:+o/.           ${c7}'+sssoo+/.  "
    "  ${c7}.++/+:${c3}+oo+o:'             ${c7}/sssooo.   "
    " ${c7}/+++//+:${c3}'oo+o               ${c7}/::--:.   "
    " ${c7}\+/+o+++${c3}'o++o               ${c6}++////.   "
    "   ${c7}.++.o+${c3}+oo+:'             ${c6}/dddhhh.   "
    "      ${c3}.+.o+oo:.           ${c6}'oddhhhh+.   "
    "       ${c3}\+.++o+o'${c6}'_''''.:ohdhhhhh+.     "
    "        ${c3}':o+++ ${c6}'ohhhhhhhhyo++os:       "
    "          ${c3}.o:${c6}'.shhhhhhh/${c3}.oo++o'.       "
    "              ${c6}/osyyyyyyo${c3}++ooo+++/.     "
    "                  ${c6}''''' ${c3}+oo+++o\:      "
    "                         ${c3}'oo++.        ${reset}"
  )

  # -------------------------------
  # INFO ARRAY
  # -------------------------------
  info=(
  "${c2}User:${reset}      $USER_NAME@$HOST_NAME"
  "${c2}OS:${reset}        $OS_FULL"
  "${c2}Kernel:${reset}    $KERNEL"
  "${c2}Uptime:${reset}    $UPTIME"
  "${c2}Shell:${reset}     $SHELL_NAME"
  "${c2}Terminal:${reset}  $TERM_NAME"
  "${c2}CPU:${reset}       $CPU_MODEL"
  "${c2}CPU Load:${reset}  $CPU_BAR"
  "${c2}Memory:${reset}    $MEM_TOTAL_HR"
  "${c2}Mem Used:${reset}  $MEM_BAR"
  )

  # -------------------------------
  # PRINT: center info vertically next to logo
  # -------------------------------
  logo_lines=${#logo[@]}
  info_lines=${#info[@]}
  start_line=$(( (logo_lines - info_lines) / 2 + 1 ))
  info_index=0

  for ((i=0;i<logo_lines;i++)); do
    if (( i+1 >= start_line && info_index < info_lines )); then
      echo -e "${logo[i]}   ${info[info_index]}"
      ((info_index++))
    else
      echo -e "${logo[i]}"
    fi
  done
}

# Optional: automatically run neofetch when opening terminal
neofetch
