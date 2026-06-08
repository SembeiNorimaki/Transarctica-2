extends Node2D
class_name ReachableTilesOverlay

var navigation_graph_service: NavigationGraphService
var grid_service: GridService

var tiles: Array[Vector2i] = []

func show_reachable_tiles(unit):
	tiles = navigation_graph_service.get_reachable_tiles(unit, 4.0)
	queue_redraw()

func clear():
	tiles.clear()
	queue_redraw()

func _draw():
	for tile in tiles:
		_highlight_tile(tile, Color(0, 1, 0, 0.3))

func _highlight_tile(tile, color_):
	var world_pos = grid_service.tile_to_world(tile)
	var local_pos = world_pos
	var half_tile_size = grid_service.tile_half_size
	
	var points = PackedVector2Array([
			local_pos + Vector2(0, -half_tile_size.y + 2), # Top
			local_pos + Vector2(half_tile_size.x - 2, 0), # Right
			local_pos + Vector2(0, half_tile_size.y - 2), # Bottom
			local_pos + Vector2(-half_tile_size.x + 2, 0) # Left
	])
	draw_colored_polygon(points, color_)
