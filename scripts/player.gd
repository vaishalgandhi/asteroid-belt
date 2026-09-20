class_name Player
extends CharacterBody2D

## Emmited when player dies. Main listens to this and trigger the Game Over flow.
signal player_died

## Emitted when the ship fires. Whoever owns the world decides where the bullet lives.
signal bullet_fired(bullet: Bullet)

@export var speed: float = 300.0
@export var shoot_cooldown: float = 0.3

@export var bullet_scene: PackedScene

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var gun_cooldown: Timer = $GunCooldown
@onready var muzzle: Marker2D = $Muzzle
@onready var hitbox_area: Area2D = $HitboxArea
@onready var _shoot_sound: AudioStreamPlayer = $ShootSound

# Simple guard so a player who's already dying can't somehow trigger
# this twice (e.g. overlapping two asteroids in the same frame).
var is_dead: bool = false

func _ready() -> void:
	gun_cooldown.wait_time = shoot_cooldown
	gun_cooldown.one_shot = true
	
	# Throw an error if bullet scene is not assigned
	if bullet_scene == null:
		push_error("Player: bullet_scene is not assigned in the Inspector!")
	
	hitbox_area.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(_delta: float) -> void:
	# stop responding to input entirely once dead
	if is_dead:
		return  

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	_clamp_to_screen()
	_handle_shooting()

func _clamp_to_screen() -> void:
	# Fetch the current size of the visible game window, in pixels.
	var screen_size := get_viewport_rect().size

	# Get the ship's collision shape and find its bounding box size,
	# then divide by 2 to get the "half shape size"
	var half_shape_size := collision_shape.shape.get_rect().size / 2.0

	# Clamp horizontal position:
	# - Minimum: half_shape_size.x (center can't get closer to the left edge
	#   than half the ship's width, or the left half would clip off-screen)
	# - Maximum: screen_size.x - half_shape_size.x (same logic, mirrored for
	#   the right edge)
	global_position.x = clampf(global_position.x, half_shape_size.x, screen_size.x - half_shape_size.x)

	# Same idea, but for vertical position (top/bottom edges of the screen).
	global_position.y = clampf(global_position.y, half_shape_size.y, screen_size.y - half_shape_size.y)

func _handle_shooting() -> void:
	# Fire a shot only if gun cooldown is stopped
	# Once the fired a bullet start the cooldown timer
	if Input.is_action_just_pressed("shoot") and gun_cooldown.is_stopped():
		_fire_bullet()
		gun_cooldown.start()

func _fire_bullet() -> void:
	var bullet := bullet_scene.instantiate() as Bullet
	bullet.global_position = muzzle.global_position
	bullet_fired.emit(bullet)
	
	_shoot_sound.pitch_scale = randf_range(0.95, 1.05)
	_shoot_sound.play()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_dead:
		return

	if area is Asteroid:
		_die()

func _die() -> void:
	is_dead = true
	set_physics_process(false)
	hitbox_area.set_deferred("monitoring", false)
	hide()
	player_died.emit()

## Puts the ship back into a fresh, playable state. Called by Main on restart button pressed.
func reset(start_position: Vector2) -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	is_dead = false
	hitbox_area.set_deferred("monitoring", true)
	show()
	set_physics_process(true)
