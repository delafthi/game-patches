#!/usr/bin/env bash
set -euo pipefail

# Dead Cells is a loose dir or a .app; libs live at the root or in osx/.
machinedir="$1/Contents/MacOS"
[[ -d $machinedir ]] || machinedir="$1"
libdir="$machinedir/osx"
[[ -d $libdir ]] || libdir="$machinedir"
[[ -d $libdir ]] || {
  echo "error: no native lib dir: $libdir" >&2
  exit 1
}

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$here/../../../../scripts/macos/apply-sdl2.sh" \
  "$libdir/libSDL2-2.0.0.dylib" ${2:+"$2"}
