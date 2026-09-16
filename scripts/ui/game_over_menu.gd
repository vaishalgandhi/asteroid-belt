extends Control

@onready var final_score_value: Label = $VBoxContainer/HBoxContainer/VBoxContainer/FinalScoreValue
@onready var high_score_value: Label = $VBoxContainer/HBoxContainer/VBoxContainer2/HighestScoreValue
@onready var asteroids_destroyed_value: Label = $VBoxContainer/HBoxContainer2/VBoxContainer/AsteroidsDestroyedValue
@onready var survival_time_value: Label = $VBoxContainer/HBoxContainer2/VBoxContainer2/SurvivalTimeValue
@onready var restart_button: Button = $VBoxContainer/HBoxContainer3/RestartButton

# UIManager listens for this to know when to reset the game and switch states
signal restart_requested

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("restart"):
		_on_restart_button_pressed()

func _on_restart_button_pressed() -> void:
	restart_requested.emit()

func show_results() -> void:
	final_score_value.text = "%d" % GameState.score
	high_score_value.text = "%d" % GameState.high_score
	asteroids_destroyed_value.text = "%d" % GameState.asteroids_destroyed
	survival_time_value.text = "%.1fs" % GameState.survival_time
