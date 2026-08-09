# game-patches

A collection of patches for macOS (and Linux) games. Each game documents its
fixes and ships the files that apply them. Multi-game fixes are defined once
and symlinked into the games they affect.

## Layout

```text
games/
└── <game>/
    ├── README.md                game overview and fix list
    └── <platform>/<fix-name>/   one directory per fix:
        ├── README.md            what the fix does and why
        ├── apply.sh             script that applies the fix to a destination
        └── <files>              fix payload, used by apply.sh
templates/                       README template for new games
scripts/macos/                   shared platform scripts (e.g. update-sdl2.py,
                                 the SDL2 updater used by several games)
```

`<platform>` is `macos` or `linux`, chosen automatically by the current OS.
`<fix-name>` describes the fix (e.g. `update-sdl2`), not the issue it solves.
Directories without an `apply.sh` are investigation/workaround notes and can't
be applied. All fixes are applied from the root justfile — games have no
justfiles of their own.

## Requirements

`just` and `uv`, provided by the dev shell:

```console
nix develop
# or direnv (already wired via .envrc)
```

## Usage

From the repo root:

```console
just list-games                    list all games
just list-fixes <game>             list fixes for a game
just patch <game> <game-root-dir> [fix...]   apply fix(es) to a game
```

When no fix is given, all of the game's patchable fixes for the current
platform are applied. Each fix's `apply.sh` receives the game root dir as its
argument and knows how to place its own files; the destination is always
passed in, never hardcoded.

What to pass as the game root dir:

- **Linux**: the directory that contains the game binary.
- **macOS**: the game's `.app` directory. If the game has no `.app` (e.g. a
  plain binary), use the directory that contains the binary, like on Linux.

Scaffold a new game from the templates:

```console
just new-game <game>
```

## Conventions

- One fix directory per problem, named after the fix, containing `README.md`,
  an executable `apply.sh` (takes the game root dir as `$1`), and whatever
  payload files it needs. Any fix type works — file copies, binary edits,
  whatever.
- A fix affecting several games lives in one canonical game and is symlinked
  into the others (see the Tomb Raider series' `add-8bitdo-ultimate2-mapping`
  fix, canonical in `tomb-raider`).
