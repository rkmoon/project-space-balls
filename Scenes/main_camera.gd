extends Camera2D

@export var player_planet : Node2D
@export var middle_planet : Node2D

func _process(delta):
	position = lerp(player_planet.global_position, middle_planet.global_position, 0.5)
