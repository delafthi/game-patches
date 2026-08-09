# Update bundled SDL2

Replaces the game's bundled `SDL2.framework` with a modern build so the 8BitDo
Ultimate 2 Wireless (and other modern controllers) is recognised in-game on
macOS. The bundled SDL2 is **2.0.15**, which predates the HIDAPI joystick
drivers (SDL 2.0.9+), the `SDL_HINT_GAMECONTROLLERCONFIG_FILE` hint (SDL
2.0.10+), and has a much smaller built-in controller mapping. On 2.0.15 only
controllers with a built-in mapping work; a controller that is paired/visible
in macOS — like the 8BitDo Ultimate 2 Wireless — is ignored by the game.

## Symptom

Controller isn't recognised at all in-game, even though it's paired and visible
in macOS.

## Fix

Replace the bundled `SDL2.framework` with a modern build (see `apply.sh`).
Modern SDL2 (2.32.x) covers most controllers out of the box via its HIDAPI
drivers and a much larger embedded mapping database.

The default is pinned to the newest SDL2 release, **2.32.10** (the last 2.x
release; the SDL2 line has been superseded by SDL3, which Hades can't use — the
game links the SDL2 framework soname).

## Diagnosis

- `strings <app>/Contents/MacOS/SDL2.framework/Versions/A/SDL2` shows an old
  `2.0.15` build, and `Resources/Info.plist` reports `CFBundleVersion` 2.0.15.
- The game binary (`Game.macOS`) links `@rpath/SDL2.framework/Versions/A/SDL2`,
  so the framework in `Contents/MacOS/` is the SDL that is actually loaded.

## apply.sh

Resolves the bundled framework location (`Contents/MacOS/SDL2.framework`, or
the game root for a non-`.app` layout) and delegates the replacement to the
shared
[`scripts/macos/update-sdl2.py`](../../../../scripts/macos/update-sdl2.py)
(run via `uv`).

Installs the pinned official SDL2 build (default 2.32.10, see above) from
<https://github.com/libsdl-org/SDL/releases> into
`Contents/MacOS/SDL2.framework`. The whole framework is extracted from the
official macOS `.dmg` (`SDL2.framework`), which also ships the SDL license in
its `Resources/License.txt`; pass a framework path as a second argument to use
a specific build instead of downloading.

The original framework is preserved as `SDL2.framework.bak` on first run for
easy rollback; later runs keep that original backup untouched.

Apply it via the root justfile (see the root README), then restart the game /
re-connect the controller.

Note: the new framework must be x86_64 (the game runs x86_64, under Rosetta on
Apple Silicon); the official `.dmg` build is universal (x86_64 + arm64).

## License

The artifact is distributed under the SDL zlib-style license,
Copyright (C) 1997-2025 Sam Lantinga. The license text is shipped inside the
framework as `Resources/License.txt`. It is used unaltered from its upstream
source.
