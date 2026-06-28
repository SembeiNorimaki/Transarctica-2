extends VehicleUnit
class_name TenderWagon

var wagon_type: String

func _ready() -> void:
    sprite_half_size = Vector2i(64, 23)
    capacity = WagonTypes.TYPES["TenderWagon"].capacity
    wagon_type = "TenderWagon"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func on_click():
    # print("Tender wagon clicked")
    pass
