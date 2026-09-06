# NeoOS libssh2 build

MUSL_DIR ?= ../neoos-musl/build-output
OPENSSL_DIR ?= ../neoos-openssl/build-output
PREFIX ?= build-output
UPSTREAM_DIR ?= upstream

.PHONY: all clean verify help submodule-init

all: build-output/lib/libssh2.a

submodule-init:
	@if [ ! -f "$(UPSTREAM_DIR)/CMakeLists.txt" ]; then \
		echo "Initializing upstream submodule..."; \
		git submodule update --init upstream; \
	fi

build-output/lib/libssh2.a: submodule-init
	@[ -d "$(MUSL_DIR)/include" ] || { \
		echo "Error: musl not found at $(MUSL_DIR) -- build neoos-musl first"; \
		exit 1; \
	}
	@[ -f "$(OPENSSL_DIR)/lib/libcrypto.a" ] || { \
		echo "Error: OpenSSL not found at $(OPENSSL_DIR) -- build neoos-openssl first"; \
		exit 1; \
	}
	@MUSL_DIR="$(MUSL_DIR)" OPENSSL_DIR="$(OPENSSL_DIR)" PREFIX="$(PREFIX)" ./build.sh

clean:
	rm -rf $(PREFIX) build-tmp

verify:
	@if [ -f "$(PREFIX)/lib/libssh2.a" ]; then \
		echo "OK libssh2.a built"; \
	else \
		echo "ERROR libssh2.a not found"; \
		exit 1; \
	fi

help:
	@echo "NeoOS libssh2 build"
	@echo "Usage: make [MUSL_DIR=path] [OPENSSL_DIR=path]"
