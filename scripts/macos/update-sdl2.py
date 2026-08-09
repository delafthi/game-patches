#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///

"""Replace a game's bundled SDL2 with a newer official macOS build.

Usage: update-sdl2.py <target> [source]

target  Bundled SDL2 to replace: <...>/libSDL2-2.0.0.dylib or <...>/SDL2.framework.
        The install kind is derived from the name. The original SDL is kept as
        <target>.bak, created once; later runs keep that original backup.
source  Optional explicit dylib/framework to install instead of downloading.

In dylib mode the SDL license is copied next to the target as SDL2.LICENSE
(the framework ships its own license). SDL2_TAG overrides the pinned release
tag (default release-2.32.10).
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

DEFAULT_TAG = "release-2.32.10"
FRAMEWORK = "SDL2.framework"
DYLIB = "libSDL2-2.0.0.dylib"


@contextmanager
def mounted(dmg: Path) -> Iterator[Path]:
    """Mount dmg read-only; unmount on exit."""
    mnt = dmg.parent / "mnt"
    mnt.mkdir()
    subprocess.run(
        [
            "hdiutil",
            "attach",
            "-nobrowse",
            "-readonly",
            "-mountpoint",
            str(mnt),
            str(dmg),
        ],
        check=True,
        capture_output=True,
    )
    try:
        yield mnt
    finally:
        subprocess.run(
            ["hdiutil", "detach", str(mnt)], capture_output=True, check=False
        )


def download_framework(dest: Path) -> Path:
    """Download the pinned SDL2 release DMG and extract the framework to dest."""
    tag = os.environ.get("SDL2_TAG", DEFAULT_TAG)
    version = tag.removeprefix("release-")
    url = (
        f"https://github.com/libsdl-org/SDL/releases/download/{tag}/SDL2-{version}.dmg"
    )
    dmg = dest / f"SDL2-{version}.dmg"
    print(f"downloading SDL2 {version} ({url})")
    req = urllib.request.Request(url, headers={"User-Agent": "game-patches"})
    with urllib.request.urlopen(req) as resp, dmg.open("wb") as out:
        shutil.copyfileobj(resp, out)
    with mounted(dmg) as mnt:
        if not (mnt / FRAMEWORK).is_dir():
            sys.exit(f"error: {FRAMEWORK} not found in {dmg.name}")
        shutil.copytree(mnt / FRAMEWORK, dest / FRAMEWORK)
    return dest / FRAMEWORK


def find_license(lib: Path) -> Path | None:
    """Look for Resources/License.txt in lib's directory and 3 levels up."""
    for parent in list(lib.parents)[:4]:
        candidate = parent / "Resources" / "License.txt"
        if candidate.is_file():
            return candidate
    return None


def backup_once(target: Path) -> None:
    """Rename target to .bak if none exists yet, so .bak always holds the
    original; otherwise just remove the current (already-patched) target."""
    if not target.exists():
        return
    if target.with_name(target.name + ".bak").exists():
        if target.is_dir():
            shutil.rmtree(target)
        else:
            target.unlink()
    else:
        target.rename(target.with_name(target.name + ".bak"))


def install(target: Path, src: Path, license: Path | None) -> None:
    backup_once(target)
    if src.is_dir():
        shutil.copytree(src, target)
    else:
        shutil.copy2(src, target)
        target.chmod(0o755)
        if license is not None:
            shutil.copy2(license, target.parent / "SDL2.LICENSE")
            print(f"copied SDL license -> {target.parent / 'SDL2.LICENSE'}")
    print(f"installed SDL2 -> {target}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "target",
        type=Path,
        help=f"<...>/{DYLIB} or <...>/{FRAMEWORK} to replace",
    )
    parser.add_argument(
        "source",
        nargs="?",
        type=Path,
        help="explicit dylib or framework to install instead of downloading "
        "(SDL2_TAG env overrides the pinned release tag)",
    )
    args = parser.parse_args()

    target: Path = args.target
    framework_mode = target.name.endswith(".framework")
    if not framework_mode and target.name != DYLIB:
        sys.exit(f"error: target must be {DYLIB} or *.framework: {target}")
    if not target.parent.is_dir():
        sys.exit(f"error: no such directory: {target.parent}")

    with tempfile.TemporaryDirectory(prefix="sdl2-") as tmp:
        if args.source is not None:
            src = args.source
            if framework_mode and (not src.is_dir() or src.name != FRAMEWORK):
                sys.exit(f"error: not a {FRAMEWORK}: {src}")
            if not framework_mode and not src.is_file():
                sys.exit(f"error: not a file: {src}")
            license = None if framework_mode else find_license(src)
            if not framework_mode and license is None:
                print(
                    f"warning: no license found near {src}; skipping SDL2.LICENSE",
                    file=sys.stderr,
                )
        else:
            framework = download_framework(Path(tmp))
            src = framework if framework_mode else framework / "Versions/A/SDL2"
            license = None if framework_mode else framework / "Resources/License.txt"
            if not framework_mode and not src.is_file():
                sys.exit(f"error: SDL2 binary not found: {src}")
        install(target, src, license)


if __name__ == "__main__":
    main()
