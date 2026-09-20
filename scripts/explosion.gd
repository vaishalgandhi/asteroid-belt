class_name Explosion
extends Node2D
## One-shot explosion effect. Plays itself, then frees itself.

@export var duration: float = 0.5
@export var start_scale: float = 0.3
@export var end_scale: float = 2.0

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_sprite.scale = Vector2.ONE * start_scale

	# Two tweens at once (grow + fade).
	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		_sprite,
		"scale",
		Vector2.ONE * end_scale,
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		_sprite,
		"modulate:a",
		0.0,
		duration
	)

	await tween.finished
	queue_free()
