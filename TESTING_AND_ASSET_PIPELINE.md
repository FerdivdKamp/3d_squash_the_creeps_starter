# A testing and asset pipeline for 3D Godot games

This is a working proposal for growing this tutorial project into a larger game made with Godot, Blender, Git, and possibly a second developer. A tower defense game and a kart racer need different gameplay tests, but they benefit from the same structure: small logic tests, scene tests, repeatable visual reviews, and a reliable asset import path.

## Start with what this project already has

`player.tscn` and `mob.tscn` are useful examples of the right boundary. Each is a Godot gameplay scene with a script, collision shape, and a child instance of an imported `.glb` model. Keep that pattern as the project grows: **Blender owns meshes, skeletons, and source animations; Godot owns gameplay, collision, camera, UI, effects, and scene composition.** The current `main.tscn` is a small world in which to try those pieces together.

The repository contains both `.blend` sources and `.glb` exports. Direct Blender import is disabled in `project.godot`, so `.glb` is currently the runtime input. This is a reasonable team default: everyone can import the game without installing or configuring Blender. Keep the `.blend` file as the editable source and export its matching `.glb` when it changes. Do not hand edit imported nodes: put overrides in a wrapper or inherited Godot scene. Godot documents glTF 2.0 as its recommended 3D interchange format and explains the tradeoff between `.glb` export and direct `.blend` import. [Godot 3D formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html)

GUT v9.7.1 and six starter tests are now installed; see [TESTING.md](TESTING.md) for the runnable commands. Dedicated visual review scenes and recording tools remain proposed work.

## A practical test ladder

| Layer | What to test | Example in this project | Larger game example | When to run |
| --- | --- | --- | --- | --- |
| Pure logic | Inputs and outputs without a scene tree | Extract direction or speed calculation from `player.gd` or `mob.gd` | Tower range, damage, wave schedules; kart lap order, checkpoint validation, race standings | Every commit |
| Component scene | One scene with its real child nodes and signals | Instantiate `player.tscn` and `mob.tscn`; check required nodes, collision shape, spawn state, cleanup signal | Tower acquires a target; kart suspension and animation controller respond to state | Every commit |
| Small world | A few components interacting in a controlled arena | Spawn player and mob above a test floor, advance physics frames, verify movement and collision | Projectile hits an enemy; kart passes checkpoints and completes a lap | Every commit or pull request |
| Full flow | Menus, transitions, save data, and gameplay start | Start from a future title menu and enter `main.tscn` | Select a tower map or kart, race, return to results | Pull request / release candidate |
| Visual and feel review | Appearance, rig deformation, timing, camera, and controls | Inspect the imported player/mob from several angles | Tower attacks under VFX load; kart steering, drift, wheels, camera | After relevant changes |

Keep the bottom layers fast and deterministic. A video or screenshot is evidence for human review, not a substitute for assertions about state. Likewise, a headless test can verify that an animation exists and advances, but it cannot reliably judge whether skinning looks good or steering *feels* right.

### Unit tests for functions and classes

