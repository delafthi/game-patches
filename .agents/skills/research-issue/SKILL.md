---
name: research-issue
description: Research and diagnose a game issue (e.g. "controller not working in game xyz"). Use when the user reports a problem with a game that has no fix yet — locate the install, identify the engine/framework, match against known fix patterns, then create the fix.
---

# Researching a game issue

Workflow for turning "controller abc doesn't work in game xyz" into a fix.
Work through the steps in order; don't skip to writing a fix before the root
cause is identified.

First confirm the **platform** (macOS or Linux) — install locations, bundle
layout and inspection tools differ.

## 1. Locate the game install

Search common install locations first (glob for the game name,
case-insensitive).

macOS (look for `<Name>.app`):

- `/Applications`, `~/Applications` — standalone/GOG/itch installs
- `~/Library/Application Support/Steam/steamapps/common/` — Steam (the
  `.app` sits inside a folder named after the game)
- `/Applications/Epic Games/` — Epic

Linux (look for a directory named after the game; the executable sits
inside, files usually flat next to it):

- `~/.steam/steam/steamapps/common/`,
  `~/.local/share/Steam/steamapps/common/`,
  `~/.var/app/com.valvesoftware.Steam/.steam/steam/steamapps/common/`
  (Flatpak) — Steam
- `~/GOG Games/`, `~/Games/`, Lutris/Heroic prefixes under `~/Games` —
  GOG/standalone
- `~/.config/itch/apps/` — itch

Not found → **ask the user where the game is installed**. Don't guess.

## 2. Identify the engine / input layer

Inspect the game to pin down the framework — this determines which fix
pattern applies. Inspection tooling is platform-specific — use the right
tool for the host OS:

| Task | macOS | Linux |
| --- | --- | --- |
| Executable location | `Contents/MacOS/<binary>` inside the `.app` | executable file in the install root |
| Bundled libs | `Contents/Frameworks/` | flat next to the executable or in `lib*/` subdirs |
| List linked libraries | `otool -L <binary>` | `ldd <binary>` (runtime-resolved) or `objdump -p <binary> \| rg NEEDED` (static `NEEDED` list) |
| Show lib search paths | `otool -l <binary> \| rg -A2 LC_RPATH` | `readelf -d <binary> \| rg 'RPATH\|RUNPATH'` or `patchelf --print-rpath <binary>` |
| Embedded strings / lib version | `strings <file>` (same on both) | `strings <file>` |

- **SDL2** (`libSDL2-2.0.0.dylib` / `SDL2.framework` on macOS,
  `libSDL2-2.0.so.0` on Linux): check the bundled version with
  `strings <lib>`. SDL < 2.0.9 predates the HIDAPI joystick drivers;
  < 2.0.10 lacks `SDL_HINT_GAMECONTROLLERCONFIG_FILE` → modern controllers
  are ignored. On Linux also check whether the game uses a bundled lib
  (rpath/`LD_LIBRARY_PATH`, lib next to the binary) or the system/Steam
  runtime one — the Steam runtime ships its own SDL2 under
  `~/.steam/root/ubuntu12_32/steam-runtime/`.
- **Feral Interactive ports** (Tomb Raider series): macOS bundles have
  `Contents/Resources/InputDevices/*.plist` — controller support is driven
  by those plists. On Linux Feral installs keep their support data under
  `share/feral-interactive/`.
- **Unity**: macOS `Contents/Resources/Data/Managed/Assembly-CSharp.dll`,
  Linux `<Game>_Data/Managed/Assembly-CSharp.dll` (may embed InControl,
  which matches controllers by exact device-name string).
- **Mono/FNA**: `FNA.dll`, `MonoGame.Framework.dll`, `FNA.dll.config`,
  bundled mono runtime.
- **HashLink**: `*.hdll` files, an `hl` VM binary.
- Steam game? Check whether **Steam Input** is enabled — it virtualises
  every controller to `Microsoft GamePad-N`, which some games can't match.

Linux-only input checks (when the controller fails system-wide or only in
some games):

- Device visible to user: `evtest` / `jstest` against
  `/dev/input/event*` — missing udev rules or wrong group permissions are a
  common cause.
- Wayland vs X11 session — some ports only read input correctly under X11
  (run via XWayland).

## 3. Match against known fix patterns

Search this repo for similar games/engines before inventing anything:
`just list-games`, read the READMEs under `games/`. Known patterns:

- Old bundled SDL2 → replace with modern build (`update-sdl2`; shared
  machinery in `scripts/<platform>/` — macOS only so far, create
  `scripts/linux/` when the first Linux fix needs it). On Linux the
  equivalent is swapping the bundled `.so`, or pointing the game at the
  system/Steam runtime SDL2 from a launch wrapper.
- Feral port missing a controller entry → add an `InputDevices` plist
  (`add-8bitdo-ultimate2-mapping`).
- Unity/InControl name-matching → see the `overcooked-2` investigation
  (InControl DLL patch or Steam Input setting).
- Steam Input virtualisation → disable Steam Input for the game
  (`unrailed`).

Also search the web for the specific game + symptom — engine/vendor-specific
fixes often already exist (official betas, community patches, ProtonDB
notes for the Linux/Proton case).

## 4. Create the fix and hand over

Use the **create-fix** skill to add the fix directory (or an
investigation-only README if no patch exists yet). `apply.sh` receives the
game root as `$1` — on macOS that is the `.app` dir, on Linux the install
dir containing the executable. Then report back to the user — only they can
verify in-game. State clearly:

- what you found (root cause or current hypothesis),
- what the fix does,
- what the user should test.
