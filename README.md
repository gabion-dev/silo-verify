# minio-server

Pre-built MinIO server binaries for development environments.

## What is this?

This repository provides cross-platform MinIO binaries built from the [pgsty/minio](https://github.com/pgsty/minio) community fork via GitHub Actions. The original [minio/minio](https://github.com/minio/minio) repository was archived in February 2026 and no longer provides pre-built binaries.

## Platforms

| File | Platform |
|------|----------|
| `minio-linux-amd64` | Linux x64 |
| `minio-linux-arm64` | Linux ARM64 |
| `minio-darwin-amd64` | macOS x64 (Intel) |
| `minio-darwin-arm64` | macOS ARM64 (Apple Silicon) |
| `minio-windows-amd64.exe` | Windows x64 |

## Download

Binaries are available on the [Releases](https://github.com/gabion-dev/minio-server/releases) page. Each release includes SHA256 checksums.

## Source & License

Built from [pgsty/minio](https://github.com/pgsty/minio) — a community-maintained fork of MinIO.

Distributed under the [GNU Affero General Public License v3.0](LICENSE), the same license as the original MinIO project. Every release carries, next to the binaries, the license text (`LICENSE`), the upstream copyright and third-party notices (`NOTICE`, `CREDITS`) and the exact source tree the binaries were built from (`minio-sources.tar.gz`, with its `.sha256`) — the corresponding source the license requires to accompany a binary distribution.

This project is NOT affiliated with, endorsed by, or sponsored by MinIO, Inc.