extends Node
class_name ExplorationService

var grid_service: GridService
var exploration_layer: TileMapLayer
var los_service : LOSService

func _ready() -> void: pass

func reveal_from_unit():
	pass

func _on_unit_orientation_changed(unit: Unit, new_orientation: String) -> void:
	print("CCC", unit, new_orientation)
	var cone_tiles : Array[Vector2i] = grid_service.get_tiles_in_vision_cone(unit.current_tile, new_orientation, unit.view_angle, unit.view_range)
	var visible_tiles = get_visible_tiles(unit.current_tile, cone_tiles)
	exploration_layer.reveal(visible_tiles)
	print("Tiles in vision cone:", visible_tiles)

# Given all tiles in a cone and an origin, compute those ones that are visible, so they have LOS
func get_visible_tiles(origin: Vector2i, cone_tiles: Array[Vector2i]) -> Array[Vector2i]:
	var visible_tiles : Array[Vector2i] = []
	for tile in cone_tiles:
		if los_service.has_los(origin, tile):
			visible_tiles.append(tile)
	return visible_tiles
	
