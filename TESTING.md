# Running the example tests

This project includes [GUT v9.7.1](https://github.com/bitwes/Gut/releases/tag/v9.7.1), matched to Godot 4.7.x. Its editor plugin is enabled, and `.gutconfig.json` points to `tests/`, so the GUT panel can run the tests in the editor.

From the project root in PowerShell, run the clean import once after a fresh checkout, then run the tests:

```powershell
& ..\..\Godot_v4.7.2-stable_win64.exe --headless --path . --import
& ..\..\Godot_v4.7.2-stable_win64.exe --headless --path . -s addons/gut/gut_cmdln.gd -gexit
```

Use your own path to a Godot 4.7 editor on another machine. A passing GUT run exits with code 0; a failing run exits with code 1. [GUT command line guide](https://gut.readthedocs.io/en/latest/Command-Line.html)

`test_movement_math.gd` is a pure function example: it checks input cancellation, forward direction, and diagonal normalization. `test_scenes.gd` loads real PackedScenes: it checks the player wrapper and the mob's initial position and speed. The mob test checks a range because its speed and angle are random.

When adding a gameplay rule, put calculations that can stand alone in a small script and test inputs and outputs there. Add a scene test when behavior depends on nodes, signals, imported assets, or physics. See [TESTING_AND_ASSET_PIPELINE.md](TESTING_AND_ASSET_PIPELINE.md) for the larger game plan.
