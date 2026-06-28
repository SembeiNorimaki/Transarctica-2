extends Node2D
class_name WallEdge

var current_tile := Vector2i(-1, -1)
@onready var sprite = $Sprite2D

func set_frame(frame):
    sprite.frame = frame

func apply_damage(amount: float):
    # print("Applying damage to wall edge, not implemented")
    pass
