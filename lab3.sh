#!/bin/bash

# Script directory

SCRIPT_DIR="$HOME/assgn3/lab"

# Check for verbose mode

if [[ "$1" == "-verbose" ]]; then
    verbose_option="--verbose"
else
    verbose_option=""
fi

# Executing  commands

safe_run() {
    if ! $@; then
        echo "Command failed with status $? on command: $@"
        exit 1
    fi
}

# server addresses

SERVER1="server1-mgmt"
SERVER2="server2-mgmt"

# execution of  the script

safe_run scp "$SCRIPT_DIR/configure-host.sh" "remoteadmin@$SERVER1:/root"
safe_run ssh "remoteadmin@$SERVER1" -- "/root/configure-host.sh $verbose_option -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4"

safe_run scp "$SCRIPT_DIR/configure-host.sh" "remoteadmin@$SERVER2:/root"
safe_run ssh "remoteadmin@$SERVER2" -- "/root/configure-host.sh $verbose_option -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3"

# Updates for host entries

"$SCRIPT_DIR/configure-host.sh" $verbose_option -hostentry loghost 192.168.16.3
"$SCRIPT_DIR/configure-host.sh" $verbose_option -hostentry webhost 192.168.16.4

echo "Configuration complete: loghost and webhost configured."
