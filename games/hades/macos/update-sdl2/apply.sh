#!/usr/bin/env bash
set -euo pipefail

# Hades links @rpath/SDL2.framework/Versions/A/SDL2; the framework lives in
# Contents/MacOS for .app installs, or next to the binary for loose dirs.
machinedir="$1/Contents/MacOS"
[[ -d $machinedir ]] || machinedir="$1"
[[ -d $machinedir ]] || {
  echo "error: no MacOS dir: $machinedir" >&2
  exit 1
}

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$here/../../../../scripts/macos/apply-sdl2.sh" \
  "$machinedir/SDL2.framework" ${2:+"$2"}
