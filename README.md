# WGDeploy

WGDeploy is a bash script designed to automate the process of deploying and managing a WireGuard VPN server and client setup. This tool requires superuser permissions (sudo) and must be made executable before running.

## Features

- Automated WireGuard VPN server and client configuration.
- Automatic IP forwarding and iptables rules for seamless VPN traffic.
- Supports both IPv4 and IPv6.
- Simple installation process and configuration with minimal user input.

## Requirements

- A Linux-based system with WireGuard installed.
- Root privileges to modify system networking settings.
- wireguard & curl installed (for external IP detection).

## Installation

1. Clone the Repository
   ```bash
   git clone https://github.com/N91489/WGDeploy.git
   ```

2. Navigate to the Directory
   ```bash
   cd WGDeploy
   ```
   
3. Make the script executable
   ```bash
   chmod +x wgdeploy.sh
   ```

4. Run the script
   The script needs to be run with sudo for administrative permissions:
   ```bash
   sudo ./wgdeploy.sh
   ```
   ### Usage

   1. Server Setup
      To set up the WireGuard server, use the following syntax:
      ```bash
      sudo ./wgdeploy.sh setup <server_ip> <listen_port> <mtu>
      ```
      
   This will start the process of deploying the WireGuard server, setting up IP forwarding, and configuring iptables rules.
