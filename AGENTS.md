# game-patches

Patches for macOS (and Linux) games. Content repo: markdown docs + bash
apply-scripts. No build, no test suite. Fixes live in
`games/<game>/<platform>/<fix-name>/`.

## Commands

All logic lives in the **root justfile** — games have no justfiles. Run
`just` to list recipes.

## Conventions

- Formatting is enforced: run `just fmt` before `just check`.
