.PHONY: build run

build:
	docker build -t raykrueger/satisfactory .

run: build
	docker run --rm -it raykrueger/satisfactory

shell: build
	docker run --rm -it --entrypoint /bin/bash raykrueger/satisfactory
