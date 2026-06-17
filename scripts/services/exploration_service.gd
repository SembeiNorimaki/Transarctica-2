extends Node
class_name ExplorationService

var grid_service: GridService
var exploration_layer: ExplorationLayer
var los_service: LOSService
var unit_manager: UnitManager
var fov_overlay: FOVOverlay

var merged_player_visibility = []

func _ready() -> void:
	pass

func initialize():
	_compute_merged_player_visibility()
	_reveal_tiles(merged_player_visibility)

func _reveal_tiles(tiles: Array):
	exploration_layer.reveal(tiles)

func get_merged_visible_tiles():
	return merged_player_visibility

# recalculates the viewed tiles for all player units
func _recalculate():
	pass
	# var unit_list = unit_manager.get_units_by_team("Player")
	# var visible_tiles: Array[Vector2i] = []
	# for unit in unit_list:
	# 	var cone_tiles: Array[Vector2i] = grid_service.get_tiles_in_vision_cone(unit.current_tile, unit.orientation, unit.view_angle, unit.view_range)
	# 	var a = los_service.filter_visible_tiles(unit.current_tile, cone_tiles)
	# 	visible_tiles.append_array(a)
	# print("LOS: Recalculating visibility, found %s tiles" % visible_tiles.size())
	#exploration_layer.reveal(visible_tiles)
	#_update_units_visibility(unit)		
	

func on_unit_tile_changed(unit: Unit, new_tile: Vector2i) -> void:
	#var visible_tiles = unit_manager.get_visible_tiles_for(unit)
	_compute_merged_player_visibility()
	_reveal_tiles(merged_player_visibility)
	
	#fov_overlay._tiles_to_draw_red = cone_tiles
	#fov_overlay._tiles_to_draw_green = visible_tiles
	#fov_overlay.redraw()
	

func on_unit_orientation_changed(unit: Unit, new_orientation: String) -> void:
	#var visible_tiles = unit_manager.get_visible_tiles_for(unit)
	_compute_merged_player_visibility()
	_reveal_tiles(merged_player_visibility)
	#_update_units_visibility(unit)

	#fov_overlay._tiles_to_draw_red = cone_tiles
	#fov_overlay._tiles_to_draw_green = visible_tiles
	#fov_overlay.redraw()
	
# UnitManager stores the tiles visible for each unit
# We need to merge the tiles seen by all player units
func _compute_merged_player_visibility():
	merged_player_visibility = []
	for unit in unit_manager.get_units_by_team("Player"):
		var tiles = unit_manager.get_visible_tiles_for(unit)
		print("Unit %s vision: %s tiles" % [unit.id, tiles.size()])
		merged_player_visibility.append_array(tiles)

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
