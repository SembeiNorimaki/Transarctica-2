extends Node2D
class_name FOVOverlay

# Dependencies
var grid_service: GridService

var _tiles_to_draw_red = []
var _tiles_to_draw_green = []

func redraw() -> void:
	_draw()

func _draw():
	if grid_service == null:
		return
	for tile in _tiles_to_draw_red:
		highlight_tile(tile, Color(1, 0, 0, 0.3))
	for tile in _tiles_to_draw_green:
		highlight_tile(tile, Color(0, 1, 0, 0.3))
	queue_redraw()
		
func highlight_tile(tile, color_):
	var world_pos = grid_service.tile_to_world(tile)
	var local_pos = world_pos
	var half_tile_size = grid_service.tile_half_size
	
	var points = PackedVector2Array([
			local_pos + Vector2(0, -half_tile_size.y+2), # Top
			local_pos + Vector2(half_tile_size.x-2, 0), # Right
			local_pos + Vector2(0, half_tile_size.y-2), # Bottom
			local_pos + Vector2(-half_tile_size.x+2, 0) # Left
	])
	#print("HTS", points)
	draw_colored_polygon(points, color_)
