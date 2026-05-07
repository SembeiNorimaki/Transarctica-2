extends VehicleUnit
class_name MerchandiseWagon

var wagon_type: String

func _ready() -> void:
	sprite_half_size = Vector2i(128, 46)
	capacity = 3
	wagon_type = "MerchandiseWagon"
