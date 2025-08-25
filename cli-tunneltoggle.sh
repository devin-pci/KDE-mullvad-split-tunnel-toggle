#!/bin/bash
# Toggles an application between VPN and split-tunnel mode (excluded from VPN)

# Prompt for the application name
echo -e "Enter the name of the application to toggle\n"
read app

# Check if user entered anything
if [ -z "$app" ]; then
    echo "Error. No application entered. Exiting"
    exit 1
fi
# Get all PIDs for the app
app_pids=$(pgrep -x "$app")

if [ -z "$app_pids" ]; then
    echo "Error. Application $app is not running."
    exit 1
fi

# Check if any of the app's PIDs are in the split-tunnel list
in_split_tunnel=false
for pid in $app_pids; do
    if mullvad split-tunnel list | grep -q "$pid"; then
        in_split_tunnel=true
        break
    fi
done

# Toggle split-tunnel
if [ "$in_split_tunnel" = true ]; then
    for pid in $app_pids; do
        mullvad split-tunnel delete "$pid"
    done
echo "$app is now routed through VPN"
else
    for pid in $app_pids; do
        mullvad split-tunnel add "$pid"
    done
echo "$app is now excluded from VPN"
fi

