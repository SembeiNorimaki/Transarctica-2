extends Node2D
class_name HealthBar

@export var width := 32.0
@export var height := 4.0
@export var offset := Vector2(0, 0)

@onready var background := $Background
@onready var fill := $Fill
@onready var value := $Value

func _ready() -> void:
    background.size = Vector2(width, height)
    fill.size = Vector2(width, height)
    position = offset

func update_health(current_: int, max_: float):
    #print("HealthBar update_health %s %s" % [current_, max_])
    var ratio = float(current_) / float(max_)
    #fill.size.x = lerp(fill.size.x, width * ratio, 0.2) # smooth animation
    fill.size.x = width * ratio
    fill.visible = ratio > 0
    value.text = str(current_) + " / " + str(max_)
