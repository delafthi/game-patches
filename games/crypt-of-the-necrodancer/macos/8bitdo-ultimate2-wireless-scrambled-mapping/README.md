# 8BitDo Ultimate 2 Wireless scrambled mapping

8BitDo Ultimate 2 Wireless controller mapping scrambled in-game on macOS.
Status: **investigated — no clean fix possible**
([why](#why-no-fix)); workaround = in-game control remap
([below](#workaround)).

## Symptom

Controller connects over Bluetooth and is visible to macOS, but in-game the
mapping is completely scrambled: Start acts as Down, Y acts as Start, R3
acts as Left, some buttons do nothing. An Xbox Series X controller works
fine with the same game.

## Root cause

The GOG macOS build (`NecroDancer.app`) has **no controller database and no
input API** — nothing data-driven to add a mapping to:

- Engine: Monkey X / BlitzMax, **GLFW 2.7 statically linked**
  (`glfw/lib/cocoa/cocoa_joystick.m`). Input via raw IOKit HID
  (`IOHIDDeviceInterface` polling). No SDL, no `GameController.framework`.
- The game has **one fixed controller mapping** for all devices.
  `GetControllerType()` exists in the binary but is a stub that always
  returns 0 — dead code, no per-device detection anywhere.
- GLFW 2.7 converts the dpad hat switch into 4 virtual buttons appended
  **after** the physical buttons, in enumeration order.

The fixed mapping matches the Xbox Wireless Controller's Bluetooth
descriptor: 16 buttons, hat at indices 16–19.

The 8BitDo Ultimate 2 Wireless (Bluetooth = DInput, vid `2DC8` pid `6012`)
exposes **24 buttons** in a different order (classic 8BitDo layout:
face buttons at usages 1,2,5,6, i.e. A,B,_,_,X,Y with gaps), so its hat
lands at indices 24–27 and every index the game reads hits the wrong
physical button. That produces exactly the observed scramble
(Start→Down, Y→Start, R3→Left, dead buttons).

Verified with a probe replicating GLFW 2.7's exact enumeration and polling:
the 8BitDo enumerates fine, opens fine, and every physical input (24
buttons, hat, 4 axes) registers live at that layer. The device and macOS
are not the problem — the game's fixed layout is.

Side notes:

- GLFW 2.7 has **no hotplug** — connect the controller before launching.
- Wired/2.4GHz-dongle modes of this controller are XInput (XUSB class), not
  HID at all — invisible to this game no matter what. Bluetooth is the only
  usable mode.

## Why no fix

All per-device fix avenues are dead ends:

- **In-game rebinding** works (every input registers in *Options → Reassign
  Controls*), but bindings are stored globally in
  `Contents/Resources/data/save_data.xml` (`keybinding0_0..15`, no device
  key). Rebinding for the 8BitDo breaks the Xbox controller's mapping, and
  button prompts no longer match.
- **Patching the default mapping table in the binary** has the same
  problem: one global table, so it would break the Xbox layout instead.
- **Lua modding API** can register new keybinds for mod actions but cannot
  remap the physical buttons of built-in actions.
- A per-device mapping would require injecting code (DYLD shim reordering
  the HID elements of this specific controller) or a virtual device
  (Karabiner) — both rejected as out of scope for this repo.

## Workaround

Remap the controls in-game: **Options → Reassign Controls**, select the
controller as input device, then bind the actions. Every physical input of
the 8BitDo registers in the remap screen (verified), so all actions can be
bound.

Caveats:

- Bindings are stored globally (`keybinding0_0..15` in
  `Contents/Resources/data/save_data.xml`, no per-device key). The custom
  layout then also applies to other controllers, e.g. an Xbox controller
  that worked out of the box before.
- In-game button prompts show the default labels, not the custom physical
  buttons.
- Connect the controller **before** launching — GLFW 2.7 has no hotplug.
- Bluetooth only: wired and 2.4GHz-dongle modes are XInput (not HID) and
  invisible to this game.

Alternative: `NecroDancerMP.app` (Synchrony-era build, ships next to the
base app in the GOG install) links `GameController.framework` and uses the
modern macOS input stack, which supports the 8BitDo natively — no fixed
GLFW layout involved. **Untested** — needs in-game verification.
