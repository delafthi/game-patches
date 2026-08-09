# Loop Hero

## Fixes

- macOS:
  - [update-yoyogamepad](macos/update-yoyogamepad/) — replace the bundled
    2022 libYoYoGamepad.dylib with a 2024 build; fixes totally wrong
    controller bindings (shared, symlinked from katana-zero). Known quirk:
    menus behave a little oddly with a controller — accepted, the game is
    designed for mouse.
