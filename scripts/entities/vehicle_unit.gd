extends Unit
class_name VehicleUnit

@onready var storage = $Storage
@onready var qty_label = $Labels/QtyLabel


@onready var animated_sprite: AnimatedSprite2D = $Sprite

var wagon_manager: HorizontalTrainManager

var sprite_half_size = Vector2i(50, 25)
var capacity: int = 0

var resource_name_to_frame = {
    "alcohol": 0,
    "antiques": 1,
    "missiles": 2,
    "bricks": 3,
    "caviar": 4,
    "oil": 5,
    "earth": 6,
    "coal": 7,
    "plants": 8,
    "copper": 9,
    "mammothdung": 10,
    "rails": 11,
    "fish": 12,
    "fishingrods": 13,
    "salt": 14,
    "furs": 15,
    "gasoline": 16,
    "inspection": 17,
    "gray": 18,
    "wolfmeat": 19,
    "wood": 20
}


func check_click(mouse_pos) -> bool:
    # print(mouse_pos, global_position, sprite_half_size)
    if mouse_pos.x > global_position.x - sprite_half_size.x and \
        mouse_pos.x < global_position.x + sprite_half_size.x and \
        mouse_pos.y > global_position.y - 2 * sprite_half_size.y and \
        mouse_pos.y < global_position.y:
            return true
    return false
            

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            pass
            # print("Left mouse button clicked inside the Area2D")
func set_resource_type(resource: String):
    if resource == "":
        pass
        #storage.visible = false
    else:
        pass
        #storage.visible = true
        #storage.frame = resource_name_to_frame[resource]

func set_resource_qty(qty: int):
    pass
    #qty_label.text = "%s / %s " % [str(qty), str(capacity)]
