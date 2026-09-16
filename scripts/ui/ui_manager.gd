extends CanvasLayer

enum UIState { MENU, PLAYING, PAUSED, GAME_OVER }

@onready var menu_background: TextureRect = $BackgroundManager/MenuBackground
@onready var start_screen: Control = $UI_Root/StartScreen
@onready var pause_menu: Control = $UI_Root/PauseMenu
@onready var game_over_menu: Control = $UI_Root/GameOverMenu

# Main listens for this event signals
signal game_start_requested
signal restart_requested

var current_state: UIState = UIState.MENU

func _ready() -> void:
	# Keep this node (and everything under it) processing even while
	# get_tree().paused = true — otherwise Pause Menu buttons would freeze
	# along with the rest of the game and be unclickable.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Wire up buttons that UIManager can fully handle itself
	start_screen.get_node("VBoxContainer/MenuButtons/StartButton").pressed.connect(_on_start_button_pressed)
	pause_menu.get_node("VBoxContainer/HBoxContainer2/ResumeButton").pressed.connect(_on_resume_button_pressed)
	pause_menu.get_node("VBoxContainer/HBoxContainer2/QuitButton").pressed.connect(_on_quit_pressed)

	# game_over_menu already emits its own restart_requested signal
	# Listen for game over signal
	game_over_menu.restart_requested.connect(_on_game_over_restart_requested)

	set_ui_state(UIState.MENU)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if current_state == UIState.PLAYING:
			set_ui_state(UIState.PAUSED)
		elif current_state == UIState.PAUSED:
			set_ui_state(UIState.PLAYING)

func set_ui_state(new_state: UIState) -> void:
	current_state = new_state

	start_screen.visible = (new_state == UIState.MENU)
	pause_menu.visible = (new_state == UIState.PAUSED)
	game_over_menu.visible = (new_state == UIState.GAME_OVER)
	menu_background.visible = (new_state != UIState.PLAYING)

	# If game over state add Rust coloured tint
	var target_tint := 1.0 if new_state == UIState.GAME_OVER else 0.0
	var current_tint: float = menu_background.material.get_shader_parameter("tint_amount")
	var tween := create_tween()
	tween.tween_method(
		func(value: float): menu_background.material.set_shader_parameter("tint_amount", value),
		current_tint, target_tint, 0.4
	)

	get_tree().paused = (new_state == UIState.PAUSED or new_state == UIState.GAME_OVER)

# Called by Main right when the player dies
func show_game_over(results_visible: bool = true) -> void:
	game_over_menu.show_results()
	set_ui_state(UIState.GAME_OVER)

func _on_start_button_pressed() -> void:
	game_start_requested.emit()

func _on_resume_button_pressed() -> void:
	set_ui_state(UIState.PLAYING)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_game_over_restart_requested() -> void:
	restart_requested.emit()
