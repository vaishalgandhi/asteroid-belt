class_name Bullet
extends Area2D
## A projectile Bullet. Flies straight up and destroys the first asteroid it touches.

@export var speed: float = 600.0

@onready var _notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	_notifier.screen_exited.connect(_on_screen_exited)

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
	# `as` returns null if the area isn't an Asteroid, so we ignore everything else.
	var asteroid := area as Asteroid
	if asteroid == null:
		return
	asteroid.take_hit()
	queue_free()
