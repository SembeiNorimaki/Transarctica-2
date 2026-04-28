extends Unit
class_name VehicleUnit

@onready var storage = $Storage
@onready var qty_label = $Labels/QtyLabel

@onready var animated_sprite = $Sprite2D

var wagon_manager: HorizontalTrainManager

var sprite_half_size = Vector2i(50, 25)

func set_resource_type(resource: String):
	if resource == null:
		storage.visible = false
	else:
		storage.visible = true
		storage.frame = 3

func set_resource_qty(qty: int):
	qty_label.text = str(qty)


func check_click(mouse_pos) -> bool:
	print(mouse_pos, position, sprite_half_size)
	if mouse_pos.x > position.x - sprite_half_size.x and \
		mouse_pos.x < position.x + sprite_half_size.x and \
		mouse_pos.y > position.y - 2* sprite_half_size.y and \
		mouse_pos.y < position.y:
			return true
	return false
			


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Left mouse button clicked inside the Area2D")
