class_name UIManager
extends CanvasLayer

# Main listens for this event signals
signal game_start_requested
signal restart_requested

enum UIState { MENU, PLAYING, PAUSED, GAME_OVER }

const TINT_DURATION: float = 0.4
const TINT_NONE: float = 0.0
const TINT_RUST: float = 1.0

var current_state: UIState = UIState.MENU

var _tint_tween: Tween

@onready var _menu_background: TextureRect = %MenuBackground
@onready var _start_screen: Control = %StartScreen
@onready var _pause_menu: PauseMenu = %PauseMenu
@onready var _game_over_menu: GameOverMenu = %GameOverMenu

@onready var _start_button: Button = %StartButton
@onready var _start_quit_button: Button = %StartQuitButton
@onready var _resume_button: Button = %ResumeButton
@onready var _pause_quit_button: Button = %PauseQuitButton
@onready var _game_over_quit_button: Button = %GameOverQuitButton

func _ready() -> void:
	# Keep this node (and everything under it) processing even while
	# get_tree().paused = true — otherwise Pause Menu buttons would freeze
	# along with the rest of the game and be unclickable.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Wire up buttons that UIManager can fully handle itself
	_start_button.pressed.connect(_on_start_button_pressed)
	_resume_button.pressed.connect(_on_resume_button_pressed)
	for quit_button: Button in [_start_quit_button, _pause_quit_button, _game_over_quit_button]:
		quit_button.pressed.connect(_on_quit_pressed)


	# game_over_menu already emits its own restart_requested signal
	# Listen for game over signal
	_game_over_menu.restart_requested.connect(_on_game_over_restart_requested)

	set_ui_state(UIState.MENU)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if current_state == UIState.PLAYING:
			set_ui_state(UIState.PAUSED)
		elif current_state == UIState.PAUSED:
			set_ui_state(UIState.PLAYING)

func set_ui_state(new_state: UIState) -> void:
	current_state = new_state

	_start_screen.visible = (new_state == UIState.MENU)
	_pause_menu.visible = (new_state == UIState.PAUSED)
	_game_over_menu.visible = (new_state == UIState.GAME_OVER)
	_menu_background.visible = (new_state != UIState.PLAYING)

	if new_state == UIState.PAUSED:
		_pause_menu.show_stats()

	# If game over state add Rust coloured tint
	_tween_tint(TINT_RUST if new_state == UIState.GAME_OVER else TINT_NONE)

	get_tree().paused = (new_state == UIState.PAUSED or new_state == UIState.GAME_OVER)

func _tween_tint(target: float) -> void:
	# Cancel any in-flight tween first, otherwise rapid state changes leave
	# two tweens fighting over the same shader parameter.
	if _tint_tween != null and _tint_tween.is_valid():
		_tint_tween.kill()

	_tint_tween = create_tween()
	_tint_tween.tween_property(
		_menu_background.material, "shader_parameter/tint_amount", target, TINT_DURATION
	)

# Called by Main right when the player dies
func show_game_over(results_visible: bool = true) -> void:
	_game_over_menu.show_results()
	set_ui_state(UIState.GAME_OVER)

func _on_start_button_pressed() -> void:
	game_start_requested.emit()

func _on_resume_button_pressed() -> void:
	set_ui_state(UIState.PLAYING)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_game_over_restart_requested() -> void:
	restart_requested.emit()
