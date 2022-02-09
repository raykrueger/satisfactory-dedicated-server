#!/usr/bin/env bash

# Make sure we own the potential mount points
chown -R $USERID:$USERID /home/steam/.config/Epic

echo "Updating game server"
gosu $USERID:$USERID steamcmd +force_install_dir /game +login anonymous +app_update 1690800 +quit

gosu $USERID:$USERID "./Engine/Binaries/Linux/UE4Server-Linux-Shipping" "$@"