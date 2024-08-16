extends Node2D

@export var orbital_object_scene: PackedScene
@export var orbit_radius_min: float = 100.0
@export var orbit_radius_max: float = 300.0
@export var number_of_orbits: int = 10
@export var orbit_center: Vector2
@export var gravity_strength: float = 100.0  # Same as Area2D's gravity

func _ready() -> void:
	for i in range(number_of_orbits):
		var orbit_object = orbital_object_scene.instantiate() as RigidBody2D
		
		# Randomly select a radius within the given range
		var orbit_radius = randf_range(orbit_radius_min, orbit_radius_max)

		# Calculate position based on the random radius
		var angle = i * PI * 2 / number_of_orbits
		var position_offset = Vector2(cos(angle), sin(angle)) * orbit_radius
		
		# Set the orbit object's position and relevant properties
		orbit_object.position = orbit_center + position_offset
		orbit_object.orbit_center = orbit_center
		orbit_object.gravity_strength = gravity_strength
		
		add_child(orbit_object)
