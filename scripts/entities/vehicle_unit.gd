extends Unit
class_name VehicleUnit

@onready var storage = $Storage
@onready var qty_label = $Labels/QtyLabel

@onready var animated_sprite = $Sprite2D

var wagon_manager: HorizontalTrainManager

func set_resource_type(resource: String):
    if resource == null:
        storage.visible = false
    else:
        storage.visible = true
        storage.frame = 3

func set_resource_qty(qty: int):
    qty_label.text = str(qty)
