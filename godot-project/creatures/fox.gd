extends CharacterBody2D

signal captured

# Fox: fast, erratic zigzag bursts separated by short coasting periods.
# Punishes slow loop closure — the player must commit quickly.

const BURST_SPEED := 200.0
const COAST_SPEED := 40.0
const BURST_DURATION := 0.4
const COAST_DURATION := 0.8

var loop_count := 0
var loops_needed := 4
var damage_amount := 0

enum State { BURST, COAST }
var _state := State.COAST
var _state_timer := COAST_DURATION
var _move_dir := Vector2.RIGHT


func _ready() -> void:
	$DamageHitbox.monitoring = false
	_move_dir = Vector2.from_angle(randf() * TAU)


func _physics_process(delta: float) -> void:
	_state_timer -= delta

	match _state:
		State.COAST:
			velocity = _move_dir * COAST_SPEED
			if _state_timer <= 0.0:
				_start_burst()
		State.BURST:
			velocity = _move_dir * BURST_SPEED
			if _state_timer <= 0.0:
				_start_coast()

	move_and_slide()

	# Bounce off walls
	if get_slide_collision_count() > 0:
		var col := get_slide_collision(0)
		_move_dir = _move_dir.bounce(col.get_normal())


func _start_burst() -> void:
	# Zigzag: deflect ±45° from current heading
	var angle := _move_dir.angle() + (randf() - 0.5) * (PI * 0.5)
	_move_dir = Vector2.from_angle(angle)
	_state = State.BURST
	_state_timer = BURST_DURATION


func _start_coast() -> void:
	_state = State.COAST
	_state_timer = COAST_DURATION


func add_loop() -> void:
	loop_count += 1
	if loop_count >= loops_needed:
		emit_signal("captured")
		queue_free()
