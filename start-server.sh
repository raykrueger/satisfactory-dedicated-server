#!/usr/bin/env bash

# Make sure we own the potential mount points
chown -R $USERID:$USERID /home/$USERNAME/.config/Epic

gomplate --input-dir /tmp/config --output-dir /game/FactoryGame/Saved/Config/LinuxServer/
chown -R ${USERID}:${USERID} /game/FactoryGame/Saved

if [ -n "$STEAMUPDATE" ] ; then
	echo "Updating game server"
	gosu $USERID:$USERID steamcmd +force_install_dir /game +login anonymous +app_update 1690800 $STEAMARGS +quit
else
	echo "Skipping game server update, set 'STEAMUPDATE=true' to enable"
fi

SERVERARGS="FactoryGame -NoSteamClient -unattended -log -Port=$SERVERGAMEPORT"

echo Starting server with SERVERARGS=$SERVERARGS

gosu $USERID:$USERID "/game/Engine/Binaries/Linux/FactoryServer-Linux-Shipping" $SERVERARGS
