# Satisfactory Dedicated Server Container for Docker

Works with 1.0!

This is a container that runs the excellent
[Satisfactory](https://www.satisfactorygame.com/) dedicated server so you can
easily host it and play with friends and family. This container is designed to
run the game server, and that is it. All other aspects of backups and
persistence are expected to be performed outside if the container using mounted
volumes.

The game is pre-installed in the container, but will always update to the latest version at launch. If your server is ever behind the client, just restart the container.

I do not make any symlinks for where the saved games go. This way I don't have
to maintain that location, I'm lazy. Saves are stored at
`/home/steam/.config/Epic/FactoryGame/Saved/SaveGames`, inside the container.

The Satisfactory dedicated server requires the following ports open for inbound
traffic, 7777, 15777, 15000 all UDP. The examples below map those exposed ports
as required.

Please note that the game itself is pre-release, the dedidcate server comes with
*many* in game warnings about it being buggy. It is also kind of a beast, in the
late game you'll easily need over 8gb of ram.

Finally, this game runs as the *steam* user internally, rather than root. If you
look at the Dockerfile and start-serer.sh and wonder "Why is this guy using
chown so much?", that's why.

## Run it

Run once just temporarily to test...
```
docker run --rm -it -p 7777:7777/udp -p 15777:15777/udp -p 15000:15000/udp raykrueger/satisfactory-dedicated-server
```

Run with experimental...
```
docker run --rm -it -e STEAMARGS='-beta experimental' -p 7777:7777/udp -p 15777:15777/udp -p 15000:15000/udp raykrueger/satisfactory-dedicated-server
```

Run locally with persistence...
```
docker run -d -n satisfactory -v /home/steam/.config/Epic/FactoryGame/Saved/SaveGames -p 7777:7777/udp -p 15777:15777/udp -p 15000:15000/udp raykrueger/satisfactory-dedicated-server
```

To run with docker-compose grab the [docker-compose.yaml](docker-compose.yaml) file.
```
docker-compose start #that's it
```

## Development

There is a Make file for convience, you can use `make run` and `make shell` to
test and tinker with how the container is built. The container itself uses
[gomplate](https://docs.gomplate.ca/) and [gosu](https://github.com/tianon/gosu)
interally for variable replacement and running in user context; respectively.

This image was built with version v05.2.1, it will update on boot.
