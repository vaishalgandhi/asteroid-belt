class_name Asteroid
extends Area2D
## A drifting asteroid. Moves straight down and dies when a bullet hits it.

## Fired exactly once, when a bullet destroys this asteroid.
signal asteroid_destroyed

## Set by Main at spawn time (bigger asteroids are slower).
@export var speed: float = 120.0

var _is_destroyed: bool = false

@onready var _notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	# When this asteroid drifts off the visible screen, free it.
	# Prevents the "unbounded objects" memory leak problem.
	_notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	# Constant downward movement
	position += Vector2.DOWN * speed * delta

func take_hit() -> void:
	# Guard: two bullets landing in the same physics frame must not emit the signal
	if _is_destroyed:
		return

	# When this asteroid is destroyed by a bullet emit a signal
	# Once it is destroyed free it up from the memory
	_is_destroyed = true
	asteroid_destroyed.emit()
	queue_free()

func _on_screen_exited() -> void:
	queue_free()
