extends Area2D

# Exposed in the Inspector so you can tune bullet speed without touching code.
@export var speed: float = 600.0

# Emitted when this bullet hits something on the asteroids layer.
# Main will listen for this (indirectly, via Asteroid) to know a hit happened.
signal asteroid_hit(asteroid: Node2D)

func _ready() -> void:
	# Connect the VisibleOnScreenNotifier2D's signal to our own cleanup function.
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

	# Listen for overlaps with other Area2Ds to detect asteroids
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# Bullets move in a straight line, upward, at constant speed.
	position += Vector2.UP * speed * delta

func _on_screen_exited() -> void:
	# Bullet left the visible screen — no reason to keep it around.
	# This is the fix for the "unbounded bullets = memory leak" problem
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# We only care if we hit something tagged as an asteroid.
	# Bullet is consumed on impact that is why we should free the queue as well
	if area.is_in_group("asteroids"):
		area.take_hit()
		queue_free()
