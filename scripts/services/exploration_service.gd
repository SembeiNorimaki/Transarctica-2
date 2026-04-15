extends Node
class_name ExplorationService

var grid_service: GridService
var exploration_layer: TileMapLayer
var los_service: LOSService
var unit_manager: UnitManager

func _ready() -> void: pass

func reveal_from_unit():
	pass


func reveal_tiles(tiles: Array[Vector2i]):
	exploration_layer.reveal(tiles)

# recalculates the viewed tiles for all player units
func recalculate():
	var unit_list = unit_manager.get_units_by_team("Player")
	var visible_tiles : Array[Vector2i] = []
	for unit in unit_list:
		var cone_tiles: Array[Vector2i] = grid_service.get_tiles_in_vision_cone(unit.current_tile, unit.orientation, unit.view_angle, unit.view_range)
		var a  = get_visible_tiles(unit.current_tile, cone_tiles)
		visible_tiles.append_array(a)
	exploration_layer.reveal(visible_tiles)
	#_update_units_visibility(unit)		
	


func on_unit_tile_changed(unit: Unit, new_tile: Vector2i) -> void:
	recalculate()

func on_unit_orientation_changed(unit: Unit, new_orientation: String) -> void:
	recalculate()
	
	return
	#print("Unit %s orientation changed to %s" % [unit.id, new_orientation])
	var cone_tiles: Array[Vector2i] = grid_service.get_tiles_in_vision_cone(unit.current_tile, new_orientation, unit.view_angle, unit.view_range)
	var visible_tiles = get_visible_tiles(unit.current_tile, cone_tiles)
	exploration_layer.reveal(visible_tiles)
	_update_units_visibility(unit)

func _update_units_visibility(selected_unit: Unit) -> void:
	var all_units = unit_manager.get_units_by_team("Player")
	#print("Updating visibility for %s units" % all_units.size())
	for unit in all_units:
		if unit == selected_unit: # Don't update the selected unit
			continue
		var tile = unit.current_tile
		var is_visible = exploration_layer.is_tile_visible(tile)
		#print("Unit %s is visible: %s" % [unit.id, is_visible])
		unit.visible = is_visible

# Given all tiles in a cone and an origin, compute those ones that are visible, so they have LOS
func get_visible_tiles(origin: Vector2i, cone_tiles: Array[Vector2i]) -> Array[Vector2i]:
	var visible_tiles: Array[Vector2i] = []
	for tile in cone_tiles:
		if los_service.has_los(origin, tile):
			visible_tiles.append(tile)
	return visible_tiles
