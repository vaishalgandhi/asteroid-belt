# Asteroid Belt

A fast-paced 2D arcade game built in Godot 4.x. Pilot a small spaceship through a dangerous asteroid belt — dodge or shoot incoming asteroids and survive as long as you can.

## Gameplay

Asteroids continuously spawn and drift toward your ship. You have two ways to stay alive:

- **Dodge** — steer out of the way.
- **Shoot** — blast asteroids apart before they reach you.

Get hit once and it's game over — but restarting is instant, so every run is a chance to beat your previous score. The longer you survive, the more the asteroid field ramps up.

## Controls

| Action | Keys |
|---|---|
| Start game (from menu) | Click **START**, or `Enter`/`Space` on the focused button |
| Move | `W A S D` or Arrow Keys |
| Shoot | `Space` |
| Pause / Resume | `Escape` |
| Restart (on Game Over) | `Enter`, or click **RESTART** |

## Scoring

- **+100** per asteroid destroyed
- **+1 per second** survived (passive trickle)
- A running **best score** for the current session

The Game Over screen shows your final score, asteroids destroyed, and time survived.

## Project Status

**MVP complete and playable, full UI system implemented.** Core loop (movement, shooting, spawning, collision, scoring, difficulty ramp, restart) is done, and the game now runs through a full `MENU → PLAYING → PAUSED → GAME_OVER` flow with a themed, resolution-independent UI (Start Screen, Pause Menu, Game Over screen with a rust-tint shader transition) rather than auto-starting into gameplay.

**Done since the original MVP:**
- Difficulty ramp (asteroid spawn rate increases with survival time, floored at `spawn_interval_floor`)
- Asteroid size/speed variance (bigger = slower, smaller = faster, randomized per spawn)
- Start Screen, Pause Menu, and Game Over screen, all themed and resolution-independent
- Background shader tint (cyan → rust) on death

**In progress / up next:**
- Explosion feedback on death
- Screen shake on death
- Basic sound effects
- Settings screen (button exists, not yet wired)

## Tech Stack

- **Engine:** Godot 4.7 (GDScript)
- **Renderer:** Forward+ / Mobile (2D)

## Project Structure

```
res://
├── scenes/
│   ├── Main.tscn
│   ├── Player.tscn
│   ├── Bullet.tscn
│   ├── Asteroid.tscn
│   └── ui/
│       ├── HUD.tscn
│       └── UIManager.tscn        # Start / Pause / Game Over state machine
├── scripts/
│   ├── player.gd
│   ├── bullet.gd
│   ├── asteroid.gd
│   ├── main.gd
│   ├── game_state.gd             # Autoload singleton — score/stats
│   ├── hud.gd
│   └── ui/
│       ├── ui_manager.gd         # MENU/PLAYING/PAUSED/GAME_OVER state machine
│       └── game_over_menu.gd     # Game Over stat display + restart signal
├── assets/
│   ├── sprites/                  # Player/bullet/asteroid art
│   ├── images/                   # UI background, logo
│   ├── fonts/                    # Chakra Petch
│   ├── shaders/                  # background_tint.gdshader + material
│   ├── themes/                   # ui_theme.tres — shared Theme resource
│   └── audio/
└── project.godot
```

## Architecture Notes

- **Orchestrator pattern:** `Player`, `Bullet`, and `Asteroid` only emit signals about themselves (`player_died`, `asteroid_destroyed`, etc.). `main.gd` is the sole listener that decides what those events mean for the game as a whole — gameplay nodes never manage global state directly.
- **GameState autoload:** a singleton (`scripts/game_state.gd`) tracks `score`, `asteroids_destroyed`, `survival_time`, and `high_score` as independent stats, accessible from any node via `GameState.*`.
- **Collision layers:** `player` (1), `player_bullets` (2), `asteroids` (3) — deliberately separated to avoid cross-collisions (e.g. bullets damaging the player).
- **UI state machine:** `UIManager` (instanced inside `Main.tscn`) drives a `MENU / PLAYING / PAUSED / GAME_OVER` enum via `set_ui_state()`, toggling which screen is visible, whether the background frame is shown, the shader's cyan→rust tint, and `get_tree().paused`. Same orchestrator philosophy as gameplay: `main.gd` never reaches into `UIManager`'s internal screens directly — it only calls `set_ui_state()` / `show_game_over()` and listens for `game_start_requested` / `restart_requested` signals. Full contract documented in `asteroid_belt_ui_spec.md` §5.
- **Resolution-independent UI:** `canvas_items` stretch mode + `expand` aspect (Project Settings), with every UI screen positioned via percentage-based anchors rather than fixed pixel coordinates, so layout holds up across different desktop window sizes. Details in `asteroid_belt_ui_spec.md` §2.
- **Shared Theme resource:** all buttons/labels across every screen pull from one `Theme` (`assets/themes/ui_theme.tres`) assigned at `UI_Root`, rather than per-screen styling.

## Running the Project

1. Install [Godot 4.7](https://godotengine.org/download) (Standard build, not .NET).
2. Clone this repo.
3. Open Godot → **Import** → select the project folder (the one containing `project.godot`).
4. Press **F5** to run.

## Credits

Placeholder art/SFX during development — free asset sources (Kenney.nl, OpenGameArt.org).
