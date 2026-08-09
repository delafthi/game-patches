# Disable Steam Input

Disabling Steam Input fixes Unrailed! (Indoor Astronaut) not recognising
controllers. Steam Input virtualises every controller to a generic
`Microsoft GamePad-N` device; Unrailed!'s input layer does not match those
virtual names, so the controller does nothing in-game. Steam Input is the
default per-game setting.

## Workaround

Disable Steam Input for the game:

Steam → Library → right-click *Unrailed!* → **Properties** → **Controller** →
**Disable Steam Input**.

The controller is then seen under its raw device name (e.g.
`8BitDo Ultimate 2 Wireless`) and works normally. This is a manual Steam
setting, not something a patch can apply — hence no patch payload in this
directory.
