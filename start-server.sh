#!/usr/bin/env bash

# Make sure we own the potential mount points
chown -R $USERID:$USERID /home/steam/.config/Epic

gomplate --input-dir /tmp/config --output-dir /game/FactoryGame/Saved/Config/LinuxServer/
chown -R ${USERID}:${USERID} /game/FactoryGame/Saved

echo "Updating game server"
gosu $USERID:$USERID steamcmd +force_install_dir /game +login anonymous +app_update 1690800 $STEAMARGS +quit

SERVERARGS="FactoryGame -NoSteamClient -unattended -log -Port=$SERVERGAMEPORT -BeaconPort=$SERVERBEACONPORT -ServerQueryPort=$SERVERQUERYPORT"

echo Starting server with SERVERARGS=$SERVERARGS

# update 8 with Unreal 5 changed the server binary
if [ -f /game/Engine/Binaries/Linux/UnrealServer-Linux-Shipping ]; then
	gosu $USERID:$USERID "/game/Engine/Binaries/Linux/UnrealServer-Linux-Shipping" $SERVERARGS
else
	gosu $USERID:$USERID "/game/Engine/Binaries/Linux/UE4Server-Linux-Shipping" $SERVERARGS
fi