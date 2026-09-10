extends CanvasLayer

@onready var final_score_label: Label = $FinalScoreLabel
@onready var asteroids_destroyed_label: Label = $AsteroidsDestroyedLabel
@onready var survival_time_label: Label = $SurvivalTimeLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var restart_button: Button = $RestartButton

# Main listens for this to know when to actually perform the reset.
signal restart_requested

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)

	# Let players restart via a keyboard action
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("restart"):
		_on_restart_button_pressed()

func _on_restart_button_pressed() -> void:
	restart_requested.emit()

func show_results() -> void:
	# Called by Main right when the player dies
	# Pulls final numbers straight from GameState
	final_score_label.text = "Final Score: %d" % GameState.score
	asteroids_destroyed_label.text = "Asteroids Destroyed: %d" % GameState.asteroids_destroyed
	survival_time_label.text = "Time Survived: %.1fs" % GameState.survival_time
	high_score_label.text = "Best This Session: %d" % GameState.high_score

	visible = true
