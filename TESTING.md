# Run the example tests

This project includes [GUT v9.7.1](https://github.com/bitwes/Gut/releases/tag/v9.7.1) for Godot 4.7.x. Test files are in `tests/`; `.gutconfig.json` tells the command line runner where to find them.

## From a Windows command line

Open **PowerShell** or the VS Code terminal. Change to the folder containing `project.godot`:

```powershell
Set-Location 'C:\GameDesign\Godot\test_01\3d_squash_the_creeps_starter'
```

After a fresh clone, or after changing imported assets, run Godot's import step:

```powershell
& ..\..\Godot_v4.7.2-stable_win64.exe --headless --path . --import
```

Then run all tests:

```powershell
& ..\..\Godot_v4.7.2-stable_win64.exe --headless --path . -s addons/gut/gut_cmdln.gd -gexit
$LASTEXITCODE
```

The `&` tells PowerShell to run the executable. The `..\..\` path reaches the Godot executable two folders above this project; `--path .` selects the current project. `--headless` runs without opening a window. `-s addons/gut/gut_cmdln.gd` starts GUT's command line runner. GUT reads `.gutconfig.json` to find `res://tests`; `-gexit` closes Godot when the run finishes. If Godot is installed elsewhere, replace the executable path with yours. [GUT command line reference](https://gut.readthedocs.io/en/latest/Command-Line.html)

You should see **2 scripts, 6 tests, 6 passing tests** and `All tests passed!`; `$LASTEXITCODE` should print `0`. A failed test should produce a nonzero exit code. Also check that both scripts and all expected tests were collected: a syntax error in a test file can cause GUT to skip that file while the remaining tests pass. The commands work from a terminal; they do not require opening the Godot editor GUI.

To run only the scene test file, disable the shared directory configuration for that run and name the file explicitly:

```powershell
& ..\..\Godot_v4.7.2-stable_win64.exe --headless --path . -s addons/gut/gut_cmdln.gd -gconfig= -gtest=res://tests/test_scenes.gd -gexit
```

This should report **1 script, 2 tests**. Without `-gconfig=`, GUT also loads the two files listed through `.gutconfig.json`.

## From the Godot editor

Open the project in Godot. **GUT** is a tab in the editor's bottom panel. Select it, open the panel's **Settings**, add `res://tests` as a test directory if it is not already there, then click **Run All**. The panel shows test names and results. It saves its own editor settings, so the CLI's `.gutconfig.json` does not automatically configure this panel. If you do not see the tab, check **Project → Project Settings → Plugins** and enable GUT. The [GUT quick start](https://gut.readthedocs.io/en/v9.5.0/Quick-Start.html) shows the panel and its run controls.

This panel is a **Godot editor GUI**, separate from Visual Studio's Test Explorer. The project does not currently install an IDE test integration. An optional [GUT Tools extension for VS Code](https://github.com/bitwes/gut-extension) provides commands to run all tests, the current file, or a test at the cursor from VS Code. The command line above is the common path that works in any editor and in CI.

### Make the results easier to read

If **Run All** opens a small separate Godot window and you only need the results, click the GUT panel's **Run Mode** button (it shows `ExB` or `ExN` for external runs). Choose **Externally - NonBlocking**, put `--headless` in **Additional Arguments**, then save. The run will have no game window and its output will appear in the GUT panel; expand that dock or pop it into its own editor window. **In Editor** uses Godot's normal Play/debugger path and may still create a game window, depending on the editor's game embedding settings. GUT's external Blocking mode does not support `--headless`.

To keep external runs but start with a larger Godot window, open **Run Mode** and put `--resolution 1600x900` or `--maximized` in **Additional Arguments**, then save and run again. These are Godot window options for that test launch; they do not change the game's project-wide resolution. [Godot command line display options](https://docs.godotengine.org/en/4.6/tutorials/editor/command_line_tutorial.html)

The external **GUT result overlay has its own size**. Enlarging the Godot window gives it more room but does not automatically enlarge the overlay. Drag the diagonal grips at the bottom corners of the overlay to make the output area wider and taller. In the GUT panel's **Settings → Runner Appearance**, increase **Font Size** if the text itself is too small; the default is 16. The overlay's text area grows when you resize the overlay.

## What the examples test

- `test_movement_math.gd` calls a pure function: no input, opposite inputs, forward direction, and diagonal normalization.
- `test_scenes.gd` instantiates real `PackedScene` resources: it checks the player wrapper and the mob's initial position and bounded speed. The mob test checks a range because its speed and angle are random.

When adding a gameplay rule, put calculations that can stand alone in a small script and test their inputs and outputs. Add a scene test when behavior depends on nodes, signals, imported assets, or physics. See [TESTING_AND_ASSET_PIPELINE.md](TESTING_AND_ASSET_PIPELINE.md) for the larger game plan.

## What are `.gd.uid` files?

Godot generates a small `.gd.uid` file next to each GDScript file. It contains that script's stable resource ID, such as `uid://...`, so scene and resource references can keep pointing to the same script when files move or are renamed. The GUT add-on includes many of them because it contains many scripts. **Commit `.gd.uid` files with their matching `.gd` files**; do not add them to `.gitignore` or edit their IDs by hand. If you move or remove a script outside the Godot editor, move or remove its `.gd.uid` file with it. [Godot's explanation of script UIDs](https://godotengine.org/article/uid-changes-coming-to-godot-4-4/)
