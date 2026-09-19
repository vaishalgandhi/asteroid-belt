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
- A running **best score** for the current session (not saved between launches)

The Pause menu shows your current and highest score. The Game Over screen shows final score, highest score, asteroids destroyed, and time survived.

## Project Status

**MVP complete and playable; full UI system implemented, reviewed and cleaned up.** The game runs through a `MENU → PLAYING → PAUSED → GAME_OVER` flow with a themed, resolution-independent UI (Start Screen, Pause Menu, Game Over screen with a cyan → rust shader tint).

**Done:**
- Movement, shooting with cooldown, 1-hit KO, screen clamping
- Asteroid spawning, off-screen cleanup, bullet-vs-asteroid destruction
- Scoring (kills + survival), session high score, restart flow with full state reset
- Difficulty ramp (spawn interval shrinks with survival time, floored at `spawn_interval_floor`)
- Asteroid size/speed variance (bigger = slower, smaller = faster)
- Start / Pause / Game Over screens, shared Theme, background tint shader
- UI review pass: full-rect background, real `Button` nodes, all Quit buttons wired, pause-menu stats, scene-unique node names, `class_name` + static typing across UI scripts, timer no longer auto-starts on the menu

**Up next:**
- Explosion feedback on player death (currently the ship just hides)
- Screen shake / hit-stop on death
- Basic sound effects (`assets/audio/` is empty)
- Optional: live high-score label on the HUD, real sprites in place of placeholders
- Optional cleanup: rename scene files to `snake_case` (see Naming Conventions)

**Deliberately out of scope for now:** persistent high score, multiple lives/power-ups, multiple enemy types, Settings screen (button is present but disabled), mobile controls, live background during play.

## Tech Stack

- **Engine:** Godot 4.7 (GDScript, statically typed)
- **Renderer:** Forward+ (2D game; Mobile also works)
- **Platform used for development:** macOS

## Project Structure

```
res://
├── autoload/
│   └── game_state.gd             # Autoload singleton — score/stats
├── scenes/
│   ├── Main.tscn
│   ├── Player.tscn
│   ├── Bullet.tscn
│   ├── Asteroid.tscn
│   └── ui/
│       ├── HUD.tscn
│       └── UIManager.tscn        # Start / Pause / Game Over screens + background
├── scripts/
│   ├── main.gd                   # Orchestrator: spawning, difficulty, restart
│   ├── player.gd                 # class_name Player
│   ├── bullet.gd
│   ├── asteroid.gd
│   ├── hud.gd
│   └── ui/
│       ├── ui_manager.gd         # class_name UIManager — state machine
│       ├── pause_menu.gd         # class_name PauseMenu
│       └── game_over_menu.gd     # class_name GameOverMenu
├── assets/
│   ├── sprites/                  # Player/bullet/asteroid art
│   ├── images/                   # UI background, logo
│   ├── fonts/                    # Chakra Petch
│   ├── shaders/                  # background_tint.gdshader + material
│   ├── themes/                   # ui_theme.tres — shared Theme resource
│   └── audio/                    # (empty)
└── project.godot
```

## Architecture Notes

- **Orchestrator pattern ("call down, signal up"):** `Player`, `Bullet` and `Asteroid` only emit signals about themselves (`player_died`, `asteroid_destroyed`). `main.gd` is the sole listener that decides what those events mean for the game.
- **GameState autoload:** `autoload/game_state.gd` tracks `score`, `asteroids_destroyed`, `survival_time` and `high_score` as independent stats, accessible from anywhere via `GameState.*`.
- **Collision layers:** `player` (1), `player_bullets` (2), `asteroid` (3), with masks set so bullets never hit the player and asteroids never collide with each other.
- **UI state machine:** `UIManager` (instanced inside `Main.tscn`, `process_mode = ALWAYS`) drives a `MENU / PLAYING / PAUSED / GAME_OVER` enum via `set_ui_state()`, toggling screen visibility, the background, the shader tint (any in-flight tween is cancelled before a new one starts), and `get_tree().paused`. `main.gd` only calls `set_ui_state()` / `show_game_over()` and listens for `game_start_requested` / `restart_requested`. Full contract in `asteroid_belt_ui_spec.md` §5.
- **Typed, decoupled UI scripts:** UI scripts find nodes through scene-unique names (`%NodeName`) rather than long `get_node()` paths, and each screen has its own script and `class_name`.
- **Resolution-independent UI:** `canvas_items` stretch + `expand` aspect (1280×720 base), with every screen positioned by percentage anchors rather than pixel coordinates.
- **Shared Theme resource:** all buttons/labels pull from one `Theme` (`assets/themes/ui_theme.tres`) assigned at `UI_Root`.
- **Gameplay does not auto-start:** the player is inert and `AsteroidSpawnTimer` is stopped (Autostart off) until **START** is pressed.

## Naming Conventions

Scripts, folders and assets follow Godot's `snake_case` convention. Scene files (`Main.tscn`, `Player.tscn`, …) are still PascalCase and are slated for renaming. On macOS, rename them from inside the Godot FileSystem dock in two steps (e.g. `Main.tscn` → `main_tmp.tscn` → `main.tscn`), because the default filesystem is case-insensitive.

## Running the Project

1. Install [Godot 4.7](https://godotengine.org/download) (Standard build, not .NET).
2. Clone this repo.
3. Open Godot → **Import** → select the folder containing `project.godot`.
4. Press **F5** to run.

## Credits

Placeholder art/SFX during development — free asset sources (Kenney.nl, OpenGameArt.org). Font: Chakra Petch.
