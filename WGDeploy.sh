#!/bin/bash

# Function to setup WireGuard server
wg0_setup()
{
    # Check if the correct number of arguments are provided
    if [[ -z "$2" || -z "$3" || -z "$4" ]]; then
        echo "Usage: $0 setup <Server_IP_Address> <Listen_Port> <MTU>"
        exit 1
    fi

    # Setup Directories
    mkdir -pv /etc/wireguard/clients
    mkdir -pv /etc/wireguard/keys

    # Generate wg0_private.key & mask it
    (umask 077 && wg genkey > /etc/wireguard/keys/wg0_private.key)

    # Generate wg0_public.key
    wg pubkey < /etc/wireguard/keys/wg0_private.key > /etc/wireguard/keys/wg0_public.key

    # Get network interface name
    networkinterfacename=$(ip route | grep default | awk '{print $5}')

    # Create WireGuard config
    cat <<EOF > /etc/wireguard/wg0.conf

    [Interface]
    SaveConfig = false
    PrivateKey = $(cat /etc/wireguard/keys/wg0_private.key)
    Address = $2/32
    ListenPort = $3
    MTU = $4
    PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $networkinterfacename -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $networkinterfacename -j MASQUERADE
    PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $networkinterfacename -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $networkinterfacename -j MASQUERADE

EOF

    echo "wg0 config file created"

    # Enable IP forwarding
    cat <<EOF >> /etc/sysctl.conf

     net.ipv4.ip_forward=1
     net.ipv6.conf.all.forwarding=1

EOF
    echo "IP forwarding enabled"

    echo "wg0 setup complete"
}

# Function to setup WireGuard client
client_setup()
{
    # Check if the correct number of arguments are provided
    if [[ -z "$2" || -z "$3" ]]; then
        echo "Usage: $0 client <Client_Name> <DNS>"
        exit 1
    fi

    client=$2
    dns=$3

    # Check if AllowedIPs exists
    if grep -q "AllowedIPs" /etc/wireguard/wg0.conf; then
        Address=$(grep "AllowedIPs" /etc/wireguard/wg0.conf | tail -n 1 | awk '{print $3}')
    else
        Address=$(grep "Address" /etc/wireguard/wg0.conf | awk '{print $3}')
    fi

    
    IP=$(echo $Address | sed 's/\/.*//')
    clientIP=$(echo $IP | awk -F. '{print $1"."$2"."$3"."$4+1}')


    # Generate client_private.key & mask it
    (umask 077 && wg genkey > /etc/wireguard/keys/${client}_private.key)

    # Generate client_public.key
    wg pubkey < /etc/wireguard/keys/${client}_private.key > /etc/wireguard/keys/${client}_public.key

    # Create client config
    cat <<EOF > /etc/wireguard/clients/${client}.conf

    # $client device config
    [Interface]
    PrivateKey = $(cat /etc/wireguard/keys/${client}_private.key)
    ListenPort = $(grep ListenPort /etc/wireguard/wg0.conf | awk '{print $3}')
    MTU = $(grep MTU /etc/wireguard/wg0.conf | awk '{print $3}')
    Address = $clientIP/32
    DNS = $dns

    # Server device config
    [Peer]
    PublicKey = $(cat /etc/wireguard/keys/wg0_public.key)
    AllowedIPs = 0.0.0.0/0
    
EOF

    # Add client as a peer in the server config
    cat <<EOF >> /etc/wireguard/wg0.conf
    # $client
    [Peer]
    PublicKey = $(cat /etc/wireguard/keys/${client}_public.key)
    AllowedIPs = $clientIP/32

EOF
    echo "Client setup complete for ${client}"
}

# Check WireGuard installation
check_wireguard()
{
    if ! command -v wg &> /dev/null; then
        echo "WireGuard is not installed. Please install WireGuard first."
        exit 1
    fi
}

# Main script logic
if [[ $1 == "setup" ]]; then
    check_wireguard
    wg0_setup "$@"
elif [[ $1 == "client" ]]; then
    check_wireguard
    client_setup "$@"
else
    echo "Usage: $0 <setup> | <client> "
    echo "Commands:"
    echo "  setup <Server_IP_Address> <Listen_Port> <MTU> - Set up the WireGuard server"
    echo "  client <Client_Name> <DNS> - Add a new WireGuard client"
    exit 1
fi
