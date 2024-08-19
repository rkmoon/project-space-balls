extends Node2D


@export var orbital_object_scene: PackedScene
@export var orbit_radius_min: float = 100.0
@export var orbit_radius_max: float = 300.0
@export var number_of_orbits: int = 10
@export var orbit_center: Vector2
@export var gravity_strength: float = 100.0  # Same as Area2D's gravity
@export var asteroid_types: Array[Texture2D]

# Getting player stats from player scene
@export var player_planet: RigidBody2D
var player_mass: int
var player_speed: int
# Setting temporary player stats to use for score updating
var temp_player_mass := player_mass
var prev_player_mass := player_mass
var temp_player_speed := player_speed
var prev_player_speed := player_speed
# The score and score label
var score: int
var score_label: Label
var mass_label: Label
var speed_label: Label

func _ready() -> void:
	for i in range(number_of_orbits):
		var orbit_object = orbital_object_scene.instantiate() as RigidBody2D
		
		# Randomly select a radius within the given range
		var orbit_radius = randf_range(orbit_radius_min, orbit_radius_max)

		# Calculate position based on the random radius
		var angle = i * PI * 2 / number_of_orbits
		var position_offset = Vector2(cos(angle), sin(angle)) * orbit_radius
		
		var asteroid_sprite: Sprite2D
		for child in orbit_object.get_children():
			if child is Sprite2D:
				asteroid_sprite = child as Sprite2D
				break
		asteroid_sprite.texture = asteroid_types.pick_random()

		# Set the orbit object's position and relevant properties
		orbit_object.position = orbit_center + position_offset
		orbit_object.orbit_center = orbit_center
		orbit_object.gravity_strength = gravity_strength
		
		add_child(orbit_object)
	
	score_label = %ScoreNumber
	mass_label = %MassNumber
	speed_label = %SpeedNumber
	set_labels_for_manager()



func set_labels_for_manager():
	GameManager._init_labels(score_label, mass_label, speed_label)
