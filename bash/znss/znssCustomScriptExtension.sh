#!/bin/sh

# Install NSS Certificate sudo nss install-cert NssCertificate.zip
if ! [ -f "NssCertificate.zip" ]; then
    echo "The file NssCertificate.zip was not found."
    echo "Put this script in the same path where NssCertificate.zip is."
    echo "And run it again."
    exit 1
fi

echo "installing certificate"
sudo nss install-cert NssCertificate.zip

# Configure NSS Settings
NEW_NAME_SERVER_IPS=()
NEW_NS="n"
echo "Do you wish to add a new nameserver? <n:no y:yes> , press enter for [n]"
read RESP
until [ -z "$RESP" ] || [ "$RESP"  != "y" ]; do
    echo "Enter the nameserver IP address:"
    read NEW_NAME_SERVER_IP
    until ! [ -z "$NEW_NAME_SERVER_IP" ] && [[ $NEW_NAME_SERVER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
        echo "Please enter a valid nameserver IP address:"
        read NEW_NAME_SERVER_IP
    done
    NEW_NAME_SERVER_IPS+=("$NEW_NAME_SERVER_IP")
    echo "Do you wish to add a new nameserver? <n:no y:yes> , press enter for [n]"
    read RESP
done

# NSS Server Interface IP Configuration
echo "Enter service interface IP address with netmask. (ex. 192.166.100.4/24): "
read MY_IP

# NSS Default Gateway Configuration
DEFAULT_GW=$(netstat -r | grep default | awk '{print $2}')
echo "Enter service interface default gateway IP address, press enter for [${DEFAULT_GW}]: "
read DEFAULT_GW_ENTERED
if ! [ -z "${DEFAULT_GW_ENTERED}" ]; then
    DEFAULT_GW=${DEFAULT_GW_ENTERED}
fi
SERVERS=$(sudo nss dump-config | grep "nameserver:"|  tr  "nameserver:" " " | tr [:space:] " ")
IFS=', ' read -r -a EXISTING_NAME_SERVERS <<< "$SERVERS"
# -----
SKIP_SERVERS=""
for server in "${EXISTING_NAME_SERVERS[@]}"
do
    SKIP_SERVERS+="\n"
done
NEW_SERVERS_COMMAND=""
for new_server in "${NEW_NAME_SERVER_IPS[@]}"
do
    NEW_SERVERS_COMMAND+="y\n${new_server}\n"
done
printf "${SKIP_SERVERS}${NEW_SERVERS_COMMAND}\n${MY_IP}\n${DEFAULT_GW}\n\n" | sudo nss configure

echo "Successfully Applied Changes"

# Download NSS Binaries
sudo nss update-now
echo "Connecting to server..."
echo "Downloading latest version" # Wait until system echo back the next message
echo "Installing build /sc/smcdsc/nss_upgrade.sh" # Wait until system echo back the next message
echo "Finished installation!"

 #Check NSS Version
sudo nss checkversion

# Enable the NSS to start automatically
sudo nss enable-autostart
echo "Auto-start of NSS enabled "

# Start NSS Service
sudo nss start
echo "NSS service running."

# Dump all Important Configuration
sudo netstat -r > nss_dump_config.log
sudo nss dump-config > nss_dump_config.log
sudo nss checkversion >> nss_dump_config.log
sudo nss troubleshoot netstat|grep tcp >> nss_dump_config.log
sudo nss test-firewall >> nss_dump_config.log
sudo nss troubleshoot netstat >> nss_dump_config.log
/sc/bin/smmgr -ys smnet=ifconfig >> nss_dump_config.log

exit 0