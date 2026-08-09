#!/usr/bin/env bash
# Shared driver for per-fix apply.sh scripts: run update-sdl2.py via uv.
# Usage: apply-sdl2.sh <target> [source]   (SDL2_TAG env passes through)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v uv >/dev/null || {
  echo "error: uv not found (dev shell provides it)" >&2
  exit 1
}

exec uv run --no-project "$here/update-sdl2.py" "$@"
