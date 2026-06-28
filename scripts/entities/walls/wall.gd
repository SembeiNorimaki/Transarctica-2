extends Node2D
class_name Wall

var current_tile := Vector2i(-1, -1)
@onready var sprite = $Sprite2D

func apply_damage(_amount: float):
	# print("Applying damage to wall, not implemented")
	pass
