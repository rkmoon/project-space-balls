extends RigidBody2D

@export var gravity_node : Node2D
@export var color_gradient: Array[Color] = [Color(1, 1, 1, 0.5), Color(1, 0, 0, 0.5)]  # Default gradient from white to red
@export var prediction_time: float = 10.0
@export var step : float = 0.1
@export var scale_factor = .1
@export var damping: float = 0.05

var click_position: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var has_fired: bool = false
var trajectory_points: Array = []
var target_scale = Vector2(1,1)
var target_mass : float
var absorbing_area : Area2D
var children : Array = []
var current_children_scale = Vector2(1,1)
var initial_scales: Array[Vector2] = []
var accumulated_scale_factor : float = 0.0
var collision_shape : CollisionShape2D
var initial_radius : float
var speed_number: Label
var mass_number: Label


func _ready() -> void:
	freeze = true
	connect("body_entered", _on_body_entered)
	target_scale = scale
	target_mass = mass
	children = children_utils.get_all_children(self)
	for child in children:
		if child is Area2D:
			layer_utils.set_prelauch_layers(child)
		initial_scales.append(child.scale)
	layer_utils.set_prelauch_layers(self)
	collision_shape = get_node("CollisionShape2D")
	initial_radius = collision_shape.shape.radius
	speed_number = %SpeedNumber
	mass_number = %MassNumber
	linear_damp = damping

	


func _input(event: InputEvent) -> void:
	if !has_fired:
		if event.is_action_pressed("pull_action"):
			click_position = event.position
			is_dragging = true
			freeze = true
			queue_redraw()
		elif event.is_action_released("pull_action"):
			is_dragging = false
			freeze = false
			var release_position = event.position
			var direction = -(release_position - click_position).normalized()
			var force = (release_position - click_position).length()
			apply_central_impulse(direction * force * mass)			
			has_fired = true
			queue_redraw()  # Triggers the _draw function to clear the trajectory after firing
			layer_utils.set_regular_layers(self)
			for child in children:
				if child is Area2D:
					layer_utils.set_regular_layers(child)

	if event.is_action_pressed("reset_planet"):
		
		GameManager._restart_scene()

func _process(_delta: float) -> void:
	if has_fired:
		GameManager.change_mass_label(mass)
		GameManager.change_speed_label(linear_velocity.length())

func _physics_process(_delta: float) -> void:
	if is_dragging:
		update_trajectory()
	elif !is_dragging and freeze:
		position = get_global_mouse_position()
		update_trajectory()

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	mass = target_mass
	angular_velocity = 0


func update_trajectory() -> void:
	trajectory_points.clear()
	
	var release_position = get_viewport().get_mouse_position()
	var direction = (release_position - click_position).normalized()
	var force = (release_position - click_position).length()
	
	var velocity = -direction * force
	
	var current_position = position
	var current_velocity = velocity
	
	for i in range(int(prediction_time / step)):
			var next_position = current_position + current_velocity * step
			trajectory_points.append([current_position, next_position])
			current_position = next_position
			
			# Recalculate gravity direction and force at each step
			var gravity_point = gravity_node.global_position
			var gravity_direction = (gravity_point - current_position).normalized()
			current_velocity += gravity_direction * gravity_node.gravity * step
	
	queue_redraw()  # Triggers the _draw function to redraw the trajectory



func _draw() -> void:
	if !has_fired and is_dragging:
		var num_points = trajectory_points.size()
		var num_colors = color_gradient.size()
		
		for i in range(num_points):
			var points = trajectory_points[i]
			var point1 = points[0] - position  # subtract object's position
			var point2 = points[1] - position  # subtract object's position
			
			# Calculate the interpolation factor
			var t = float(i) / float(num_points - 1)
			
			# Determine the two colors to interpolate between
			var color_index = int(t * (num_colors - 1))
			var color_t = (t * (num_colors - 1)) - color_index
			var start_color = color_gradient[color_index]
			var end_color = color_gradient[min(color_index + 1, num_colors - 1)]
			
			# Interpolate between the start and end colors
			var color = start_color.lerp(end_color, color_t)
			
			# Draw the line with the interpolated color
			draw_line(point1, point2, color)


func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		if body.mass < self.mass:
			absorb_object(body)
			_change_score()


			
func absorb_object(body: RigidBody2D) -> void:
	var added_mass = body.mass
	target_mass = added_mass + mass
	body.queue_free()
	accumulated_scale_factor += scale_factor
	target_scale = (Vector2.ONE * accumulated_scale_factor)
	set_scales()

func set_scales():
	for i in range(children.size()):
		var tween = get_tree().create_tween()
		var child = children[i]
		var new_scale = initial_scales[i] + target_scale
		tween.tween_property(child, "scale", new_scale, 0.001)
	var circle_shape = collision_shape.shape as CircleShape2D
	if circle_shape:
		circle_shape.radius = initial_radius * accumulated_scale_factor
	current_children_scale = target_scale


func _update_particle_direction():
	var particles: GPUParticles2D = get_node("GPUParticles2D")
	var part_material : ParticleProcessMaterial = particles.process_material
	var direction = -linear_velocity.normalized()
	part_material.direction = Vector3(direction.x, direction.y, 0)
	part_material.angle_min = direction.angle_to(Vector2.UP) - 0.1
	part_material.angle_max = direction.angle_to(Vector2.UP) + 0.1


func _change_score():
	var score = mass * linear_velocity.length()
	GameManager.add_score(score)
