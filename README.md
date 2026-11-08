# Vector Runner for PICO-8

A faithful, independently implemented remake of the classic Flash game *Vector Runner* as a PICO-8 cartridge for the Anbernic CubeXX running MustardOS.

## Goal and design

Recreate the low-resolution wireframe look with PICO-8's 128×128 display and 16-color palette. Use a compact fake-3D projection: project world-space coordinates onto the screen with perspective scaling rather than building a full 3D engine.

The game should include:

- A scrolling perspective road with road edges and a grid advancing toward the player.
- Wireframe obstacles spawned ahead and moved toward the camera.
- Left/right steering on the CubeXX D-pad, with collision checks in world space.
- Scoring and progressive acceleration.
- Original-style obstacle patterns and power-ups as gameplay develops.

## Development and delivery

Prototype and test in desktop PICO-8. Keep the cartridge within PICO-8's 8,192-token code limit and avoid unsupported features where compatibility with PICO-8 substitutes is needed.

The release artifact is `vector_runner_pico8.p8.png`, exported from PICO-8 with `save vector_runner_pico8.p8.png`. Test it on the CubeXX using MustardOS's PICO-8-compatible runtime by placing it in the device's PICO-8 ROM folder and launching it there.

## Build status

`vector_runner_pico8.p8` is now an independently authored, editable PICO-8
source cartridge. It uses only standard Lua and PICO-8 drawing/input/audio
APIs: `btn`, `line`, `print`, `sfx`, tables, and numeric helpers. It implements
the scrolling projected grid, wireframe barriers, three-lane patterns, diamond
power-ups (yellow score, green shield repair, purple temporary invincibility),
world-space steering/collision, score, acceleration, title, restart, and
best-score flow. A blue EMP mine briefly disrupts the depth view, and the
projection gradually zooms as velocity rises. These are independent mechanics,
not copied assets or code.

Controls: left/right D-pad steer; either O or X starts and restarts; X pauses
and resumes during a run without affecting score. The earlier 2007 build had a
pause penalty, but the developer later said it was removed; this cartridge
follows the later release. The player ship stays centred visually while its
world-space lateral coordinate is used for road projection and collision checks.

The licensed official PICO-8 v0.2.7 macOS package is available locally. macOS
Gatekeeper must be approved once (Control-click `PICO-8.app`, choose **Open**,
then confirm) before its headless exporter can be used. Once approved, export
with `PICO8_BIN=/path/to/pico8 make export-png`; it refuses to overwrite an
existing PNG. Copy the result to the device runtime's PICO-8 ROM folder. The
PNG has not yet been produced, and this cartridge has not yet been tested on a
CubeXX/MustardOS device.

## Development checks

Run `make test` to execute the deterministic host-Lua behavior suite. It loads
the cartridge's `__lua__` section, expands only PICO-8's `+=`/`-=` syntax, and
provides a deliberately small shim for the APIs used by the game. It covers
start flow, bounded steering, pause score preservation, all three pickup effects, EMP, shield/invincibility
collision behavior, game-over, drawing, and sound-event calls.

For handheld-compatibility smoke checks, an MIT-licensed `tac08` runtime was
built locally from source; it successfully stayed running with this cartridge
for a headless launch. Its binary is intentionally ignored under `tools/bin/`.
The project follows the useful testing practices of the MIT-licensed
[PicoTestDriver](https://github.com/adamico/picotestdriver)—named scenarios,
deterministic inputs, and bounded checks—but includes no third-party test code.
The project keeps production code in one cartridge file for normal PICO-8 and
FAKE-08 compatibility, with host-only verification isolated in `scripts/`.

## Provenance status

The user referenced a starter `vector_runner_pico8.p8` attachment from a separate ChatGPT conversation. That attachment and its download link were not available in the accessible conversation archive or common local download folders when this repository was created. Do not claim to have retrieved, tested, or incorporated it. If it becomes available, inspect and test it before deciding whether to build on it; otherwise implement the cartridge from scratch and identify that provenance honestly.

No original Flash/ActionScript source has been retrieved or used. On 2026-11-08,
the public [Newgrounds](https://www.newgrounds.com/portal/view/412588) player
was opened in a normal browser and Ruffle reported that it could not load the
hosted SWF because the file no longer exists. The page's author comments and
public reviews document steering, score pickups, shield recharge,
invincibility, an EMP mine that disrupts vision, and progressive speed/camera
zoom. The page preserves an earlier 250-point pause-cost note, while the later
[Kongregate release](https://www.kongregate.com/en/games/digyourowngrave/vector-runner)
says it was recoded in AS3 and its developer comment says that penalty was
removed; the cartridge follows the later behavior. Flashpoint's catalog and
[release notes](https://flashpointarchive.org/news/2021051000) confirm preserved
compiled copies, including an older variant, but no editable author source has
been found or used. No original art, audio, code, or assets are included here.

On 2026-11-08, Flashpoint's public search API identified the preserved entry as
`7c449d9d-3dd5-4b2d-915f-db90481cc358` (version 1.8) and disclosed archived
original-site and Kongregate SWF paths. The archive returned valid SWF metadata
(including MIME type and byte lengths), but this environment's web filter denied
the binary GET requests; the files were therefore not downloaded, inspected, or
used. Flashpoint's 9o3o browser player currently falls back to the dead original
URL and likewise cannot load this title. This is evidence that compiled copies
are preserved, not evidence that authoring source is public.

## Rights

This is an independent remake, not an automatic conversion or redistribution of the original Flash source or assets. Keep any use or distribution of original material within the rights granted by its creator.
