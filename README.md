# NeoOS libssh2

libssh2 1.11.1, built for NeoOS as a static library
(`libssh2.a`) using `neoos-openssl` as its crypto backend. The SSH/SFTP
client library the `neoos-curl` port (a later milestone) will link
against for `sftp://` support.

Library only: no interactive `ssh` CLI (a separate, larger problem --
session/channel/pty/terminal-I/O plumbing on top of this library, not
part of this repo) and no SSH server (an unrelated code path, its own
future milestone).

## Quick Start

Build `neoos-musl` and `neoos-openssl` first, then:

```sh
make MUSL_DIR=../neoos-musl/build-output OPENSSL_DIR=../neoos-openssl/build-output
# Produces: build-output/lib/libssh2.a,
#           build-output/include/libssh2.h, libssh2_sftp.h, ...
```

## Documentation

- **Design spec:** [neoos-kernel's
  docs/superpowers/specs/2026-09-06-libssh2-port-design.md](https://github.com/NeoOSOrganization/neoos-kernel/blob/main/docs/superpowers/specs/2026-09-06-libssh2-port-design.md)

## In This Organization

- **[neoos-kernel](https://github.com/NeoOSOrganization/neoos-kernel)** — Kernel source
- **[neoos-musl](https://github.com/NeoOSOrganization/neoos-musl)** — musl libc (build dependency)
- **[neoos-openssl](https://github.com/NeoOSOrganization/neoos-openssl)** — OpenSSL, this repo's crypto backend
- **[neoos-docs](https://github.com/NeoOSOrganization/neoos-docs)** — Guides and architecture
