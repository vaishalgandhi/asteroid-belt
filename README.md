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
| Move | `W A S D` or Arrow Keys |
| Shoot | `Space` |
| Restart (on Game Over) | `Enter` |

## Scoring

- **+100** per asteroid destroyed
- **+1 per second** survived (passive trickle)
- A running **best score** for the current session

The Game Over screen shows your final score, asteroids destroyed, and time survived.

## Project Status

**MVP complete and playable** — full core loop working: movement, shooting, asteroid spawning, collision, scoring, Game Over, and restart.

**In progress / up next:**
- Difficulty ramp (spawn rate increases over time)
- Asteroid size/speed variance
- Explosion feedback on death
- Screen shake on death
- Basic sound effects

See `development-phase-1-session-notes.md` for detailed dev-session history and next steps.

## Tech Stack

- **Engine:** Godot 4.x (GDScript)
- **Renderer:** Forward+ / Mobile (2D)

## Project Structure

```
res://
├── scenes/
│   ├── main.tscn
│   ├── player.tscn
│   ├── bullet.tscn
│   ├── asteroid.tscn
│   └── ui/
│       ├── hud.tscn
│       └── game_over.tscn
├── scripts/
│   ├── player.gd
│   ├── bullet.gd
│   ├── asteroid.gd
│   ├── main.gd
│   ├── game_state.gd      # Autoload singleton — score/stats
│   ├── hud.gd
│   └── game_over.gd
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── project.godot
```

## Architecture Notes

- **Orchestrator pattern:** `Player`, `Bullet`, and `Asteroid` only emit signals about themselves (`player_died`, `asteroid_destroyed`, etc.). `main.gd` is the sole listener that decides what those events mean for the game as a whole — gameplay nodes never manage global state directly.
- **GameState autoload:** a singleton (`scripts/game_state.gd`) tracks `score`, `asteroids_destroyed`, `survival_time`, and `high_score` as independent stats, accessible from any node via `GameState.*`.
- **Collision layers:** `player` (1), `player_bullets` (2), `asteroids` (3) — deliberately separated to avoid cross-collisions (e.g. bullets damaging the player).

## Running the Project

1. Install [Godot 4.x](https://godotengine.org/download) (Standard build, not .NET).
2. Clone this repo.
3. Open Godot → **Import** → select the project folder (the one containing `project.godot`).
4. Press **F5** to run.

## Credits

Placeholder art/SFX during development — free asset sources (Kenney.nl, OpenGameArt.org).
