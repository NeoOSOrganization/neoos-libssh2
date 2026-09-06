# NeoOS cross-compile toolchain for CMake-based ports.
#
# CMAKE_SYSTEM_NAME Generic is CMake's own spelling of "freestanding,
# cross-compiling, do not assume a hosted OS" -- the same freestanding
# posture every other userland build in this org already takes with
# -ffreestanding/-nostdlib.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER x86_64-elf-gcc)
set(CMAKE_AR x86_64-elf-ar)
set(CMAKE_RANLIB x86_64-elf-ranlib)
# NOT set here as CMAKE_C_FLAGS_INIT: build.sh passes the full
# freestanding flag set (these plus -isystem $MUSL_DIR/include, which
# this static file cannot know the path to) via an explicit
# -DCMAKE_C_FLAGS=..., which as a directly-set cache value always wins
# over an _INIT seed anyway -- a second, different definition here
# would just be silently-overridden dead code.

# CMake cross-compiling: find_program searches the HOST (we want the
# host's own cmake/make, not a target one -- there is no target one),
# but find_library/find_path must search ONLY the target root
# (CMAKE_FIND_ROOT_PATH, passed on the command line by build.sh) so a
# host-installed OpenSSL/libssl-dev is never picked up by mistake.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Every CMake feature-detection macro (check_function_exists,
# check_c_source_compiles, check_symbol_exists, ...) defaults to linking
# a full EXECUTABLE for its probe. Our freestanding build flags
# (-nostdlib etc, passed via CMAKE_C_FLAGS) have no crt1.o/-lc attached
# to those probes, so every such check fails to *link* regardless of
# whether the function it's testing actually exists in musl -- this is
# what made libssh2's CheckNonblockingSocketSupport.cmake report
# HAVE_POLL/HAVE_SELECT/HAVE_O_NONBLOCK/HAVE_FIONBIO/
# HAVE_IOCTLSOCKET_CASE/HAVE_SO_NONBLOCK all undefined even though NeoOS
# supports every one of them, silently turning session_nonblock() into
# a no-op and leaving sockets permanently blocking underneath libssh2's
# nonblocking-mode bookkeeping (root-caused via a channel_read() hang:
# docs/superpowers/plans/2026-09-06-libssh2-port.md Task 3).
# Building a STATIC_LIBRARY instead needs no entry point or libc, so the
# probe tests only what it's meant to: does this header/symbol compile.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
