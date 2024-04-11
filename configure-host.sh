#!/bin/bash

# Verbose flag
verbose=0

# Log messages
log_and_echo() {
    local message=$1
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    logger "$timestamp $message"  # Logging to syslog
    if [ "$verbose" -eq 1 ]; then
        echo "$timestamp $message"
    fi
}

# script run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Changing the hostname
change_hostname() {
    local desired_name=$1
    local current_hostname=$(hostname)

    if [ "$desired_name" != "$current_hostname" ]; then
        echo "$desired_name" > /etc/hostname
        hostname "$desired_name"
        sed -i "s/127.0.1.1\s.*/127.0.1.1\t$desired_name/g" /etc/hosts
        log_and_echo "Hostname changed to $desired_name"
    else
        log_and_echo "Hostname already set to $desired_name"
    fi
}

# Updating IP address
change_ip_address() {
    local desired_ip=$1
    local interface=$(ip route get 1 | awk '{print $5; exit}')
    ip addr add $desired_ip/24 dev $interface
    ip route add default via $(echo $desired_ip | sed -r 's/\.[0-9]+$/.1/')
    if [ $? -eq 0 ]; then
        log_and_echo "IP address changed to $desired_ip on interface $interface"
    else
        echo "Failed to change IP address to $desired_ip on interface $interface"
        exit 1
    fi
}

# host entry
add_host_entry() {
    local name=$1
    local ip=$2
    if ! grep -q "$name" /etc/hosts; then
        echo "$ip $name" >> /etc/hosts
        log_and_echo "Added $name with IP $ip to /etc/hosts"
    else
        log_and_echo "$name entry already exists in /etc/hosts"
    fi
}

# Command-line arguments
while getopts ":v:name:ip:hostentry:" opt; do
    case $opt in
        v)
            verbose=1
            ;;
        name)
            desired_name=$OPTARG
            ;;
        ip)
            desired_ip=$OPTARG
            ;;
        hostentry)
            IFS=' ' read -ra ADDR <<< "$OPTARG"
            host_name=${ADDR[0]}
            host_ip=${ADDR[1]}
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# configuration changes
[ ! -z "$desired_name" ] && change_hostname "$desired_name"
[ ! -z "$desired_ip" ] && change_ip_address "$desired_ip"
[ ! -z "$host_name" ] && add_host_entry "$host_name" "$host_ip"
