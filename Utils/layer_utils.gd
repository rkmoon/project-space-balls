extends Node2D
class_name layer_utils

enum Layer {DONOTUSE, GRAVITY, OBJECTS, PLAYERNOCOLLISION, ATTACHED}


static func set_prelauch_layers(body: Node):
    body.set_collision_layer_value(Layer.GRAVITY, false)
    body.set_collision_layer_value(Layer.OBJECTS, false)
    body.set_collision_layer_value(Layer.PLAYERNOCOLLISION, true)

    body.set_collision_mask_value(Layer.GRAVITY, false)
    body.set_collision_mask_value(Layer.OBJECTS, false)
    body.set_collision_mask_value(Layer.PLAYERNOCOLLISION, true)
    body.set_collision_mask_value(Layer.ATTACHED, false)



static func set_regular_layers(body: Node):
    body.set_collision_layer_value(Layer.GRAVITY, true)
    body.set_collision_layer_value(Layer.OBJECTS, true)
    body.set_collision_layer_value(Layer.PLAYERNOCOLLISION, false)
    body.set_collision_layer_value(Layer.ATTACHED, true)

    body.set_collision_mask_value(Layer.GRAVITY, true)
    body.set_collision_mask_value(Layer.OBJECTS, true)
    body.set_collision_mask_value(Layer.PLAYERNOCOLLISION, false)
    body.set_collision_mask_value(Layer.ATTACHED, false)

static func set_attached_layers(body: Node):
    body.set_collision_layer_value(Layer.OBJECTS, false)
    body.set_collision_layer_value(Layer.ATTACHED, true)

    body.set_collision_mask_value(Layer.ATTACHED, false)
