class_name ShakeCamera
extends Camera2D
## Camera that can shake itself by changing its offset.

@export var shake_strength: float = 20.0
@export var shake_duration: float = 0.35

var _shake_tween: Tween


func shake() -> void:
	# Cancel a previous shake so two tweens don't fight over offset.
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()

	_shake_tween = create_tween()

	# Gradually reduce the shake from 100% to 0%.
	_shake_tween.tween_method(
		_apply_shake.bind(shake_strength),
		1.0,
		0.0,
		shake_duration
	)

	# Make absolutely sure the camera finishes at zero offset.
	_shake_tween.tween_callback(
		func() -> void:
			offset = Vector2.ZERO
	)


func _apply_shake(intensity: float, strength: float) -> void:
	offset = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	) * strength * intensity
