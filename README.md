# silo-verify

Verification of Silo releases before Gabion pins them.

## What is this?

Gabion's development environment runs an S3-compatible object store next to the application: [Silo](https://github.com/pgsty/silo), the maintained fork of MinIO. Silo publishes ready-made binaries with checksums, and Gabion downloads them straight from Silo's releases. This repository builds and distributes nothing; it holds the check a Silo release passes before Gabion pins its version.

## The check

The `Verify Silo` workflow (`.github/workflows/verify.yml`) is run by hand with a Silo release tag. On the native machine of each platform Gabion installs Silo on — Linux x64 and ARM64, macOS ARM64 and Intel, each macOS on two versions — it:

1. downloads the release archive and verifies its checksum against the release's `checksums.txt`;
2. checks that the archive carries the binary, `LICENSE` and `NOTICE`;
3. runs `scripts/verify-silo.sh`: the version the binary reports, a start with the arguments Gabion uses, and the bucket and object operations Gabion's storage module performs — create a bucket, put an object, read it back, delete it — plus the console answering.

A release Gabion pins is one that passed on every platform.

## License

See [LICENSE](LICENSE).

This project is NOT affiliated with, endorsed by, or sponsored by MinIO, Inc. or PGSTY.
