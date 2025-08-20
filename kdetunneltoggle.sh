#!/bin/bash
# apptunneltoggle.sh
# Toggles an application between VPN and split-tunnel mode (excluded from VPN)

# Prompt for the application name
app=$(kdialog --inputbox "Enter the name of the application to toggle:")

# Check if user entered anything
if [ -z "$app" ]; then
    kdialog --error "No application entered. Exiting."
    exit 1
fi
# Get all PIDs for the app
app_pids=$(pgrep -x "$app")

if [ -z "$app_pids" ]; then
    kdialog --error "Application '$app' is not running."
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
    kdialog --passivepopup "'$app' is now routed through VPN" 5
    for pid in $app_pids; do
        mullvad split-tunnel delete "$pid"
    done
else
    kdialog --passivepopup "'$app' is now excluded from VPN" 5
    for pid in $app_pids; do
        mullvad split-tunnel add "$pid"
    done
fi

