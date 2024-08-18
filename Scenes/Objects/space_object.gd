extends RigidBody2D

@export var orbit_center: Vector2
@export var gravity_strength: float = 100.0  # The gravity in px/s²

func _ready() -> void:
	# Calculate the distance from the orbit center
	var distance = position.distance_to(orbit_center)

	# Calculate the correct orbital velocity
	var orbital_velocity = sqrt(gravity_strength * distance)

	# Determine the direction of the velocity (perpendicular to the radius)
	var direction = (position - orbit_center).normalized()
	var perpendicular_direction = Vector2(-direction.y, direction.x)  # Perpendicular vector

	# Randomly decide whether to invert the direction
	#if randf() < 0.5:
	#	perpendicular_direction = -perpendicular_direction

	# Apply the calculated orbital velocity
	linear_velocity = perpendicular_direction * orbital_velocity

	# Add a small random angular velocity
	angular_velocity = randf_range(-5, 5)  # Random angular velocity in radians per second

	# Set a random scale for the object
	var random_scale = randf_range(0.5, 2.0)  # Random scale between 0.5 and 2.0
	for child in children_utils.get_all_children(self):
		var initial_scale = child.scale
		child.scale = Vector2(random_scale, random_scale) * initial_scale
	mass = mass * random_scale  # Adjust the mass based on the scale
