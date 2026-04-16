extends CharacterBody2D

signal captured

# Bird: medium speed, travels in a straight line. Wraps around when it exits the scene boundary.
# Teaches the player to time loops around a creature that won't stay put.

const SPEED := 100.0

var loop_count := 0
var loops_needed := 3
var damage_amount := 0

# Set by CaptureScene after instantiation so the bird knows the arena extents.
# Rect2 in world space (e.g. Rect2(0, 0, 640, 480)).
var scene_bounds := Rect2()

var _move_dir := Vector2.RIGHT


func _ready() -> void:
	$DamageHitbox.monitoring = false
	_move_dir = Vector2.from_angle(randf() * TAU)


func _physics_process(_delta: float) -> void:
	velocity = _move_dir * SPEED
	move_and_slide()
	if not scene_bounds.is_equal_approx(Rect2()) and not scene_bounds.has_point(global_position):
		_wrap_position()


func _wrap_position() -> void:
	var pos := global_position
	if pos.x < scene_bounds.position.x:
		pos.x = scene_bounds.end.x
	elif pos.x > scene_bounds.end.x:
		pos.x = scene_bounds.position.x
	if pos.y < scene_bounds.position.y:
		pos.y = scene_bounds.end.y
	elif pos.y > scene_bounds.end.y:
		pos.y = scene_bounds.position.y
	global_position = pos


func add_loop() -> void:
	loop_count += 1
	if loop_count >= loops_needed:
		emit_signal("captured")
		queue_free()
