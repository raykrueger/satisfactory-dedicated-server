# Satisfactory Dedicated Server Container for Docker

Run [Satisfactory](https://www.satisfactorygame.com/) on your own machine so
you, your friends, and your family can play together.

This container runs the Satisfactory dedicated server and nothing else. The
game is pre-installed, and all other concerns — backups, persistence,
monitoring — are expected to be handled outside the container with mounted
volumes.

## Ports

The server needs three inbound bindings, and the image exposes all of them:

| Port | Protocol | Usage |
| ---- | -------- | ----- |
| `7777` | UDP | Game traffic, Lightweight Query API |
| `7777` | TCP | Server traffic, HTTPS API |
| `8888` | TCP | Reliable messaging (required as of patch 1.1.0.0) |

The examples below map all three; without `8888/tcp` players can connect but
get stuck on the loading screen. If you change `SERVERGAMEPORT`, only the
`7777` pair moves — the reliable port stays `8888`.

## Quick start

Temporary test run (the server starts immediately and runs until you Ctrl-C):

```bash
docker run --rm -it -p 7777:7777/udp -p 7777:7777/tcp -p 8888:8888/tcp \
  raykrueger/satisfactory-dedicated-server
```

Running with docker-compose:

```bash
# grab the docker-compose.yaml from this repo, then:
docker compose up -d
```

### Persistence

Saves live at `/home/steam/.config/Epic/FactoryGame/Saved/SaveGames` inside
the container. Mount a volume (or bind mount) there and nothing is ever lost
when the container is recreated:

```bash
docker run -d \
  -v satisfactory-saves:/home/steam/.config/Epic/FactoryGame/Saved/SaveGames \
  -p 7777:7777/udp -p 7777:7777/tcp -p 8888:8888/tcp \
  raykrueger/satisfactory-dedicated-server
```

The server keeps 3 rotating autosaves in that directory.

## Configuration

All options are environment variables:

| Variable             | Default | Description                                                    |
| -------------------- | ------- | -------------------------------------------------------------- |
| `SERVERGAMEPORT`     | `7777`  | Port the game listens on (UDP and TCP; the reliable port is always `8888/tcp`) |
| `NUMPLAYERS`         | `4`     | Maximum players (rendered into `Game.ini`)                     |
| `CONNECTION_TIMEOUT` | `30`    | Connection timeout in seconds (rendered into `Engine.ini`)     |
| `STEAMUPDATE`        | _(empty)_ | Set to `true` to run `steamcmd` and update the game at boot |
| `STEAMARGS`          | _(empty)_ | Extra steamcmd args, e.g. `-beta <branch>` (only used when `STEAMUPDATE=true`) |
| `USERNAME` / `USERID` | `steam` / `1010` | User the server process runs as |

At boot, [gomplate](https://docs.gomplate.ca/) renders the template files in
[`config/`](config) into the server's config directory, so `NUMPLAYERS` and
`CONNECTION_TIMEOUT` take effect without touching game files.

### Updating the game

By default the container starts the game exactly as baked into the image (the
`latest` tag is rebuilt nightly). Set `STEAMUPDATE=true` to force a
`steamcmd` update at boot, or simply pull the new image.

## Good to know

- The server runs as the non-root `steam` user, not root.
- The game is pre-release; Epic ships the dedicated server with in-game
  warnings about its state. Late-game factories are heavy — plan on 8 GB+ of
  RAM for a busy save.
- If your server is ever behind the client version, restart it (or bump the
  image).

## Running with systemd

The [systemd/](systemd) directory has units that run the container under
systemd, with optional timers that start it in the morning and stop it at
night:

- `satisfactory.service` runs the container in the foreground (`--rm`,
  `--pull always`, all three ports, saves at `/var/lib/satisfactory/data`),
  stops it with SIGINT so the server saves and exits cleanly, and restarts
  it if it crashes.
- `satisfactory-start.timer` / `satisfactory-stop.timer` start it at 06:00
  and stop it at midnight (host local time) via
  `satisfactory-stop.service`.

Adjust the save path, ports, and schedule in the units to taste, then:

```bash
sudo mkdir -p /var/lib/satisfactory/data
sudo cp systemd/* /etc/systemd/system/
sudo systemctl daemon-reload
```

Run on demand:

```bash
sudo systemctl start satisfactory
sudo systemctl stop satisfactory
```

Turn the daily schedule on / off:

```bash
sudo systemctl enable --now satisfactory-start.timer satisfactory-stop.timer
sudo systemctl disable --now satisfactory-start.timer satisfactory-stop.timer
```

Logs: `journalctl -u satisfactory`.


## Development

A [Makefile](Makefile) is included for testing and tinkering:

```bash
make run    # build and run the container
make shell  # build and drop into a bash shell in the container
```

The container uses [gomplate](https://docs.gomplate.ca/) for config variable
replacement and [gosu](https://github.com/tianon/gosu) to drop privileges to
the `steam` user at runtime.

## License

[Apache License 2.0](LICENSE)
