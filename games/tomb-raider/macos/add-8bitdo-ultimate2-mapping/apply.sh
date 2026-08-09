#!/usr/bin/env bash
set -euo pipefail

dest="$1"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d $dest ]]; then
  echo "error: not a directory: $dest" >&2
  exit 1
fi

cp -R "$here/8BitDoUltimate2Wireless.plist" "$dest/"
echo "copied 8BitDoUltimate2Wireless.plist -> $dest/"
