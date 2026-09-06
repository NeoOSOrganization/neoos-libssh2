#!/bin/bash
set -e

MUSL_DIR="${MUSL_DIR:-../neoos-musl/build-output}"
OPENSSL_DIR="${OPENSSL_DIR:-../neoos-openssl/build-output}"
PREFIX="${PREFIX:-build-output}"
UPSTREAM_DIR="${UPSTREAM_DIR:-upstream}"
BUILD_TMP="${BUILD_TMP:-build-tmp}"

if [ ! -d "$MUSL_DIR/include" ]; then
    echo "Error: musl not found at $MUSL_DIR (build neoos-musl first)" >&2
    exit 1
fi
if [ ! -f "$OPENSSL_DIR/lib/libcrypto.a" ]; then
    echo "Error: OpenSSL not found at $OPENSSL_DIR (build neoos-openssl first)" >&2
    exit 1
fi
if [ ! -f "$UPSTREAM_DIR/CMakeLists.txt" ]; then
    echo "Error: upstream libssh2 checkout not found at $UPSTREAM_DIR" >&2
    exit 1
fi

ABS_PREFIX="$(mkdir -p "$PREFIX" && cd "$PREFIX" && pwd)"
ABS_MUSL_DIR="$(cd "$MUSL_DIR" && pwd)"
ABS_OPENSSL_DIR="$(cd "$OPENSSL_DIR" && pwd)"

echo "Building libssh2 for NeoOS..."
rm -rf "$BUILD_TMP"

# CMAKE_FIND_ROOT_PATH restricts find_library/find_path (see
# toolchain.cmake's MODE ONLY settings) to exactly these two prefixes
# -- this, not just OPENSSL_ROOT_DIR alone, is what guarantees a
# host-installed OpenSSL (very likely present on any real dev machine)
# is never found instead of the cross-built one.
cmake -S "$UPSTREAM_DIR" -B "$BUILD_TMP" \
    -DCMAKE_TOOLCHAIN_FILE="$(pwd)/toolchain.cmake" \
    -DCMAKE_FIND_ROOT_PATH="$ABS_OPENSSL_DIR;$ABS_MUSL_DIR" \
    -DCMAKE_INSTALL_PREFIX="$ABS_PREFIX" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DCRYPTO_BACKEND=OpenSSL \
    -DOPENSSL_ROOT_DIR="$ABS_OPENSSL_DIR" \
    -DOPENSSL_INCLUDE_DIR="$ABS_OPENSSL_DIR/include" \
    -DCMAKE_C_FLAGS="-isystem $ABS_MUSL_DIR/include"

cmake --build "$BUILD_TMP" -j"$(nproc)"
cmake --install "$BUILD_TMP"

if [ -f "$PREFIX/lib/libssh2.a" ]; then
    echo ""
    echo "OK libssh2 built successfully at $PREFIX"
    ls -lh "$PREFIX/lib/libssh2.a"
else
    echo "ERROR: build finished but libssh2.a not found" >&2
    exit 1
fi
