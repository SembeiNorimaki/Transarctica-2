extends HBoxContainer
class_name TenderPanel

@onready var fuel_label: Label = $FuelLabel
@onready var fuel_bar: ProgressBar = $FuelBar

func setup(wagon_data: Dictionary, _wagon_id: int, _wagon_manager: WagonManager) -> void:
    var cargo_name: String = wagon_data.get("cargo_name", "coal")
    var cargo_qty: int = int(wagon_data.get("cargo_qty", 0))
    var capacity: int = int(wagon_data.get("capacity", 0))

    fuel_label.text = "%s:  %d / %d" % [cargo_name.capitalize(), cargo_qty, capacity]
    fuel_bar.max_value = capacity if capacity > 0 else 1
    fuel_bar.value = cargo_qty
