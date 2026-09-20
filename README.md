# Asteroid Belt

A fast-paced 2D arcade game built in Godot 4.7 (GDScript). Pilot a small spaceship through a dangerous asteroid belt — dodge or shoot incoming asteroids and survive as long as you can.

## Gameplay

Asteroids continuously spawn and drift toward your ship. You have two ways to stay alive:

- **Dodge** — steer out of the way.
- **Shoot** — blast asteroids apart before they reach you.

Get hit once and it's game over — but restarting is instant, so every run is a chance to beat your previous score. The longer you survive, the busier the asteroid field gets.

## Controls

| Action | Keys |
|---|---|
| Start game (from menu) | Click **START** |
| Move | `W A S D` or Arrow Keys |
| Shoot | `Space` |
| Pause / Resume | `Escape` |
| Restart (on Game Over) | `Enter`, or click **RESTART** |

## Scoring

- **+100** per asteroid destroyed
- **+1 per second** survived (passive trickle)
- A running **best score** for the current session (not yet saved between launches — see *Up next*)

The Pause menu shows your current and highest score. The Game Over screen shows final score, highest score, asteroids destroyed, and time survived.

## Project Status

**MVP complete and playable, including death feedback and sound.** The game runs through a `MENU → PLAYING → PAUSED → GAME_OVER` flow with a themed, resolution-independent UI (Start Screen, Pause Menu, Game Over screen) built from translucent bordered panels over the cockpit artwork, with a cyan → rust shader tint on death. All MVP acceptance criteria (requirements §16) are met.

**Done:**

*Gameplay*
- Movement, shooting with cooldown, 1-hit KO, screen clamping
- Asteroid spawning, off-screen cleanup, bullet-vs-asteroid destruction
- Scoring (kills + survival), session high score, restart flow with full state reset
- Difficulty ramp (spawn interval shrinks with survival time, floored at `spawn_interval_floor`; recomputed once per spawn tick, not every frame)
- Asteroid size/speed variance (bigger = slower, smaller = faster)

*Game feel and audio*
- Death sequence: explosion effect at the ship's position, camera shake, hit-stop (brief near-freeze), then a short delay before the Game Over screen
- Shoot and explosion sound effects (`.ogg`), with slight pitch variation on shots
- Escape is ignored while no run is active (menu / death animation)

*UI*
- Start / Pause / Game Over screens, shared Theme (also set as the project-wide custom theme so the HUD matches), background tint shader
- Review pass: full-rect background, real `Button` nodes, all Quit buttons wired, pause-menu stats, scene-unique node names, `class_name` + static typing across UI scripts, timer no longer auto-starts on the menu
- Restyle pass: translucent bordered `Panel` backdrops, framed title, "stat card" boxes, all driven by Theme Type Variations; spacing from container separation instead of `VSeparator` lines
- Polish pass: aligned anchors, consistent button sizing/flags, clearer node names, `UIManager.show_game_over()` takes no parameters

