extends Node

var parent_scene: Node = null
var unit : Unit = null

var delta_to_orientation = {
	Vector2i(1, 0): "SE",
	Vector2i(-1, 0): "NW",
	Vector2i(0, 1): "SW",
	Vector2i(0, -1): "NE",

	Vector2i(1, 1): "S",
	Vector2i(-1, 1): "W",
	Vector2i(1, -1): "E",
	Vector2i(-1, -1): "N",
}

var orientation_to_heading = {
	"N": Vector2(0, -1),
	"S": Vector2(0, 1),
	"E": Vector2(1, 0),
	"W": Vector2(-1, 0),

	"NE": Vector2(1, -1).normalized(),
	"NW": Vector2(-1, -1).normalized(),
	"SW": Vector2(-1, 1).normalized(),
	"SE": Vector2(1, 1).normalized()
}

var heading = Vector2.ZERO
var target_position = Vector2i.ZERO
var target_tile = Vector2i.ZERO

# params should contain injected scenes and parameters needed by the node
func enter(prev, params={}):    
	unit = params["unit"] 
	var current_tile : Vector2i = unit.current_tile
	target_tile = unit.target_tile
	var grid_service : GridService = unit.grid_service

	target_position = grid_service.tile_to_world(target_tile)

	var delta = target_tile - current_tile
	var ori = delta_to_orientation[delta]

	heading = orientation_to_heading[ori]
	unit.play_animation(ori)

	print("SM: Unit moving. CP: %s, TP: %s, ori: %s" % [unit.position, target_position, ori])

	# calculate orientation


func exit(next, params={}):
	pass

func update(delta: float):
	var new_pos = unit.position.move_toward(target_position, unit.move_speed * delta)
	if new_pos == unit.position:
		print("Arrived")
		unit.on_arrived_to_tile(target_tile)
		
	else:
		unit.position = new_pos
	
	

func handle_click(tile: Vector2i, button_index: int):
	pass
