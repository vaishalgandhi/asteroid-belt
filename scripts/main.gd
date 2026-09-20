extends Node2D

@export var initial_spawn_interval: float = 1.0
@export var spawn_interval_floor: float = 0.3
@export var asteroid_min_speed: float = 50.0
@export var asteroid_max_speed: float = 180.0
@export var difficulty_ramp_rate: float = 50.0
@export var game_over_delay: float = 0.8

@export var asteroid_min_scale: float = 0.7
@export var asteroid_max_scale: float = 1.4

@export var asteroid_scene: PackedScene
@export var explosion_scene: PackedScene

@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer
@onready var asteroids_container: Node2D = $Asteroids
@onready var bullets_container: Node2D = $Bullets
@onready var player: Player = $Player
@onready var ui_manager: UIManager = $UIManager


var _player_start_position: Vector2

func _ready() -> void:
	if asteroid_scene == null:
		push_error("Main: asteroid_scene is not assigned in the Inspector!")

	if explosion_scene == null:
		push_error("Main: explosion_scene is not assigned in the Inspector!")


	_player_start_position = player.global_position

	# Game doesn't start playing until the Start Screen's button is pressed
	player.set_physics_process(false)

	asteroid_spawn_timer.timeout.connect(_on_asteroid_spawn_timer_timeout)
	player.player_died.connect(_on_player_died)
	player.bullet_fired.connect(_on_player_bullet_fired)
	
	ui_manager.game_start_requested.connect(_on_game_start_requested)
	ui_manager.restart_requested.connect(_on_restart_requested)

func _on_game_start_requested() -> void:
	player.set_physics_process(true)
	ui_manager.set_ui_state(UIManager.UIState.PLAYING)
	_start_run()

func _start_run() -> void:
	# Initialize asteroid spawn
	asteroid_spawn_timer.wait_time = initial_spawn_interval
	asteroid_spawn_timer.start()
	# Start tracking survival time / score the moment a run begins.
	GameState.start_run()

func _on_asteroid_spawn_timer_timeout() -> void:
	_spawn_asteroid()
	_update_asteroid_spawn_interval()

func _spawn_asteroid() -> void:
	var asteroid := asteroid_scene.instantiate() as Asteroid

	# Random X position along the top edge of the screen, so asteroids
	# spawn just above the visible area and drift down into view.
	var screen_size := get_viewport_rect().size
	var spawn_x := randf_range(0.0, screen_size.x)
	var spawn_y := -30.0

	asteroid.position = Vector2(spawn_x, spawn_y)

	# Roll ONE random factor and derive both scale and speed from it,
	# 0.0 = big & slow, 1.0 = small & fast
	var size_factor := randf()

	# Randomize this asteroid's speed and scale within min max range.
	# lerp(from, to, weight) returns a value that's weight-percent of the way between from and to.
	var asteroid_scale: float = lerpf(asteroid_max_scale, asteroid_min_scale, size_factor)
	var speed: float = lerpf(asteroid_min_speed, asteroid_max_speed, size_factor)

	asteroid.scale = Vector2(asteroid_scale, asteroid_scale)
	asteroid.speed = speed

	# This is the dynamic per-spawn signal connection
	asteroid.asteroid_destroyed.connect(_on_asteroid_destroyed)

	asteroids_container.add_child(asteroid)

func _spawn_explosion(at: Vector2) -> void:
	if explosion_scene == null:
		return

	var explosion := explosion_scene.instantiate() as Explosion
	add_child(explosion)
	explosion.global_position = at

## As survival_time climbs, shrink asteroid spawnwait_time, but never below the floor.
func _update_asteroid_spawn_interval() -> void:
	var reduction: float = GameState.survival_time / difficulty_ramp_rate
	asteroid_spawn_timer.wait_time = maxf(initial_spawn_interval - reduction, spawn_interval_floor)

func _on_player_bullet_fired(bullet: Bullet) -> void:
	bullets_container.add_child(bullet)

func _on_asteroid_destroyed() -> void:
	GameState.add_asteroid_destroyed()

func _on_player_died() -> void:
	GameState.stop_run()
	asteroid_spawn_timer.stop()

	# Create the explosion where the player died.
	_spawn_explosion(player.global_position)

	# Give the player time to see the explosion.
	await get_tree().create_timer(game_over_delay).timeout

	ui_manager.show_game_over()

func _on_restart_requested() -> void:
	# Clear all live gameplay objects
	# Grab every child and from asteroids and bullet container and free it
	for asteroid in asteroids_container.get_children():
		asteroid.queue_free()
	for bullet in bullets_container.get_children():
		bullet.queue_free()

	# Reset the player
	player.reset(_player_start_position)

	# Reset global stats
	GameState.reset()

	# Show plying scene
	ui_manager.set_ui_state(UIManager.UIState.PLAYING)

	# Restart the run
	_start_run()
