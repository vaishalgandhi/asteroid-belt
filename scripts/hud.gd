extends CanvasLayer

@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
	GameState.score_changed.connect(_on_score_changed)

	# Set the initial label text immediately, in case score is already
	# non-zero when this HUD becomes active.
	_update_label(GameState.score)

func _on_score_changed(new_score: int) -> void:
	_update_label(new_score)

func _update_label(value: int) -> void:
	score_label.text = "Score: %d" % value
