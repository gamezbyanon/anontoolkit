#!/usr/bin/env bash
# ============================================================
#        Anon's Toolkit of Anonymity
#              c0d3d By @non G00nz
# ============================================================
# Purpose : Anonymity toolkit for ethical security testing
# Platform: Debian/Ubuntu/Arch-based Linux
# Run as  : sudo bash anon_toolkit.sh
# ============================================================

# ── Colours ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Root check ────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[!] This toolkit must be run as root. Use: sudo bash $0${RESET}"
    exit 1
fi

# ── Detect package manager ────────────────────────────────────
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt-get"
        PKG_INSTALL="apt-get install -y"
        PKG_UPDATE="apt-get update -y"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="pacman -S --noconfirm"
        PKG_UPDATE="pacman -Sy"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="dnf install -y"
        PKG_UPDATE="dnf check-update"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
        PKG_INSTALL="yum install -y"
        PKG_UPDATE="yum check-update"
    else
        echo -e "${RED}[!] No supported package manager found. Install packages manually.${RESET}"
        PKG_MANAGER=""
    fi
}

# ── Banner ────────────────────────────────────────────────────
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ██████╗ ███╗   ██╗ ██████╗ ███╗   ██╗███████╗"
    echo " ██╔══██╗████╗  ██║██╔═══██╗████╗  ██║██╔════╝"
    echo " ███████║██╔██╗ ██║██║   ██║██╔██╗ ██║███████╗"
    echo " ██╔══██║██║╚██╗██║██║   ██║██║╚██╗██║╚════██║"
    echo " ██║  ██║██║ ╚████║╚██████╔╝██║ ╚████║███████║"
    echo " ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝"
    echo -e "${WHITE}"
    echo "      ████████╗ ██████╗  ██████╗ ██╗      ██╗  ██╗██╗████████╗"
    echo "         ██╔══╝██╔═══██╗██╔═══██╗██║      ██║ ██╔╝██║╚══██╔══╝"
    echo "         ██║   ██║   ██║██║   ██║██║      █████╔╝ ██║   ██║   "
    echo "         ██║   ██║   ██║██║   ██║██║      ██╔═██╗ ██║   ██║   "
    echo "         ██║   ╚██████╔╝╚██████╔╝███████╗ ██║  ██╗██║   ██║   "
    echo "         ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝ ╚═╝  ╚═╝╚═╝   ╚═╝  "
    echo -e "${MAGENTA}"
    echo "        ██████╗ ███████╗     █████╗ ███╗   ██╗ ██████╗ ███╗   ██╗██╗   ██╗███╗   ███╗██╗████████╗██╗   ██╗"
    echo "       ██╔═══██╗██╔════╝    ██╔══██╗████╗  ██║██╔═══██╗████╗  ██║╚██╗ ██╔╝████╗ ████║██║╚══██╔══╝╚██╗ ██╔╝"
    echo "       ██║   ██║█████╗      ███████║██╔██╗ ██║██║   ██║██╔██╗ ██║ ╚████╔╝ ██╔████╔██║██║   ██║    ╚████╔╝ "
    echo "       ██║   ██║██╔══╝      ██╔══██║██║╚██╗██║██║   ██║██║╚██╗██║  ╚██╔╝  ██║╚██╔╝██║██║   ██║     ╚██╔╝  "
    echo "       ╚██████╔╝██║         ██║  ██║██║ ╚████║╚██████╔╝██║ ╚████║   ██║   ██║ ╚═╝ ██║██║   ██║      ██║   "
    echo "        ╚═════╝ ╚═╝         ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝     ╚═╝╚═╝   ╚═╝      ╚═╝  "
    echo -e "${YELLOW}"
    echo "                              c0d3d By @non G00nz"
    echo -e "${CYAN}  ════════════════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${GREEN}         [*] Ethical Testing & Anonymity Framework  |  For Authorized Use Only${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ── Status helper ─────────────────────────────────────────────
info()    { echo -e "${CYAN}[*]${RESET} $*"; }
success() { echo -e "${GREEN}[+]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[-]${RESET} $*"; }

press_enter() {
    echo ""
    echo -e "${YELLOW}[Press ENTER to return to menu...]${RESET}"
    read -r
}

# ── Tool presence check ───────────────────────────────────────
is_installed() { command -v "$1" &>/dev/null; }

