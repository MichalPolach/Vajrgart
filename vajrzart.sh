#!/bin/bash

# Basic error handling
set -euo pipefail

# Function to check if script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERROR: This script must be run as root!"
        exit 1
    fi
}

check_dep() {
    if ! command -v dialog >/dev/null 2>&1; then
        apt-get update >/dev/null 2>&1
        apt-get install -y dialog >/dev/null 2>&1
    fi
}

# Function to validate entered port number
validate_port() {
    local port=$1
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        dialog --title "Error" \
               --msgbox "Invalid port number. Please use a number between 1-65535" 8 50
        exit 1
    fi
    return 0
}

# Function to validate entered hostname/IP
validate_hostname() {
    local hostname=$1
    if ! host "$hostname" >/dev/null 2>&1 && ! [[ "$hostname" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        dialog --title "Warning" \
               --msgbox "Unable to resolve hostname/IP. Please verify it's correct" 8 50
    fi
    return 0
}

# Function to install WireGuard if not already installed
install_wireguard() {
    if ! command -v wg-quick >/dev/null 2>&1; then
        dialog --title "WireGuard Installation" \
               --yesno "WireGuard is not installed. Do you want to install it?" 8 50
        
        response=$?
        
        if [ $response -eq 0 ]; then
            (
                echo "10" ; echo "XXX"
                echo "Updating package lists..."
                echo "XXX"
                
                apt-get update >/dev/null 2>&1
                
                echo "40" ; echo "XXX"
                echo "Installing WireGuard..."
                echo "XXX"
                
                apt-get install -y wireguard >/dev/null 2>&1
                
                echo "80" ; echo "XXX"
                echo "Finalizing installation..."
                echo "XXX"
                
                sleep 1
                
                echo "100" ; echo "XXX"
                echo "Installation complete!"
                echo "XXX"
            ) | dialog --title "WireGuard Installation" --gauge "Starting installation..." 8 50 0
            
            sleep 2
        fi
    else
        dialog --infobox "WireGuard is already installed" 8 50
        sleep 2
    fi
}

# Function to generate keys
generate_keys() {
    local key_dir=$1
    dialog --infobox "Generating key pairs..." 8 50
    sleep 3
    wg genkey | tee $key_dir/privatekey | wg pubkey > $key_dir/publickey
    dialog --infobox "Key generation completed" 8 50
    sleep 2
}

# Fucntion to add a new peer to the server and generate configuration file
add_peer() {
    temp_file=$(mktemp)

    local conf_dir="/etc/wireguard"
    local client_dir="/home/${SUDO_USER:-$USER}/.wireguard"
    local current_ip=$(grep -E "AllowedIPs.*10\.0\.0\." "${conf_dir}/wg0.conf" | tail -1 | grep -oE "10\.0\.0\.[0-9]+" | cut -d. -f4 || echo 1)
    local new_ip=$(($current_ip + 1))

    if [ "$new_ip" -gt 254 ]; then
        dialog --title "Error" \
               --msgbox "No more IP addresses available" 8 50
        exit 1
    fi

    dialog --title "Add Peer" \
           --inputbox "Enter peer name:" 8 50 2> $temp_file
    echo "$(cat $temp_file)" >> /tmp/peern.tmp
    peer_name=$(cat /tmp/peern.tmp)

    dialog --title "Add Peer" \
           --inputbox "Enter port number:" 8 50 2> $temp_file
    echo "$(cat $temp_file)" >> /tmp/portn.tmp
    wport=$(cat /tmp/portn.tmp)
    validate_port "$wport"

    dialog --title "Add Peer" \
           --inputbox "Enter IP address or Domain:" 8 50 2> $temp_file
    echo "$(cat $temp_file)" >> /tmp/addr.tmp
    server=$(cat /tmp/addr.tmp)
    validate_hostname "$server"

    dialog --infobox "Generating client keys... for ${peer_name}" 8 50
    sleep 3
    local client_priv_key
    local client_pub_key
    client_priv_key="$(wg genkey)"
    client_pub_key="$(echo "$client_priv_key" | wg pubkey)"
    
    # Add peer to server config
    dialog --infobox "Adding peer to server configuration..." 8 50
    sleep 3
    {
        echo ""
        echo "[Peer]"
        echo "PublicKey = ${client_pub_key}"
        echo "AllowedIPs = 10.0.0.${new_ip}/32"
        echo "PersistentKeepalive = 25"
    } >> "${conf_dir}/wg0.conf"
    
    # Create client configuration directory if it doesn't exist
    mkdir -p "$client_dir"

    # Save client configuration
    dialog --infobox "Saving client configuration..." 8 50
    sleep 3
    {
        echo "[Interface]"
        echo "PrivateKey = ${client_priv_key}"
        echo "Address = 10.0.0.${new_ip}/24"
        echo "DNS = 1.1.1.1, 8.8.8.8"
        echo ""
        echo "[Peer]"
        echo "PublicKey = $(cat "${conf_dir}/public.key")"
        echo "Endpoint = ${server}:${wport}"
        echo "AllowedIPs = 0.0.0.0/0"
        echo "PersistentKeepalive = 25"
    } > "${client_dir}/${peer_name}.conf"
    
    cp wajrzard_client_setup.sh ${client_dir}/${peer_name}_setup.sh
    chmod 600 "${client_dir}/${peer_name}.conf"
    
    dialog --title "Add Peer" \
            --msgbox "Peer ${peer_name} added successfully\n\n
                    Configuration saved to: ${client_dir}/${peer_name}.conf" 12 50

    rm -f /tmp/peern.tmp /tmp/portn.tmp /tmp/addr.tmp
    wg-quick down wg0 2>/dev/null || true
}

# Main script starts here
check_root

# Process command line arguments if any
if [ "${1:-}" = "add" ]; then
    add_peer
    exit 0
fi

# Initial setup
check_dep
install_wireguard

temp_file=$(mktemp)

dialog --title "Setup Wajrgard" \
        --inputbox "Enter port number:" 8 50 2> $temp_file
echo "$(cat $temp_file)" >> /tmp/portn.tmp
wport=$(cat /tmp/portn.tmp)
validate_port "$wport"

# Generate server keys
generate_keys "/etc/wireguard"

# Detect active interface
active_interface=$(ip -o link show up | awk -F': ' '{print $2}' | grep -v '^lo$' | head -1)
if [ -z "$active_interface" ]; then
    dialog --title "Error" \
           --msgbox "No active network interface found" 8 50
    exit 1
fi

dialog --msgbox "Using network interface: ${active_interface}" 8 50
sleep 3

# Create server configuration
dialog --infobox "Creating WireGuard server configuration..." 8 50
sleep 3
{
    echo "[Interface]"
    echo "PrivateKey = $(cat /etc/wireguard/private.key)"
    echo "Address = 10.0.0.1/24"
    echo "ListenPort = ${wport}"
    echo ""
    echo "# NAT Configuration"
    echo "PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${active_interface} -j MASQUERADE; iptables -A FORWARD -o wg0 -j ACCEPT"
    echo "PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${active_interface} -j MASQUERADE; iptables -D FORWARD -o wg0 -j ACCEPT"
} > /etc/wireguard/wg0.conf

# Cleanup temp files
rm -f /tmp/portn.tmp

# Set permissions for the client configurations
chmod 600 /etc/wireguard/wg0.conf

# IP forwarding
dialog --infobox "Enabling IP forwarding..." 8 50
sleep 2
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

# Create and start the WireGuard interface
dialog --infobox "Starting WireGuard interface..." 8 50
sleep 2
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

dialog --title "Setup Wajrgard" \
       --msgbox "WireGuard setup completed successfully\n\n
                Server public key: $(cat /etc/wireguard/public.key)\n\n
                Configuration file: /etc/wireguard/wg0.conf" 12 50
