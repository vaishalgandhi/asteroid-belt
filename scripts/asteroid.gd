extends Area2D

@export var min_speed: float = 80.0
@export var max_speed: float = 160.0
@export var speed: float = 120.0

# Fired when this asteroid is destroyed by a bullet
signal asteroid_destroyed

func _ready() -> void:
	# When this asteroid drifts off the visible screen, free it.
	# Prevents the "unbounded objects" memory leak problem.
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	# Constant downward movement
	position += Vector2.DOWN * speed * delta

func _on_screen_exited() -> void:
	queue_free()

func take_hit() -> void:
	# When this asteroid is destroyed by a bullet emit a signal
	# Once it is destroyed free it up from the memory
	asteroid_destroyed.emit()
	queue_free()
