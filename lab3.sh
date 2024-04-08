#!/bin/bash

# script directory
SCRIPT_DIR="$HOME/assgn3/lab"

# verbose mode
if [[ "$1" == "-verbose" ]]; then
    verbose="-verbose"
else
    verbose=""
fi

# execute commands
safe_run() {
    if ! $@; then
        echo "Command failed: $@"
        exit 1
    fi
}

# transfer and execute the script 
safe_run scp "$SCRIPT_DIR/configure-host.sh" remoteadmin@server1-mgmt:/root
safe_run ssh remoteadmin@server1-mgmt -- /root/configure-host.sh $verbose -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4

safe_run scp "$SCRIPT_DIR/configure-host.sh" remoteadmin@server2-mgmt:/root
safe_run ssh remoteadmin@server2-mgmt -- /root/configure-host.sh $verbose -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3

# updates for host entries
"$SCRIPT_DIR/configure-host.sh" $verbose -hostentry loghost 192.168.16.3
"$SCRIPT_DIR/configure-host.sh" $verbose -hostentry webhost 192.168.16.4