# ── Install dependencies ──────────────────────────────────────
install_dependencies() {
    print_banner
    echo -e "${BOLD}${WHITE}  [DEPENDENCY INSTALLER]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    detect_pkg_manager

    if [[ -z "$PKG_MANAGER" ]]; then
        error "Cannot auto-install. Please install packages manually."
        press_enter
        return
    fi

    TOOLS=(
        "tor"
        "proxychains4"
        "macchanger"
        "nmap"
        "curl"
        "wget"
        "whois"
        "net-tools"
        "iptables"
        "openvpn"
        "wireguard"
        "torsocks"
        "bleachbit"
        "secure-delete"
        "haveged"
        "dnscrypt-proxy"
        "resolvconf"
        "traceroute"
        "netcat-openbsd"
        "tcpdump"
        "aircrack-ng"
        "iproute2"
        "rfkill"
        "uuid-runtime"
        "openssl"
    )

    info "Updating package repositories..."
    $PKG_UPDATE &>/dev/null && success "Repositories updated." || warn "Update had warnings (non-fatal)."
    echo ""

    FAILED=()
    for tool in "${TOOLS[@]}"; do
        if is_installed "$tool" || dpkg -l "$tool" &>/dev/null 2>&1; then
            echo -e "  ${GREEN}[✓]${RESET} $tool — already installed"
        else
            echo -ne "  ${YELLOW}[~]${RESET} Installing $tool ..."
            if $PKG_INSTALL "$tool" &>/dev/null 2>&1; then
                echo -e " ${GREEN}done${RESET}"
            else
                echo -e " ${RED}FAILED${RESET}"
                FAILED+=("$tool")
            fi
        fi
    done

    # Install proxychains if proxychains4 failed
    if [[ " ${FAILED[*]} " =~ "proxychains4" ]]; then
        echo -ne "  ${YELLOW}[~]${RESET} Trying proxychains (fallback) ..."
        if $PKG_INSTALL proxychains &>/dev/null 2>&1; then
            echo -e " ${GREEN}done${RESET}"
        else
            echo -e " ${RED}FAILED${RESET}"
        fi
    fi

    echo ""
    if [[ ${#FAILED[@]} -gt 0 ]]; then
        warn "The following packages could not be installed automatically:"
        for f in "${FAILED[@]}"; do echo -e "  ${RED}- $f${RESET}"; done
    else
        success "All tools installed successfully."
    fi

    press_enter
}

# ── TOR Control ───────────────────────────────────────────────
start_tor() {
    print_banner
    echo -e "${BOLD}${WHITE}  [TOR ANONYMITY ENGINE]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if ! is_installed tor; then
        error "Tor is not installed. Run option [1] to install dependencies."
        press_enter; return
    fi

    info "Starting Tor service..."
    systemctl start tor 2>/dev/null || service tor start 2>/dev/null
    sleep 2
    if systemctl is-active --quiet tor 2>/dev/null || pgrep tor &>/dev/null; then
        success "Tor is running."
    else
        error "Tor failed to start. Check: journalctl -xe | grep tor"
        press_enter; return
    fi

    # Configure proxychains
    PCHAIN_CONF=""
    [[ -f /etc/proxychains4.conf ]] && PCHAIN_CONF="/etc/proxychains4.conf"
    [[ -f /etc/proxychains.conf  ]] && PCHAIN_CONF="/etc/proxychains.conf"

    if [[ -n "$PCHAIN_CONF" ]]; then
        sed -i 's/^strict_chain/#strict_chain/'   "$PCHAIN_CONF" 2>/dev/null
        sed -i 's/^#dynamic_chain/dynamic_chain/' "$PCHAIN_CONF" 2>/dev/null
        sed -i '/^socks4/d'  "$PCHAIN_CONF" 2>/dev/null
        sed -i '/^socks5/d'  "$PCHAIN_CONF" 2>/dev/null
        echo "socks5 127.0.0.1 9050" >> "$PCHAIN_CONF"
        success "ProxyChains configured to route through Tor (port 9050)."
    else
        warn "ProxyChains config not found. Install proxychains4 first."
    fi

    # Route DNS through Tor
    if is_installed torsocks; then
        success "torsocks is available — use: torsocks <command>"
    fi

    press_enter
}

stop_tor() {
    print_banner
    echo -e "${BOLD}${WHITE}  [STOP TOR SERVICE]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    info "Stopping Tor service..."
    systemctl stop tor 2>/dev/null || service tor stop 2>/dev/null
    sleep 1
    if ! pgrep tor &>/dev/null; then
        success "Tor has been stopped."
    else
        warn "Tor may still be running. Check manually: pgrep tor"
    fi
    press_enter
}

renew_tor_identity() {
    print_banner
    echo -e "${BOLD}${WHITE}  [RENEW TOR IDENTITY]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if ! pgrep tor &>/dev/null; then
        error "Tor is not running. Start Tor first."
        press_enter; return
    fi
    info "Sending NEWNYM signal to Tor..."
    if is_installed nc; then
        echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\nQUIT' | nc 127.0.0.1 9051 2>/dev/null \
            && success "New Tor circuit established." \
            || warn "Could not signal Tor. Ensure ControlPort 9051 is enabled in /etc/tor/torrc"
    else
        warn "netcat not found. Install netcat-openbsd to renew Tor identity."
    fi
    press_enter
}

# ── MAC Address Changer ───────────────────────────────────────
change_mac() {
    print_banner
    echo -e "${BOLD}${WHITE}  [MAC ADDRESS CHANGER]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if ! is_installed macchanger; then
        error "macchanger not installed. Run option [1]."
        press_enter; return
    fi

    info "Available network interfaces:"
    ip link show | awk -F': ' '/^[0-9]+:/{print "  ["NR"] "$2}' | grep -v lo
    echo ""
    echo -ne "${YELLOW}  Enter interface name (e.g. eth0, wlan0): ${RESET}"
    read -r IFACE

    if ! ip link show "$IFACE" &>/dev/null; then
        error "Interface '$IFACE' not found."
        press_enter; return
    fi

    echo ""
    echo -e "  ${WHITE}[1]${RESET} Random MAC address"
    echo -e "  ${WHITE}[2]${RESET} Random vendor MAC"
    echo -e "  ${WHITE}[3]${RESET} Custom MAC address"
    echo -e "  ${WHITE}[4]${RESET} Restore original MAC"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r MAC_OPT

    info "Bringing interface $IFACE down..."
    ip link set "$IFACE" down

    case "$MAC_OPT" in
        1)
            macchanger -r "$IFACE"
            ;;
        2)
            macchanger -A "$IFACE"
            ;;
        3)
            echo -ne "${YELLOW}  Enter MAC (format XX:XX:XX:XX:XX:XX): ${RESET}"
            read -r CUSTOM_MAC
            macchanger --mac="$CUSTOM_MAC" "$IFACE"
            ;;
        4)
            macchanger -p "$IFACE"
            ;;
        *)
            warn "Invalid choice."
            ;;
    esac

    info "Bringing interface $IFACE back up..."
    ip link set "$IFACE" up
    success "MAC operation complete on $IFACE."
    press_enter
}

