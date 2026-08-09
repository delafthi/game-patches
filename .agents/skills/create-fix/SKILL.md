---
name: create-fix
description: Add a new game fix or game to the game-patches repo. Use when creating a fix directory, writing an apply.sh, scaffolding a new game, or sharing a fix across games via symlink.
---

# Creating a fix

## Directory layout

One fix per directory: `games/<game>/<platform>/<fix-name>/` where
`<platform>` is `macos` or `linux`.

- Name the directory after the **fix**, not the issue (`update-sdl2`, not
  `controllers-not-recognised`).
- No fix yet → investigation notes only: no `apply.sh`, keep the symptom
  name until a fix exists.
- New game: scaffold with `just new-game <game>`, then fill its README.

A fix directory contains:

- `README.md` — leads with what the fix does (and which hardware it fixes),
  then symptom/diagnosis.
- `apply.sh` — executable, takes the game root dir as `$1` (macOS: the
  `.app` dir), knows how to place its own payload. The destination is always
  passed in, never hardcoded.
- Any payload files `apply.sh` needs.

## Shared machinery

- Reusable fix machinery lives in `scripts/<platform>/` — delegate to it from
  `apply.sh` instead of duplicating logic (example: the SDL2 updater used by
  several games).
- Mind the relative depth: from a fix dir, scripts are at
  `../../../../scripts/...`.

## Fixes shared by several games

Keep one canonical copy in one game, symlink it into the others with a
relative link from `<platform>/`:

```console
ln -s ../../<canonical-game>/<platform>/<fix-name> \
  games/<game>/<platform>/<fix-name>
```

Add the game to the "Affected games" list in the canonical fix's README.

## Verify

1. `just fmt`, then `just check`.
2. `just patch <game> <tmp-dir>` against a throwaway dir. Note: some fixes
   (e.g. the SDL2 updater) download from the network.
