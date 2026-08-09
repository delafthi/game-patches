set quiet
set shell := ["bash", "-c"]

red := "\u{001b}[31m"
yellow := "\u{001b}[33m"
green := "\u{001b}[32m"
reset := "\u{001b}[0m"

# List recipes.
default:
    @just --list

# List all games.
list-games:
    @for d in games/*/; do if [[ -d "$d" ]]; then basename "$d"; fi; done

# List fixes for a game.
# Usage: just list-fixes <game>
list-fixes game:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    dirs=("games/{{ game }}/{{ os() }}/"*/)
    if [[ ${#dirs[@]} -eq 0 ]]; then
        echo "{{ red }}error{{ reset }}: no fixes for game '{{ game }}' on {{ os() }}" >&2
        exit 1
    fi
    for d in "${dirs[@]}"; do basename "$d"; done

# Format the repo with nix fmt (treefmt).
fmt:
    nix fmt

# Check formatting and flake evaluation.
check:
    #!/usr/bin/env bash
    set -euo pipefail
    treefmt --fail-on-change
    nix flake check

# Apply fix(es) to a game. No fix -> apply all patchable fixes.
# Usage: just patch <game> <game-root-dir> [fix ...]
patch game dest +fixes='':
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    if [[ ! -d "games/{{ game }}" ]]; then
        echo "{{ red }}error{{ reset }}: unknown game '{{ game }}'" >&2
        exit 1
    fi
    if [[ ! -d "{{ dest }}" ]]; then
        echo "{{ red }}error{{ reset }}: not a directory: {{ dest }}" >&2
        exit 1
    fi
    fixes=({{ fixes }})
    if [[ ${#fixes[@]} -eq 0 ]]; then
        for d in "games/{{ game }}/{{ os() }}/"*/; do
            [[ -f "$d/apply.sh" ]] && fixes+=("$d")
        done
    fi
    [[ ${#fixes[@]} -gt 0 ]] || { echo "{{ red }}error{{ reset }}: no patchable fixes for {{ game }} on {{ os() }}" >&2; exit 1; }
    for f in "${fixes[@]}"; do
        name="$(basename "$f")"
        dir="games/{{ game }}/{{ os() }}/$name"
        if [[ ! -d "$dir" ]]; then
            echo "{{ red }}error{{ reset }}: unknown fix '$name' for {{ game }}" >&2
            exit 1
        fi
        if [[ ! -f "$dir/apply.sh" ]]; then
            echo "{{ red }}error{{ reset }}: fix '$name' has no apply.sh (investigation only?)" >&2
            exit 1
        fi
        bash "$dir/apply.sh" "{{ dest }}"
        echo "{{ green }}=>{{ reset }} applied '$name' -> {{ dest }}"
    done

# Scaffold a new game from the templates.
# Usage: just new-game <game>
new-game game:
    #!/usr/bin/env bash
    set -euo pipefail
    game="{{ game }}"
    if [[ -z "$game" ]]; then
        echo "usage: just new-game <game>" >&2
        exit 1
    fi
    if [[ -d "games/$game" ]]; then
        echo "{{ red }}error{{ reset }}: already exists: games/$game" >&2
        exit 1
    fi
    mkdir -p "games/$game/macos" "games/$game/linux"
    sed "s/__GAME__/$game/g" templates/game-README.md > "games/$game/README.md"
    echo "created games/$game"
    echo "next steps:"
    echo "  1. fill games/$game/README.md"
    echo "  2. add fixes under games/$game/{macos,linux}/<fix-name>/,"
    echo "     each with a README.md + an apply.sh that takes the game root dir"
    echo "  3. symlink shared fixes:"
    echo "     ln -s ../../<canonical-game>/<platform>/<fix-name> games/$game/<platform>/<fix-name>"
