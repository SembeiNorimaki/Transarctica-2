extends Unit
class_name VehicleUnit

@onready var storage = $Storage
@onready var qty_label = $Labels/QtyLabel

@onready var animated_sprite = $Sprite2D

var wagon_manager: HorizontalTrainManager

var sprite_half_size = Vector2i(50, 25)


var resource_name_to_frame = {
	"alcohol":    0,
	"antiques":   1,
	"missiles":   2,
	"bricks":     3,
	"caviar":     4,
	"oil":     	  5,
	"earth": 	  6,
	"coal": 	  7,
	"plants": 	  8,
	"copper": 	  9,
	"dung": 	  10,
	"rails": 	  11,
	"fish": 	  12,
	"rods": 	  13,
	"salt": 	  14,
	"furs": 	  15,
	"gasoline":   16,
	"inspection": 17,
	"gray":       18,
	"meat":       19,
	"wood":       20
}




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
