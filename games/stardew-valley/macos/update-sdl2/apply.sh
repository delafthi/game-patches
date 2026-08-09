#!/usr/bin/env bash
set -euo pipefail

# Stardew Valley is a .app; the dylib sits directly in Contents/MacOS.
libdir="$1/Contents/MacOS"
[[ -d $libdir ]] || {
  echo "error: no MacOS dir: $libdir" >&2
  exit 1
}

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$here/../../../../scripts/macos/apply-sdl2.sh" \
  "$libdir/libSDL2-2.0.0.dylib" ${2:+"$2"}
