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

    # Apply the calculated orbital velocity
    linear_velocity = perpendicular_direction * orbital_velocity
