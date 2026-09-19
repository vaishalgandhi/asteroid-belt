class_name GameOverMenu
extends Control

@onready var _final_score_value: Label = %FinalScoreValue
@onready var _high_score_value: Label = %HighScoreValue
@onready var _asteroids_destroyed_value: Label = %AsteroidsDestroyedValue
@onready var _survival_time_value: Label = %SurvivalTimeValue
@onready var _restart_button: Button = %RestartButton

# UIManager listens for this to know when to reset the game and switch states
signal restart_requested

func _ready() -> void:
	_restart_button.pressed.connect(_on_restart_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("restart"):
		_on_restart_button_pressed()
		get_viewport().set_input_as_handled()

func show_results() -> void:
	_final_score_value.text = "%d" % GameState.score
	_high_score_value.text = "%d" % GameState.high_score
	_asteroids_destroyed_value.text = "%d" % GameState.asteroids_destroyed
	_survival_time_value.text = "%.1fs" % GameState.survival_time

func _on_restart_button_pressed() -> void:
	restart_requested.emit()
