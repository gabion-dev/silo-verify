# minio-server

Verification of the object store Gabion uses in development.

## What is this?

Gabion's development environment runs an S3-compatible object store next to the application. It used to be MinIO, built in this repository from the [pgsty/minio](https://github.com/pgsty/minio) community fork. That fork is now [pgsty/silo](https://github.com/pgsty/silo), and it publishes ready-made binaries for Linux, macOS and Windows with checksums. Gabion downloads those releases directly; nothing is built here anymore.

What remains here is the check a Silo release passes before Gabion pins it: the `Verify Silo` workflow (`.github/workflows/verify.yml`) downloads the release on the native machine of each platform Gabion installs it on — Linux x64 and ARM64, macOS ARM64 and Intel on two macOS versions — verifies its checksum against the release's `checksums.txt`, and runs `scripts/verify-silo.sh`: the version the binary reports, a start with the arguments Gabion uses, and the bucket and object operations Gabion's storage module performs.

## Earlier releases

The releases of this repository (MinIO binaries built from pgsty/minio, with their license, notices and source archive) stay published for installations of Gabion that still download them.

## License

The releases of this repository are distributed under the [GNU Affero General Public License v3.0](LICENSE), the same license as MinIO. Every release carries, next to the binaries, the license text (`LICENSE`), the upstream copyright and third-party notices (`NOTICE`, `CREDITS`) and the exact source tree the binaries were built from (`minio-sources.tar.gz`, with its `.sha256`).

This project is NOT affiliated with, endorsed by, or sponsored by MinIO, Inc. or PGSTY.
