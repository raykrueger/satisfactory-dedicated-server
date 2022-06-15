.PHONY: build run

build:
	docker build -t raykrueger/satisfactory .

build-experimental:
	docker build --build-arg STEAMARGS="-beta experimental" -t raykrueger/satisfactory:experimental .

run: build
	docker run --rm -it -p 7777:7777/udp -p 15777:15777/udp -p 15000:15000/udp raykrueger/satisfactory

run-experimental: build-experimental
	docker run --rm -it -p 7777:7777/udp -p 15777:15777/udp -p 15000:15000/udp raykrueger/satisfactory:experimental

shell: build
	docker run --rm -it --entrypoint /bin/bash raykrueger/satisfactory
