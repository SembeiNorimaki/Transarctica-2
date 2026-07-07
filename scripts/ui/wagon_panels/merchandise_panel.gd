extends HBoxContainer
class_name MerchandisePanel

@onready var cargo_label: Label = $CargoLabel

func setup(wagon_data: Dictionary, _wagon_id: int, _wagon_manager: WagonManager) -> void:
    var cargo_name: String = wagon_data.get("cargo_name", "")
    var cargo_qty: int = int(wagon_data.get("cargo_qty", 0))
    var capacity: int = int(wagon_data.get("capacity", 0))

    if cargo_name.is_empty():
        cargo_label.text = "Empty  (0 / %d)" % capacity
    else:
        cargo_label.text = "%s:  %d / %d" % [cargo_name.capitalize(), cargo_qty, capacity]
