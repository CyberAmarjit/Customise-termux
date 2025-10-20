#!/data/data/com.termux/files/usr/bin/bash

# === Color Variables ===
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
BOLD='\e[1m'
NC='\e[0m'

DEV_URL="https://github.com/CyberAmarjit"

# === Banner Function ===
display_banner() {
    clear
    echo -e "${GREEN}"
    cat << "EOF"
  █████╗ ███╗   ███╗ █████╗ ██████╗      ██╗██╗████████╗
 ██╔══██╗████╗ ████║██╔══██╗██╔══██╗     ██║██║╚══██╔══╝
 ███████║██╔████╔██║███████║██████╔╝     ██║██║   ██║   
 ██╔══██║██║╚██╔╝██║██╔══██║██╔══██╗██   ██║██║   ██║   
 ██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██║╚█████╔╝██║   ██║   
 ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚════╝ ╚═╝   ╚═╝   
EOF
    echo -e "${RED}➪ Credit by @CyberAmarjit${NC}"
    echo -e "${YELLOW}==============================================${NC}"
    echo -e "${CYAN}        Customise Termux${NC}"
    echo -e "${YELLOW}==============================================${NC}\n"
}

# === Open URL with fallbacks (non-blocking) ===
open_url() {
    local url="$1"

    # 1) termux-open-url (preferred on Termux)
    if command -v termux-open-url &>/dev/null; then
        termux-open-url "$url" &>/dev/null &
        return 0
    fi

    # 2) xdg-open (common on desktop)
    if command -v xdg-open &>/dev/null; then
        xdg-open "$url" &>/dev/null &
        return 0
    fi

    # 3) Android am start (intent) — works on many Android environments
    if command -v am &>/dev/null; then
        am start -a android.intent.action.VIEW -d "$url" &>/dev/null &
        return 0
    fi

    # 4) fallback: tries 'sensible-browser' or 'gio open'
    if command -v sensible-browser &>/dev/null; then
        sensible-browser "$url" &>/dev/null &
        return 0
    fi
    if command -v gio &>/dev/null; then
        gio open "$url" &>/dev/null &
        return 0
    fi

    # 5) last resort: tell the user the URL
    echo -e "${YELLOW}Could not open browser automatically.${NC}"
    echo -e "Please visit: ${CYAN}${url}${NC}"
    return 1
}

# === Progress Bar ===
progress_bar() {
    local duration=$1
    local elapsed=0
    local bar_length=30
    while [ $elapsed -lt $duration ]; do
        local filled=$((elapsed * bar_length / duration))
        local empty=$((bar_length - filled))
        printf "\r${CYAN}["
        printf "%0.s#" $(seq 1 $filled)
        printf "%0.s-" $(seq 1 $empty)
        printf "] ${elapsed}s/${duration}s${NC}"
        sleep 1
        ((elapsed++))
    done
    printf "\r${GREEN}[##############################] Done!${NC}\n"
}

# === Error Handler ===
handle_error() {
    echo -e "\n${RED}[!] ERROR:${NC} $1"
    echo -e "${YELLOW}[?] SOLUTION:${NC} $2\n"
    sleep 2
}

# === Network Check ===
check_network() {
    if ! ping -c 1 google.com &>/dev/null; then
        handle_error "No internet connection detected." "Please check your network and try again."
        return 1
    fi
    return 0
}

# === Change Font ===
change_termux_font() {
    echo -e "\n${BLUE}=== Change Termux Font ===${NC}"
    if ! command -v vfonts &>/dev/null; then
        echo -e "${YELLOW}Installing void-fonts...${NC}"
        apt install -y void-fonts &>/dev/null
    fi
    vfonts
    echo -e "\n${GREEN}Font changed successfully!${NC}"
}

