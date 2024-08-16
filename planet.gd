extends RigidBody2D

@export var initial_velocity: Vector2 = Vector2(0, 10)

var click_position: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var initial_position: Vector2 = Vector2.ZERO
var has_fired: bool = false

func _ready() -> void:
	initial_position = position
	apply_impulse(initial_velocity, Vector2.ZERO)
	freeze = true

func _input(event: InputEvent) -> void:
	if !has_fired:
		if event.is_action_pressed("pull_action"):
			click_position = event.position
			is_dragging = true
		elif event.is_action_released("pull_action"):
			is_dragging = false
			freeze = false
			var release_position = event.position
			var direction = -(release_position - click_position).normalized()
			var force = (release_position - click_position).length()
			apply_central_impulse(direction * force)

func _physics_process(delta: float) -> void:
	if !is_dragging and freeze:
		position = get_global_mouse_position()