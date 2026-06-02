extends VehicleUnit
class_name LocomotiveWagon

var wagon_type: String

func _ready() -> void:
	sprite_half_size = Vector2i(256, 66)
	wagon_type = "LocomotiveWagon"

func set_money(money: int):
	qty_label.text = "Money: " + str(money)

func on_click():
	print("Locomotive clicked")
	pass
