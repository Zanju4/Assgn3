#!/bin/bash

# verbose flag
verbose=0

# log messages
log_and_echo() {
    local message=$1
    logger "$message"
    if [ "$verbose" -eq 1 ]; then
        echo "$message"
    fi
}

# change the hostname
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

# Function to update IP address
change_ip_address() {
    local desired_ip=$1
    # This is a placeholder for the actual commands you would use to change the IP address
    log_and_echo "IP address change to $desired_ip simulated."
}

# Function to add a host entry
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

# command-line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -verbose)
            verbose=1
            ;;
        -name)
            desired_name="$2"
            shift
            ;;
        -ip)
            desired_ip="$2"
            shift
            ;;
        -hostentry)
            host_name="$2"
            host_ip="$3"
            shift 2
            ;;
    esac
    shift
done

# Execute configuration changes based on arguments
[ ! -z "$desired_name" ] && change_hostname "$desired_name"
[ ! -z "$desired_ip" ] && change_ip_address "$desired_ip"
[ ! -z "$host_name" ] && add_host_entry "$host_name" "$host_ip"