This project uses **GUT v9.7.1**, matched to Godot 4.7. Pin a release that explicitly supports the Godot version used by the team; GUT publishes a version compatibility table. Avoid blindly installing the latest plugin when upgrading the engine. GUT supports command line runs and JUnit reports for CI. [GUT repository and compatibility table](https://github.com/bitwes/Gut)

Write pure functions for rules that can be separated from nodes. For example, extract the direction calculation from `player.gd` into a small function that accepts four booleans or a `Vector2`. Test zero input, diagonals (normalized), and opposite keys. For `mob.gd`, test a speed selection function with an injected random value or seeded random generator; don't test that one random run happens to choose a specific speed. In a tower defense game, make damage, targeting priority, costs, upgrades, and wave definitions testable without loading the arena. In a kart racer, isolate lap validity, checkpoint order, countdown rules, and scoring from vehicle physics.

Keep tests focused on behavior. Avoid tests that merely repeat an implementation expression. A good regression test names a failure a player could notice, such as “diagonal movement is no faster than straight movement” or “crossing the finish line without the final checkpoint does not increment the lap.”

### Scene and integration tests

Load a `PackedScene`, instantiate it in a test scene tree, then check its public behavior. Assert that expected child nodes, signals, collision shapes, animation names, and exported configuration exist. Advance real physics frames for movement tests; place bodies on a simple floor so `is_on_floor()` and `move_and_slide()` run under realistic conditions. Clean up spawned nodes and reset global input, time scale, autoload state, and RNG between tests.

Useful first checks here:

- `player.tscn` instantiates, has a `Pivot` and collision shape, and moves roughly `speed × elapsed_time` on a flat floor, allowing a tolerance for physics steps.
- `mob.tscn` instantiates, and `initialize(start_position, player_position)` puts it near the start position with a horizontal speed within `minimal_speed` and `maximum_speed`.
- A mob leaving the visible area is freed after the notifier emits its exit signal. Test this through the signal or a tiny rendered scene; a headless run may not provide meaningful visibility behavior.
- Imported player and mob scenes contain the expected mesh/skeleton/animation structure once those assets actually have rigs and clips.

In a larger game, make tiny fixtures: a one tower/one enemy lane; a short kart track with three checkpoints; a save/load fixture with temporary data; a menu fixture with a fake profile. A small fixture makes failures easier to diagnose than loading the entire game. For physics tests, set up known initial transforms and speeds and assert broad outcomes rather than exact floating point coordinates on every frame.

Run the import pass before headless tests on a fresh checkout because `.godot/` is generated and should not be committed. Godot provides `--import`, `--headless`, and direct scene execution from the command line. For example (replace `godot` with the path to your pinned editor binary): [Godot command line reference](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)

```sh
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gexit
godot --path . res://test_scenes/character_lab.tscn
```

The commands above use `godot` as a generic executable name. On this Windows machine, the installed editor is `..\..\Godot_v4.7.2-stable_win64.exe` relative to the project root, so the first command in PowerShell is `& ..\..\Godot_v4.7.2-stable_win64.exe --headless --path . --import`. Keep the editor binary outside the repository: each developer and CI runner can install the pinned version locally without committing a large platform-specific executable. A local `GODOT_EXE` variable or wrapper script can make the commands convenient on different machines. [TESTING.md](TESTING.md) records the exact commands for this machine. Keep local and CI checks equivalent. Inspect the process exit code, test report, number of collected tests, and import/parse errors: GUT can report a passing run when an invalid test script was skipped during collection.

## A character and vehicle review scene

Build `test_scenes/character_lab.tscn` as a **developer tool scene**, not a production menu. It should be runnable directly from Godot and from a command line. The same design can become `vehicle_lab.tscn` for karts or `unit_lab.tscn` for towers and enemies.

Suggested controls:

| Control | Purpose |
| --- | --- |
| Asset dropdown | Select a registered character, mob, tower, or kart scene. Populate it from an explicit list of `PackedScene` resources so renamed paths fail clearly. |
| Animation dropdown | Read the selected instance's `AnimationPlayer` libraries; show available clips and missing expected clips. |
| State controls | Trigger idle, move, jump, attack, hit, death, drift, or wheel turn through the same public controller methods the game uses. |
| Movement controls | Drive the real controller with recorded inputs or a scripted path; display speed, grounded state, steering, and animation state. |
| View controls | Orbit camera, fixed front/side/back views, grid, scale marker, optional wireframe/bone markers, light preset, and slow motion. |
| Reset button | Restore transform, animation, RNG seed, and input state, so comparisons start from the same state. |
| Record button/preset | Run a fixed review sequence with visible asset/version label and known duration. |

For rig review, include poses that expose shoulders, elbows, hips, feet, wheel pivots, and any mesh seams. For movement review, use a floor, ramp, slope, step, and collision target. Keep the imported visual scene separate from the `CharacterBody3D`/`RigidBody3D` wrapper so a rig can be swapped without rebuilding gameplay. Use the same animation state machine as gameplay where possible; a raw clip preview alone misses transition and blending defects. Godot's `AnimationTree` controls animations held by an `AnimationPlayer`, and the docs explain `RESET` tracks for consistent blending. [Godot AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html)

For tower defense, add a `combat_lab.tscn`: choose tower/enemy types, toggle target priority, spawn one or many enemies, and show range, target, health, damage events, and projectile paths. For kart racing, add `vehicle_lab.tscn`: choose chassis and driver, then run launch, brake, reverse, steering, drift, jump/landing, and checkpoint sequences. Add a separate `menu_lab.tscn` for keyboard, mouse, and controller navigation, focus indicators, resolution changes, and return/back flows. Keep these labs under version control because they are executable specifications of how an asset or feature should behave.

## Can I record a video for review?

Yes, **when this workspace has a runnable Godot editor with graphics access**. I can build a deterministic review scene, run the scripted sequence, capture output, inspect representative frames, and attach a video or frame sequence for a reviewer. The Godot executable is available two directories above this project even though `godot` is not on `PATH`. No capture has been run yet, and Blender's executable location has not been checked.

Godot's Movie Maker can write an AVI or a PNG image sequence at a fixed frame rate; its command line supports `--write-movie`, `--fixed-fps`, and `--quit-after`. For example, after setting up a 10 second scripted review sequence at 30 fps:

```sh
godot --path . --scene res://test_scenes/character_lab.tscn --write-movie review.avi --fixed-fps 30 --quit-after 300
```

Run capture with a graphical display/rendering environment. A normal headless CI job is suitable for assertions and imports, not a trustworthy visual review. Convert the AVI to a small MP4 for easy sharing if the team has a video tool available; retain the original or selected PNG frames when visual fidelity matters. Make the script set the asset, camera, animations, inputs, seed, and duration automatically. Show a label containing the Git commit, asset name, and clip/state in the video. Reviewers can then compare two recordings or request a specific correction. Godot documents Movie Maker's output formats and capture behavior. [Godot creating movies](https://docs.godotengine.org/en/stable/tutorials/animation/creating_movies.html)

Store review clips as CI artifacts or in a release/review folder with a clear retention policy; don't commit every large video to Git. A short human review checklist should cover proportions, clipping, feet or wheels contacting the ground, orientation, timing, camera motion, materials, and UI readability. For important assets, keep a few approved reference frames. Image comparison can flag large changes, but renderer and driver differences make exact pixel equality a poor universal gate.

## Blender → Godot asset contract

Agree on a short contract before making many assets:

1. **Source and export:** one editable `.blend` source per asset or related set, one named `.glb` export at a stable path, with a documented export preset. Commit both for the current workflow. When using direct `.blend` import instead, choose it deliberately for the whole team and ensure Blender is available on every build machine. Godot's `.blend` import calls Blender to export glTF internally. [Godot 3D formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html)
2. **Scale and orientation:** define meters, origin/pivot, and facing direction for each asset class. Check the model at the intended in game size in the review scene. Godot uses Y up; its model front convention is +Z, while camera forward is -Z. Keep motion and look direction conventions explicit in controllers. [Godot model export considerations](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/model_export_considerations.html)
3. **Rig and clips:** use stable bone, skeleton, material, and animation names. Record expected clips in a small asset manifest, for example `idle`, `run`, `turn`, `attack`, `hit`, `death`, or `steer`, `drift`, `suspension`. Check rest pose, deformations, looping, root motion choice, and transitions in the lab scene. Blender's glTF exporter only exports actions linked according to its animation export mode; verify the exported GLB in Godot, not just in Blender. [Blender glTF exporter manual](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html)
4. **Materials and geometry:** check texture paths, normals, UVs, transparency, material count, triangle count, and visible backfaces. Apply the intended transforms and triangulate predictably before export. Put gameplay lights in Godot. [Godot model export considerations](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/model_export_considerations.html)
5. **Import settings:** commit the source asset and its `.import` settings when they affect behavior. Use Godot's Advanced Import Settings to inspect animation clips, extract materials or animations where needed, and avoid editing the generated imported scene directly. [Godot advanced import settings](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/advanced_import_settings.html)
6. **Collision and gameplay sockets:** keep collision shapes and gameplay attachment points in the Godot wrapper unless a specific imported helper convention is agreed. For karts, verify wheel origins and steering axes; for towers, verify muzzle and pivot positions; for characters, verify hand/weapon attachment and hitbox positions.

An automated asset audit can open every registered GLB after import and report missing animation names, missing skeletons, zero size meshes, unexpectedly large bounding boxes, and broken scene paths. Treat numeric budgets as warnings first, then tighten them when target hardware and art style are known.

### Script the Blender export

Yes: a checked in Blender Python exporter is a strong next step for a larger project. Blender can run a `.blend` file in background mode and call `bpy.ops.export_scene.gltf()` with explicit settings, producing the `.glb` files Godot consumes. This makes the export repeatable for both artists and CI. Pin Blender's version because exporter options and animation behavior can change between versions. [Blender glTF export operator](https://docs.blender.org/api/current/bpy.ops.export_scene.html), [Blender glTF animation behavior](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html)

Use **one export script with asset type profiles**, rather than copying slightly different scripts for each model. An asset manifest can map each source to its profile, output path, required clips, and optional budgets:

```text
art/player.blend -> character -> art/player.glb -> idle, run, jump
art/mob.blend    -> character -> art/mob.glb    -> idle, move, hit
art/kart.blend   -> vehicle   -> art/kart.glb   -> steer, wheel_spin
art/tower.blend  -> tower     -> art/tower.glb  -> idle, fire
```

Those clip names are **future contract examples**; the tutorial assets do not yet promise them. A `prop` profile could export selected collections with no animations; a `character` profile could include armature, skins, shape keys, and linked actions; a `vehicle` profile could validate wheel origins and named pivot objects. Profiles should set GLB format, object selection/collection, animation mode, inclusion of cameras/lights, and any texture policy explicitly. Avoid depending on whatever values happened to be last used in Blender's export dialog. For animated assets, the script should verify that intended actions are active or stashed appropriately for the selected glTF animation mode; otherwise a valid GLB can silently omit clips. [Blender glTF exporter manual](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html)

The export sequence should be: load source `.blend` → validate naming, scale, origin, armature, materials, and required actions → export to a temporary `.glb` → verify the result exists and is nonempty → replace the expected output → run Godot's clean import and asset audit. Fail with a nonzero exit code and an asset specific message on validation or export errors. A typical invocation is:

```sh
blender --background art/player.blend --python-exit-code 1 --python tools/export_asset.py -- --profile character --output art/player.glb
```

The `--` separates arguments passed to the Python script; `--python-exit-code 1` makes Python exceptions fail the command for CI. [Blender command line arguments](https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html) Build a small local wrapper for Windows or macOS that points to each developer's Blender executable; keep the binary outside Git. In CI, re export and compare the generated assets with the committed `.glb` files to catch stale exports. Binary files may differ across Blender versions or exporter changes, so pin versions and investigate meaningful import differences rather than assuming any byte change means a broken asset. The script can also produce a compact JSON report of object names, bounds, triangle counts, materials, bones, and animations for pull request review.

## Git and two person collaboration

- Pin the exact Godot version and Blender version in `README.md`; keep a short upgrade branch and run a clean import/test pass before both developers switch. Pin the test plugin version too. Keep editor executables outside Git. This repository currently tracks `.vscode/settings.json` with an absolute path to this computer's Godot executable; make that path a local setting or document how each collaborator configures their own editor path.
- Ignore `.godot/` and temporary outputs; commit `.gd`, `.tscn`, `.tres`, `.gd.uid`, source assets, exported assets chosen by the pipeline, and relevant `.import` metadata. The current `.gitignore` already excludes `.godot/*` and `*.tmp`. Godot's version control guide explains generated files and Windows line ending behavior. [Godot version control guide](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html)
- Add `.gitattributes` for consistent text line endings. Consider Git LFS **before** large binary assets accumulate (`.blend`, `.glb`, high resolution textures, audio). Check hosting storage quotas and ensure both developers install Git LFS before pulling. Keep text Godot scenes/resources in regular Git for readable diffs. [Godot Git LFS guidance](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html)
- Give scenes and assets stable names and paths. Avoid both people editing the same large `.tscn` or `.blend` simultaneously. Prefer scene composition: each person can own a unit, vehicle, map section, UI screen, or fixture. Use short branches and pull requests with a clear demo or capture for visual changes.
- Review a change with three questions: Did a clean import succeed? Did relevant automated tests pass? Can another person inspect the changed behavior in a small scene or recording? List intended behavior and any known limitations in the pull request.
- Run CI on pull requests: checkout with LFS, install the pinned Godot editor, import from scratch, run tests, and optionally perform a debug export. Run graphical capture on a machine with a renderer only for changes that need visual review, or schedule it as a separate job. Archive reports, logs, and short clips with the commit identifier.

## Suggested first implementation order

1. Write a one page team `README` with engine/Blender versions and how to open the project. Add a small Blender Python exporter for the existing player and mob assets, then add `.gitattributes` and decide on LFS before more art arrives.
2. Extend the installed GUT examples with the next gameplay rule and scene behavior. Keep the clean import and test commands working locally and in CI.
3. Build the asset dropdown scene for player and mob, with orbit camera, animation list, reset, and a scripted movement sequence. It is useful even before the models have full rigs.
4. Add one vertical slice fixture for the chosen game: one tower and one enemy path, or one kart and three checkpoints. Assert one complete success/failure path.
5. Add CI and a repeatable 5–15 second recording preset. Ask a second person to run the project from a fresh clone and review the recording; fix every undocumented setup step they encounter.

This order makes the workflow valuable at tutorial scale while establishing the same boundaries needed for a larger production game.
