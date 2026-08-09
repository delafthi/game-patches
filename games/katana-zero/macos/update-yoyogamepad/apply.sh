#!/usr/bin/env bash
set -euo pipefail

app="$1"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

target="$app/Contents/Frameworks/libYoYoGamepad.dylib"
if [[ ! -f $target ]]; then
  echo "error: no libYoYoGamepad.dylib at $target" >&2
  exit 1
fi

# Back up the original once; keep the first backup on repeat runs.
[[ -f $target.bak ]] || mv "$target" "$target.bak"

cp "$here/libYoYoGamepad.dylib" "$target"
cp "$here/libYoYoGamepad.LICENSE" "$(dirname "$target")/libYoYoGamepad.LICENSE"

# The swap breaks the bundle seal; ad-hoc re-sign so the game still launches.
codesign --force --sign - "$target"
codesign --force --deep --sign - "$app"

echo "updated libYoYoGamepad.dylib -> $target (backup: $target.bak)"