*Code quality*
- Typed `Asteroid` and `Bullet` classes (`class_name`), no untyped dynamic calls between them
- `Player.reset()` owns the restart state instead of `main.gd` poking at player internals
- `Player` emits `bullet_fired`; `main.gd` decides where bullets live ("call down, signal up")
- `Asteroid.take_hit()` is idempotent (two bullets in one frame can't award score twice)
- Dead code removed (unused `asteroid_hit` signal, unused asteroid speed exports)

**Quick fixes still open:**
- Spawn asteroids from `y = -100` instead of `-30` in `main.gd` so large asteroids don't visibly pop in
- Comment typos and style nits (`game_state.gd`: declare the signal before the variables and add `##` doc comments; header comments for `main.gd` and `hud.gd`)
- Optional: compute the player's start position from the viewport size so it stays at the bottom in tall windows

## Up next

Work is grouped in the recommended build order. Each item is small enough to build and test on its own.

### 1. Persistence and player identity
1. **`SaveSystem` autoload** — one focused autoload that owns everything written to disk (`user://`), using `ConfigFile` or JSON. `GameState` stays runtime-only and asks `SaveSystem` to load/save. Loaded on startup, saved when a run ends or settings change.
2. **Player name entry** — ask for a player name (`LineEdit`, length-limited, trimmed, with a sensible default such as `PILOT`). Asked once on first launch and stored as the player's profile; editable later from the Settings screen. Implemented as a new UI state (e.g. `NAME_ENTRY`) in the existing `UIManager` state machine so the `Main` ⇄ `UIManager` signal contract stays intact.
3. **Persistent high score** — the best score survives closing the game (completes FR-014, currently session-only).
4. **Top 5 scores with player name** — keep a sorted list of the five best runs, each entry `{ name, score }` (optionally asteroids destroyed, survival time and date). A run is inserted only if it makes the top 5. The Game Over screen shows the run's rank ("You placed #2!") and a highlighted **NEW BEST!** when it beats the previous best.
5. **Leaderboard screen** — a *Leaderboard* button on the Start screen opens a panel listing the top 5 (rank, name, score), styled with the existing `StatBox` theme variations. Local-only for now; an online leaderboard would need a backend and is a separate, later decision.

### 2. Settings screen
- Enable the currently disabled **Settings** button and build the screen (same anchors and theme variations as the other panels; new `UIState.SETTINGS`)
- Music and SFX volume sliders (create `Music` and `SFX` audio buses in the Audio tab)
- Screen-shake on/off toggle and fullscreen toggle
- Edit player name (from 1.2) and reset saved scores (with a confirmation step)
- All settings persisted through `SaveSystem` in a separate `settings.cfg`

### 3. Visual polish
- Live scrolling starfield during `PLAYING` (currently a flat clear color) using `Parallax2D`, ideally two layers at different speeds
- Slow random rotation on asteroids and 2–3 asteroid sprite variants
- Muzzle flash, hit flash when an asteroid is destroyed, floating "+100" score popups
- Replace the gradient explosion and other placeholders with real sprites (Kenney.nl)
- Live HUD extras: high score and survival time

### 4. Difficulty and game feel
- Ramp asteroid speed as well as spawn rate (the overview promises "faster and busier")
- Optionally move tuning values into a `DifficultyConfig` `Resource` editable in the Inspector

### 5. Input and UX
- `grab_focus()` on the first button of each screen for keyboard and gamepad menu navigation
- Gamepad bindings on the existing Input Map actions
- Auto-pause when the window loses focus (`NOTIFICATION_APPLICATION_FOCUS_OUT`)
- Background music loop

### 6. Gameplay depth (v2)
- Asteroids that split into smaller ones when shot
- Power-ups (shield, rapid fire, spread shot) and multiple lives
- Score combo multiplier
- A second hazard type (e.g. fast comets)

### 7. Engineering and release
- Unit tests for `GameState`, the difficulty formula and the top-5 insertion logic (GUT or GdUnit4)
- `gdlint` / `gdformat` (gdtoolkit) and a GitHub Actions workflow running them on each push
- macOS export, then a web export published to itch.io
- Optional: rename scene files to `snake_case` (see Naming Conventions)

**Not planned yet:** mobile touch controls, online leaderboard/accounts, multiple enemy AI types, image-based (9-slice) decorative panel frames — panels intentionally use plain `StyleBoxFlat` styling.

## Tech Stack

- **Engine:** Godot 4.7 (GDScript, statically typed)
- **Renderer:** Forward+ (2D game; Mobile also works)
- **Platform used for development:** macOS

## Project Structure

```
res://
├── autoload/
│   └── game_state.gd             # Autoload singleton — score/stats (runtime only)
├── scenes/
│   ├── Main.tscn
│   ├── Player.tscn
│   ├── Bullet.tscn
│   ├── Asteroid.tscn
│   ├── Explosion.tscn            # Self-freeing explosion effect + sound
│   └── ui/
│       ├── HUD.tscn
│       └── UIManager.tscn        # Start / Pause / Game Over screens + background
├── scripts/
│   ├── main.gd                   # Orchestrator: spawning, difficulty, death sequence, restart
│   ├── player.gd                 # class_name Player
│   ├── bullet.gd                 # class_name Bullet
│   ├── asteroid.gd               # class_name Asteroid
│   ├── explosion.gd              # class_name Explosion
│   ├── camera.gd                 # class_name ShakeCamera
│   ├── hud.gd
│   └── ui/
│       ├── ui_manager.gd         # class_name UIManager — state machine
│       ├── pause_menu.gd         # class_name PauseMenu
│       └── game_over_menu.gd     # class_name GameOverMenu
├── assets/
│   ├── sprites/                  # Player/bullet/asteroid art
│   ├── images/                   # UI background, logo
│   ├── fonts/                    # Chakra Petch (Regular, SemiBold, Bold used)
│   ├── shaders/                  # background_tint.gdshader + material
│   ├── themes/                   # ui_theme.tres — shared Theme resource
│   └── audio/                    # shoot.ogg, explosion.ogg
└── project.godot
```

## Architecture Notes

- **Orchestrator pattern ("call down, signal up"):** `Player`, `Bullet` and `Asteroid` only emit signals about themselves (`player_died`, `bullet_fired`, `asteroid_destroyed`). `main.gd` is the sole listener that decides what those events mean for the game.
- **Death sequence:** `Player` emits `player_died` immediately, so `Main` stops scoring and spawning at once. `Main` then spawns an `Explosion` at the ship's position, shakes the camera, applies a short hit-stop (`Engine.time_scale`, with a timer that ignores time scale), waits `game_over_delay`, and finally calls `ui_manager.show_game_over()`. `Engine.time_scale` is reset on startup and on restart.
- **Camera:** `Camera2D` uses **Anchor Mode = Fixed Top Left** at `(0, 0)` so the `expand` stretch layout is unchanged. UI lives on `CanvasLayer`s, so it never shakes.
- **Player owns its state:** `Player.reset(start_position)` restores position, velocity, hitbox monitoring and visibility; `Main` never mutates player internals.
- **GameState autoload:** `autoload/game_state.gd` tracks `score`, `asteroids_destroyed`, `survival_time` and `high_score` as independent stats, accessible from anywhere via `GameState.*`. Persistence is planned to live in a separate `SaveSystem` autoload so runtime state and disk I/O stay decoupled.
- **Collision layers:** `player` (1), `player_bullets` (2), `asteroid` (3), with masks set so bullets never hit the player and asteroids never collide with each other.
- **UI state machine:** `UIManager` (instanced inside `Main.tscn`, `process_mode = ALWAYS`) drives a `MENU / PLAYING / PAUSED / GAME_OVER` enum via `set_ui_state()`, toggling screen visibility, the background, the shader tint (any in-flight tween is cancelled before a new one starts), and `get_tree().paused`. `main.gd` only calls `set_ui_state()` / `show_game_over()` and listens for `game_start_requested` / `restart_requested`. Full contract in `asteroid_belt_ui_spec.md` §5.
- **Typed, decoupled UI scripts:** UI scripts find nodes through scene-unique names (`%NodeName`) rather than long `get_node()` paths, and each screen has its own script and `class_name`.
- **Resolution-independent UI:** `canvas_items` stretch + `expand` aspect (1280×720 base), with every screen positioned by percentage anchors rather than pixel coordinates. All three screens (Start, Pause, Game Over) share the same safe zone: `0.25 / 0.2 / 0.75 / 0.8`, with zero offsets.
- **Gameplay does not auto-start:** the player is inert and `AsteroidSpawnTimer` is stopped (Autostart off) until **START** is pressed.

## UI Theming

All buttons and labels pull from one `Theme` (`assets/themes/ui_theme.tres`, assigned at `UI_Root` and also set as the project-wide custom theme so the HUD matches). Fonts are referenced from the `.ttf` files, never embedded, which keeps the theme file a few KB. Pause and Game Over screens are styled through **Theme Type Variations** — set on a node's *Theme Type Variation* property rather than styled per node:

| Variation | Base type | Used for |
|---|---|---|
| `MenuPanel` | Panel | Pause screen backdrop — translucent dark fill, cyan border, soft cyan glow, diagonal rounded corners |
| `GameOverPanel` | Panel | Game Over backdrop — same shape with a rust border |
| `StatBox` | PanelContainer | Bordered "stat card" wrapping a caption + value pair |
| `TitleBox` | PanelContainer | Title frame with top and bottom borders only (Pause screen) |
| `TitleLabel` | Label | Screen titles (Bold, 44, cyan) |
| `CaptionLabel` | Label | Stat captions (SemiBold, 14, light cyan) |
| `ValueLabel` | Label | Stat values (Bold, 32, white) |

Layout gaps come from each container's **Separation** constant, not from `VSeparator` nodes (which draw a visible line). Buttons are real `Button` nodes styled by the theme's `Button` type; the Settings button is disabled until that screen is built (see *Up next*).

## Naming Conventions

Scripts, folders and assets follow Godot's `snake_case` convention. Scene files (`Main.tscn`, `Player.tscn`, …) are intentionally left PascalCase for now; renaming them is optional. If you do it on macOS, rename from inside the Godot FileSystem dock in two steps (e.g. `Main.tscn` → `main_tmp.tscn` → `main.tscn`), because the default filesystem is case-insensitive.

## Running the Project

1. Install [Godot 4.7](https://godotengine.org/download) (Standard build, not .NET).
2. Clone this repo.
3. Open Godot → **Import** → select the folder containing `project.godot`.
4. Press **F5** to run.

## Credits

Placeholder art/SFX during development — free asset sources (Kenney.nl, OpenGameArt.org). Font: Chakra Petch.
