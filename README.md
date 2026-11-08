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

## Prototype status

The user referenced a starter `vector_runner_pico8.p8` attachment from a separate ChatGPT conversation. That attachment and its download link were not available in the accessible conversation archive or common local download folders when this repository was created. Do not claim to have retrieved, tested, or incorporated it. If it becomes available, inspect and test it before deciding whether to build on it; otherwise implement the cartridge from scratch and identify that provenance honestly.

## Rights

This is an independent remake, not an automatic conversion or redistribution of the original Flash source or assets. Keep any use or distribution of original material within the rights granted by its creator.
