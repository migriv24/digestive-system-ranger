extends CharacterBody2D

signal captured

# Dinosaur: medium speed wander, periodically stops to bite in front of itself.
# DamageHitbox is enabled only during the bite window — teaches attack timing/avoidance.

const SPEED := 90.0
const WANDER_TIME_MIN := 1.5
const WANDER_TIME_MAX := 3.0
const BITE_DURATION := 0.5
const BITE_RANGE := 32.0

var loop_count := 0
var loops_needed := 4
var damage_amount := 2

enum State { WANDER, BITE }
var _state := State.WANDER
var _state_timer := 0.0
var _move_dir := Vector2.RIGHT


func _ready() -> void:
	$DamageHitbox.monitoring = false
	_move_dir = Vector2.from_angle(randf() * TAU)
	_state_timer = randf_range(WANDER_TIME_MIN, WANDER_TIME_MAX)


func _physics_process(delta: float) -> void:
	_state_timer -= delta

	match _state:
		State.WANDER:
			velocity = _move_dir * SPEED
			if _state_timer <= 0.0:
				_start_bite()
		State.BITE:
			velocity = Vector2.ZERO
			if _state_timer <= 0.0:
				_end_bite()

	move_and_slide()

	if get_slide_collision_count() > 0:
		var col := get_slide_collision(0)
		_move_dir = _move_dir.bounce(col.get_normal())


func _start_bite() -> void:
	_state = State.BITE
	_state_timer = BITE_DURATION
	# Position the damage hitbox in front of the dinosaur
	$DamageHitbox.position = _move_dir * BITE_RANGE
	$DamageHitbox.monitoring = true


func _end_bite() -> void:
	$DamageHitbox.monitoring = false
	_state = State.WANDER
	_state_timer = randf_range(WANDER_TIME_MIN, WANDER_TIME_MAX)
	_move_dir = Vector2.from_angle(randf() * TAU)


func add_loop() -> void:
	loop_count += 1
	if loop_count >= loops_needed:
		emit_signal("captured")
		queue_free()
