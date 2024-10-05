# WGDeploy

WGDeploy is a bash script designed to automate the process of deploying and managing a WireGuard VPN server and client setup. This tool requires superuser permissions (sudo) and must be made executable before running.

## Features

- Automated WireGuard VPN server and client configuration.
- Automatic IP forwarding and iptables rules for seamless VPN traffic.
- Supports both IPv4 and IPv6.
- Simple installation process and configuration with minimal user input.

## Requirements

- A Linux-based system with wireguard & curl installed.
- Root privileges to modify system networking settings.
- Static External IP

## Pre-Installation

1. **Setting up Static External IP**:In most cloud environments, it’s recommended to use a static external IP for      your server so the VPN clients can always connect to the same address.
  
   - GCP: Reserve a static external IP for your instance under VPC network >                External IP addresses.
     
   - AWS: Associate an Elastic IP with your EC2 instance.
        
   - Azure: Assign a Static Public IP Address to your VM under Networking > IP          Configurations.
   

2. **Opening Port for Listening**:
   make sure to open the port for UDP traffic on your machine or                      cloud provider. For cloud environments, update the firewall or                     security group settings to allow UDP traffic on the chosen port

   - **GCP**: Set a firewall rule allowing UDP traffic on port that                              wireguard will use in your VM.
   - **AWS**: Modify the security group to allow incoming UDP traffic on                         port that wireguard will use (default: 51820).
   - **Azure**: Create an inbound security rule allowing UDP traffic on                            the chosen port for your VM

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
      sudo ./wgdeploy.sh setup <Server_IP> <Listen_Port> <MTU>
      ```
      - <Server_IP>: This is the internal IP address that the WireGuard server             will use. You should choose an IP address based on your network setup.
        
	      - Common internal IP address ranges:
            - 10.0.0.0        -   10.255.255.255  (10/8 prefix)
            - 172.16.0.0      -   172.31.255.255  (172.16/12 prefix)
            - 192.168.0.0     -   192.168.255.255 (192.168/16 prefix)

      **Note**: Ensure the IP address you choose does not conflict with existing          devices on your network.

      - <Listen_Port>: This is the port on which your WireGuard server will listen       for incoming connections.

        - Common Ports:
           - Default Wireguard port: 51820
           - Other common VPN ports: 1194 (OpenVPN), 500 (IPsec)
         
        **Recommendation**: Stick with the default port 51820 unless you have a             reason to use another port

   - <MTU>: The MTU (Maximum Transmission Unit) defines the largest size of a                  packet that can be sent over the network without fragmentation.

     **Note**: If you experience connectivity issues or packet loss, adjust the                   MTU.
  
   This will start the process of deploying the WireGuard server, setting up IP       forwarding, and configuring iptables rules.
     
   2. Client Configuration
  
      To generate a configuration for a client, use the following syntax:
      ```bash
      sudo ./wgdeploy.sh client <Client_Name> <D.N.S> <MTU>
      ```

     - <Client_Name>: This is the name of the client you are setting up, which can                       be anything meaningful (e.g., Phone1 or Laptop2 ).
       
	  - <D.N.S>: The DNS server the client will use. Common DNS providers:
		            - 1.1.1.1 (Cloudflare DNS)
		            - 8.8.8.8 (Google DNS)
     
     - <MTU>: The MTU (Maximum Transmission Unit) defines the largest size of a                  packet that can be sent over the network without fragmentation.

       **Note**: If you experience connectivity issues or packet loss, adjust the                   MTU.

   This will generate the client configuration and store it in the clients/           directory.
