extends Control

signal findengine_pressed
signal save_pressed
signal minimap_pressed

func update_gold(new_value):
	$CanvasLayer/HBoxContainer/Container5/Gold/Label.text = str(new_value)

func update_fuel(new_value):
	$CanvasLayer/HBoxContainer/Container6/Fuel/Label.text = str(new_value)

func update_speed(new_value):
	$CanvasLayer/HBoxContainer/Container7/Frame/Label.text = str(new_value)

func update_time(new_value):
	$TimeLabel.text = str(new_value)

func _on_button_findengine_pressed() -> void:
	emit_signal("findengine_pressed")

func _on_button_save_pressed() -> void:
	emit_signal("save_pressed")

func _on_button_minimap_pressed() -> void:
	emit_signal("minimap_pressed")
