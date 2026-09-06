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
set(CMAKE_C_FLAGS_INIT "-static -nostdlib -mcmodel=large -fno-pic -mno-red-zone -fno-stack-protector -O2")

# CMake cross-compiling: find_program searches the HOST (we want the
# host's own cmake/make, not a target one -- there is no target one),
# but find_library/find_path must search ONLY the target root
# (CMAKE_FIND_ROOT_PATH, passed on the command line by build.sh) so a
# host-installed OpenSSL/libssl-dev is never picked up by mistake.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
