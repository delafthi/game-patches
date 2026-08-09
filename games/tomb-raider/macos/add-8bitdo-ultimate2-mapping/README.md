# Add 8BitDo Ultimate 2 Wireless input mapping

Installs an input-device mapping for the 8BitDo Ultimate 2 Wireless so the
Feral Interactive macOS ports of the Tomb Raider series recognise the
controller. Without the mapping the controller is simply absent from the
game's controls.

## Diagnosis

- VendorID `11720` (`0x2DC8`), ProductID `24594` (`0x6012`).
- Feral ports read controller mappings from plists in the game's
  `Contents/Resources/InputDevices/` directory; a missing entry for the
  controller means it is never detected.
- Check the controller is paired and visible in macOS Bluetooth settings before
  assuming this patch is the problem.

## apply.sh

The `8BitDoUltimate2Wireless.plist` in this directory maps the controller:
axis/button assignments, hatswitch directions, and trigger initial values.

`apply.sh` copies it into the game's `InputDevices` directory. Apply it via the
root justfile (see the root README), then restart the game / re-connect the
controller.

## Affected games

This fix applies to every Tomb Raider Feral port. The directory is canonical
here and symlinked into the other games of the series:

- `tomb-raider`
- `rise-of-the-tomb-raider`
- `shadow-of-the-tomb-raider`
