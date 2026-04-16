extends CharacterBody2D

signal captured

# Urchin: very slow, stops periodically, wanders within a short radius.
# Its passive spike aura (DamageHitbox always on) punishes tight loops.

const SPEED := 50.0
const STOP_DURATION := 2.0
const WANDER_RADIUS := 80.0

var loop_count := 0
var loops_needed := 3
var damage_amount := 1

enum State { WANDER, STOP }
var _state := State.WANDER
var _wander_target := Vector2.ZERO
var _stop_timer := 0.0


func _ready() -> void:
	$DamageHitbox.monitoring = true  # Spike aura is always active
	_pick_wander_target()


func _physics_process(delta: float) -> void:
	match _state:
		State.WANDER:
			_do_wander()
		State.STOP:
			_do_stop(delta)
	move_and_slide()


func _do_wander() -> void:
	var dir := _wander_target - global_position
	if dir.length() < 8.0:
		_state = State.STOP
		_stop_timer = STOP_DURATION
		velocity = Vector2.ZERO
		return
	velocity = dir.normalized() * SPEED


func _do_stop(delta: float) -> void:
	velocity = Vector2.ZERO
	_stop_timer -= delta
	if _stop_timer <= 0.0:
		_pick_wander_target()
		_state = State.WANDER


func _pick_wander_target() -> void:
	var angle := randf() * TAU
	var dist := randf_range(20.0, WANDER_RADIUS)
	_wander_target = global_position + Vector2(cos(angle), sin(angle)) * dist


func add_loop() -> void:
	loop_count += 1
	if loop_count >= loops_needed:
		emit_signal("captured")
		queue_free()
