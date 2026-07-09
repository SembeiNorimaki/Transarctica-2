extends Control

signal reverse_pressed

func _on_reverse_button_pressed() -> void:
    emit_signal("reverse_pressed")
