# Update bundled SDL2

Replaces the game's bundled SDL2 with a modern build so the 8BitDo Ultimate 2
Wireless (and other modern controllers) is recognised in-game on macOS. The
bundled SDL2 is an old build that predates the HIDAPI joystick drivers (SDL
2.0.9+) and has a much smaller built-in controller mapping. On such builds
only controllers with a built-in mapping work (e.g. Xbox); a controller that
is paired/visible in macOS — like the 8BitDo Ultimate 2 Wireless — is ignored
by the game.

## Symptom

Controller isn't recognised at all in-game, even though it's paired and visible
in macOS.

## Fix

Replace the bundled SDL2 with a modern build (see `apply.sh`). Modern SDL2
(2.32.x) covers most controllers out of the box via its HIDAPI drivers and a
much larger embedded mapping database.

The default is pinned to the newest SDL2 release, **2.32.10** (the last 2.x
release; the SDL2 line has been superseded by SDL3, which Stardew Valley can't
use — the game binary links the SDL2 soname).

## Diagnosis

- `strings <app>/Contents/MacOS/libSDL2-2.0.0.dylib` shows an old build. Note:
  `libSDL2-2.0.0.dylib` is just the macOS *soname* of SDL2 — it is the same
  filename for every 2.x version, so the filename does not reveal the actual
  version.
- The game binary (`Stardew Valley`) links `@rpath/libSDL2-2.0.0.dylib`, so the
  `libSDL2-2.0.0.dylib` in `Contents/MacOS/` is the SDL that is actually
  loaded. Replacing it in place is enough — no config change is needed.

## apply.sh

Resolves the bundled SDL location (`Contents/MacOS/libSDL2-2.0.0.dylib`) and
delegates the replacement to the shared
[`scripts/macos/update-sdl2.py`](../../../../scripts/macos/update-sdl2.py)
(run via `uv`), which does two things:

1. Installs the pinned official SDL2 build (default 2.32.10, see above) from
   <https://github.com/libsdl-org/SDL/releases> into the game's
   `Contents/MacOS/libSDL2-2.0.0.dylib`. The binary is extracted from the
   official macOS `.dmg` (`SDL2.framework`); pass a dylib path as a second
   argument to use a specific build instead of downloading. Because the file
   keeps SDL2's soname, the game binary already points at it — no config change
   is needed.
2. Copies the SDL license notice from the downloaded framework's
   `Resources/License.txt` to `SDL2.LICENSE` next to the dylib (the zlib-style
   license covers redistribution of the SDL binary).

The original SDL is preserved as `libSDL2-2.0.0.dylib.bak` on first run for
easy rollback; later runs keep that original backup untouched.

Apply it via the root justfile (see the root README), then restart the game /
re-connect the controller.

Note: the new SDL must be x86_64 (the game runs x86_64, under Rosetta on Apple
Silicon); the official `.dmg` build is universal (x86_64 + arm64).

## License

The artifact is distributed under the SDL zlib-style license,
Copyright (C) 1997-2025 Sam Lantinga. The license text is copied from the
downloaded framework's `Resources/License.txt` to `SDL2.LICENSE` next to the
dylib. It is used unaltered from its upstream source.
