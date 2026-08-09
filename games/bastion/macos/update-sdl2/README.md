# Update bundled SDL2

Replaces the game's bundled SDL2 with a modern build so controllers are
recognised in-game on macOS. The bundled SDL2 is **2.0.6**, which predates the
HIDAPI joystick drivers (SDL 2.0.9+), the `SDL_HINT_GAMECONTROLLERCONFIG_FILE`
hint (SDL 2.0.10+), and has a much smaller built-in controller mapping. On
2.0.6 only controllers with a built-in mapping work (e.g. Xbox, via a
hardcoded name fallback); a controller that is paired/visible in macOS is
ignored by the game.

Modern SDL2 (2.32.x) covers most controllers out of the box via its HIDAPI
drivers and a much larger embedded mapping database, so the stale bundled
`gamecontrollerdb.txt` is no longer required. The default is pinned to
**SDL2 2.32.10**; override the tag with `SDL2_TAG=release-2.32.x` to test a
different build.

> [!NOTE]
> The **8BitDo Ultimate 2 Wireless** (Bluetooth) works with the updated SDL2,
> but Bastion does not auto-switch to the gamepad control scheme for it: the
> game boots into keyboard/mouse and shows no button glyphs. Switch the
> control scheme to **Gamepad** manually in the settings — everything works
> after that. An Xbox
> controller auto-switches as expected. Reason: SDL exposes the Xbox pad
> synchronously via IOKit (visible when Bastion checks for controllers at
> startup), while the 8BitDo arrives seconds later via the async macOS
> GameController-framework discovery path, so the startup check misses it.
> Hotplug itself is fine, hence the working manual switch.

## Diagnosis

- `strings <game>/Contents/MacOS/osx/libSDL2-2.0.0.dylib` shows an old
  `2.0.6` build. Note: `libSDL2-2.0.0.dylib` is just the macOS *soname* of
  SDL2 — it is the same filename for every 2.x version, so the filename does
  not reveal the actual version. Other games shipping `libSDL2-2.0.0.dylib`
  (e.g. Unrailed) usually bundle a much newer SDL2 build.
- The launcher (`Contents/MacOS/Bastion`) sets `DYLD_LIBRARY_PATH=./osx/`, so
  `osx/libSDL2-2.0.0.dylib` is the SDL that is actually loaded. On macOS the
  Windows `SDL2.dll` in `Contents/MacOS` is not used; `FNA.dll.config` maps
  `SDL2.dll` to the macOS `libSDL2-2.0.0.dylib`.

## Fix

`apply.sh` resolves the bundled SDL location
(`Contents/MacOS/osx/libSDL2-2.0.0.dylib`) and delegates the replacement to the
shared
[`scripts/macos/update-sdl2.py`](../../../../scripts/macos/update-sdl2.py)
(run via `uv`), which does two things:

1. Installs the pinned official SDL2 build (2.32.10, see above) from
   <https://github.com/libsdl-org/SDL/releases> into
   `Contents/MacOS/osx/libSDL2-2.0.0.dylib`. The binary is extracted from the
   official macOS `.dmg` (`SDL2.framework`); pass a dylib path as a second
   argument to use a specific build instead of downloading.
   Because the file keeps SDL2's soname, the stock `FNA.dll.config` already
   points at it — no config change is needed.
2. Copies the SDL license notice from the downloaded framework's
   `Resources/License.txt` to `Contents/MacOS/osx/SDL2.LICENSE` (the zlib-style
   license covers redistribution of the SDL binary).

The original SDL is preserved as `libSDL2-2.0.0.dylib.bak` on first run for
easy rollback; later runs keep that original backup untouched. The bundled
`gamecontrollerdb.txt` is left
untouched — modern SDL2 does not need it.

Apply it via the root justfile (see the root README), then restart the game /
re-connect the controller.

Note: the new SDL must be x86_64 (Bastion runs x86_64, under Rosetta on Apple
Silicon); the official `.dmg` build is universal (x86_64 + arm64).

## License

Both artifacts are distributed under the SDL zlib-style license,
Copyright (C) 1997-2025 Sam Lantinga. The license text is copied from the
downloaded framework's `Resources/License.txt` to `SDL2.LICENSE` next to the
dylib. They are used unaltered from their upstream sources.
