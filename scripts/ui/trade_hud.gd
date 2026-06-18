extends Control

@onready var gold_label = $CanvasLayer/HBoxContainer/Container5/Gold/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_gold(new_value):
	gold_label.text = str(new_value)
