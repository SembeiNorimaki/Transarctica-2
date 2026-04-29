extends Node2D
class_name TrafficLight

var sprite_half_size = Vector2i(20, 40)
var state = "OFF"

@onready var sprite = $Sprite2D

func check_click(mouse_pos: Vector2i) -> bool:
	if mouse_pos.x > position.x - sprite_half_size.x and \
		mouse_pos.x < position.x + sprite_half_size.x and \
		mouse_pos.y > position.y - sprite_half_size.y and \
		mouse_pos.y < position.y + sprite_half_size.y:
			return true
	return false

func toggle():
	if state == "OFF":
		state = "ON"
		sprite.frame = 0
	else:
		state = "OFF"
		sprite.frame = 1
