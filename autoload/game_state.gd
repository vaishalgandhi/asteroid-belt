extends Node

var score: int = 0
var asteroids_destroyed: int = 0
var survival_time: float = 0.0
var high_score: int = 0  # session-only for MVP, per §8/FR-014 note

# Controls whether survival_time accumulates in _process.
# Main flips this on when a run starts and off when the player dies
var is_active: bool = false

# How many points survival time converts to, per second, and how often
# we actually award it. Don't want score to update every second
const SURVIVAL_POINTS_PER_SECOND: int = 1
var _survival_score_accumulator: float = 0.0

# Emitted whenever score changes, for screen to update.
signal score_changed(new_score: int)

func _process(delta: float) -> void:
	if not is_active:
		return

	survival_time += delta

	# Accumulate fractional seconds and only award a point once a full
	# second's worth has passed, rather than adding tiny fractional
	# amounts every single frame.
	_survival_score_accumulator += delta
	if _survival_score_accumulator >= 1.0:
		_survival_score_accumulator -= 1.0
		add_score(SURVIVAL_POINTS_PER_SECOND)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

	if score > high_score:
		high_score = score

func add_asteroid_destroyed() -> void:
	# Kept as two separate calls
	# So kill-count and point-value stay independently.
	asteroids_destroyed += 1
	add_score(100)

func reset() -> void:
	score = 0
	asteroids_destroyed = 0
	survival_time = 0.0
	_survival_score_accumulator = 0.0
	
	score_changed.emit(score)

func start_run() -> void:
	is_active = true

func stop_run() -> void:
	is_active = false
