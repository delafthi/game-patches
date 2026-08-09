# Update libYoYoGamepad

Replaces the game's bundled `libYoYoGamepad.dylib` — an old GameMaker Studio
2 build — with a July 2024 build from a current GMS2 export, so controllers
get correct bindings in-game on macOS.

## Symptom

Controller is detected in-game, but the binding layout is totally wrong —
buttons/axes map to the wrong inputs, making the controller unusable.

## Diagnosis

- GameMaker games delegate all gamepad handling to the bundled
  `Contents/Frameworks/libYoYoGamepad.dylib`, which carries a built-in
  GUID→mapping database (SDL_gamecontrollerdb-style). Older builds predate
  modern controllers (PS4/PS5, Switch Pro, 8BitDo, ...), so unmapped devices
  fall back to garbage bindings.
- The library's C ABI is stable across GMS2 versions: the 2024 build exports
  all symbols the runners use (a superset), and its install name is identical
  (`@executable_path/../Frameworks/libYoYoGamepad.dylib`) — a drop-in swap.
- Katana ZERO ships the 2019 build (x86_64-only, macOS 10.13 SDK) and links
  13 of its symbols. Loop Hero ships a 2022-era build (signed 2022-05-11,
  universal, macOS 12.0 SDK) and `dlopen`s the dylib, resolving only six
  symbols at runtime — both are compatible with the 2024 build.

## Fix

`apply.sh`:

1. Backs up the original dylib to `libYoYoGamepad.dylib.bak` (only on first
   run — an existing `.bak` is kept untouched).
2. Installs the bundled 2024 build (universal x86_64 + arm64; the x86_64
   slice is what the game loads) and copies the license note next to it.
3. Ad-hoc re-signs the dylib and the app bundle (`codesign --force --deep
   --sign -`), since the swap breaks the original code signature.

Apply it via the root justfile (see the root README), then restart the game /
re-connect the controller. Roll back by moving the `.bak` back over the
dylib.

## Source

The replacement `libYoYoGamepad.dylib` was extracted unaltered from the
GameMaker macOS export published at
<https://github.com/KristinDolan/puppy-park> (`YoYo Runner.app`), code-signed
2024-07-08, built against the macOS 13.3 SDK. (Fallback candidates from 2022
GMS2 exports exist, e.g. <https://github.com/Badam17/Group-Project-6->.)

## License

`libYoYoGamepad.dylib` is proprietary software of YoYo Games / Opera — see
`libYoYoGamepad.LICENSE` (also copied next to the dylib by `apply.sh`). It is
used unaltered; all rights remain with YoYo Games / Opera.
