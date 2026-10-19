#!/usr/bin/env bash
# scripts/verify-silo.sh — checks a Silo binary the way Gabion uses it.
#
# Usage: verify-silo.sh <path to silo> <expected release tag>
#
# Gabion starts Silo as the development stand's object store: one data
# directory, the S3 API and the console on loopback ports, credentials from
# MINIO_ROOT_USER/MINIO_ROOT_PASSWORD. The storage module needs a bucket, and
# objects put, read and deleted in it. This script does exactly that against
# a fresh data directory and fails on the first step that does not hold.
set -euo pipefail

SILO="$1"
TAG="$2"
WORK="$(mktemp -d)"
LOG="$WORK/silo.log"
PID=""

cleanup() {
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    wait "$PID" 2>/dev/null || true
  fi
  rm -rf "$WORK"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  if [ -f "$LOG" ]; then
    echo "--- silo log ---" >&2
    cat "$LOG" >&2
  fi
  exit 1
}

free_port() {
  python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'
}

VERSION="$("$SILO" --version)"
echo "$VERSION"
echo "$VERSION" | grep -q -F "$TAG" || fail "--version does not name $TAG"

S3_PORT="$(free_port)"
CONSOLE_PORT="$(free_port)"
mkdir -p "$WORK/data"
MINIO_ROOT_USER=minioadmin MINIO_ROOT_PASSWORD=minioadmin \
  "$SILO" server "$WORK/data" \
  "--address=127.0.0.1:$S3_PORT" \
  "--console-address=127.0.0.1:$CONSOLE_PORT" >"$LOG" 2>&1 &
PID=$!

# Ready or dead: the server either answers its readiness probe or its
# process ends. The attempt count only bounds a server that neither
# answers nor exits.
ready=""
for _ in $(seq 1 300); do
  if ! kill -0 "$PID" 2>/dev/null; then
    fail "silo exited before it was ready"
  fi
  if curl -sf -o /dev/null "http://127.0.0.1:$S3_PORT/minio/health/ready"; then
    ready=yes
    break
  fi
  sleep 0.2
done
[ -n "$ready" ] || fail "silo did not become ready"
echo "ready: S3 on $S3_PORT, console on $CONSOLE_PORT"

S3="http://127.0.0.1:$S3_PORT"
sigv4() {
  curl -s --aws-sigv4 "aws:amz:us-east-1:s3" --user minioadmin:minioadmin "$@"
}
status() {
  sigv4 -o /dev/null -w '%{http_code}' "$@"
}

[ "$(status -I "$S3/gabion-check")" = "404" ] || fail "missing bucket is not 404"
[ "$(status -X PUT "$S3/gabion-check")" = "200" ] || fail "create bucket"
[ "$(status -I "$S3/gabion-check")" = "200" ] || fail "head bucket"
printf 'gabion object store check\n' >"$WORK/object.txt"
[ "$(status -X PUT -H 'Content-Type: text/plain' --data-binary "@$WORK/object.txt" "$S3/gabion-check/dir/object.txt")" = "200" ] \
  || fail "put object"
sigv4 -o "$WORK/read.txt" "$S3/gabion-check/dir/object.txt"
cmp -s "$WORK/object.txt" "$WORK/read.txt" || fail "object read back differs"
[ "$(status -X DELETE "$S3/gabion-check/dir/object.txt")" = "204" ] || fail "delete object"
body="$(sigv4 "$S3/gabion-check/dir/object.txt")"
echo "$body" | grep -q '<Code>NoSuchKey</Code>' || fail "deleted object is not NoSuchKey: $body"
[ "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$CONSOLE_PORT/")" = "200" ] || fail "console does not answer"

echo "OK: $TAG — version, start, bucket, put, get, delete, console"
