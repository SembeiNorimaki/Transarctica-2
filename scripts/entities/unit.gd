extends Node2D
class_name Unit

@onready var sprite = $Sprite
@onready var sprite_selected = $SpriteSelected

#Labels
@onready var id_label = $Labels/IDLabel

var grid_service: GridService
var unit_manager: UnitManager

var current_tile = Vector2i(-1, -1)

var id: String = ""
var move_speed := 4.0 # tiles per second or world units per second
var target_tile: Vector2i

signal movement_finished

func _ready() -> void:
	set_process(false)

func set_id(id_: String) -> void:
	if id == "":
		id = id_
		id_label.text = "ID: %s" % id
	else:
		push_error("Unit already has an id")

func _process(delta: float) -> void:
	var target_pos = grid_service.tile_to_world(target_tile)
	global_position = global_position.move_toward(target_pos, move_speed * delta)
	if global_position.distance_to(target_pos) < 0.1:
		global_position = target_pos
		set_process(false)
		unit_manager.on_unit_reached_tile(self)


func set_selected(selected: bool) -> void:
	print("Selected: %s" % selected)
	sprite_selected.visible = selected


func _move_to_tile(tile: Vector2i):
	target_tile = tile
	set_process(true)
