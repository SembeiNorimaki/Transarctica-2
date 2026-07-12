extends Node2D
class_name WallEdge

var current_tile := Vector2i(-1, -1)
@onready var sprite: Sprite2D = $Sprite2D


func set_type(wall_name: String, part_name: String):
    print("Setting wall type to %s - %s" % [wall_name, part_name])
    var texture_ = WallDatabase.get_image_for_part(wall_name, part_name)
    print("Atlas cache", WallDatabase.wall_cache)
    sprite.texture = texture_


func apply_damage(amount: float):
    # print("Applying damage to wall edge, not implemented")
    pass
