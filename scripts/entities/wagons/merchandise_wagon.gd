extends VehicleUnit
class_name MerchandiseWagon

var wagon_type: String

func _ready() -> void:
	sprite_half_size = Vector2i(128, 46)
	capacity = 3
	wagon_type = "MerchandiseWagon"


func open_doors():
	animated_sprite.play("open")

func close_doors():
	animated_sprite.play("close")

func on_click():
	print("Merchandise wagon clicked")
	pass
