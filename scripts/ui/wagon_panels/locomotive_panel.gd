extends HBoxContainer
class_name LocomotivePanel

@onready var hp_label: Label = $HpLabel
@onready var hp_bar: ProgressBar = $HpBar
@onready var status_label: Label = $StatusLabel

func setup(wagon_data: Dictionary, _wagon_id: int, _wagon_manager: WagonManager) -> void:
	var hp: int = int(wagon_data.get("hp", 0))
	var max_hp: int = int(wagon_data.get("max_hp", 0))

	hp_label.text = "Hull:  %d / %d" % [hp, max_hp]
	hp_bar.max_value = max_hp if max_hp > 0 else 1
	hp_bar.value = hp
	status_label.text = "Status: %s" % ("Operational" if hp > 0 else "Destroyed")
