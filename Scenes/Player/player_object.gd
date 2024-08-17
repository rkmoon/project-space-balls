extends RigidBody2D

@export var gravity_node : Node2D
@export var color_gradient: Array[Color] = [Color(1, 1, 1, 0.5), Color(1, 0, 0, 0.5)]  # Default gradient from white to red
@export var prediction_time: float = 10.0
@export var step : float = 0.1

var click_position: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var has_fired: bool = false
var trajectory_points: Array = []
var target_scale = Vector2(1,1)
var target_mass : float
var absorbing_area : Area2D
var children : Array = []




func _ready() -> void:
	freeze = true
	connect("body_entered", _on_body_entered)
	target_scale = scale
	target_mass = mass
	children = get_children()
	for child in children:
		if child is Area2D:
			layer_utils.set_prelauch_layers(child)
	layer_utils.set_prelauch_layers(self)

	


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
			print(release_position)
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
		freeze = true
		has_fired = false



func _physics_process(delta: float) -> void:
	if is_dragging:
		update_trajectory()
	elif !is_dragging and freeze:
		position = get_global_mouse_position()
		update_trajectory()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	scale = target_scale
	if mass != target_mass:
			print(linear_velocity)
	#mass = target_mass


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


			
func absorb_object(body: RigidBody2D) -> void:
	var added_mass = body.mass
	target_mass = body.mass + mass
	var scale_factor = pow((added_mass/mass), 1./3.)
	body.queue_free()
	target_scale += Vector2(1,1)
	#print(body.name + ": absorbed. New Mass: " + str(mass) + " New Scale:" + str(target_scale))
