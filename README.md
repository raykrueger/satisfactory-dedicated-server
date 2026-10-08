# Satisfactory Dedicated Server Container for Docker

Run [Satisfactory](https://www.satisfactorygame.com/) on your own machine so
you, your friends, and your family can play together.

This container runs the Satisfactory dedicated server and nothing else. The
game is pre-installed, and all other concerns — backups, persistence,
monitoring — are expected to be handled outside the container with mounted
volumes.

## Ports

The image exposes **7777** (UDP and TCP). The examples below map
`7777/udp`, which is what the game listens on.

## Quick start

Temporary test run (the server starts immediately and runs until you Ctrl-C):

```bash
docker run --rm -it -p 7777:7777/udp raykrueger/satisfactory-dedicated-server
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
  -p 7777:7777/udp \
  raykrueger/satisfactory-dedicated-server
```

The server keeps 3 rotating autosaves in that directory.

## Configuration

All options are environment variables:

| Variable             | Default | Description                                                    |
| -------------------- | ------- | -------------------------------------------------------------- |
| `SERVERGAMEPORT`     | `7777`  | UDP port the game listens on                                   |
| `NUMPLAYERS`         | `4`     | Maximum players (rendered into `Game.ini`)                     |
| `CONNECTION_TIMEOUT` | `30`    | Connection timeout in seconds (rendered into `Engine.ini`)     |
| `STEAMUPDATE`        | _(empty)_ | Set to `true` to run `steamcmd` and update the game at boot |
| `STEAMARGS`          | _(empty)_ | Extra steamcmd args, e.g. `-beta experimental` (only used when `STEAMUPDATE=true`) |
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
