.PHONY: build run

build:
	docker build -t raykrueger/satisfactory .

run: build
	docker run --rm -it -p 7777:7777/udp -p 15777:15777/udp -p 15000:15000/udp raykrueger/satisfactory

run-experimental: build
	docker run --rm -it -e STEAMARGS="-beta experimental" -p 7777:7777/udp -p 15777:15777/udp -p 15000:15000/udp raykrueger/satisfactory

shell: build
	docker run --rm -it --entrypoint /bin/bash raykrueger/satisfactory
