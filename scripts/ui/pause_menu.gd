class_name PauseMenu
extends Control

@onready var _score_value: Label = %PauseScoreValue
@onready var _high_score_value: Label = %PauseHighScoreValue

# Called by UIManager each time the game pauses.
func show_stats() -> void:
	_score_value.text = "%d" % GameState.score
	_high_score_value.text = "%d" % GameState.high_score