# === Menu ===
show_menu() {
    display_banner
    echo -e "${BLUE}MAIN MENU:${NC}"
    echo -e "  ${GREEN}[1]${NC} Follow Developer"
    echo -e "  ${GREEN}[2]${NC} Install TermuxVoid Theme"
    echo -e "  ${GREEN}[3]${NC} Change Termux Font"
    echo -e "  ${GREEN}[4]${NC} System Information"
    echo -e "  ${GREEN}[5]${NC} Quick System Update"
    echo -e "  ${GREEN}[6]${NC} Cleanup System"
    echo -e "  ${GREEN}[7]${NC} Run All Tasks"
    echo -e "  ${RED}[0]${NC} Exit\n"
}

# === Main Loop ===
while true; do
    show_menu
    read -p "$(echo -e ${CYAN}"Select Option > "${NC})" selection

    case $selection in
        1)
            echo -e "\n${BLUE}=== Opening Developer Page in Browser... ===${NC}"
            open_url "$DEV_URL"
            echo -e "${GREEN}If a browser is available it should open now.${NC}\n"
            ;;
        2)
            echo -e "\n${BLUE}=== Installing TermuxVoid Theme ===${NC}"
            check_network || continue
            curl -LO https://github.com/termuxvoid/TermuxVoid-Theme/raw/main/termuxvoid-theme.sh && \
            bash termuxvoid-theme.sh && rm -f termuxvoid-theme.sh
            echo -e "\n${GREEN}Theme installed successfully!${NC}"
            ;;
        3)
            change_termux_font
            ;;
        4)
            echo -e "\n${BLUE}=== System Information ===${NC}"
            echo -e "OS: $(uname -o)"
            echo -e "Architecture: $(uname -m)"
            echo -e "Free Space: $(df -h $PREFIX | awk 'NR==2{print $4}')"
            ;;
        5)
            echo -e "\n${BLUE}=== Quick System Update ===${NC}"
            check_network || continue
            apt update && apt upgrade -y
            echo -e "\n${GREEN}System updated!${NC}"
            ;;
        6)
            echo -e "\n${BLUE}=== System Cleanup ===${NC}"
            apt clean && apt autoremove -y
            echo -e "\n${GREEN}Cleanup done!${NC}"
            ;;
        7)
            echo -e "\n${YELLOW}${BOLD}⚙ Starting TermuxVoid Auto Tasks...${NC}\n"
            
            echo -e "${CYAN}[1/5] Following Developer...${NC}"
            progress_bar 2
            open_url "$DEV_URL"
            echo -e "${GREEN}✅ Done!${NC}\n"

            echo -e "${CYAN}[2/5] Installing Theme...${NC}"
            progress_bar 3
            curl -sLO https://github.com/termuxvoid/TermuxVoid-Theme/raw/main/termuxvoid-theme.sh && \
            bash termuxvoid-theme.sh && rm -f termuxvoid-theme.sh
            echo -e "${GREEN}✅ Theme Installed${NC}\n"

            echo -e "${CYAN}[3/5] Changing Font...${NC}"
            progress_bar 2
            change_termux_font
            echo -e "${GREEN}✅ Font Applied${NC}\n"

            echo -e "${CYAN}[4/5] Updating System...${NC}"
            progress_bar 4
            apt update -y && apt upgrade -y
            echo -e "${GREEN}✅ System Updated${NC}\n"

            echo -e "${CYAN}[5/5] Cleaning Up...${NC}"
            progress_bar 3
            apt clean && apt autoremove -y
            echo -e "${GREEN}✅ Cleanup Completed${NC}\n"

            echo -e "${BOLD}${GREEN}✨ All Tasks Completed Successfully!${NC}\n"
            ;;
        0)
            echo -e "\n${GREEN}Goodbye!${NC}\n"
            exit 0
            ;;
        *)
            handle_error "Invalid selection." "Please choose 0–7"
            ;;
    esac
    read -p "$(echo -e ${YELLOW}"Press Enter to continue..."${NC})"
done