# ── IP Info & Leak Check ──────────────────────────────────────
check_ip() {
    print_banner
    echo -e "${BOLD}${WHITE}  [IP / LEAK STATUS CHECK]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if ! is_installed curl; then
        error "curl is not installed."
        press_enter; return
    fi

    info "Fetching current public IP information..."
    echo ""
    IPDATA=$(curl -s --max-time 10 https://ipinfo.io 2>/dev/null)
    if [[ -z "$IPDATA" ]]; then
        warn "Could not reach ipinfo.io. Check your connection."
    else
        echo -e "${WHITE}  ── IP Information ──────────────────────────────${RESET}"
        echo "$IPDATA" | grep -E '"ip"|"city"|"region"|"country"|"org"' \
            | sed 's/[",]//g' | sed 's/^/  /'
    fi

    echo ""
    echo -e "${WHITE}  ── DNS Leak Test ───────────────────────────────${RESET}"
    info "Querying DNS leak test API..."
    DNS_IP=$(curl -s --max-time 10 "https://bash.ws/dnsleak/test/$(openssl rand -hex 8)?json" 2>/dev/null)
    if [[ -z "$DNS_IP" ]]; then
        warn "Could not reach DNS leak API."
    else
        echo "$DNS_IP" | grep -oP '"ip":"[^"]*"' | head -5 | sed 's/"ip"://g;s/"//g' \
            | while read -r dnsip; do echo -e "  ${YELLOW}DNS Server:${RESET} $dnsip"; done
    fi

    echo ""
    echo -e "${WHITE}  ── Tor Detection ───────────────────────────────${RESET}"
    TOR_CHECK=$(curl -s --max-time 10 "https://check.torproject.org/api/ip" 2>/dev/null)
    if echo "$TOR_CHECK" | grep -q '"IsTor":true'; then
        success "You ARE routing through the Tor network."
    else
        warn "You are NOT routing through Tor."
    fi

    press_enter
}

# ── DNS Leak Protection ───────────────────────────────────────
setup_dns_protection() {
    print_banner
    echo -e "${BOLD}${WHITE}  [DNS LEAK PROTECTION]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    echo -e "  ${WHITE}[1]${RESET} Set DNS to Tor (127.0.0.1 via torsocks)"
    echo -e "  ${WHITE}[2]${RESET} Set DNS to Cloudflare (1.1.1.1)"
    echo -e "  ${WHITE}[3]${RESET} Set DNS to Quad9 (9.9.9.9)"
    echo -e "  ${WHITE}[4]${RESET} Set custom DNS"
    echo -e "  ${WHITE}[5]${RESET} Backup & lock /etc/resolv.conf"
    echo -e "  ${WHITE}[6]${RESET} Restore /etc/resolv.conf backup"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r DNS_OPT

    backup_resolv() {
        cp /etc/resolv.conf /etc/resolv.conf.anon_bak 2>/dev/null
        info "Backup saved to /etc/resolv.conf.anon_bak"
    }

    set_dns() {
        chattr -i /etc/resolv.conf 2>/dev/null
        backup_resolv
        echo -e "nameserver $1\nnameserver $2" > /etc/resolv.conf
        chattr +i /etc/resolv.conf 2>/dev/null
        success "DNS set to $1 and locked."
    }

    case "$DNS_OPT" in
        1) set_dns "127.0.0.1" "127.0.0.1" ;;
        2) set_dns "1.1.1.1" "1.0.0.1" ;;
        3) set_dns "9.9.9.9" "149.112.112.112" ;;
        4)
            echo -ne "${YELLOW}  Primary DNS: ${RESET}"; read -r D1
            echo -ne "${YELLOW}  Secondary DNS: ${RESET}"; read -r D2
            set_dns "$D1" "$D2"
            ;;
        5)
            backup_resolv
            chattr +i /etc/resolv.conf 2>/dev/null
            success "/etc/resolv.conf is now locked (immutable)."
            ;;
        6)
            chattr -i /etc/resolv.conf 2>/dev/null
            cp /etc/resolv.conf.anon_bak /etc/resolv.conf 2>/dev/null \
                && success "resolv.conf restored." \
                || error "No backup found."
            ;;
        *) warn "Invalid option." ;;
    esac
    press_enter
}

# ── Firewall / IPTables Anonymity Rules ───────────────────────
setup_firewall() {
    print_banner
    echo -e "${BOLD}${WHITE}  [IPTABLES ANONYMITY FIREWALL]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if ! is_installed iptables; then
        error "iptables not found."
        press_enter; return
    fi

    echo -e "  ${WHITE}[1]${RESET} Enable — Force all traffic through Tor (Transparent Proxy)"
    echo -e "  ${WHITE}[2]${RESET} Enable — Block all non-VPN traffic (kill switch)"
    echo -e "  ${WHITE}[3]${RESET} Flush all anonymity rules (reset firewall)"
    echo -e "  ${WHITE}[4]${RESET} Show current iptables rules"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r FW_OPT

    TOR_UID=$(id -u debian-tor 2>/dev/null || id -u tor 2>/dev/null || echo "109")
    NON_TOR="192.168.0.0/16 10.0.0.0/8 172.16.0.0/12"

    case "$FW_OPT" in
        1)
            info "Setting up Tor transparent proxy rules..."
            iptables -F
            iptables -t nat -F
            # Allow Tor process itself
            iptables -t nat -A OUTPUT -m owner --uid-owner "$TOR_UID" -j RETURN
            # Allow LAN traffic
            for NET in $NON_TOR; do
                iptables -t nat -A OUTPUT -d "$NET" -j RETURN
            done
            # Redirect DNS to Tor
            iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353
            # Redirect all TCP through Tor TransPort
            iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports 9040
            # Drop non-Tor UDP/ICMP
            iptables -A OUTPUT -m owner --uid-owner "$TOR_UID" -j ACCEPT
            iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
            for NET in $NON_TOR; do
                iptables -A OUTPUT -d "$NET" -j ACCEPT
            done
            iptables -A OUTPUT -p tcp -j ACCEPT
            iptables -A OUTPUT -j DROP
            success "All TCP traffic redirected through Tor. DNS leaks blocked."
            warn "Ensure TransPort 9040 and DNSPort 5353 are set in /etc/tor/torrc"
            ;;
        2)
            echo -ne "${YELLOW}  Enter your VPN interface (e.g. tun0, wg0): ${RESET}"
            read -r VPN_IFACE
            info "Setting up VPN kill switch on $VPN_IFACE..."
            iptables -F; iptables -X
            iptables -P INPUT DROP
            iptables -P FORWARD DROP
            iptables -P OUTPUT DROP
            iptables -A INPUT  -i lo -j ACCEPT
            iptables -A OUTPUT -o lo -j ACCEPT
            iptables -A INPUT  -i "$VPN_IFACE" -j ACCEPT
            iptables -A OUTPUT -o "$VPN_IFACE" -j ACCEPT
            # Allow VPN handshake (UDP 1194 OpenVPN / 51820 WireGuard)
            iptables -A OUTPUT -p udp --dport 1194 -j ACCEPT
            iptables -A OUTPUT -p udp --dport 51820 -j ACCEPT
            iptables -A OUTPUT -p tcp --dport 443  -j ACCEPT
            iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
            success "Kill switch active. Only $VPN_IFACE traffic is allowed."
            ;;
        3)
            iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X
            iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT
            success "All iptables rules flushed. Firewall is open."
            ;;
        4)
            echo ""
            echo -e "${WHITE}  ── Filter Table ─────────────────────────────────${RESET}"
            iptables -L -v -n --line-numbers
            echo ""
            echo -e "${WHITE}  ── NAT Table ────────────────────────────────────${RESET}"
            iptables -t nat -L -v -n --line-numbers
            ;;
        *) warn "Invalid option." ;;
    esac
    press_enter
}

