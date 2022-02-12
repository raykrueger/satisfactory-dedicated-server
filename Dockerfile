FROM steamcmd/steamcmd

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L --silent -o /usr/local/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v3.10.0/gomplate_linux-amd64 \
    && chmod +x /usr/local/bin/gomplate \
    && curl -L --silent -o /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64 \
    && chmod +x /usr/local/bin/gosu

ENV USERNAME=steam \
    USERID=1000 \
    SERVERBEACONPORT=15000 \
    SERVERGAMEPORT=7777 \
    SERVERQUERYPORT=15777 \
    NUMPLAYERS=4 \
    CONNECTION_TIMEOUT=30

RUN useradd -u ${USERID} -m ${USERNAME}

RUN mkdir /game && chown ${USERID}:${USERID} /game

WORKDIR /game

RUN gosu ${USERID}:${USERID} steamcmd +force_install_dir /game +login anonymous +app_update 1690800 +quit

RUN mkdir -p /home/${USERNAME}/.config/Epic/FactoryGame/Saved/SaveGames \
    && chown -R ${USERID}:${USERID} /home/${USERNAME}/.config

COPY config/ /tmp/config/

COPY --chown=${USERID}:${USERID} start-server.sh /game/

RUN chmod +x /game/start-server.sh /game/Engine/Binaries/Linux/UE4Server-Linux-Shipping

ENTRYPOINT ["./start-server.sh", "FactoryGame", "-NoSteamClient", "-unattended", "-log", "-Port=$SERVERGAMEPORT", "-BeaconPort=$SERVERBEACONPORT", "-ServerQueryPort=$SERVERQUERYPORT"]

EXPOSE 7777/udp 15000/udp 15777/udp