extends Node2D
class_name GenericBar

@export var width := 32.0
@export var height := 4.0
#@export var offset := Vector2(0, 0)

@onready var background := $Background
@onready var fill := $Fill
@onready var value := $Value

func _ready() -> void:
	background.size = Vector2(width, height)
	fill.size = Vector2(width, height)
	#position = offset

func update_value(current_: int, max_: float):
	var ratio = float(current_) / float(max_)
	fill.size.x = width * ratio
	fill.visible = ratio > 0
	value.text = str(current_) + " / " + str(max_)