# ── Hostname Randomiser ───────────────────────────────────────
change_hostname() {
    print_banner
    echo -e "${BOLD}${WHITE}  [HOSTNAME RANDOMISER]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    CURRENT=$(hostname)
    info "Current hostname: $CURRENT"
    echo ""
    echo -e "  ${WHITE}[1]${RESET} Generate random hostname"
    echo -e "  ${WHITE}[2]${RESET} Set custom hostname"
    echo -e "  ${WHITE}[3]${RESET} Restore original hostname"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r HN_OPT

    ORIG_FILE="/etc/hostname.anon_original"
    [[ ! -f "$ORIG_FILE" ]] && echo "$CURRENT" > "$ORIG_FILE"

    case "$HN_OPT" in
        1)
            ADJ=("silent" "ghost" "shadow" "phantom" "null" "void" "stealth" "cipher" "anon" "masked")
            NOUN=("node" "host" "box" "unit" "agent" "relay" "nexus" "core" "cell" "gate")
            RAND_HOSTNAME="${ADJ[$RANDOM % ${#ADJ[@]}]}-${NOUN[$RANDOM % ${#NOUN[@]}]}-$((RANDOM % 9999))"
            ;;
        2)
            echo -ne "${YELLOW}  New hostname: ${RESET}"
            read -r RAND_HOSTNAME
            ;;
        3)
            RAND_HOSTNAME=$(cat "$ORIG_FILE" 2>/dev/null || echo "localhost")
            ;;
        *) warn "Invalid option."; press_enter; return ;;
    esac

    echo "$RAND_HOSTNAME" > /etc/hostname
    hostname "$RAND_HOSTNAME"
    sed -i "s/$CURRENT/$RAND_HOSTNAME/g" /etc/hosts 2>/dev/null
    success "Hostname changed to: $RAND_HOSTNAME"
    press_enter
}

