# Makefile for building and deploying a Elixir app in a Docker container

# App name, repository name, and image name can be configured through
# environment variables, flags, or by extracting defaults from the local .git folder or accessible Docker configs
APP_NAME ?= $(shell git rev-parse --show-toplevel | xargs basename)
REPO_NAME ?= $(APP_NAME)
IMAGE_NAME ?= $(REPO_NAME)
# Nixpacks, releases, and Docker can be used to build the app in a resilient and efficient way
.PHONY: nix-build
nix-build:
	nix-build -A $(APP_NAME)

# A minimal, Alpine-based image can be used and a multi-stage, multi-architecture (AMD64, ARM) build process can be used to ensure image compatibility with different platforms and podman or systemd
.PHONY: build
build:
	docker build --pull --tag $(IMAGE_NAME) .

# The Docker image can be published to a registry, such as Docker Hub, with the ability to specify the repository name, organization name, and image name through environment variables, flags, or extracting defaults from the local .git folder or accessible Docker configs
.PHONY: push
push:
	docker push $(IMAGE_NAME)

# Removes any generated files and build artifacts
.PHONY: clean
clean:
	rm -rf _build

# Runs the app in the container using podman run or docker run command
.PHONY: run
run:
	docker run --rm --interactive --tty $(IMAGE_NAME)

# Opens a shell inside the container using podman exec or docker exec command
.PHONY: shell
shell:
	docker exec --interactive --tty $(IMAGE_NAME) sh

# Inspects the container logs using podman logs or docker logs command
.PHONY: logs
logs:
	docker logs $(IMAGE_NAME)

# Stops the running container using podman stop or docker stop command
.PHONY: stop
stop:
	docker stop $(IMAGE_NAME)

# Removes the container using podman rm or docker rm command
.PHONY: rm
rm:
	docker rm $(IMAGE_NAME)

# Uses ab for localhost benchmark
.PHONY: ab
ab:
	ab -n 10000 -c 100  http://127.0.0.1:4000/api/cache/author

# Check all prerequisites
.PHONY: bootstrap
bootstrap:
	command -v nix-build >/dev/null 2>&1 || echo "nix-build is not installed"
	command -v docker >/dev/null 2>&1 || echo "docker is not installed"
