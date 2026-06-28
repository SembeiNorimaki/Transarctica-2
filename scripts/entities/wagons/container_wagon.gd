extends VehicleUnit
class_name ContainerWagon

var wagon_type: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    wagon_type = "ContainerWagon"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func on_click():
	# print("Container wagon clicked")
	pass
