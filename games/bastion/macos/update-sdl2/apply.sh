#!/usr/bin/env bash
set -euo pipefail

# Bastion is a .app; libs sit in Contents/MacOS/osx/.
libdir="$1/Contents/MacOS/osx"
[[ -d $libdir ]] || {
  echo "error: no native lib dir: $libdir" >&2
  exit 1
}

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$here/../../../../scripts/macos/apply-sdl2.sh" \
  "$libdir/libSDL2-2.0.0.dylib" ${2:+"$2"}