# ── Timezone Spoofer ──────────────────────────────────────────
spoof_timezone() {
    print_banner
    echo -e "${BOLD}${WHITE}  [TIMEZONE SPOOFER]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    CURRENT_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null)
    info "Current timezone: $CURRENT_TZ"
    echo ""

    TZ_LIST=("America/New_York" "Europe/London" "Asia/Tokyo" "Australia/Sydney"
             "Europe/Berlin" "America/Chicago" "Asia/Singapore" "America/Los_Angeles"
             "Europe/Moscow" "Asia/Dubai" "America/Toronto" "Pacific/Auckland")

    echo -e "  ${WHITE}Common Timezones:${RESET}"
    for i in "${!TZ_LIST[@]}"; do
        printf "  ${WHITE}[%2d]${RESET} %s\n" "$((i+1))" "${TZ_LIST[$i]}"
    done
    echo -e "  ${WHITE}[ 0]${RESET} Enter custom timezone"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r TZ_OPT

    if [[ "$TZ_OPT" -eq 0 ]]; then
        echo -ne "${YELLOW}  Enter timezone (e.g. Asia/Karachi): ${RESET}"
        read -r NEW_TZ
    elif [[ "$TZ_OPT" -ge 1 && "$TZ_OPT" -le ${#TZ_LIST[@]} ]]; then
        NEW_TZ="${TZ_LIST[$((TZ_OPT-1))]}"
    else
        warn "Invalid option."; press_enter; return
    fi

    if timedatectl set-timezone "$NEW_TZ" 2>/dev/null; then
        success "Timezone spoofed to: $NEW_TZ"
    else
        ln -sf "/usr/share/zoneinfo/$NEW_TZ" /etc/localtime 2>/dev/null \
            && echo "$NEW_TZ" > /etc/timezone \
            && success "Timezone set to: $NEW_TZ" \
            || error "Failed to set timezone. Check the timezone string."
    fi
    press_enter
}

# ── Proxychains Launcher ──────────────────────────────────────
proxychains_run() {
    print_banner
    echo -e "${BOLD}${WHITE}  [PROXYCHAINS LAUNCHER]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    PC_CMD=""
    is_installed proxychains4 && PC_CMD="proxychains4"
    is_installed proxychains  && PC_CMD="proxychains"

    if [[ -z "$PC_CMD" ]]; then
        error "proxychains not installed. Run option [1]."
        press_enter; return
    fi

    echo -ne "${YELLOW}  Enter command to run through ProxyChains (e.g. nmap -sT target.com): ${RESET}"
    read -r USER_CMD
    echo ""
    info "Executing: $PC_CMD $USER_CMD"
    echo -e "${CYAN}  ────────────────────────────────────────${RESET}"
    eval "$PC_CMD $USER_CMD"
    echo -e "${CYAN}  ────────────────────────────────────────${RESET}"
    press_enter
}

# ── Secure Log & File Wiper ───────────────────────────────────
wipe_logs() {
    print_banner
    echo -e "${BOLD}${WHITE}  [SECURE LOG & TRACE WIPER]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    echo -e "  ${WHITE}[1]${RESET} Wipe bash history"
    echo -e "  ${WHITE}[2]${RESET} Wipe system logs (/var/log/*)"
    echo -e "  ${WHITE}[3]${RESET} Wipe temp files (/tmp /var/tmp)"
    echo -e "  ${WHITE}[4]${RESET} Wipe all recent files (via BleachBit)"
    echo -e "  ${WHITE}[5]${RESET} Secure-delete a specific file (srm)"
    echo -e "  ${WHITE}[6]${RESET} Wipe ALL traces (1+2+3+4)"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r WIPE_OPT

    wipe_bash_history() {
        cat /dev/null > ~/.bash_history
        history -c
        history -w
        unset HISTFILE
        export HISTSIZE=0
        export HISTFILESIZE=0
        success "Bash history wiped."
    }

    wipe_system_logs() {
        for logfile in /var/log/auth.log /var/log/syslog /var/log/kern.log \
                       /var/log/messages /var/log/dpkg.log /var/log/wtmp \
                       /var/log/btmp /var/log/lastlog /var/log/faillog; do
            [[ -f "$logfile" ]] && cat /dev/null > "$logfile" && echo -e "  ${GREEN}[✓]${RESET} Cleared $logfile"
        done
        # Wipe journald
        journalctl --rotate &>/dev/null
        journalctl --vacuum-time=1s &>/dev/null
        success "System logs cleared."
    }

    wipe_tmp() {
        rm -rf /tmp/* /var/tmp/* 2>/dev/null
        success "Temp directories cleared."
    }

    case "$WIPE_OPT" in
        1) wipe_bash_history ;;
        2) wipe_system_logs ;;
        3) wipe_tmp ;;
        4)
            if is_installed bleachbit; then
                bleachbit --clean system.tmp system.trash system.cache bash.history &>/dev/null \
                    && success "BleachBit cleaning complete." \
                    || warn "BleachBit encountered errors."
            else
                warn "BleachBit not installed. Run option [1] first."
            fi
            ;;
        5)
            echo -ne "${YELLOW}  Enter full path to file: ${RESET}"
            read -r SFILE
            if [[ -f "$SFILE" ]]; then
                if is_installed srm; then
                    srm -vz "$SFILE" && success "File securely deleted: $SFILE"
                elif is_installed shred; then
                    shred -vzn 7 "$SFILE" && rm -f "$SFILE" && success "File shredded: $SFILE"
                else
                    warn "Neither srm nor shred found. Using basic rm."
                    rm -f "$SFILE"
                fi
            else
                error "File not found: $SFILE"
            fi
            ;;
        6)
            wipe_bash_history
            wipe_system_logs
            wipe_tmp
            is_installed bleachbit && bleachbit --clean system.tmp system.trash \
                system.cache bash.history &>/dev/null && success "BleachBit done."
            ;;
        *) warn "Invalid option." ;;
    esac
    press_enter
}

# ── Random Identity Generator ─────────────────────────────────
generate_identity() {
    print_banner
    echo -e "${BOLD}${WHITE}  [RANDOM IDENTITY GENERATOR]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    FIRST_NAMES=("Alex" "Jordan" "Morgan" "Casey" "Taylor" "Riley" "Avery" "Quinn"
                 "Blake" "Logan" "Reese" "Skyler" "Peyton" "Drew" "Jamie")
    LAST_NAMES=("Smith" "Johnson" "Williams" "Brown" "Jones" "Miller" "Davis"
                "Wilson" "Moore" "Anderson" "Thomas" "Jackson" "White" "Harris")
    COUNTRIES=("United States" "Germany" "Canada" "Australia" "Netherlands"
               "Sweden" "France" "Japan" "New Zealand" "Switzerland")
    CITIES=("Chicago" "Berlin" "Toronto" "Sydney" "Amsterdam" "Stockholm"
            "Paris" "Tokyo" "Auckland" "Zurich")
    DOMAINS=("protonmail.com" "tutanota.com" "guerrillamail.com" "mailfence.com" "disroot.org")

    FNAME="${FIRST_NAMES[$RANDOM % ${#FIRST_NAMES[@]}]}"
    LNAME="${LAST_NAMES[$RANDOM % ${#LAST_NAMES[@]}]}"
    IDX=$((RANDOM % ${#COUNTRIES[@]}))
    COUNTRY="${COUNTRIES[$IDX]}"
    CITY="${CITIES[$IDX]}"
    DOMAIN="${DOMAINS[$RANDOM % ${#DOMAINS[@]}]}"
    DOB_Y=$((1970 + RANDOM % 30))
    DOB_M=$(printf "%02d" $((1 + RANDOM % 12)))
    DOB_D=$(printf "%02d" $((1 + RANDOM % 28)))
    PHONE="+1-$(shuf -i 200-999 -n1)-$(shuf -i 100-999 -n1)-$(shuf -i 1000-9999 -n1)"
    EMAIL_USER=$(echo "${FNAME}${LNAME}" | tr '[:upper:]' '[:lower:]')$((RANDOM % 999))
    ZIP=$(shuf -i 10000-99999 -n1)

    echo -e "  ${CYAN}┌─────────────────────────────────────────────┐${RESET}"
    echo -e "  ${CYAN}│${WHITE}         GENERATED ANONYMOUS IDENTITY         ${CYAN}│${RESET}"
    echo -e "  ${CYAN}├─────────────────────────────────────────────┤${RESET}"
    printf "  ${CYAN}│${RESET}  %-20s %-24s${CYAN}│${RESET}\n" "Full Name:"   "$FNAME $LNAME"
    printf "  ${CYAN}│${RESET}  %-20s %-24s${CYAN}│${RESET}\n" "Date of Birth:" "$DOB_Y-$DOB_M-$DOB_D"
    printf "  ${CYAN}│${RESET}  %-20s %-24s${CYAN}│${RESET}\n" "Country:"     "$COUNTRY"
    printf "  ${CYAN}│${RESET}  %-20s %-24s${CYAN}│${RESET}\n" "City:"        "$CITY"
    printf "  ${CYAN}│${RESET}  %-20s %-24s${CYAN}│${RESET}\n" "ZIP/Post Code:" "$ZIP"
    printf "  ${CYAN}│${RESET}  %-20s %-24s${CYAN}│${RESET}\n" "Phone:"       "$PHONE"
    printf "  ${CYAN}│${RESET}  %-20s %-24s${CYAN}│${RESET}\n" "Email:"       "${EMAIL_USER}@${DOMAIN}"
    echo -e "  ${CYAN}└─────────────────────────────────────────────┘${RESET}"

    press_enter
}

# ── OpenVPN Quick Connect ─────────────────────────────────────
connect_vpn() {
    print_banner
    echo -e "${BOLD}${WHITE}  [OPENVPN QUICK CONNECT]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if ! is_installed openvpn; then
        error "OpenVPN is not installed. Run option [1]."
        press_enter; return
    fi

    echo -ne "${YELLOW}  Enter full path to your .ovpn config file: ${RESET}"
    read -r OVPN_FILE
    if [[ ! -f "$OVPN_FILE" ]]; then
        error "File not found: $OVPN_FILE"
        press_enter; return
    fi

    info "Starting OpenVPN with $OVPN_FILE ..."
    openvpn --config "$OVPN_FILE" --daemon --log /tmp/openvpn_anon.log
    sleep 3
    if pgrep openvpn &>/dev/null; then
        success "OpenVPN connected. Logs: /tmp/openvpn_anon.log"
    else
        error "OpenVPN failed to start. Check: cat /tmp/openvpn_anon.log"
    fi
    press_enter
}

disconnect_vpn() {
    print_banner
    echo -e "${BOLD}${WHITE}  [OPENVPN DISCONNECT]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if pgrep openvpn &>/dev/null; then
        pkill openvpn && success "OpenVPN disconnected." || error "Failed to kill OpenVPN."
    else
        warn "No active OpenVPN session found."
    fi
    press_enter
}

# ── WireGuard Quick Connect ───────────────────────────────────
connect_wireguard() {
    print_banner
    echo -e "${BOLD}${WHITE}  [WIREGUARD QUICK CONNECT]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    if ! is_installed wg; then
        error "WireGuard not installed. Run option [1]."
        press_enter; return
    fi

    echo -ne "${YELLOW}  Enter WireGuard interface name (e.g. wg0): ${RESET}"
    read -r WG_IFACE
    echo -ne "${YELLOW}  Enter full path to .conf file (e.g. /etc/wireguard/wg0.conf): ${RESET}"
    read -r WG_CONF

    if [[ ! -f "$WG_CONF" ]]; then
        error "Config file not found: $WG_CONF"
        press_enter; return
    fi

    cp "$WG_CONF" "/etc/wireguard/${WG_IFACE}.conf" 2>/dev/null
    wg-quick up "$WG_IFACE" && success "WireGuard $WG_IFACE is up." || error "WireGuard failed to start."
    press_enter
}

disconnect_wireguard() {
    print_banner
    echo -e "${BOLD}${WHITE}  [WIREGUARD DISCONNECT]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    echo -ne "${YELLOW}  Enter WireGuard interface to bring down (e.g. wg0): ${RESET}"
    read -r WG_DOWN
    wg-quick down "$WG_DOWN" 2>/dev/null && success "WireGuard $WG_DOWN disconnected." \
        || error "Failed to disconnect $WG_DOWN."
    press_enter
}

# ── Browser Fingerprint Hardening Tips ───────────────────────
browser_tips() {
    print_banner
    echo -e "${BOLD}${WHITE}  [BROWSER FINGERPRINT HARDENING GUIDE]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    echo -e "${WHITE}  Firefox Hardening:${RESET}"
    echo -e "  ${GREEN}[+]${RESET} Go to about:config and set:"
    echo -e "      ${YELLOW}privacy.resistFingerprinting${RESET}    = true"
    echo -e "      ${YELLOW}privacy.trackingprotection.enabled${RESET} = true"
    echo -e "      ${YELLOW}geo.enabled${RESET}                     = false"
    echo -e "      ${YELLOW}media.peerconnection.enabled${RESET}     = false  (blocks WebRTC leak)"
    echo -e "      ${YELLOW}network.dns.disablePrefetch${RESET}      = true"
    echo -e "      ${YELLOW}browser.safebrowsing.enabled${RESET}     = false"
    echo ""
    echo -e "${WHITE}  Recommended Browsers for Anonymity:${RESET}"
    echo -e "  ${GREEN}[+]${RESET} Tor Browser  — best anonymity, built-in Tor"
    echo -e "  ${GREEN}[+]${RESET} Brave         — fingerprint randomisation, Tor tabs"
    echo -e "  ${GREEN}[+]${RESET} LibreWolf     — hardened Firefox fork"
    echo ""
    echo -e "${WHITE}  Recommended Extensions:${RESET}"
    echo -e "  ${GREEN}[+]${RESET} uBlock Origin — ad/tracker blocking"
    echo -e "  ${GREEN}[+]${RESET} Canvas Blocker — canvas fingerprint spoofing"
    echo -e "  ${GREEN}[+]${RESET} User-Agent Switcher"
    echo -e "  ${GREEN}[+]${RESET} Privacy Badger"
    echo ""
    echo -e "${WHITE}  WebRTC Leak Prevention:${RESET}"
    echo -e "  ${GREEN}[+]${RESET} Always disable WebRTC or set to 'Disable non-proxied UDP'"
    echo -e "  ${GREEN}[+]${RESET} Test at: https://browserleaks.com/webrtc"
    press_enter
}

# ── Anonymity Status Dashboard ────────────────────────────────
anon_status() {
    print_banner
    echo -e "${BOLD}${WHITE}  [ANONYMITY STATUS DASHBOARD]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    chk() {
        if eval "$2" &>/dev/null; then
            printf "  ${GREEN}[✓]${RESET} %-35s ${GREEN}ACTIVE${RESET}\n" "$1"
        else
            printf "  ${RED}[✗]${RESET} %-35s ${RED}INACTIVE${RESET}\n" "$1"
        fi
    }

    chk "Tor Service"           "pgrep tor"
    chk "OpenVPN"               "pgrep openvpn"
    chk "WireGuard"             "ip link show | grep -q wg"
    chk "ProxyChains"           "command -v proxychains4 || command -v proxychains"
    chk "macchanger"            "command -v macchanger"
    chk "iptables Rules Active" "iptables -L OUTPUT | grep -q DROP"
    chk "DNS Locked (immutable)" "lsattr /etc/resolv.conf 2>/dev/null | grep -q '\-i\-'"
    chk "BleachBit"             "command -v bleachbit"
    chk "Torsocks"              "command -v torsocks"
    chk "dnscrypt-proxy"        "pgrep dnscrypt-proxy"

    echo ""
    echo -e "${WHITE}  ── Current Public IP ───────────────────────────${RESET}"
    PUB_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
    echo -e "  ${YELLOW}Public IP:${RESET} ${PUB_IP:-Unable to fetch}"

    echo ""
    echo -e "${WHITE}  ── Tor Detection ────────────────────────────────${RESET}"
    TOR_STATUS=$(curl -s --max-time 5 "https://check.torproject.org/api/ip" 2>/dev/null)
    if echo "$TOR_STATUS" | grep -q '"IsTor":true'; then
        echo -e "  ${GREEN}[✓] Currently routing through Tor${RESET}"
    else
        echo -e "  ${RED}[✗] NOT routing through Tor${RESET}"
    fi

    echo ""
    echo -e "${WHITE}  ── DNS Servers In Use ───────────────────────────${RESET}"
    grep "^nameserver" /etc/resolv.conf 2>/dev/null | awk '{print "  DNS: "$2}'

    press_enter
}

# ── Tor Torrc Configuration Helper ───────────────────────────
configure_torrc() {
    print_banner
    echo -e "${BOLD}${WHITE}  [TOR TORRC CONFIGURATION]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    TORRC="/etc/tor/torrc"
    [[ ! -f "$TORRC" ]] && { error "torrc not found at $TORRC"; press_enter; return; }

    cp "$TORRC" "${TORRC}.anon_bak" 2>/dev/null && info "Backup: ${TORRC}.anon_bak"
    echo ""
    echo -e "  ${WHITE}[1]${RESET} Enable TransPort 9040 (transparent proxy)"
    echo -e "  ${WHITE}[2]${RESET} Enable DNSPort 5353 (DNS over Tor)"
    echo -e "  ${WHITE}[3]${RESET} Enable ControlPort 9051 (identity renewal)"
    echo -e "  ${WHITE}[4]${RESET} Enable all three"
    echo -e "  ${WHITE}[5]${RESET} View current torrc"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r TORRC_OPT

    add_torrc_line() {
        grep -qF "$1" "$TORRC" || echo "$1" >> "$TORRC"
        success "Added: $1"
    }

    case "$TORRC_OPT" in
        1) add_torrc_line "TransPort 9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort" ;;
        2) add_torrc_line "DNSPort 5353" ;;
        3) add_torrc_line "ControlPort 9051"
           add_torrc_line 'HashedControlPassword ""' ;;
        4)
            add_torrc_line "TransPort 9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort"
            add_torrc_line "DNSPort 5353"
            add_torrc_line "ControlPort 9051"
            add_torrc_line 'HashedControlPassword ""'
            ;;
        5) cat "$TORRC" | less ;;
        *) warn "Invalid option." ;;
    esac

    info "Restarting Tor to apply changes..."
    systemctl restart tor 2>/dev/null || service tor restart 2>/dev/null
    press_enter
}

# ── Network Recon (through Tor) ───────────────────────────────
network_recon() {
    print_banner
    echo -e "${BOLD}${WHITE}  [ANONYMOUS NETWORK RECON]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""

    PC_CMD=""
    is_installed proxychains4 && PC_CMD="proxychains4 -q"
    is_installed proxychains  && PC_CMD="proxychains -q"

    echo -e "  ${WHITE}[1]${RESET} Whois lookup"
    echo -e "  ${WHITE}[2]${RESET} Nmap TCP scan (via ProxyChains)"
    echo -e "  ${WHITE}[3]${RESET} Traceroute (via torsocks)"
    echo -e "  ${WHITE}[4]${RESET} DNS lookup"
    echo -e "  ${WHITE}[5]${RESET} HTTP header grab (via curl+Tor)"
    echo ""
    echo -ne "${YELLOW}  Choose: ${RESET}"
    read -r RECON_OPT
    echo -ne "${YELLOW}  Enter target (domain/IP): ${RESET}"
    read -r TARGET

    echo ""
    case "$RECON_OPT" in
        1) whois "$TARGET" 2>/dev/null | head -40 ;;
        2)
            if [[ -z "$PC_CMD" ]]; then
                warn "ProxyChains not found. Running without proxy."
                nmap -sT -Pn --open -T2 "$TARGET"
            else
                eval "$PC_CMD nmap -sT -Pn --open -T2 $TARGET"
            fi
            ;;
        3)
            if is_installed torsocks; then
                torsocks traceroute "$TARGET" 2>/dev/null
            else
                traceroute "$TARGET" 2>/dev/null
            fi
            ;;
        4) host "$TARGET" 2>/dev/null || nslookup "$TARGET" ;;
        5)
            if is_installed torsocks && pgrep tor &>/dev/null; then
                torsocks curl -sI --max-time 10 "http://$TARGET" 2>/dev/null
            else
                curl -sI --max-time 10 "http://$TARGET" 2>/dev/null
            fi
            ;;
        *) warn "Invalid option." ;;
    esac
    press_enter
}

# ── System Entropy Booster ────────────────────────────────────
boost_entropy() {
    print_banner
    echo -e "${BOLD}${WHITE}  [SYSTEM ENTROPY BOOSTER]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    ENTROPY=$(cat /proc/sys/kernel/random/entropy_avail 2>/dev/null)
    info "Current entropy pool: ${ENTROPY} bits"
    echo ""

    if is_installed haveged; then
        info "Starting haveged entropy daemon..."
        systemctl start haveged 2>/dev/null || service haveged start 2>/dev/null || haveged &
        sleep 1
        NEW_ENTROPY=$(cat /proc/sys/kernel/random/entropy_avail 2>/dev/null)
        success "Entropy pool is now: ${NEW_ENTROPY} bits"
    else
        warn "haveged not installed. Run option [1] to install."
    fi
    press_enter
}

# ── Kernel Hardening (sysctl) ─────────────────────────────────
harden_kernel() {
    print_banner
    echo -e "${BOLD}${WHITE}  [KERNEL HARDENING (SYSCTL)]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    warn "This will modify /etc/sysctl.conf with anonymity-focused settings."
    echo -ne "${YELLOW}  Proceed? (y/N): ${RESET}"
    read -r CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && press_enter && return

    SYSCTL_FILE="/etc/sysctl.d/99-anon-hardening.conf"
    cat > "$SYSCTL_FILE" <<'EOF'
# Anon Toolkit - Kernel Hardening Settings
# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable IPv6 (reduces attack/leak surface)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Prevent IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Disable ICMP broadcast
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable TCP SYN cookie protection
net.ipv4.tcp_syncookies = 1

# Protect against time-wait assassination
net.ipv4.tcp_rfc1337 = 1

# Randomise process IDs and VA space
kernel.randomize_va_space = 2

# Restrict kernel logs
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2

# Disable magic SysRq key
kernel.sysrq = 0

# Restrict core dumps
fs.suid_dumpable = 0
EOF

    sysctl --system &>/dev/null && success "Kernel hardening applied." || error "Failed to apply sysctl settings."
    press_enter
}

# ── Revert All Changes ────────────────────────────────────────
revert_all() {
    print_banner
    echo -e "${BOLD}${WHITE}  [REVERT ALL ANONYMITY CHANGES]${RESET}"
    echo -e "${CYAN}  ════════════════════════════════════════${RESET}"
    echo ""
    warn "This will attempt to revert all changes made by this toolkit."
    echo -ne "${YELLOW}  Proceed? (y/N): ${RESET}"
    read -r CONF
    [[ ! "$CONF" =~ ^[Yy]$ ]] && press_enter && return

    # Stop Tor
    systemctl stop tor 2>/dev/null; success "Tor stopped."

    # Stop OpenVPN
    pkill openvpn 2>/dev/null; success "OpenVPN stopped."

    # Flush iptables
    iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X
    iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT
    success "iptables flushed."

    # Restore resolv.conf
    chattr -i /etc/resolv.conf 2>/dev/null
    [[ -f /etc/resolv.conf.anon_bak ]] && cp /etc/resolv.conf.anon_bak /etc/resolv.conf \
        && success "resolv.conf restored."

    # Restore hostname
    if [[ -f /etc/hostname.anon_original ]]; then
        ORIG_HN=$(cat /etc/hostname.anon_original)
        echo "$ORIG_HN" > /etc/hostname
        hostname "$ORIG_HN"
        success "Hostname restored to: $ORIG_HN"
    fi

    # Remove kernel hardening
    rm -f /etc/sysctl.d/99-anon-hardening.conf
    sysctl --system &>/dev/null
    success "Kernel hardening reverted."

    press_enter
}

# ── Main Menu ─────────────────────────────────────────────────
main_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}${WHITE}  MAIN MENU${RESET}"
        echo -e "${CYAN}  ════════════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "  ${CYAN}── SETUP ─────────────────────────────────────────────${RESET}"
        echo -e "  ${WHITE}[1]${RESET}  Install / Update All Dependencies"
        echo -e "  ${WHITE}[2]${RESET}  Check Anonymity Status Dashboard"
        echo ""
        echo -e "  ${CYAN}── TOR ───────────────────────────────────────────────${RESET}"
        echo -e "  ${WHITE}[3]${RESET}  Start Tor + Configure ProxyChains"
        echo -e "  ${WHITE}[4]${RESET}  Stop Tor Service"
        echo -e "  ${WHITE}[5]${RESET}  Renew Tor Circuit / New Identity"
        echo -e "  ${WHITE}[6]${RESET}  Configure Torrc (TransPort/DNSPort/ControlPort)"
        echo ""
        echo -e "  ${CYAN}── NETWORK / IDENTITY ────────────────────────────────${RESET}"
        echo -e "  ${WHITE}[7]${RESET}  Change / Randomise MAC Address"
        echo -e "  ${WHITE}[8]${RESET}  DNS Leak Protection"
        echo -e "  ${WHITE}[9]${RESET}  Setup Anonymity Firewall (iptables)"
        echo -e "  ${WHITE}[10]${RESET} Spoof Hostname"
        echo -e "  ${WHITE}[11]${RESET} Spoof System Timezone"
        echo -e "  ${WHITE}[12]${RESET} Generate Random Anonymous Identity"
        echo ""
        echo -e "  ${CYAN}── VPN ───────────────────────────────────────────────${RESET}"
        echo -e "  ${WHITE}[13]${RESET} Connect OpenVPN"
        echo -e "  ${WHITE}[14]${RESET} Disconnect OpenVPN"
        echo -e "  ${WHITE}[15]${RESET} Connect WireGuard"
        echo -e "  ${WHITE}[16]${RESET} Disconnect WireGuard"
        echo ""
        echo -e "  ${CYAN}── TOOLS & RECON ─────────────────────────────────────${RESET}"
        echo -e "  ${WHITE}[17]${RESET} Run Command via ProxyChains"
        echo -e "  ${WHITE}[18]${RESET} Anonymous Network Recon"
        echo -e "  ${WHITE}[19]${RESET} Check IP / DNS / Tor Leak Status"
        echo ""
        echo -e "  ${CYAN}── HARDENING & CLEANUP ───────────────────────────────${RESET}"
        echo -e "  ${WHITE}[20]${RESET} Wipe Logs & Traces"
        echo -e "  ${WHITE}[21]${RESET} Kernel Hardening (sysctl)"
        echo -e "  ${WHITE}[22]${RESET} Boost System Entropy (haveged)"
        echo -e "  ${WHITE}[23]${RESET} Browser Fingerprint Hardening Guide"
        echo ""
        echo -e "  ${CYAN}── SYSTEM ────────────────────────────────────────────${RESET}"
        echo -e "  ${WHITE}[24]${RESET} Revert ALL Anonymity Changes"
        echo -e "  ${RED}[0]${RESET}  Exit"
        echo ""
        echo -e "${CYAN}  ════════════════════════════════════════════════════════${RESET}"
        echo -ne "${YELLOW}  Choose an option: ${RESET}"
        read -r CHOICE

        case "$CHOICE" in
            1)  install_dependencies ;;
            2)  anon_status ;;
            3)  start_tor ;;
            4)  stop_tor ;;
            5)  renew_tor_identity ;;
            6)  configure_torrc ;;
            7)  change_mac ;;
            8)  setup_dns_protection ;;
            9)  setup_firewall ;;
            10) change_hostname ;;
            11) spoof_timezone ;;
            12) generate_identity ;;
            13) connect_vpn ;;
            14) disconnect_vpn ;;
            15) connect_wireguard ;;
            16) disconnect_wireguard ;;
            17) proxychains_run ;;
            18) network_recon ;;
            19) check_ip ;;
            20) wipe_logs ;;
            21) harden_kernel ;;
            22) boost_entropy ;;
            23) browser_tips ;;
            24) revert_all ;;
            0)
                echo ""
                echo -e "${GREEN}  [*] Exiting Anon's Toolkit of Anonymity. Stay safe.${RESET}"
                echo ""
                exit 0
                ;;
            *)
                warn "Invalid option. Please choose from the menu."
                sleep 1
                ;;
        esac
    done
}

# ── Entry Point ───────────────────────────────────────────────
detect_pkg_manager
main_menu

